# Finance Tracker

A full-stack finance tracking application with mobile, backend, analytics, and automated data workflows.

## Project Structure

- **mobile/**: Flutter Android application.
- **backend/**: FastAPI backend service.
- **airflow/**: Apache Airflow configuration and DAGs for data processing.
- **analytics/**: DuckDB-related analytical code and data.
- **database/**: Database initialization, migrations, and seed files.

## Architecture

- **Frontend**: Flutter (Mobile)
- **API**: FastAPI (REST)
- **Primary Database**: PostgreSQL (Source of Truth)
- **Analytics Engine**: DuckDB
- **Orchestration**: Apache Airflow

## Development Setup

1. Ensure Docker Desktop is running.
2. Copy `.env.example` to `.env`.
3. Run `docker-compose up -d` to start infrastructure.