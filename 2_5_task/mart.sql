CREATE MATERIALIZED view IF NOT exists sales_mart as

with tmp_all as (
		select
			p.product_id,
			d.shop_id,
			sum(d.sales_cnt) as sum
		from products as p
		left join shop_dns as d on p.product_id = d.product_id
		where (d.date_sale between '2023-04-15' and '2023-05-15')
		group by p.product_id, d.shop_id
	union all
		select
			p.product_id,
			m.shop_id,
			sum(m.sales_cnt) as sum
		from products as p
		left join shop_mvideo as m on p.product_id = m.product_id
		where (m.date_sale between '2023-04-15' and '2023-05-15')
		group by p.product_id, m.shop_id
	union all
		select
			p.product_id,
			s.shop_id,
			sum(s.sales_cnt) as sum
		from products as p
		left join shop_sitilink as s on p.product_id = s.product_id
		where (s.date_sale between '2023-04-15' and '2023-05-15')
		group by p.product_id, s.shop_id
)

select  
	   sh.shop_name as "shop_name",
	   p.product_name as "product_name",
	   ta.sum as "sales_fact",
	   pl.plan_cnt as "sales_plan",
	   ta.sum/pl.plan_cnt as "sales_fact/sales_plan",
	   ta.sum*p.price  as "income_fact",
	   pl.plan_cnt*p.price as "income_plan",
	   (ta.sum*p.price)/(pl.plan_cnt*p.price) as "income_fact/income_plan",
	   1.0 * ta.sum / (date '2023-05-15' - date '2023-04-15') as "avg(sales/date)"
-- т.к. нужно собрать всю информацию для анаиза планирования, то цепляюсь к планам
from plan as pl 
left join products as p on pl.product_id = p.product_id  
left join shop as sh on pl.shop_id = sh.shop_id 
left join tmp_all as ta on (pl.shop_id = ta.shop_id and pl.product_id  = ta.product_id)
