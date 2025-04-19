create view gold.report_products as
with product_base_query as (
	select 
		f.order_number,
		f.product_key,
		p.product_name,
		f.customer_key,
		f.order_date,
		f.sales_amount,
		f.quantity,
		p.category,
		p.subcategory,
		p.cost
	from gold.fact_sales f
	left join gold.dim_products p on p.product_key = f.product_key
	where order_date is not null
)
, product_aggregation as(
	select 
		product_key,
		product_name,
		category,
		subcategory,
		cost,
		count(distinct order_number) as total_orders,
		sum(sales_amount) as total_sales,
		sum(quantity) as total_quantity,
		count(distinct customer_key) as total_customers,
		datediff(month, min(order_date), max(order_date)) as lifespan,
		max(order_date) as last_order_date,
		round(avg(cast(sales_amount as float) / nullif(quantity, 0)), 1) as avg_selling_price
	from product_base_query
	group by 
		product_key,
		product_name,
		category,
		subcategory,
		cost
)

select 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	total_orders,
	total_sales,
	avg_selling_price,
	case 
		when total_sales < 18000 then 'Low-Performers'
		when total_sales between 18000 and 50000 then 'Mid-Range'
		else 'High-Performers'
	end as revenue_segmentation,
	total_quantity,
	total_customers,
	lifespan,
	datediff(month, last_order_date, getdate()) as recency,
	case
		when total_orders = 0 then 0
		else total_sales / total_orders
	end as average_order_revenue,
	case
		when lifespan = 0 then 0
		else total_sales / lifespan
	end as average_monthly_revenue
from product_aggregation



/*
case 
		when sales_amount < 50 then 'Low-Performers'
		when sales_amount between 50 and 150 then 'Mid-Range'
		else 'High-Performers'
	end as revenue_segmentation
*/