#** Phase 8: DuckDB Analytics **
# script to extract transactions from PostgreSQL into DuckDB
# DuckDB is just a Python library, no separate service/container needed — it reads/writes a single .db file on disk
# reads all transactions from Postgres → dumps them into a local DuckDB file,
# CREATE OR REPLACE means it fully refreshes each run (simple, no incremental sync complexity


import sys, os
sys.path.append(os.path.join(os.path.dirname(__file__), "..", "backend"))

import duckdb
from database import SessionLocal
from models import Transaction

DUCKDB_PATH = os.path.join(os.path.dirname(__file__), "finance_analytics.duckdb")

def extract():
    db = SessionLocal()
    transactions = db.query(Transaction).all()

    rows = [
        (str(t.id), str(t.user_id), str(t.category_id), float(t.amount), t.type, str(t.transaction_date))
        for t in transactions
    ]
    db.close()

    con = duckdb.connect(DUCKDB_PATH)
    con.execute("""
        CREATE OR REPLACE TABLE transactions (
            id VARCHAR, user_id VARCHAR, category_id VARCHAR,
            amount DOUBLE, type VARCHAR, transaction_date DATE
        )
    """)
    con.executemany("INSERT INTO transactions VALUES (?, ?, ?, ?, ?, ?)", rows)
    con.close()
    print(f"Extracted {len(rows)} transactions into DuckDB.")

if __name__ == "__main__":
    extract()