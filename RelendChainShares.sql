WITH data AS (
    SELECT
        http_get('https://api.llama.fi/protocol/relend%20network') AS response 
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
),
combined_tvl AS (
    SELECT date, chain, tvl
    FROM base_tvl
    UNION ALL
    SELECT date, chain, tvl
    FROM ethereum_tvl
    UNION ALL
    SELECT date, chain, tvl
    FROM swellchain_tvl
),
latest_tvl AS (
    SELECT
        chain,
        tvl,
        SUM(tvl) OVER () AS total_tvl,
        (tvl / SUM(tvl) OVER ()) * 100 AS percentage_share
    FROM combined_tvl
    WHERE date = (SELECT MAX(date) FROM combined_tvl)
)
SELECT
    chain,
    tvl,
    ROUND(percentage_share, 2) AS percentage_share
FROM latest_tvl
ORDER BY chain ASC;
