
import uuid
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import User, Transaction, Category
from schemas import TransactionCreate, TransactionResponse
from auth import get_current_user

router = APIRouter()




# Transaction endpoints
# every query filters by current_user.id
# the ownership check, users cannot see/edit/delete each other's data even by guessing IDs


@router.post("/transactions", response_model=TransactionResponse)
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


@router.get("/transactions", response_model=list[TransactionResponse])
def list_transactions(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):

    return db.query(Transaction).filter(Transaction.user_id == current_user.id).order_by(Transaction.transaction_date.desc()).all()


@router.get("/transactions/{tx_id}", response_model=TransactionResponse)
def get_transaction(tx_id: uuid.UUID, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):

    tx = db.query(Transaction).filter(Transaction.id == tx_id, Transaction.user_id == current_user.id).first()
    if not tx:
        raise HTTPException(status_code=404, detail="Transaction not found")
    return tx


@router.put("/transactions/{tx_id}", response_model=TransactionResponse)
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


@router.delete("/transactions/{tx_id}")
def delete_transaction(tx_id: uuid.UUID, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):

    tx = db.query(Transaction).filter(Transaction.id == tx_id, Transaction.user_id == current_user.id).first()
    if not tx:
        raise HTTPException(status_code=404, detail="Transaction not found")
    db.delete(tx)
    db.commit()
    return {"detail": "Transaction deleted"}