
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func as sqlfunc
from database import get_db
from models import User, Transaction, Category
from auth import get_current_user

router = APIRouter()




# Dashboard summary endpoint
# Sums all Income, Sums all Expenses, Balance = Difference, Finds Category with Highest Total Spend


@router.get("/dashboard/summary")
def dashboard_summary(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    income = db.query(sqlfunc.coalesce(sqlfunc.sum(Transaction.amount), 0)).filter(
        Transaction.user_id == current_user.id, Transaction.type == "income"
    ).scalar()

    expenses = db.query(sqlfunc.coalesce(sqlfunc.sum(Transaction.amount), 0)).filter(
        Transaction.user_id == current_user.id, Transaction.type == "expense"
    ).scalar()

    top_category_row = (
        db.query(Category.name, sqlfunc.sum(Transaction.amount).label("total"))
        .join(Category, Transaction.category_id == Category.id)
        .filter(Transaction.user_id == current_user.id, Transaction.type == "expense")
        .group_by(Category.name)
        .order_by(sqlfunc.sum(Transaction.amount).desc())
        .first()
    )

    return {
        "balance": income - expenses,
        "income": income,
        "expenses": expenses,
        "savings": income - expenses,
        "top_category": top_category_row[0] if top_category_row else None,
    }

# Category breakdown + monthly endpoints
# categories = spend grouped by category,
# monthly = income/expense totals grouped by month
# > both feed dashboard charts.

@router.get("/dashboard/categories")
def dashboard_categories(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    results = (
        db.query(Category.name, sqlfunc.sum(Transaction.amount).label("total"))
        .join(Category, Transaction.category_id == Category.id)
        .filter(Transaction.user_id == current_user.id, Transaction.type == "expense")
        .group_by(Category.name)
        .order_by(sqlfunc.sum(Transaction.amount).desc())
        .all()
    )
    return [{"category": r[0], "total": r[1]} for r in results]


@router.get("/dashboard/monthly")
def dashboard_monthly(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    results = (
        db.query(
            sqlfunc.date_trunc("month", Transaction.transaction_date).label("month"),
            Transaction.type,
            sqlfunc.sum(Transaction.amount).label("total"),
        )
        .filter(Transaction.user_id == current_user.id)
        .group_by("month", Transaction.type)
        .order_by("month")
        .all()
    )
    return [{"month": str(r[0].date()), "type": r[1], "total": r[2]} for r in results]