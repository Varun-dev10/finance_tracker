
import uuid
import datetime
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
from models import User, Budget
from schemas import BudgetCreate, BudgetResponse
from auth import get_current_user

router = APIRouter()


@router.get("/budget", response_model=BudgetResponse)
def get_budget(month: datetime.date, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    # We normalize the date to the 1st of the month.
    # This means a budget for 2024-03-15 is saved as the budget for all of March.
    first_of_month = month.replace(day=1)
    budget = db.query(Budget).filter(Budget.month == first_of_month, Budget.user_id == current_user.id).first()

    if not budget:
        # If no budget is set, we return a temporary one with 0 amount
        return {"id": uuid.uuid4(), "amount": 0, "month": first_of_month}
    return budget

@router.put("/budget", response_model=BudgetResponse)
def update_budget(budget_data: BudgetCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    first_of_month = budget_data.month.replace(day=1)
    budget = db.query(Budget).filter(Budget.month == first_of_month, Budget.user_id == current_user.id).first()

    if budget:
        # If it exists, update the amount
        budget.amount = budget_data.amount
    else:
        # If it doesn't exist, create a new one
        budget = Budget(
            user_id=current_user.id,
            month=first_of_month,
            amount=budget_data.amount
        )
        db.add(budget)

    db.commit()
    db.refresh(budget)
    return budget
