from pathlib import Path
import pandas as pd
from prefect import flow, task
from prefect_gcp.cloud_storage import GcsBucket
from random import randint
from prefect.tasks import task_input_hash
from datetime import timedelta


@task(retries=3, cache_key_fn=task_input_hash, cache_expiration=timedelta(days=1))
def fetch(dataset_url: str) -> pd.DataFrame:
    """Read crypto data from web into pandas DataFrame"""

    df = pd.read_csv(dataset_url)
    return df


@task(log_prints=True)
def clean(df: pd.DataFrame) -> pd.DataFrame:
    """Fix dtype issues and add transformed columns"""
    df["date"] = pd.to_datetime(df["date"])
    df["price"] = df["price"].astype("float64")
    df["total_volume"] = df["total_volume"].astype("float64")
    df["market_cap"] = df["market_cap"].astype("float64")

    # creating new columns based on aggregated data
    df['coins_traded'] = df['total_volume'] / df['price']
    df['coins_mined'] = df['market_cap'] / df['price']

    print(df.head(2))
    print(f"columns: {df.dtypes}")
    print(f"rows: {len(df)}")
    return df


@task()
def write_local(df: pd.DataFrame, coin: str, dataset_file: str) -> Path:
    """Write DataFrame out locally as parquet file"""
    path = Path(f"00_data//{dataset_file}.parquet")
    df.to_parquet(path, compression="gzip")
    return path


@task()
def write_gcs(path: Path) -> None:
    """Upload local parquet file to GCS"""
    gcs_block = GcsBucket.load("zoomcamp-gcs")
    gcs_block.upload_from_path(from_path=f"{path}", to_path=path)
    return


@flow()
def etl_web_to_gcs(coin: str) -> None:
    """The main ETL function"""
 #   coin = "fhv_parquet"
    dataset_file = f"{coin}_CoinGecko_data"
    dataset_url = f"https://github.com/ankosta/de-zoomcamp-project/releases/download/cryptocurrency/{coin}.csv"

    df = fetch(dataset_url)
    df_clean = clean(df)
    path = write_local(df_clean, coin, dataset_file)
    write_gcs(path)

@flow()
def etl_parent_flow(
    coins: list[str] = ["dogecoin", "ethereum", "ethereum-classic", "bitcoin", "litecoin", "polkadot", "solana", "tether"]
):
    for coin in coins:
        etl_web_to_gcs(coin)

if __name__ == "__main__":
    coins: list[str] = ["dogecoin", "ethereum", "ethereum-classic", "bitcoin", "litecoin", "polkadot", "solana", "tether"]

    etl_parent_flow(coins)