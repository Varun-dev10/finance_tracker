import sys, os
sys.path.append(os.path.join(os.path.dirname(__file__), "..", "backend"))

from database import SessionLocal
from models import Category

expense_categories = ["Food", "Transport", "Shopping", "Entertainment", "Bills", "Healthcare", "Education", "Other"]
income_categories = ["Salary", "Freelance", "Investment", "Other Income"]

db = SessionLocal()

for name in expense_categories:
    db.add(Category(name=name, type="expense"))
for name in income_categories:
    db.add(Category(name=name, type="income"))

db.commit()
print("Categories seeded.")
db.close()