WITH data AS (
    SELECT
        http_get('https://api.llama.fi/protocol/relend%20network') AS response 
)


SELECT
    FROM_UNIXTIME(TRY_CAST(st.date AS BIGINT)) AS date,    
    st.tvl AS "Swellchain Tvl"
FROM data
CROSS JOIN 
    JSON_TABLE(
        CAST(response AS VARCHAR),
        'lax $.chainTvls.Swellchain.tvl[*]'
        COLUMNS(
            date BIGINT PATH 'lax $.date[0]',
            tvl DOUBLE PATH 'lax $.totalLiquidityUSD[0]'
        )
    ) AS st
ORDER BY 1 DESC


    
