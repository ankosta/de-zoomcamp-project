{{ config(materialized='table') }}

select
    date,	
    inflation_rate,	
    unemployment_rate,	
    GDP_change
from {{ ref('poland_macro_data') }}