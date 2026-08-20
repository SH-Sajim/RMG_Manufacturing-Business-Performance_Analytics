SELECT 'dim_date' AS table_name, COUNT(*) AS row_count FROM dim_date
UNION ALL
SELECT 'dim_buyer', COUNT(*) FROM dim_buyer
UNION ALL
SELECT 'dim_factory', COUNT(*) FROM dim_factory
UNION ALL
SELECT 'dim_line', COUNT(*) FROM dim_line
UNION ALL
SELECT 'dim_style', COUNT(*) FROM dim_style
UNION ALL
SELECT 'fact_order', COUNT(*) FROM fact_order
UNION ALL
SELECT 'fact_production_daily', COUNT(*) FROM fact_production_daily
UNION ALL
SELECT 'fact_cutting_daily', COUNT(*) FROM fact_cutting_daily
UNION ALL
SELECT 'fact_finishing_daily', COUNT(*) FROM fact_finishing_daily
UNION ALL
SELECT 'fact_shipment', COUNT(*) FROM fact_shipment
UNION ALL
SELECT 'fact_knitting', COUNT(*) FROM fact_knitting
UNION ALL
SELECT 'fact_dyeing', COUNT(*) FROM fact_dyeing
UNION ALL
SELECT 'fact_fabric_inspection', COUNT(*) FROM fact_fabric_inspection



-- All dimension table Primary Key / Duplicate Validation

SELECT 
    'dim_date' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT "DateKey") AS unique_keys
FROM dim_date

UNION ALL

SELECT 
    'dim_buyer',
    COUNT(*),
    COUNT(DISTINCT "BuyerID")
FROM dim_buyer

UNION ALL

SELECT 
    'dim_factory',
    COUNT(*),
    COUNT(DISTINCT "FactoryID")
FROM dim_factory

UNION ALL

SELECT 
    'dim_line',
    COUNT(*),
    COUNT(DISTINCT "LineID")
FROM dim_line

UNION ALL

SELECT 
    'dim_style',
    COUNT(*),
    COUNT(DISTINCT "StyleID")
FROM dim_style;


-- Validation — Fact Table Primary Keys

SELECT 
    'fact_order' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT "OrderID") AS unique_keys
FROM fact_order

UNION ALL

SELECT 
    'fact_production_daily',
    COUNT(*),
    COUNT(DISTINCT "ProductionID")
FROM fact_production_daily

UNION ALL

SELECT 
    'fact_cutting_daily',
    COUNT(*),
    COUNT(DISTINCT "CuttingID")
FROM fact_cutting_daily

UNION ALL

SELECT 
    'fact_finishing_daily',
    COUNT(*),
    COUNT(DISTINCT "FinishingID")
FROM fact_finishing_daily

UNION ALL

SELECT 
    'fact_shipment',
    COUNT(*),
    COUNT(DISTINCT "ShipmentID")
FROM fact_shipment

UNION ALL

SELECT 
    'fact_knitting',
    COUNT(*),
    COUNT(DISTINCT "KnittingID")
FROM fact_knitting

UNION ALL

SELECT 
    'fact_dyeing',
    COUNT(*),
    COUNT(DISTINCT "DyeingID")
FROM fact_dyeing

UNION ALL

SELECT 
    'fact_fabric_inspection',
    COUNT(*),
    COUNT(DISTINCT "InspectionID")
FROM fact_fabric_inspection;




SELECT
    'BuyerID' AS key_name,
    COUNT(*) AS invalid_rows
FROM fact_order f
LEFT JOIN dim_buyer b
    ON f."BuyerID" = b."BuyerID"
WHERE b."BuyerID" IS NULL

UNION ALL

SELECT
    'FactoryID',
    COUNT(*)
FROM fact_order f
LEFT JOIN dim_factory d
    ON f."FactoryID" = d."FactoryID"
WHERE d."FactoryID" IS NULL

UNION ALL

SELECT
    'StyleID',
    COUNT(*)
FROM fact_order f
LEFT JOIN dim_style s
    ON f."StyleID" = s."StyleID"
WHERE s."StyleID" IS NULL

UNION ALL

SELECT
    'OrderDateKey',
    COUNT(*)
FROM fact_order f
LEFT JOIN dim_date d
    ON f."OrderDateKey" = d."DateKey"
WHERE d."DateKey" IS NULL

UNION ALL

SELECT
    'ShipDateKey',
    COUNT(*)
FROM fact_order f
LEFT JOIN dim_date d
    ON f."ShipDateKey" = d."DateKey"
WHERE d."DateKey" IS NULL;




SELECT
    MIN("Date") AS earliest_date,
    MAX("Date") AS latest_date
