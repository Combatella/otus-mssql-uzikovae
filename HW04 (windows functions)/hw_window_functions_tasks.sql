/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters
/*
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

set statistics time on

;with InvoiceReportCTE (InvoiceID, CustomerName, InvoiceDate, Price) as (
	select 
			i.InvoiceID as InvoiceID,
			(select CustomerName from Sales.Customers where CustomerID = i.CustomerID) as CustomerName,
			i.InvoiceDate as InvoiceDate,
			(select sum(ExtendedPrice) from Sales.InvoiceLines where InvoiceID = i.InvoiceID) as Price
		from Sales.Invoices as i
		where YEAR(i.InvoiceDate) >= '2015'
	)

select 
	*,
	(select sum(Price) from InvoiceReportCTE as ircte1
	where ircte1.InvoiceDate <= ircte2.InvoiceDate) AS TotalPrice
from InvoiceReportCTE as ircte2
order by InvoiceDate

set statistics time off
--  SQL Server Execution Times:
--   CPU time = 40343 ms,  elapsed time = 52565 ms.


/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

set statistics time on

select 
	InvoiceID, CustomerName, InvoiceDate, Price,
	sum(Price) over (partition by month(InvoiceDate) order by InvoiceDate) as TotalPrice
from
(
	select 
		i.InvoiceID as InvoiceID,
		(select CustomerName from Sales.Customers where CustomerID = i.CustomerID) as CustomerName,
		i.InvoiceDate as InvoiceDate,
		(select sum(ExtendedPrice) from Sales.InvoiceLines where InvoiceID = i.InvoiceID) as Price
	from Sales.Invoices as i
	where YEAR(i.InvoiceDate) >= '2015'
) as base order by base.InvoiceDate

set statistics time off
-- SQL Server Execution Times:
-- CPU time = 125 ms,  elapsed time = 349 ms.
-- при использовании оконной функции время получения результата сократилось на 2 порядка по сравнению с работой запроса без использования оконной функции

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

select 
	[Description],
	Quantity,
	year(InvoiceDate) as [Year],
	datename(month, InvoiceDate) as [Month]
from (
	select 
		row_number() over (
		partition by month(i.InvoiceDate) 
		order by month(i.InvoiceDate), sum([Quantity]) desc
		) as Num,
		[Description],
		sum(il.Quantity) as Quantity,
		i.InvoiceDate,
		month(i.InvoiceDate) as [Month]
	from Sales.Invoices as i
		join (select * from Sales.InvoiceLines) as il 
		on il.InvoiceID = i.InvoiceID
	where year(i.InvoiceDate) = '2016'
	group by [Description], i.InvoiceDate
) as t
where Num <= 2
order by month(t.InvoiceDate), Quantity desc

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

-- * пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
select 
	row_number() over (
		partition by substring(si.StockItemName, 1, 1)
		order by si.StockItemName desc
		) as NumberByFirstChar,
	si.StockItemID,
	si.StockItemName,
	si.Brand,
	si.RecommendedRetailPrice
from Warehouse.StockItems as si

-- * посчитайте общее количество товаров и выведете полем в этом же запросе
select 
	si.StockItemID,
	si.StockItemName,
	si.Brand,
	si.RecommendedRetailPrice,
	count(*) over () AS TotalStockItems
from Warehouse.StockItems as si

-- * посчитайте общее количество товаров в зависимости от первой буквы названия товара
select 
	si.StockItemID,
	si.StockItemName,
	si.Brand,
	si.RecommendedRetailPrice,
	count(*) over (partition by substring(si.StockItemName, 1, 1)) AS TotalByFirstChar
from Warehouse.StockItems as si

-- * отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
select 
	si.StockItemID,
	si.StockItemName,
	si.Brand,
	si.RecommendedRetailPrice,
	si.TypicalWeightPerUnit,
	lead(si.StockItemID) over(order by si.StockItemName) as NextStockItemID
from Warehouse.StockItems as si	

-- * предыдущий ид товара с тем же порядком отображения (по имени)
select 
	si.StockItemID,
	si.StockItemName,
	si.Brand,
	si.RecommendedRetailPrice,
	si.TypicalWeightPerUnit,
	lag(si.StockItemID) over(order by si.StockItemName) as PrevStockItemID
from Warehouse.StockItems as si	

-- * названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
select 
	si.StockItemID,
	si.StockItemName,
	si.Brand,
	si.RecommendedRetailPrice,
	si.TypicalWeightPerUnit,
	lag(si.StockItemName, 2, 'No items') over(order by si.StockItemID)
from Warehouse.StockItems as si	
order by si.StockItemID

-- * сформируйте 30 групп товаров по полю вес товара на 1 шт
select 
	si.StockItemID,
	si.StockItemName,
	si.Brand,
	si.RecommendedRetailPrice,
	si.TypicalWeightPerUnit,
	ntile(30) over(order by si.TypicalWeightPerUnit) as WeightPerUnitGroup
from Warehouse.StockItems as si	


/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

select 
	t.PersonID, t.FullName, t.CustomerID, t.CustomerName, t.InvoiceDate, t.SumPrice
from (
	select 
		p.PersonID,
		p.FullName,
		c.CustomerID,
		c.CustomerName,
		i.InvoiceDate,
		(select sum(il.ExtendedPrice) from Sales.InvoiceLines as il 
		where il.InvoiceID = i.InvoiceID) as SumPrice,		
		row_number() over (partition by p.FullName order by i.InvoiceDate desc) as Num
	from Sales.Invoices as i
	join Application.People as p on i.SalespersonPersonID = p.PersonID
	join Sales.Customers as c on i.CustomerID = c.CustomerID
) as t
where Num = 1

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

select t2.CustomerID, t2.CustomerName, t2.StockItemID, t2.StockItemName, t2.UnitPrice, t2.InvoiceDate
from (
	select
		t.CustomerID, t.CustomerName, t.StockItemID, t.StockItemName, t.UnitPrice, t.InvoiceDate,
		row_number() over (partition by t.CustomerID order by t.UnitPrice desc) as n1
	from (
		select 
			c.CustomerID,
			c.CustomerName,
			il.StockItemID,
			si.StockItemName,
			il.UnitPrice,
			i.InvoiceDate,
			lag(il.StockItemID, 1, 0) over (partition by i.CustomerID order by il.UnitPrice desc) as LagID	
		from Sales.Invoices as i
		join Sales.InvoiceLines as il on i.InvoiceID = il.InvoiceID
		join Sales.Customers as c on i.CustomerID = c.CustomerID
		join Warehouse.StockItems as si on si.StockItemID = il.StockItemID
	) as t where t.LagID <> t.StockItemID 
) as t2 where t2.n1 <= 2

--Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 