SELECT count(*) from `crypto-reality-382409.crypto_all.CoinGecko_data`

-- Creating external table referring to gcs path
CREATE OR REPLACE EXTERNAL TABLE `crypto-reality-382409.crypto_all.external_CoinGecko_data`
OPTIONS (
  format = 'CSV',
  uris = ['gs://de_data_lake_crypto-reality-382409/00_data/*_CoinGecko_data.parquet.csv.gz']
);

-- Check the sample of the crypto data
SELECT * FROM `crypto-reality-382409.crypto_all.external_CoinGecko_data` limit 10;

-- Create a non partitioned table from external table
CREATE OR REPLACE TABLE `crypto-reality-382409.crypto_all.external_CoinGecko_data_non_partitoned` AS
SELECT * FROM `crypto-reality-382409.crypto_all.external_CoinGecko_data`;


-- Create a partitioned table from external table
CREATE OR REPLACE TABLE `crypto-reality-382409.crypto_all.external_CoinGecko_data_partitoned`
PARTITION BY
  DATE(date) AS
SELECT * FROM `crypto-reality-382409.crypto_all.external_CoinGecko_data`;

-- Creating a partitioned and clustered table
CREATE OR REPLACE TABLE `crypto-reality-382409.crypto_all.external_CoinGecko_data_partitoned_clustered`
PARTITION BY DATE(date)
CLUSTER BY coin_name AS
SELECT * FROM `crypto-reality-382409.crypto_all.external_CoinGecko_data`;
