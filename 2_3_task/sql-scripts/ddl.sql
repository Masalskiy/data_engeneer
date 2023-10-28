create table if not exists public.Customers (
	CustomerID serial primary key,
	FirstName varchar(40),
	LastName varchar(40),
	Email varchar(40)
);

create table if not exists public.Orders (
	OrderID serial primary key,
	CustomerID integer,
	OrderDate timestamp,
	TotalAmount decimal,
	FOREIGN key (CustomerID) references Customers (CustomerID)
);

create table if not exists public.OrderDetails (
	OrderDetailID serial primary key,
	OrderID integer references public.Orders,
	ProductID integer,
	Quantity integer,
	UnitPrice decimal
);
