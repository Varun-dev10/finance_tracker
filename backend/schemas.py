import uuid
from pydantic import BaseModel, EmailStr

class UserRegister(BaseModel):
    email: EmailStr
    password: str
    display_name: str | None = None

class UserResponse(BaseModel):
    id: uuid.UUID
    email: str
    display_name: str | None = None

    class Config:
        from_attributes = True

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"



import datetime
from decimal import Decimal
# TransactionCreate = what client sends when adding a transaction

class TransactionCreate(BaseModel):
    category_id: uuid.UUID
    amount: Decimal
    type: str
    description: str | None = None
    transaction_date: datetime.date

# TransactionResponse = what we send back (includes generated id)

class TransactionResponse(BaseModel):  
    id: uuid.UUID
    category_id: uuid.UUID
    amount: Decimal
    type: str
    description: str | None = None
    transaction_date: datetime.date

    class Config:
        from_attributes = True