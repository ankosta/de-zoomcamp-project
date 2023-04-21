{{ config(materialized='table') }}

select
    date,	
    inflation_rate,	
    unemployment_rate,	
    GDP_change
from {{ ref('Poland_macro_data') }}
