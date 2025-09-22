WITH data AS (
    SELECT
        http_get('https://api.llama.fi/protocol/relend%20network') AS response 
)


SELECT
    FROM_UNIXTIME(TRY_CAST(bt.date AS BIGINT)) AS date,    
    bt.tvl AS "Base Tvl"
FROM data
CROSS JOIN 
    JSON_TABLE(
        CAST(response AS VARCHAR),
        'lax $.chainTvls.Base.tvl[*]'
        COLUMNS(
            date VARCHAR PATH 'lax $.date[0]',
            tvl DOUBLE PATH 'lax $.totalLiquidityUSD[0]'
        )
    ) AS bt
ORDER BY 1 DESC