FROM dim_date;



SELECT
    MIN("OrderDate") AS earliest_order_date,
    MAX("OrderDate") AS latest_order_date
FROM fact_order;


SELECT 
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'dim_date'
ORDER BY ordinal_position;


SELECT
    f."OrderDateKey",
    f."OrderDate"
FROM fact_order f
LEFT JOIN dim_date d
    ON f."OrderDateKey" = d."DateKey"
WHERE d."DateKey" IS NULL
ORDER BY f."OrderDate"
LIMIT 10


SELECT
    "Date",
    "DayOfWeek",
    "DayName",
    "IsWeekend"
FROM dim_date
ORDER BY "Date"
LIMIT 10;



SELECT
    "Date",
    "DayOfWeek",
    "DayName",
    "IsWeekend"
FROM dim_date
WHERE "IsWeekend" = true
ORDER BY "Date"
LIMIT 10;

INSERT INTO dim_date
(
    "DateKey",
    "Date",
    "Year",
    "Month",
    "MonthName",
    "Day",
    "DayOfWeek",
    "DayName",
    "IsWeekend"
)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::bigint AS "DateKey",
    TO_CHAR(d, 'YYYY-MM-DD') AS "Date",
    EXTRACT(YEAR FROM d)::bigint AS "Year",
    EXTRACT(MONTH FROM d)::bigint AS "Month",
    TO_CHAR(d, 'Month') AS "MonthName",
    EXTRACT(DAY FROM d)::bigint AS "Day",
    EXTRACT(ISODOW FROM d)::bigint AS "DayOfWeek",
    TO_CHAR(d, 'FMDay') AS "DayName",
    CASE
        WHEN EXTRACT(ISODOW FROM d) IN (5, 6)
        THEN TRUE
        ELSE FALSE
    END AS "IsWeekend"
FROM generate_series(
    DATE '2021-09-06',
    DATE '2021-12-31',
    INTERVAL '1 day'
) AS d
WHERE NOT EXISTS (
    SELECT 1
    FROM dim_date existing
    WHERE existing."DateKey" = TO_CHAR(d, 'YYYYMMDD')::bigint
);


SELECT
    COUNT(*) AS invalid_rows
FROM fact_order f
LEFT JOIN dim_date d
    ON f."OrderDateKey" = d."DateKey"
WHERE d."DateKey" IS NULL;




-- Foreign Key Validation

SELECT
    'fact_production_daily → OrderID' AS relationship,
    COUNT(*) AS invalid_rows
FROM fact_production_daily f
LEFT JOIN fact_order o
    ON f."OrderID" = o."OrderID"
WHERE o."OrderID" IS NULL

UNION ALL

SELECT
    'fact_production_daily → FactoryID',
    COUNT(*)
FROM fact_production_daily f
LEFT JOIN dim_factory d
    ON f."FactoryID" = d."FactoryID"
WHERE d."FactoryID" IS NULL

UNION ALL

SELECT
    'fact_production_daily → LineID',
    COUNT(*)
FROM fact_production_daily f
LEFT JOIN dim_line d
    ON f."LineID" = d."LineID"
WHERE d."LineID" IS NULL

UNION ALL

SELECT
    'fact_production_daily → StyleID',
    COUNT(*)
FROM fact_production_daily f
LEFT JOIN dim_style d
    ON f."StyleID" = d."StyleID"
WHERE d."StyleID" IS NULL

UNION ALL

SELECT
    'fact_production_daily → DateKey',
    COUNT(*)
FROM fact_production_daily f
LEFT JOIN dim_date d
    ON f."DateKey" = d."DateKey"
WHERE d."DateKey" IS NULL

UNION ALL

SELECT
    'fact_cutting_daily → OrderID',
    COUNT(*)
FROM fact_cutting_daily f
LEFT JOIN fact_order o
    ON f."OrderID" = o."OrderID"
WHERE o."OrderID" IS NULL

UNION ALL

SELECT
    'fact_cutting_daily → FactoryID',
    COUNT(*)
FROM fact_cutting_daily f
LEFT JOIN dim_factory d
    ON f."FactoryID" = d."FactoryID"
WHERE d."FactoryID" IS NULL

UNION ALL

SELECT
    'fact_cutting_daily → StyleID',
    COUNT(*)
FROM fact_cutting_daily f
LEFT JOIN dim_style d
    ON f."StyleID" = d."StyleID"
WHERE d."StyleID" IS NULL

UNION ALL

SELECT
    'fact_cutting_daily → DateKey',
    COUNT(*)
FROM fact_cutting_daily f
LEFT JOIN dim_date d
    ON f."DateKey" = d."DateKey"
