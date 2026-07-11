--membuat tabel baru
create table  master_table as 
select
	customers."CustomerEmail" as cust_email,
	customers."CustomerCity" as cust_city,
	orders."Date" as order_date,
	orders."Quantity" as order_qty,
	orders."ProdNumber" as product_number,
	products."Price" as product_price,
	product_category."CategoryName" as category_name,
	(orders."Quantity" * products."Price") as total_sales
from customers
join orders
	on customers."CustomerID" = orders."CustomerID"
join products
	on orders."ProdNumber" = products."ProdNumber"
join product_category
	on products."Category" = product_category."CategoryID"
;

select*from master_table
limit 5;

--membuat kolom rencency
ALTER TABLE master_table ADD COLUMN recency INTEGER;

--mengisi kolom recency
UPDATE master_table
SET recency = (SELECT MAX(order_date) FROM master_table) - order_date;

SELECT 
    cust_email,
    cust_city,
    MAX(order_date) AS latest_customer_order,
    
    -- Menghitung recency
    ((SELECT MAX(order_date) FROM master_table) - MAX(order_date))
	AS customer_recency_days,
    
    -- 1 jika recency >360, dan 0 jika <360
    CASE 
        WHEN ((SELECT MAX(order_date) FROM master_table) - MAX(order_date)) > 360 THEN 1
        ELSE 0
    END AS churn_flag
FROM master_table
GROUP BY cust_email, cust_city;