/*
drop table public.shop cascade;
drop table public.products cascade;
drop table public.plan cascade;
drop table shop_dns cascade;
drop table shop_mvideo cascade;
drop table shop_sitilink cascade;
*/

create table if not exists public.shop (
	shop_id smallserial primary key,
	shop_name varchar(40),
	address varchar(255)
);

create table if not exists public.products (
	product_id serial primary key,
	product_name varchar(255),
	price decimal,
	date_price_start date not null,
	date_price_end date null
);

create table if not exists public.plan (
	shop_id smallint references shop,
	product_id integer references products,
	plan_cnt decimal,
	plan_date_start date,
	plan_date_end date,
	primary key (shop_id, product_id)
);

create table if not exists public.shop_dns (
	shop_product serial primary key,
	shop_id smallint references shop,
	product_id integer references products,
	date_sale date,
	sales_cnt smallint
);

create table if not exists public.shop_mvideo (
	shop_product serial primary key,
	shop_id smallint references shop,
	product_id integer references products,
	date_sale date,
	sales_cnt smallint
);

create table if not exists public.shop_sitilink (
	shop_product serial primary key,
	shop_id smallint references shop,
	product_id integer references products,
	date_sale date,
	sales_cnt smallint
);

create table if not exists public.promo (
	id_promo serial primary key,
	product_id integer references products,
	shop_id smallint references shop,
	discount decimal,
	promo_date date
)



	




