# Project Context: End-to-End Data Engineering Pipeline (DataSUS)

## General Objective

Build a robust, modern, and automated data engineering pipeline to extract, clean, transform, test, and serve Brazil's public health data (DataSUS / SIH-SUS — Hospital Information System), using cloud architecture, governance, and software engineering best practices.

## Tech Stack

- **Storage / Data Lake**: AWS S3 (partitioned bucket) and AWS IAM (access management).
- **Ingestion & Initial Validation**: Python (PySUS, boto3, pandas).
- **Processing**: Databricks Community or AWS Databricks (Spark engine).
- **Transformation & Modeling**: dbt Core (dbt-databricks, dbt-expectations).
- **Orchestration**: Apache Airflow running via Docker (Astro CLI) + Astronomer Cosmos (Airflow-dbt integration).
- **Versioning & DataOps**: Git, GitHub, GitHub Actions (CI/CD with sqlfluff and flake8).
- **Infrastructure as Code (IaC)**: Terraform (optional/differential, for provisioning S3 and IAM).

## Data Architecture (Medallion Architecture)

- **Bronze** (`s3://.../bronze/`): Raw data extracted from DataSUS via Python script, converted to high-performance Parquet format.
- **Silver** (`s3://.../silver/`): Clean, deduplicated data with standardized schemas and converted columns (done via dbt on Databricks).
- **Gold** (`s3://.../gold/`): Dimensional modeling (fact and dimension tables, such as `fact_hospitalizations`, `dim_municipality`, `dim_date`) and aggregations ready for business analysis.

## Data Quality (Multi-layer)

- **Ingestion Validation (Bronze)**: Python function run by Airflow checking minimum volume (avoids empty tables) and presence of required source columns.
- **Transformation Validation (Silver/Gold)**: Declarative dbt tests (`unique`, `not_null`) and domain rules via `dbt-expectations` (e.g., ensuring hospitalization costs are ≥ 0 and state codes are valid). A failure in any test halts the pipeline.

### Known Data Gaps

DataSUS's own FTP source has genuine publication gaps: not every state has all 12 months of a given year available at all times. For example, for competência year 2024, SP is missing months 02, 06, 08, and 12, while RJ is only missing month 07 — the gap is state-specific and not caused by the pipeline. The ingestion script's minimum-row-count validation correctly detects and halts on these empty competências instead of loading bad/empty data into the bronze layer.

**Competência vs. clinical dates.** A hospitalization's `competência` (the year/month of the source file it was published under) is not the same thing as its `admission_date`/`discharge_date`. A long admission can start in one month but only be reported under a later competência's file — so a missing competência file does not necessarily mean zero admissions with clinical dates in that month; some may already appear, filed under a later month. For SP/2024, grouping by clinical `admission_date` shows only December fully at zero, while February, June, and August still show partial data leaking in from later files. The only reliable way to see the true source-file gap is to group by `competency_year`/`competency_month` (carried through to `fact_hospitalizations` for exactly this reason) — that query cleanly shows the 8 present months with no trace of the 4 missing ones.

## Governance, CI/CD, and Visualization

- **Lineage and Data Dictionary**: Automatic generation of interactive documentation and the visual lineage graph (`dbt docs generate`), publishable on GitHub Pages.
- **CI/CD on GitHub**: GitHub Actions workflow validating SQL formatting (`sqlfluff`) and Python syntax on every Pull Request to the main branch.

## Sequential Execution Roadmap

1. **AWS & Git Setup**: Create the Git repository, an S3 bucket with `bronze/`, `silver/`, `gold/` folders, and an IAM user.
2. **Python Ingestion**: Develop the extraction script using PySUS and upload to S3 with boto3.
3. **Airflow Orchestration**: Set up the Airflow project with Astro CLI and create the DAG controlling extraction and initial validation.
4. **Databricks & dbt Setup**: Configure the Databricks cluster, mount the S3 paths, and initialize the local dbt project connected to Databricks.
5. **dbt Modeling**: Write the SQL models for the Silver and Gold layers, adding the test layer in `.yml` files.
6. **Airflow + dbt Integration**: Use `astronomer-cosmos` in the DAG to run dbt directly from Airflow.
7. **CI/CD and Docs**: Add GitHub Actions and generate the static dbt documentation.
