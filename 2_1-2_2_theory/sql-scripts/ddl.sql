--DROP table public.rchild ; --1
--DROP table public.radult;--2
--drop table public.rlibcard CASCADE;--3
--drop table public.sauthor CASCADE;--4
--drop table public.spublisher CASCADE;--5
--drop table public.sudc CASCADE;--6
--drop table public.cformat CASCADE;--7
--drop table public.cbinding CASCADE;--8
--drop table public.cgenre CASCADE;--9
--drop table public.rbook CASCADE;--10
--drop table public.authorbook;--11
--drop table public.genrebook;--12
--drop table public.instancebook CASCADE;--13
--drop table public.jlibticket cascade;--14

--определить on delete

CREATE TABLE IF NOT EXISTS public.rlibcard (
	pkcard serial not null primary key,
	lclastn varchar(40) not null,
	lcfirstn varchar(40) not null,
	lcthirdn varchar(40) null
);--1.1

CREATE TABLE IF NOT EXISTS public.radult (
	pkacard integer NOT null primary key references rlibcard ,
	aaddress varchar(40) not null,
	aphone varchar(11) not null,
	apassseriesnum varchar(10) not null,
	adatepassrelease date not null --CHECK(),--ограничение не раньше текущего дня
);--1.2

CREATE TABLE IF NOT EXISTS public.rchild (
	pkccard integer NOT null primary key references rlibcard,
	fkacard integer not null references radult, 
	bcert varchar(7) null, -- CHECK(), --должен содержать только цифры
	releasecrt date NULL
);--1.3

CREATE TABLE IF NOT EXISTS public.sauthor (
	pkidauthor serial NOT null PRIMARY key,
	alastn varchar(20) NOT null,
	afirstn varchar(20) not null,
	athirdn varchar(20) null,
	acountry varchar(20) not null
); --1.4

CREATE TABLE IF NOT EXISTS public.spublisher (
	pkidpublisher smallserial primary key,
	pname varchar(40) not null,
	paddress varchar(40) not null,
	pphone varchar(11) not null,
	plastn varchar(40) null,
	pfirstn varchar(40) null,
	pthirdn varchar(40) null
);--1.5

CREATE TABLE IF NOT EXISTS public.sudc (
	pkidudc varchar(20) primary key NOT NULL,
	udesc varchar(20) null
); --1.6

create table if not exists public.cformat (
	pkidformat smallserial primary key NOT NULL,
	fname varchar(20) not null
); --1.7

create table if not exists public.cbinding (
	pkidbinding smallserial primary key NOT null,
	bname varchar(20) NOT null
); --1.8

create table if not exists public.cgenre (
	idgenres smallserial primary key NOT null,
	gname varchar(20) NOT null
); --1.9

CREATE TABLE IF NOT EXISTS public.rbook (
	pkisbn varchar(20) primary key NOT null,
	bname varchar(40) not NULL,
	bypubl numeric(4) NULL,
	bquantity smallint not null,
	fkcodepubl smallint null references spublisher,
	fkbudc varchar(20) not null references sudc,
	fkbidbformat smallint not null references cformat,
	fkbidbinding smallint NOT null references cbinding
);--1.10

CREATE TABLE IF NOT EXISTS public.authorbook(
	pkfkabisbn varchar(20) not null references rbook,
	pkfkauthor integer  not null references sauthor,
	primary key (pkfkabisbn, pkfkauthor)
);--1.11

CREATE TABLE IF NOT EXISTS public.genrebook (
	fkgbisbn varchar(20) not null references rbook,
	fkgbidgenre smallint not null references cgenre,
	primary key (fkgbisbn, fkgbidgenre)
);--1.12

CREATE TABLE IF NOT EXISTS public.instancebook (
	pkibarcode varchar(20) not null primary key,
	iisbn varchar(20) not null references rbook
);--1.13

CREATE TABLE IF NOT EXISTS public.jlibticket (
-- несколько раз взять одну книгу - одна запись
-- одна книга в одни руки
	fktcard INTEGER not null references rlibcard,
	fktbarcode varchar(20) not null references instancebook,
	dategive date not null,
	datereturnexpect date not null,
	datereturnfact date NULL,
	PRIMARY key (fktcard, fktbarcode)
);--1.14










