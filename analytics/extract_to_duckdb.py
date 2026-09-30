#** Phase 8: DuckDB Analytics **
# script to extract transactions from PostgreSQL into DuckDB
# DuckDB is just a Python library, no separate service/container needed - it reads/writes a single .db file on disk
# reads all transactions from Postgres → dumps them into a local DuckDB file,
# CREATE OR REPLACE means it fully refreshes each run (simple, no incremental sync complexity


import sys, os
sys.path.append(os.path.join(os.path.dirname(__file__), "..", "backend"))

import duckdb
from database import SessionLocal
from models import User, Category, Transaction, Budget

DUCKDB_PATH = os.path.join(os.path.dirname(__file__), "finance_analytics.duckdb")

def extract():
    db = SessionLocal()

    users = db.query(User).all()
    categories = db.query(Category).all()
    transactions = db.query(Transaction).all()
    budgets = db.query(Budget).all()

    user_rows = [(str(u.id), u.email, u.display_name or "", str(u.created_at)) for u in users]
    category_rows = [(str(c.id), c.name, c.type, c.icon or "") for c in categories]
    tx_rows = [
        (str(t.id), str(t.user_id), str(t.category_id), float(t.amount), t.type, t.description or "", str(t.transaction_date))
        for t in transactions
    ]
    budget_rows = [(str(b.id), str(b.user_id), str(b.month), float(b.amount)) for b in budgets]

    db.close()

    con = duckdb.connect(DUCKDB_PATH)

    # 1. Users table
    con.execute("CREATE OR REPLACE TABLE users (id VARCHAR, email VARCHAR, display_name VARCHAR, created_at VARCHAR)")
    if user_rows:
        con.executemany("INSERT INTO users VALUES (?, ?, ?, ?)", user_rows)

    # 2. Categories table
    con.execute("CREATE OR REPLACE TABLE categories (id VARCHAR, name VARCHAR, type VARCHAR, icon VARCHAR)")
    if category_rows:
        con.executemany("INSERT INTO categories VALUES (?, ?, ?, ?)", category_rows)

    # 3. Transactions table
    con.execute("""
        CREATE OR REPLACE TABLE transactions (
            id VARCHAR, user_id VARCHAR, category_id VARCHAR,
            amount DOUBLE, type VARCHAR, description VARCHAR, transaction_date DATE
        )
    """)
    if tx_rows:
        con.executemany("INSERT INTO transactions VALUES (?, ?, ?, ?, ?, ?, ?)", tx_rows)

    # 4. Budgets table
    con.execute("CREATE OR REPLACE TABLE budgets (id VARCHAR, user_id VARCHAR, month DATE, amount DOUBLE)")
    if budget_rows:
        con.executemany("INSERT INTO budgets VALUES (?, ?, ?, ?)", budget_rows)

    con.close()
    print(f"Extracted {len(user_rows)} users, {len(category_rows)} categories, {len(tx_rows)} transactions, {len(budget_rows)} budgets into DuckDB.")

if __name__ == "__main__":
    extract()