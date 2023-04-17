{{ config(materialized='view') }}

select 
    -- identifiers
    {{ dbt_utils.surrogate_key(['coin_name', 'date']) }} as record_id,
    cast(coin_name as string) as coin_name,
    {{ get_coin_abb('coin_name') }} as coin_code,

    -- timestamp
    cast(date as timestamp) as date,

    -- crypto transactions info
    cast(price as numeric) as price,
    cast(total_volume as numeric) as total_volume,
    cast(market_cap as numeric) as market_cap,
    cast(coins_traded as numeric) as coins_traded,
    cast(coins_mined as numeric) as coins_mined

from {{ source('staging', 'CoinGecko_data') }}

-- dbt build --m <model.sql> --var 'is_test_run: true'
{% if var('is_test_run', default=false) %}

  limit 100

{% endif %}