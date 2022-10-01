/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

select 
p.PersonID,
p.FullName
from Application.People as p
where p.IsSalesperson = 1 
and p.PersonID not in 
	(select i.SalespersonPersonID 
	from Sales.Invoices as i 
	where i.InvoiceDate = '20150407' 
	and i.SalespersonPersonID = p.PersonID)

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

-- выриант 1
select si.StockItemID, si.StockItemName, si.RecommendedRetailPrice 
from Warehouse.StockItems as si
where si.RecommendedRetailPrice = 
	(select top(1) RecommendedRetailPrice 
	from Warehouse.StockItems 
	order by RecommendedRetailPrice)

-- вариант 2
select si.StockItemID, si.StockItemName, 
	(select top(1) min(RecommendedRetailPrice) 
		from Warehouse.StockItems) as MinPrice
from Warehouse.StockItems as si
where si.RecommendedRetailPrice = 
	(select top(1) min(RecommendedRetailPrice) 
		from Warehouse.StockItems)

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

-- вариант 1
select c.CustomerName,
	(select max(TransactionAmount) from Sales.CustomerTransactions 
		where CustomerID = c.CustomerID) as MaxTransactionAmount
from Sales.Customers as c
where c.CustomerID in
(select CustomerID from 
	(select top(5)
		ct.CustomerID, 
		max(ct.TransactionAmount) as TransactionAmount
	from Sales.CustomerTransactions as ct
	group by ct.CustomerID
	order by TransactionAmount desc) 
as amts)

-- вариант 2
select top(5) 
	ct.CustomerID, 
	max(ct.TransactionAmount) as TransactionAmount,
	(select c.CustomerName from Sales.Customers as c 
		where c.CustomerID = ct.CustomerID) as CustomerName
from Sales.CustomerTransactions as ct
group by ct.CustomerID
order by TransactionAmount desc


-- вариант CTE
;with TopCustomerTransactionsCTE (CustomerID, TransactionAmount) as (
	select top(5)
			ct.CustomerID, 
			max(ct.TransactionAmount) as TransactionAmount
		from Sales.CustomerTransactions as ct
		group by ct.CustomerID
		order by TransactionAmount desc
)

select 
	c.CustomerName,
	(select TransactionAmount from TopCustomerTransactionsCTE
		where CustomerID = c.CustomerID)
from Sales.Customers as c 
where c.CustomerID in (select CustomerID from TopCustomerTransactionsCTE)

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

;with OrdersIDWithHighPriceUnitCTE (OrderID) as (
	select OrderID from Sales.OrderLines where UnitPrice in
		(select top(3) UnitPrice from Sales.OrderLines
		group by UnitPrice order by UnitPrice desc)
	)

select 
	(select CityID from Application.Cities where CityID = c.DeliveryCityID) as CityID,
	(select CityName from Application.Cities where CityID = c.DeliveryCityID) as CityName,
	p.FullName
from Sales.Invoices as i 
join Application.People as p on i.PackedByPersonID = p.PersonID
join Sales.Customers as c on i.CustomerID = c.CustomerID
where i.OrderID in (select OrderID from OrdersIDWithHighPriceUnitCTE)


-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

--SELECT 
--	Invoices.InvoiceID, 
--	Invoices.InvoiceDate,
--	(SELECT People.FullName
--		FROM Application.People
--		WHERE People.PersonID = Invoices.SalespersonPersonID
--	) AS SalesPersonName,
--	SalesTotals.TotalSumm AS TotalSummByInvoice, 
--	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
--		FROM Sales.OrderLines
--		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
--			FROM Sales.Orders
--			WHERE Orders.PickingCompletedWhen IS NOT NULL	
--				AND Orders.OrderId = Invoices.OrderId)	
--	) AS TotalSummForPickedItems
--FROM Sales.Invoices 
--	JOIN
--	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
--	FROM Sales.InvoiceLines
--	GROUP BY InvoiceId
--	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
--		ON Invoices.InvoiceID = SalesTotals.InvoiceID
--ORDER BY TotalSumm DESC

-- --

--TODO: напишите здесь свое решение