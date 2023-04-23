{{ config(materialized='table') }}

with coins_data as (
    select * from {{ ref('fact_coins') }}
)
    select 
    -- Grouping 
    coin_name,
    date_trunc(coin_date, month) as coin_month, 

    -- Calculation
    avg(price) as avg_monthly_price,
    sum(total_volume) as total_monthly_volume,
    avg(market_cap) as avg_monthly_market_cap,
    sum(coins_traded) as total_monthly_coins_traded,
    avg(coins_mined) as avg_monthly_coins_mined

    from coins_data
    group by 1,2