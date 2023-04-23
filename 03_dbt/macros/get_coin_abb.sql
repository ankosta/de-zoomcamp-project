 {#
    This macro returns the official abbreviation of the cryptocurrency 
#}

{% macro get_coin_abb(coin_name) -%}

    case {{ coin_name }}
        when 'bitcoin' then 'BTC'
        when 'dogecoin' then 'DOGE'
        when 'ethereum-classic' then 'ETC'
        when 'ethereum' then 'ETH'
        when 'litecoin' then 'LTC'
        when 'polkadot' then 'DOT'
        when 'solana' then 'SOL'
        when 'tether' then 'USDT'
    end

{%- endmacro %}