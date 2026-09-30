##the "analytical query" part of DuckDB's job same kind of aggregation as our dashboard endpoints,
# but running on the DuckDB copy instead of Postgres directly
# (demonstrates why DuckDB exists: fast analytical SQL on a separate copy of data,
# not hitting the production DB for heavy reporting)



import duckdb, os

DUCKDB_PATH = os.path.join(os.path.dirname(__file__), "finance_analytics.duckdb")
con = duckdb.connect(DUCKDB_PATH)

# List all tables in DuckDB and print content
tables = [row[0] for row in con.execute("SHOW TABLES").fetchall()]

print("==========================================")
print("             DUCKDB TABLES                ")
print("==========================================")

for t in tables:
    print(f"\n--- TABLE: {t} ---")
    con.sql(f"SELECT * FROM {t}").show()

print("\n==========================================")
print("    JOINED TRANSACTIONS (WITH NAMES)      ")
print("==========================================")
con.sql("""
    SELECT 
        t.transaction_date AS date,
        u.email AS user,
        c.name AS category,
        t.type,
        t.amount,
        t.description
    FROM transactions t
    LEFT JOIN users u ON t.user_id = u.id
    LEFT JOIN categories c ON t.category_id = c.id
    ORDER BY t.transaction_date DESC
""").show()

con.close()