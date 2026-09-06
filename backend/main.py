import uuid
from fastapi import FastAPI
from sqlalchemy import text
from database import engine
from fastapi import Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import User
from schemas import UserRegister, UserResponse
from auth import hash_password
from schemas import UserLogin, Token
from auth import verify_password, create_access_token
from auth import get_current_user
from models import Transaction, Category
from schemas import TransactionCreate, TransactionResponse
from sqlalchemy import func as sqlfunc


app = FastAPI(title="Finance Tracker API")

@app.get("/")
def read_root():
    return {"message": "Finance Tracker Backend is Running!"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}

@app.get("/health/db")
def health_check_db():
    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        return {"status": "healthy", "database": "connected"}
    except Exception as e:
        return {"status": "unhealthy", "database": str(e)}


@app.post("/auth/register", response_model=UserResponse)
def register(user_data: UserRegister, db: Session = Depends(get_db)):
    existing_user = db.query(User).filter(User.email == user_data.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")

    new_user = User(
        email=user_data.email,
        password_hash=hash_password(user_data.password),
        display_name=user_data.display_name,
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return new_user

@app.post("/auth/login", response_model=Token)
def login(credentials: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == credentials.email).first()
    if not user or not verify_password(credentials.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    token = create_access_token({"sub": str(user.id)})
    return {"access_token": token, "token_type": "bearer"}

# this route only works if a valid token is sent in the Authorization header proves protected routes work

@app.get("/auth/me", response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user

# Transaction endpoints
# every query filters by current_user.id
# the ownership check, users cannot see/edit/delete each other's data even by guessing IDs


@app.post("/transactions", response_model=TransactionResponse)
def create_transaction(tx: TransactionCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    category = db.query(Category).filter(Category.id == tx.category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")

    new_tx = Transaction(
        user_id=current_user.id,
        category_id=tx.category_id,
        amount=tx.amount,
        type=tx.type,
        description=tx.description,
        transaction_date=tx.transaction_date,
    )
    db.add(new_tx)
    db.commit()
    db.refresh(new_tx)
    return new_tx


@app.get("/transactions", response_model=list[TransactionResponse])
def list_transactions(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return db.query(Transaction).filter(Transaction.user_id == current_user.id).order_by(Transaction.transaction_date.desc()).all()


@app.get("/transactions/{tx_id}", response_model=TransactionResponse)
def get_transaction(tx_id: uuid.UUID, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    tx = db.query(Transaction).filter(Transaction.id == tx_id, Transaction.user_id == current_user.id).first()
    if not tx:
        raise HTTPException(status_code=404, detail="Transaction not found")
    return tx


@app.put("/transactions/{tx_id}", response_model=TransactionResponse)
def update_transaction(tx_id: uuid.UUID, tx_data: TransactionCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    tx = db.query(Transaction).filter(Transaction.id == tx_id, Transaction.user_id == current_user.id).first()
    if not tx:
        raise HTTPException(status_code=404, detail="Transaction not found")

    tx.category_id = tx_data.category_id
    tx.amount = tx_data.amount
    tx.type = tx_data.type
    tx.description = tx_data.description
    tx.transaction_date = tx_data.transaction_date
    db.commit()
    db.refresh(tx)
    return tx


@app.delete("/transactions/{tx_id}")
def delete_transaction(tx_id: uuid.UUID, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    tx = db.query(Transaction).filter(Transaction.id == tx_id, Transaction.user_id == current_user.id).first()
    if not tx:
        raise HTTPException(status_code=404, detail="Transaction not found")
    db.delete(tx)
    db.commit()
    return {"detail": "Transaction deleted"}

# categories endpoint
# It lets Flutter fetch the category list to show in a dropdown
# no auth needed since categories aren't user-specific

@app.get("/categories")
def list_categories(db: Session = Depends(get_db)):
    return db.query(Category).all()


# Dashboard summary endpoint
# Sums all Income, Sums all Expenses, Balance = Difference, Finds Category with Highest Total Spend


@app.get("/dashboard/summary")
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

@app.get("/dashboard/categories")
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


@app.get("/dashboard/monthly")
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