WHERE d."DateKey" IS NULL

UNION ALL

SELECT
    'fact_finishing_daily → OrderID',
    COUNT(*)
FROM fact_finishing_daily f
LEFT JOIN fact_order o
    ON f."OrderID" = o."OrderID"
WHERE o."OrderID" IS NULL

UNION ALL

SELECT
    'fact_finishing_daily → FactoryID',
    COUNT(*)
FROM fact_finishing_daily f
LEFT JOIN dim_factory d
    ON f."FactoryID" = d."FactoryID"
WHERE d."FactoryID" IS NULL

UNION ALL

SELECT
    'fact_finishing_daily → StyleID',
    COUNT(*)
FROM fact_finishing_daily f
LEFT JOIN dim_style d
    ON f."StyleID" = d."StyleID"
WHERE d."StyleID" IS NULL

UNION ALL

SELECT
    'fact_finishing_daily → DateKey',
    COUNT(*)
FROM fact_finishing_daily f
LEFT JOIN dim_date d
    ON f."DateKey" = d."DateKey"
WHERE d."DateKey" IS NULL

UNION ALL

SELECT
    'fact_shipment → OrderID',
    COUNT(*)
FROM fact_shipment f
LEFT JOIN fact_order o
    ON f."OrderID" = o."OrderID"
WHERE o."OrderID" IS NULL

UNION ALL

SELECT
    'fact_shipment → FactoryID',
    COUNT(*)
FROM fact_shipment f
LEFT JOIN dim_factory d
    ON f."FactoryID" = d."FactoryID"
WHERE d."FactoryID" IS NULL

UNION ALL

SELECT
    'fact_shipment → LoadDateKey',
    COUNT(*)
FROM fact_shipment f
LEFT JOIN dim_date d
    ON f."LoadDateKey" = d."DateKey"
WHERE d."DateKey" IS NULL

UNION ALL

SELECT
    'fact_knitting → FactoryID',
    COUNT(*)
FROM fact_knitting f
LEFT JOIN dim_factory d
    ON f."FactoryID" = d."FactoryID"
WHERE d."FactoryID" IS NULL

UNION ALL

SELECT
    'fact_knitting → DateKey',
    COUNT(*)
FROM fact_knitting f
LEFT JOIN dim_date d
    ON f."DateKey" = d."DateKey"
WHERE d."DateKey" IS NULL

UNION ALL

SELECT
    'fact_dyeing → FactoryID',
    COUNT(*)
FROM fact_dyeing f
LEFT JOIN dim_factory d
    ON f."FactoryID" = d."FactoryID"
WHERE d."FactoryID" IS NULL

UNION ALL

SELECT
    'fact_fabric_inspection → FactoryID',
    COUNT(*)
FROM fact_fabric_inspection f
LEFT JOIN dim_factory d
    ON f."FactoryID" = d."FactoryID"
WHERE d."FactoryID" IS NULL

UNION ALL

SELECT
    'fact_fabric_inspection → DateKey',
    COUNT(*)
FROM fact_fabric_inspection f
LEFT JOIN dim_date d
    ON f."DateKey" = d."DateKey"
WHERE d."DateKey" IS NULL;



SELECT
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name IN (
    'fact_order',
    'fact_production_daily',
    'fact_cutting_daily',
    'fact_finishing_daily',
    'fact_shipment',
    'fact_knitting',
    'fact_dyeing',
    'fact_fabric_inspection'
)
ORDER BY table_name, ordinal_position;



SELECT
    'Production' AS table_name,
    COUNT(*) AS rows,
    COUNT(DISTINCT ("OrderID", "FactoryID", "StyleID", "DateKey")) AS unique_grain
FROM fact_production_daily

UNION ALL

SELECT
    'Cutting',
    COUNT(*),
    COUNT(DISTINCT ("OrderID", "FactoryID", "StyleID", "DateKey"))
FROM fact_cutting_daily

UNION ALL

SELECT
    'Finishing',
    COUNT(*),
    COUNT(DISTINCT ("OrderID", "FactoryID", "StyleID", "DateKey"))
FROM fact_finishing_daily;



SELECT
    "OrderID",
    "FactoryID",
    "StyleID",
    "DateKey",
    COUNT(*) AS row_count
FROM fact_production_daily
GROUP BY
    "OrderID",
    "FactoryID",
    "StyleID",
    "DateKey"
HAVING COUNT(*) > 1
ORDER BY row_count DESC
LIMIT 10;



SELECT *
FROM fact_production_daily
WHERE "OrderID" = 596
  AND "FactoryID" = 1
  AND "StyleID" = 25
  AND "DateKey" = 20221020;
