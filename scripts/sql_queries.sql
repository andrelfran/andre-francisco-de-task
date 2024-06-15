-- Query 1: Longest Top 3 Ranking in 2022
WITH ranked_books AS (
    SELECT
        fbr.book_id,
        db.title,
        db.author,
        db.publisher,
        fbr.rank,
        d.date,
        ROW_NUMBER() OVER(PARTITION BY fbr.book_id ORDER BY d.date) AS rank_order
    FROM
        fact_book_rankings fbr
        JOIN dim_books db ON fbr.book_id = db.book_id
        JOIN dim_dates d ON fbr.date_id = d.date_id
    WHERE
        d.date >= '2022-01-01' AND d.date <= '2022-12-31'
        AND fbr.rank <= 3
)
SELECT
    title,
    author,
    publisher,
    MIN(date) AS start_date,
    MAX(date) AS end_date,
    COUNT(*) AS days_in_top_3
FROM
    ranked_books
WHERE
    rank_order <= 3
GROUP BY
    book_id, title, author, publisher
ORDER BY
    days_in_top_3 DESC
LIMIT 1;

-- Query 2: Lists with Least Unique Books
SELECT
    dl.list_name,
    COUNT(DISTINCT fbr.book_id) AS unique_books_count
FROM
    fact_book_rankings fbr
    JOIN dim_lists dl ON fbr.list_id = dl.list_id
GROUP BY
    dl.list_name
ORDER BY
    unique_books_count ASC
LIMIT 3;

-- Query 3: Quarterly Publisher Rankings
WITH quarterly_rankings AS (
    SELECT
        EXTRACT(year FROM d.date) AS year,
        EXTRACT(quarter FROM d.date) AS quarter,
        db.publisher,
        SUM(
            CASE
                WHEN fbr.rank = 1 THEN 5
                WHEN fbr.rank = 2 THEN 4
                WHEN fbr.rank = 3 THEN 3
                WHEN fbr.rank = 4 THEN 2
                WHEN fbr.rank = 5 THEN 1
                ELSE 0
            END
        ) AS points
    FROM
        fact_book_rankings fbr
        JOIN dim_books db ON fbr.book_id = db.book_id
        JOIN dim_dates d ON fbr.date_id = d.date_id
    WHERE
        d.date >= '2021-01-01' AND d.date <= '2023-12-31'
    GROUP BY
        d.year, quarter, publisher
),
ranked_publishers AS (
    SELECT
        year,
        quarter,
        publisher,
        ROW_NUMBER() OVER(PARTITION BY year, quarter ORDER BY SUM(points) DESC) AS rank
    FROM
        quarterly_rankings
    GROUP BY
        year, quarter, publisher
)
SELECT
    year,
    quarter,
    publisher,
    SUM(points) AS total_points
FROM
    ranked_publishers
WHERE
    rank <= 5
GROUP BY
    year, quarter, publisher
ORDER BY
    year, quarter, total_points DESC;

-- Query 4: Jake and Pete’s Book Purchases in 2023
WITH jake_purchases AS (
    SELECT
        dl.list_name,
        db.title AS book_title,
        d.date AS purchase_date
    FROM
        fact_book_rankings fbr
        JOIN dim_books db ON fbr.book_id = db.book_id
        JOIN dim_lists dl ON fbr.list_id = dl.list_id
        JOIN dim_dates d ON fbr.date_id = d.date_id
    WHERE
        d.date >= '2023-01-01' AND d.date <= '2023-12-31'
        AND fbr.rank = 1
),
pete_purchases AS (
    SELECT
        dl.list_name,
        db.title AS book_title,
        d.date AS purchase_date
    FROM
        fact_book_rankings fbr
        JOIN dim_books db ON fbr.book_id = db.book_id
        JOIN dim_lists dl ON fbr.list_id = dl.list_id
        JOIN dim_dates d ON fbr.date_id = d.date_id
    WHERE
        d.date >= '2023-01-01' AND d.date <= '2023-12-31'
        AND fbr.rank = 3
)
SELECT
    'Jake' AS team,
    list_name,
    book_title,
    purchase_date
FROM
    jake_purchases
UNION ALL
SELECT
    'Pete' AS team,
    list_name,
    book_title,
    purchase_date
FROM
    pete_purchases
ORDER BY
    purchase_date;
