# de-zoomcamp final project

# Problem statement

The year 2023 brings lots of anxiety around financial stability, as we hear news of the troubles in the banking sector. Many people, including myself, have started to look for alternatives on where and how to store/ invest their money. One of the trending directions is an investment in cryptocurrencies, however, as time has shown, this market also shows high volatility.
This brings me to this project, where I would like to solve the problem of understanding the basics of the crypto trading world. I would like to answer the question: are there any visible dependencies between the crypto prices, market cap, and transaction volumes? Can I create any kind of investment strategy based on the available crypto data?
To make the analysis more reliable, I will compare the crypto data against the macroeconomic indicators (like inflation rate, GDP change, and unemployment rate).

# Dataset description

I’ve used two types of data:

1. Cryptocurrency data on a daily basis from 01-01-2015 till 05-04-2023 (the day I've run the project), for eight chosen coins (bitcoin, ethereum, ethereum-classic, litecoin, polkadot, solana, tether, dogecoin). Source: [Kaggle](https://www.kaggle.com/datasets/sudalairajkumar/cryptocurrency-historical-prices-coingecko?select=apecoin.csv).
    
    **Original columns:**
    
    - date : date of observation - the price is taken at 00:00:00 hours
    - price : price of the coin at the given date and time
    - total_volume : volume of transactions on the given day in USD
    - market_cap : market capitalization* in USD
    
    **Created columns** during the **ETL** process:
    
    - coins_traded : average number of coins traded on a given day, obtained by dividing total_volume/price
    - coins_mined : average number of coins in the circulation, obtained by dividing market_cap/price
    
    **Created columns** during the **dbt** modeling:
    
    - record_id : unique identifier of the rows
    - coin_code : official abbreviation of the coin name as observed in the financial markets

*market capitalization (or market cap) is the total value of all the coins that have been mined. It’s calculated by multiplying the number of coins in circulation by the current market price of a single coin.

2. Poland basic macroeconomic data. I've chosen Poland, as this is my country and I would like to undertand if there are any visible relations with our economy, which does closely followup global macro trends. Source: [Polish givernment statistics](https://stat.gov.pl/)

    **Original columns:**
    
    - date : date of observation (monthly data, GDP_change is only available querterly)
    - inflation_rate : an increase in the price level in the economy leading to the loss of value of money
    - unemployment_rate : rate of people registered as unemployed
    - GDP_change : measures the change in volume of production produced by factors of production located in the territory of a given country (here Poland)

# Structure

1. Cloud

Project is run entirely on the cloud with the local backup of the files. I’ve used Infrastructure as a Code (IaC) tools like:

- Terraform
- Google Cloud Platform
- Prefect
- dbt Cloud

2. Data ingestion

Project has a workflow orchestration run by Prefect, which collects data in batches from the web and uploads to DW:

- in 1st step:
    - extracts data from the **web** in the csv format
    - fixes data type issues and creates transformed columns based on aggregated data
    - saves data files locally in the parquet format
    - loads data files into **data lake** (Google Cloud Storage)
- in 2nd step:
    - extracts data files from the **GCS**
    - cleans data files (since data has been already cleaned in the first step, here it only tests for missing values)
    - loads data files into the **data warehouse** (Big Query)

3. Data Warehouse

**Big Query** has been used as a Data Warehouse for this project. That is also where the initial data exploration took place, as well as where the dbt cloud - the transformation tool was linked. 
Data I've used for this project is small, as it is collected on a daily basis. Tables with data size < 1 GB don't show significant improvements with partitioning and clustering. However, the infrastructure of this pipeline can be used for far more detailed data. Common practice is to analyze hourly collected prices of the cryptocurrencies. Then there is a need for data optimization. The best way to do it for this dataset is to **partition by date and cluster by coin** as shown below:

4. Transformations

Whole modelling, schema definition and additional data transformation are defined using the dbt Cloud tool. In this step I’ve connected the cryptocurrency data collected by the workflow orchestration with the Poland macroeconomic data, creating a fact_coins table, which consists of both data sets joined together.

5. Dashboard

Data visualisation has been carried out using Google Data Studio. Dashboard has two main tiles with additional deep dive graphs for better understanding of the data and answering the questions asked in the problem statement.
