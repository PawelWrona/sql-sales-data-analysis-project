with product_segmenst as (
	select 
		product_key,
		product_name,
		cost,
		case 
			when cost < 100 then 'Below 100'
			when cost between 100 and 500 then '100-500'
			when cost between 500 and 1000 then '500-1000'
			else 'Above 1000'
		end cost_range
	from gold.dim_products
)

select 
	cost_range,
	count(product_key) as total_products
from product_segmenst
group by cost_range
order by total_products



with customer_spending as (
	select 
		c.customer_key,
		sum(f.sales_amount) as total_spending,
		min(f.order_date) as first_order,
		max(f.order_date) as last_order,
		datediff(month, min(f.order_date), max(f.order_date)) as lifespan
	from gold.fact_sales f
	left join gold.dim_customers c on c.customer_key = f.customer_key
	group by c.customer_key
)

select customer_segment, count(customer_key) as total_customers from(
	select
		customer_key,
		case 
			when lifespan >= 12 and total_spending > 5000 then 'VIP'
			when lifespan >= 12 and total_spending <= 5000 then 'Regular'
			else 'New'
		end as customer_segment
	from customer_spending
) as subq
group by customer_segment 
order by total_customers desc