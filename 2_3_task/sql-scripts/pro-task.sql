--ЗАДАНИЕ PRO
--1. Ваш SQL-запрос должен расшириться для учета общей суммы заказов и общего количества товаров, купленных каждым клиентом.

with tmp as (
select o.orderid, c.customerid, c.firstname, c.LastName, sum(o.totalamount) over (partition by o.customerid ) from Customers as c 
left join orders as o on c.customerid = o.customerid)

select distinct  t.firstname, t.lastname, t.sum as sum_products, 
sum(o.quantity) over (partition by t.customerid) as number_of_products
from tmp t left join orderdetails o on o.orderid = t.orderid


--2. Заказы клиентов должны быть разделены на две категории: «Новые заказы» (заказы, созданные менее месяца назад)
-- и «Старые заказы» (заказы, созданные более месяца назад).

--3. Вам нужно рассчитать среднюю оценку продукта для каждого клиента на основе отзывов, оставленных ими о продуктах.

--4. Выведите список клиентов вместе с их общей суммой заказов, общим количеством товаров, 
--новыми и старыми заказами, а также средней оценкой продукта.