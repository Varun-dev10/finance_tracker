##the "analytical query" part of DuckDB's job same kind of aggregation as our dashboard endpoints,
# but running on the DuckDB copy instead of Postgres directly
# (demonstrates why DuckDB exists: fast analytical SQL on a separate copy of data,
# not hitting the production DB for heavy reporting)



import duckdb, os

DUCKDB_PATH = os.path.join(os.path.dirname(__file__), "finance_analytics.duckdb")
con = duckdb.connect(DUCKDB_PATH)

result = con.execute("""
    SELECT type, SUM(amount) as total
    FROM transactions
    GROUP BY type
""").fetchall()

print(result)
con.close()