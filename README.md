# DataSUS Pipeline — End-to-End Data Engineering

A robust, automated data pipeline to extract, clean, transform, test, and serve Brazil's public health data (**DataSUS / SIH-SUS — Hospital Information System**), built with cloud architecture, governance, and software engineering best practices.

> Full project definitions and roadmap available in [`docs/PROJECT.md`](docs/PROJECT.md).

## Tech Stack

| Layer | Tools |
|---|---|
| Storage / Data Lake | AWS S3 (partitioned), AWS IAM |
| Ingestion | Python (PySUS, boto3, pandas) |
| Processing | Databricks (Spark) |
| Transformation / Modeling | dbt Core (dbt-databricks, dbt-expectations) |
| Orchestration | Apache Airflow (Docker / Astro CLI) + Astronomer Cosmos |
| DataOps / CI-CD | Git, GitHub Actions (sqlfluff, flake8) |
| IaC (optional) | Terraform |

## Architecture (Medallion)

```
Bronze  →  raw data (Parquet)              s3://.../bronze/
Silver  →  cleaned, standardized data      s3://.../silver/
Gold    →  dimensional modeling            s3://.../gold/
           (fact_hospitalizations, dim_municipality, dim_date)
```

## Data Quality

- **Ingestion (Bronze)**: Python validation via Airflow — minimum row count and required columns.
- **Transformation (Silver/Gold)**: declarative dbt tests (`unique`, `not_null`) and domain rules via `dbt-expectations` (e.g., costs ≥ 0, valid state codes). A failed test halts the pipeline.

## Governance

- Data lineage and dictionary generated via `dbt docs generate`, published to GitHub Pages.
- CI on GitHub Actions validating SQL (`sqlfluff`) and Python on every Pull Request.

## Roadmap

- [x] Repository setup
- [x] AWS setup (S3 + IAM)
- [x] Ingestion script (PySUS + boto3)
- [ ] Orchestration DAG (Airflow / Astro CLI)
- [ ] Databricks setup + dbt project
- [ ] dbt models (Silver / Gold) + tests
- [ ] Airflow + dbt integration (Astronomer Cosmos)
- [ ] CI/CD + static dbt documentation

## Status

🚧 Work in progress — portfolio project.

## Author

**Jairo Gonçalves**
[LinkedIn](https://www.linkedin.com/in/jairo-gonçalves-junior/)
