# [de-zoomcamp](https://datastudio.withgoogle.com/) final project

# Problem statement

The year 2023 brings lots of anxiety around financial stability, as we hear news of the troubles in the banking sector. Many people, including myself, have started to look for alternatives on where and how to store/ invest their money. One of the trending directions is an investment in cryptocurrencies, however, as time has shown, this market also shows high volatility.
This brings me to this project, where I would like to solve the problem of understanding the basics of the crypto trading world. I would like to answer the question: are there any visible dependencies between the crypto prices, market cap, and transaction volumes? Can I create any kind of investment strategy based on the available crypto data?
To make the analysis more reliable, I will compare the crypto data against the macroeconomic indicators (like inflation rate, GDP change, and unemployment rate).

# Dataset description

I’ve used two types of data:

1. Cryptocurrency data on a daily basis from 01-01-2015 till 05-04-2023 (the day I've run the project), for eight chosen coins (Bitcoin, Ethereum, Ethereum-classic, Litecoin, Polkadot, Solana, Tether, Dogecoin). Source: [Kaggle](https://www.kaggle.com/datasets/sudalairajkumar/cryptocurrency-historical-prices-coingecko?select=apecoin.csv).
    
    **Original columns:**
    
    - date : date of observation - the price is taken at 00:00:00 hours
    - price : price of the coin at the given date and time
    - total_volume : volume of transactions on the given day in USD
    - market_cap : market capitalization* in USD
    
    **Created columns** during the **ETL** process:
    
    - coins_traded : average number of coins traded on a given day, obtained by dividing total_volume/price
    - coins_mined : average number of coins in circulation, obtained by dividing market_cap/price
    
    **Created columns** during the **dbt** modeling:
    
    - record_id : the unique identifier of the rows
    - coin_code : official abbreviation of the coin name as observed in the financial markets

*market capitalization (or market cap) is the total value of all the coins that have been mined. It’s calculated by multiplying the number of coins in circulation by the current market price of a single coin.

2. Poland basic macroeconomic data. I've chosen Poland, as this is my country and I would like to undertand if there are any visible relations with our economy, which does closely followup global macro trends. Source: [Polish government statistics](https://stat.gov.pl/)

    **Columns:**
    
    - date : date of observation (monthly data, GDP_change is only available querterly)
    - inflation_rate : an increase in the price level in the economy leading to the loss of value of money
    - unemployment_rate : rate of people registered as unemployed
    - GDP_change : measures the change in volume of production produced by factors of production located in the territory of a given country (here Poland)

All data files are stored in my repository as a back up in case original source will change: [see data here](https://github.com/ankosta/de-zoomcamp-project/releases).

# Structure

**1. Cloud**

The project is run entirely on the cloud with the local backup of the files. I’ve used **Infrastructure as a Code (IaC)** tools like:

- [Terraform](https://github.com/ankosta/de-zoomcamp-project/tree/main/01_terraform)
- [Google Cloud Platform](https://github.com/ankosta/de-zoomcamp-project/tree/main/02_prefect)
- [Prefect](https://github.com/ankosta/de-zoomcamp-project/tree/main/02_prefect)
- [dbt Cloud](https://github.com/ankosta/de-zoomcamp-project/tree/main/03_dbt)

**2. Data ingestion**

The project has a workflow orchestration run by **[Prefect](https://github.com/ankosta/de-zoomcamp-project/tree/main/02_prefect)**, which collects data in batches from the web and uploads it to DW. I wanted to run things periodically, scheduling the job for specific times of the day:

- in 1st step:
    - extracts data from the **web** in the CSV format
    - fixes data type issues and creates transformed columns based on aggregated data
    - saves data files locally in the parquet format
    - loads data files into a **data lake** (**Google Cloud Storage**)
- in 2nd step:
    - extracts data files from the **GCS**
    - cleans data files (since data has been already cleaned in the first step, here it only tests for missing values)
    - loads data files into the **data warehouse** (**Big Query**)

<p align="center">
<img width="760" alt="Prefect flow runs" src="https://user-images.githubusercontent.com/59963512/234317078-e936eacf-e280-41e0-80b0-7bfda8939bee.png">
</p>

**3. Data Warehouse**

**Big Query** has been used as a Data Warehouse for this project. That is also where the initial data exploration took place, as well as where the dbt cloud - the transformation tool was linked. 
The data I've used for this project is small, as it is collected on a daily basis. Tables with data size < 1 GB don't show significant improvements with partitioning and clustering. However, the infrastructure of this pipeline can be used for far more detailed data. Common practice is to analyze hourly collected prices of the cryptocurrencies. Then there is a need for data optimization. The best way to do it for this dataset is to **partition by date** and **cluster by coin** as shown below:

<p align="center">
<img width="900" alt="partitioning and clustering" src="https://user-images.githubusercontent.com/59963512/234268940-3064f45e-e254-46f4-a3bc-a92f428f2a60.png">
</p>
    
**4. Transformations**

Whole modeling, schema definition, and additional data transformation are defined using the **[dbt Cloud](https://github.com/ankosta/de-zoomcamp-project/tree/main/03_dbt)** tool. In this step I’ve connected the cryptocurrency data collected by the workflow orchestration with the Poland macroeconomic data, creating a fact_coins table, which consists of both data sets joined together.

<p align="center">
<img width="900" alt="dbt graph" src="https://user-images.githubusercontent.com/59963512/234271577-f4eedd44-3e4b-4d06-aec2-16f68ff03421.png">
</p>

**5. Dashboard**

Data visualisation has been carried out using **Google Data Studio**. The dashboard (which can be found [here](https://lookerstudio.google.com/reporting/6202f1c4-09c0-4a9a-b362-8ba6f2bd7a96)) has two main tiles with additional deep -dive graphs for a better understanding of the data and answering the questions asked in the problem statement.

<p align="center">
![dashboard_gif](https://user-images.githubusercontent.com/59963512/234538097-4fa1a3ec-7a16-4172-8863-bac2c8d0e1f4.gif)
</p>

# Summary

The data used is not big enough to draw any significant causality relations. However, this pipeline is ready to be used on a wider range of data.
Nevertheless, graphs show interesting insights, like the negative relationship between market cap and interest rate, which is seen after the year 2020. Before, I would assume that the knowledge and trust in cryptocurrencies were low enough that investment did not follow any particular trends.
Interestingly is also observed that even though tether accounts only for 4.9% of the market cap of the given crypto sample, it is -on average- the mostly traded coin. This may indicate that most people after trading various crypto coins they exchange the earnings into tether as a 'safe' coin which closely follows the value of the fiat dollar.

In the future, I would extend the crypto information for the hourly data and I would dive deeper into the macroeconomic indicators.

# Reproducibility

The biggest challenge for me personally was the whole set up of the environment, luckily we have great #dezoomcamp lectures which explain everything step by step :)

<p align="center">
<img width="550" alt="dev-env-gilbert" src="https://user-images.githubusercontent.com/59963512/234298899-e68b0ac2-33fd-4a17-8cc7-379a684aa499.png">
</p>

1. Set up [GCP](https://cloud.google.com/) account (course video for this part of setup [here](https://www.youtube.com/watch?v=Hajwnmj0xfQ&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=11)):
    - create a new project
    - set up a new service account
    - create json credential key and download it  
2. Set up Terraform (course video for this part of setup [here](https://www.youtube.com/watch?v=dNkEgO-CExg&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=12)):
    - Download and install [Terraform](https://www.terraform.io/)
    - Copy 'main.tf', 'variables.tf', and '.terraform-version' from [here](https://github.com/ankosta/de-zoomcamp-project/tree/main/01_terraform) and run:
    ```
    terraform init
    terraform plan # where you will need enter your project id from point 1
    terraform apply
    ```
 3. Set up Virtual Machine on GCP (course video for this part of setup [here](https://www.youtube.com/watch?v=ae-CV2KfoN0&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=13)):
    - create [SSH key](https://cloud.google.com/compute/docs/connect/create-ssh-keys) and paste the public key into your compute engine settings on the GCP
    - create VM instance and configure it (as per the [video](https://www.youtube.com/watch?v=ae-CV2KfoN0&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=13))
 4. Set up Prefect (workflow orchestration) and run it (course video for this part of setup [here](https://www.youtube.com/watch?v=cdtN6dhp708&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=19)):
    - in your terminal/code editing tool create environment and install requirements found [here](https://github.com/ankosta/de-zoomcamp-project/blob/main/02_prefect/requirements.txt):
    ```
    conda create -n zoomcamp python=3.9
    conda activate zoomcamp
    pip install -r requirements.txt 
    ```
    - navigate to the localhost:4200 and set up blocks (SQLAlchemy Connector, GCS Bucket, GCP Credentials)
    - run 'etl_web_to_gcs.py' and then 'etl_gcs_to_bq.py' files found [here](https://github.com/ankosta/de-zoomcamp-project/tree/main/02_prefect)
     ```
    python etl_web_to_gcs.py
    python etl_gcs_to_bq.py
    ```
5. GCS and Big Query (course video for this part of setup [here](https://www.youtube.com/watch?v=jrHljAoD6nM&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=25)):
    - verify that your data has loaded correctly to your bucket in Google Cloud Storage and into the Big Query
    - explore data and optimize it by creating a partitioned and clustered table (see code [here](https://github.com/ankosta/de-zoomcamp-project/blob/main/bigquery.sql))
6. Set up dbt Cloud (course video for this part of setup [here](https://www.youtube.com/watch?v=iMxh6s_wL4Q&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=33)):
    - register free [dbt account](https://www.getdbt.com/) and link it to your repository
    - initialize new project
    - create models/ schemas/ seed/ tests or copy mine [here](https://github.com/ankosta/de-zoomcamp-project/tree/main/03_dbt)
    - create production deployment and schedule job runs
 7. Create a dashboard
    - go to [Google Data Studio](https://datastudio.withgoogle.com/) and connect your Biq Query coin_fact table
    - explore data and create graphs as seen above in the '5. Dashboard' section
