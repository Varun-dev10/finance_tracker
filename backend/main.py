from fastapi import FastAPI
from sqlalchemy import text
from database import engine

from routers.auth_router import router as auth_router
from routers.transactions_router import router as transactions_router
from routers.categories_router import router as categories_router
from routers.dashboard_router import router as dashboard_router
from routers.budget_router import router as budget_router

app = FastAPI(title="Finance Tracker API")

app.include_router(auth_router)
app.include_router(transactions_router)
app.include_router(categories_router)
app.include_router(dashboard_router)
app.include_router(budget_router)

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


