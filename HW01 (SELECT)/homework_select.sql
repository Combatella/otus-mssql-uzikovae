/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".
Задания выполняются с использованием базы данных WideWorldImporters.
Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak
Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

select si.StockItemID, si.StockItemName from Warehouse.StockItems as si
where si.StockItemName like '%urgent%' or si.StockItemName like 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

select s.SupplierID, s.SupplierName from Purchasing.Suppliers as s
left join Purchasing.PurchaseOrders as po on s.SupplierID = po.SupplierID 
where po.PurchaseOrderID is null


/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.
Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).
Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

SET LANGUAGE Russian;
select 
	o.OrderID, 
	format(o.OrderDate, 'dd.MM.yyyy') as OrderDate, 
	datename(month, o.OrderDate) as NameMonth, 
	datename(quarter, o.OrderDate) as Quartal,
	ceiling(cast(month(o.OrderDate) as decimal(3,1)) / 12 * 3) as Trimester,	
	--iif(month(o.OrderDate) > 8, 3, iif(month(o.OrderDate) > 4, 2, 1)) as Trimester, -- вариант с тернарным оператором
	c.CustomerName 
from Sales.Orders as o
join Sales.OrderLines as ol on o.OrderID = ol.OrderID
join Sales.Customers as c on o.CustomerID = c.CustomerID
where (ol.UnitPrice > 100 or ol.Quantity > 20) and ol.PickingCompletedWhen is not null
--where ol.UnitPrice > 100 or (ol.Quantity > 20 and ol.PickingCompletedWhen is not null) --возможно разночтение условия задачи
order by Quartal, Trimester, OrderDate 
--offset 1000 rows fetch next 100 rows only -- вариант для постраничной выборки

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

select dm.DeliveryMethodName, po.ExpectedDeliveryDate, s.SupplierName, p.FullName from Purchasing.PurchaseOrders as po
left join Purchasing.Suppliers as s on s.SupplierID = po.SupplierID
left join Application.DeliveryMethods as dm on dm.DeliveryMethodID = po.DeliveryMethodID
left join Application.People as p on p.PersonID = po.ContactPersonID
where (month(po.ExpectedDeliveryDate) = 1 and YEAR(po.ExpectedDeliveryDate) = 2013)
and (dm.DeliveryMethodName = 'Refrigerated Air Freight' or dm.DeliveryMethodName = 'Air Freight')
and po.IsOrderFinalized = 1

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

select top(10) o.*, c.CustomerName as CustomerName, leb.FullName as SalespersonName from sales.Orders as o 
left join Sales.Customers as c on c.CustomerID = o.CustomerID
left join Application.People as leb on leb.PersonID = o.SalespersonPersonID
order by OrderDate desc

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

select distinct o.CustomerID, c.CustomerName, c.PhoneNumber from sales.OrderLines as ol
left join sales.Orders as o on o.OrderID = ol.OrderID
left join Warehouse.StockItems as si on si.StockItemID = ol.StockItemID
left join Sales.Customers as c on c.CustomerID = o.CustomerID
where si.StockItemName = 'Chocolate frogs 250g'
