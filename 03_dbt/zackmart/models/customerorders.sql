{{ config(materialized="table") }}
WITH customer_orders AS (
SELECT
  c.CUSTOMERID,
  CONCAT(c.FIRSTNAME, ' ', c.LASTNAME) AS customer_name,
  COUNT(o.ORDERID) AS orders
FROM zackmart.L1_LANDING.CUSTOMERS c
RIGHT JOIN zackmart.L1_LANDING.ORDERS o
  ON c.CUSTOMERID = o.CUSTOMERID
GROUP BY 1, 2
ORDER BY orders DESC
)

SELECT 
  CUSTOMERID AS customer_id,
  customer_name,
  orders 
FROM customer_orders
