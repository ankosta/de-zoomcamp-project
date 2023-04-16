from pathlib import Path
import pandas as pd
from prefect import flow, task
from prefect_gcp.cloud_storage import GcsBucket
from prefect_gcp import GcpCredentials


@task(retries=3)
def extract_from_gcs(coin: str) -> Path:
    """Download crypto data from GCS"""
    gcs_path = f"00_data/{coin}_CoinGecko_data.parquet"
    gcs_block = GcsBucket.load("zoomcamp-gcs")
    gcs_block.get_directory(from_path=gcs_path, local_path=f"../00_data/")
    return Path(f"../00_data/{gcs_path}")


@task()
def transform(path: Path) -> pd.DataFrame:
    """Data cleaning and transformation"""
    df = pd.read_parquet(path)
    # check for missing data, without removing rows, as we dont want to have gaps in the time frame
    print(f"Missing data: {df.isnull().sum()}")

    return df


@task()
def write_bq(df: pd.DataFrame) -> None:
    """Write DataFrame to BiqQuery"""

    gcp_credentials_block = GcpCredentials.load("zoomcamp-gcp-creds")

    df.to_gbq(
        destination_table="crypto_all.CoinGecko_data",
        project_id="crypto-reality-382409",
        credentials=gcp_credentials_block.get_credentials_from_service_account(),
        chunksize=500_000,
        if_exists="append",
    )


@flow()
def etl_gcs_to_bq(
    coins: list[str] = ["dogecoin", "ethereum", "ethereum-classic", "bitcoin", "litecoin", "polkadot", "solana", "tether"]
):
    """Main ETL flow to load data into Big Query"""
    for coin in coins:
        path = extract_from_gcs(coin)
        df = transform(path)
        write_bq(df)


if __name__ == "__main__":
    etl_gcs_to_bq()
