from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
from models import Category

router = APIRouter()

# categories endpoint
# It lets Flutter fetch the category list to show in a dropdown
# no auth needed since categories aren't user-specific

@router.get("/categories")
def list_categories(db: Session = Depends(get_db)):
    return db.query(Category).all()