--Year over year analysis
with yearly_product_sales as (
	select 
		year(f.order_date) as order_year,
		p.product_name as product_name,
		sum(f.sales_amount) as current_sales
	from gold.fact_sales f
	left join gold.dim_products p on f.product_key = p.product_key
	where f.order_date is not null
	group by year(f.order_date), p.product_name
)

select 
	order_year,
	product_name,
	current_sales,
	avg(current_sales) over(partition by product_name) as avg_sales,
	current_sales - avg(current_sales) over (partition by product_name) as diff_avg,
	case
		when current_sales - avg(current_sales) over (partition by product_name) > 0 then 'Above Avg'
		when current_sales - avg(current_sales) over (partition by product_name) < 0 then 'Below Avg'
		else 'Avg'
	end avg_change,
	lag(current_sales) over(partition by product_name order by order_year) as prev_year_sales,
	current_sales - lag(current_sales) over(partition by product_name order by order_year) as diff_prev_year,
	case
		when current_sales - lag(current_sales) over(partition by product_name order by order_year) > 0 then 'Increase'
		when current_sales - lag(current_sales) over(partition by product_name order by order_year) < 0 then 'Decrease'
		else 'No change'
	end prev_year_change
from yearly_product_sales
order by product_name, order_year