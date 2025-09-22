WITH data AS (
    SELECT
        http_get('https://api.llama.fi/protocol/relend%20network') AS response 
),
ethereum_tvl AS (
    SELECT
        FROM_UNIXTIME(TRY_CAST(et.date AS BIGINT)) AS date,
        'Ethereum' AS chain,
        et.tvl AS tvl
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
),
base_tvl AS (
    SELECT
        FROM_UNIXTIME(TRY_CAST(bt.date AS BIGINT)) AS date,
        'Base' AS chain,
        bt.tvl AS tvl
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
),
swellchain_tvl AS (
    SELECT
        FROM_UNIXTIME(TRY_CAST(st.date AS BIGINT)) AS date,
        'Swellchain' AS chain,
        st.tvl AS tvl
    FROM data
    CROSS JOIN 
        JSON_TABLE(
            CAST(response AS VARCHAR),
            'lax $.chainTvls.Swellchain.tvl[*]'
            COLUMNS(
                date VARCHAR PATH 'lax $.date[0]',
                tvl DOUBLE PATH 'lax $.totalLiquidityUSD[0]'
            )
        ) AS st
)
SELECT
    date,
    chain,
    tvl
FROM (
    SELECT * FROM ethereum_tvl
    UNION ALL
    SELECT * FROM base_tvl
    UNION ALL
    SELECT * FROM swellchain_tvl
)
ORDER BY chain ASC, date DESC;
