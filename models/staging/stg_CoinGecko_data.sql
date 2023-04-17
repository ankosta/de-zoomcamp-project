{{ config{materialized="view"} }}

select 

    -- identifier
    cast(coin_name as string) as  coin_name,

    -- timestamps
    cast(date as timestamp) as date,
    
    -- crypto info
    cast(price as numeric) as price,
    cast(total_volume as numeric) as total_volume,
    cast(market_cap as numeric) as market_cap,
    cast(coins_traded as numeric) as coins_traded,
    cast(coins_mined as numeric) as coins_mined

from {{ source('staging','CoinGecko_data') }}
limit 100