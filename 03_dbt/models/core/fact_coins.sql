{{ config(materialized='table') }}

with coin_data as (
    select *,
        date(date) as coin_date
    from {{ ref('stg_CoinGecko') }}
),

dim_macro as (
    select * 
    from {{ ref('dim_macro') }}
)

select 
    coin_data.record_id,
    coin_data.coin_name,
    coin_data.coin_code,
    coin_data.coin_date,
    coin_data.price,
    coin_data.total_volume,
    coin_data.market_cap,
    coin_data.coins_traded,
    coin_data.coins_mined, 
    dim_macro.date as macro_date,
    dim_macro.inflation_rate,
    dim_macro.unemployment_rate,	
    dim_macro.GDP_change
from coin_data
left join dim_macro
on coin_data.coin_date = dim_macro.date
