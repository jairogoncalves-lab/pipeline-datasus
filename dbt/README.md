# dbt Project — pipeline_datasus

Transforms the SIH-SUS bronze data (Parquet on S3) into Silver and Gold layers using dbt Core.

Currently runs on **DuckDB** for fast, local, cost-free iteration (reads the bronze Parquet files directly from S3 via DuckDB's `httpfs`/`aws` extensions, using your local AWS CLI credentials). Migrating to `dbt-databricks` is a planned follow-up once a Databricks workspace is set up — the SQL models are written in standard, portable syntax to ease that move.

## Layers

- **staging** (`stg_sih_rd`): raw read of the bronze Parquet files, one row per admission, columns renamed to snake_case.
- **silver** (`silver_hospitalizations`): deduplicated, typed, and cleaned admission records.
- **gold**: dimensional model — `fact_hospitalizations`, `dim_date`, `dim_municipality`.

## Running locally

```bash
cd dbt
python -m venv ../.venv-dbt   # separate venv: dbt's deps conflict with pysus's pinned versions
../.venv-dbt/Scripts/pip install -r requirements.txt
../.venv-dbt/Scripts/dbt deps
export DBT_PROFILES_DIR=.     # profiles.yml lives in this folder
../.venv-dbt/Scripts/dbt build
```

Requires AWS credentials configured locally (`aws configure`) with read access to the bronze bucket.
