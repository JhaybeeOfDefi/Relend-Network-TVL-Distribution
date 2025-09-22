WITH data AS (
    SELECT
        http_get('https://api.llama.fi/protocol/relend%20network') AS response 
)


SELECT
    FROM_UNIXTIME(TRY_CAST(et.date AS BIGINT)) AS date,    
    et.tvl AS "Ethereum Tvl"
FROM data
CROSS JOIN 
    JSON_TABLE(
        CAST(response AS VARCHAR),
        'lax $.chainTvls.Ethereum.tvl[*]'
        COLUMNS(
            date VARCHAR PATH 'lax $.date[0]',
            tvl DOUBLE PATH 'lax $.totalLiquidityUSD[0]'
        )
    ) AS et
ORDER BY 1 DESC                                                                                                   
