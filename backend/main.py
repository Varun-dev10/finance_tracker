from fastapi import FastAPI
from sqlalchemy import text
from database import engine

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