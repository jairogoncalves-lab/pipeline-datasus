"""Extract SIH-SUS (hospital admissions) data from DataSUS and load it into the S3 bronze layer."""

import argparse
import tempfile
from pathlib import Path

import boto3
import pandas as pd
import pysus

REQUIRED_COLUMNS = [
    "UF_ZI",
    "ANO_CMPT",
    "MES_CMPT",
    "MUNIC_RES",
    "N_AIH",
    "VAL_TOT",
    "DT_INTER",
    "DT_SAIDA",
]
MIN_ROWS = 1


def extract(uf: str, year: int, month: int, group: str) -> pd.DataFrame:
    return pysus.sih(uf, year, month, group=group, as_dataframe=True)


def validate(df: pd.DataFrame) -> None:
    if len(df) < MIN_ROWS:
        raise ValueError(f"Expected at least {MIN_ROWS} row(s), got {len(df)}")

    missing = [c for c in REQUIRED_COLUMNS if c not in df.columns]
    if missing:
        raise ValueError(f"Missing required columns: {missing}")


def upload_to_s3(df: pd.DataFrame, bucket: str, uf: str, year: int, month: int, group: str) -> str:
    key = f"bronze/sih/group={group}/uf={uf}/year={year}/month={month:02d}/data.parquet"

    with tempfile.NamedTemporaryFile(suffix=".parquet", delete=False) as tmp:
        tmp_path = Path(tmp.name)
    df.to_parquet(tmp_path, index=False)

    s3 = boto3.client("s3")
    s3.upload_file(str(tmp_path), bucket, key)
    tmp_path.unlink()

    return f"s3://{bucket}/{key}"


def run(uf: str, year: int, month: int, group: str, bucket: str) -> None:
    print(f"Extracting SIH/{group} for {uf} {year}-{month:02d}...")
    df = extract(uf, year, month, group)

    print(f"Validating {len(df)} rows / {len(df.columns)} columns...")
    validate(df)

    print(f"Uploading to bucket '{bucket}'...")
    s3_path = upload_to_s3(df, bucket, uf, year, month, group)

    print(f"Done. {len(df)} rows written to {s3_path}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--uf", required=True, help="Two-letter state code, e.g. SP")
    parser.add_argument("--year", type=int, required=True)
    parser.add_argument("--month", type=int, required=True)
    parser.add_argument("--group", default="RD", help="SIH sub-group (default: RD, reduced AIH)")
    parser.add_argument("--bucket", default="pipeline-datasus-jairo")
    args = parser.parse_args()

    run(args.uf, args.year, args.month, args.group, args.bucket)


if __name__ == "__main__":
    main()
