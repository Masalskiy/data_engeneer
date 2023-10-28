CREATE TABLE IF NOT EXISTS rates (
	id serial,
    date timestamp,
    from_curr varchar(3),
    to_curr varchar(3),
    rate double precision
);
             
create table if not exists currency (
	id_cur smallserial primary key,
	curr varchar(3) unique
);

create table if not exists rate (
	id serial primary key,
	date timestamp,
	from_curr smallint references currency (id_cur),
    to_curr smallint references currency (id_cur),
    rate double precision
);

CREATE OR REPLACE FUNCTION maint_rate() 
returns trigger     
LANGUAGE PLPGSQL
as 
$name1111$
	declare 
		tmp_rates_id rates.id%type;
		tmp_date rates.date%type;
		tmp_from_curr_id currency.id_cur%type;
		tmp_from_curr rates.from_curr%type;
		tmp_to_curr_id currency.id_cur%type;
		tmp_to_curr rates.to_curr%type;
		tmp_rate rates.rate%type;
	begin
		IF (TG_OP = 'INSERT') then
			tmp_rates_id = new.id;
			tmp_date = new.date;
			tmp_from_curr = new.from_curr;
			tmp_to_curr = new.to_curr;
			tmp_rate = new.rate;
		END IF;
	
		select id_cur into tmp_from_curr_id from currency where curr = tmp_from_curr;
		if (tmp_from_curr_id is null) then
			insert into currency(curr) 
			values (tmp_from_curr)
			returning id_cur into tmp_from_curr_id;
		end if;
	
		select id_cur into tmp_to_curr_id from currency where curr = tmp_to_curr;
		if (tmp_to_curr_id is null) then
			insert into currency(curr) 
			values (tmp_to_curr)
			returning id_cur into tmp_to_curr_id;
		end if;
		
		insert into rate(date, from_curr, to_curr, rate) 
			values (tmp_date, tmp_from_curr_id, tmp_to_curr_id, tmp_rate);
		
		delete from rates where id = tmp_rates_id;
		RETURN null;
	end;
$name1111$;

create trigger maint_insert_rate
	after insert on rates
	for each row 
	execute procedure maint_rate();
		   
create table if not exists statistic_rate(
	id serial,
	year_month varchar(7),
	from_curr varchar(3),
	to_curr varchar(3),
	max_curr_rate decimal,
	max_curr_date date,
	min_curr_rate decimal,
	min_curr_date date,
	avg_rate_month decimal,
	last_rate_in_month decimal not null,
	last_date_in_month timestamp
);

ALTER TABLE statistic_rate ADD CONSTRAINT unique_stat_raw UNIQUE (year_month, from_curr, to_curr);
select * from statistic_rate

CREATE OR REPLACE FUNCTION maint_rate() 
returns trigger     
LANGUAGE PLPGSQL
as 
$name1111$
	declare
	
	begin
		
		RETURN null;
	end;
$name1111$;

create trigger maint_insert_rate
	before insert on statistic_rate
	for each row 
	execute procedure maint_rate();
