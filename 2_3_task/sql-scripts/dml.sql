insert into public.Customers (FirstName, LastName, Email)
values ('дима', 'корочаев', 'coroch@mail.ru'),
	   ('Алексей', 'Попов', 'popovi4PRO@gmail.com'),
	   ('Кристина', 'Кожевникова', 'krasotulka666@yandex.ru'),
	   ('Ирина', 'Бычкова', 'bichok@mail.ru');

insert into public.Orders (CustomerID, OrderDate, TotalAmount) 
values (1, '2023-10-3 11:13:17', 23005),
	   (2, '2023-10-3 12:13:20', 5000),
	   (3, '2023-10-3 14:15:00', 465),
	   (4, '2023-10-3 15:40:30',7800),
	   (2, '2023-10-4 5:35:00', 20000);

insert into public.OrderDetails (OrderID, ProductID, Quantity, UnitPrice)
values (1, 1, 10, 800),
	   (1, 2, 3, 5000),
	   (1, 3, 1, 5),
	   (2, 2, 1, 5000),
	   (3, 4, 1, 460),
	   (3, 3, 1, 5),
	   (4, 5, 1, 7800),
	   (5, 6, 1, 20000);  