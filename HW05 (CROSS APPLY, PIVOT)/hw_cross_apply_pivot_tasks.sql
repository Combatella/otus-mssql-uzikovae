/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

select 
	(select format(cast(concat('01.', [Month], '.', [Year]) as date), 'dd.MM.yyyy' )) as InvoiceMonth,
	isnull([Jessie, ND], 0) as [Jessie, ND],
	isnull([Medicine Lodge, KS], 0) as [Medicine Lodge, KS],
	isnull([Peeples Valley, AZ],  0) as [Peeples Valley, AZ],
	isnull([Sylvanite, MT], 0) as [Sylvanite, MT]
from 
(
	select distinct 
		month(i.InvoiceDate) as [Month],
		year(i.InvoiceDate) as [Year],
		replace(replace(c.CustomerName, left(c.CustomerName, charindex('(', c.CustomerName)), ''), ')', '') as CustomerName,		
		sum((
			select count(*) from Sales.InvoiceLines as il 
			where i.InvoiceID = il.InvoiceID
			)) 
		over(
			partition by year(i.InvoiceDate), month(i.InvoiceDate), CustomerName
		) as InvoiceCount		
	from Sales.Invoices as i
		join Sales.Customers as c on i.CustomerID = c.CustomerID
	where i.CustomerID between 2 and 6
) as Invoices
pivot (
	sum(InvoiceCount)
	for CustomerName in ([Gasport, NY], [Jessie, ND], [Medicine Lodge, KS], [Peeples Valley, AZ],  [Sylvanite, MT])
) as pvt_i

/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

select CustomerName, Adress
from (
	select 
		c.CustomerName,
		c.DeliveryAddressLine1, 
		c.DeliveryAddressLine2, 
		c.PostalAddressLine1, 
		c.PostalAddressLine2
	from Sales.Customers as c
	where c.CustomerName like 'Tailspin Toys%'
) as TailspinToysAdressLines
unpivot (
	Adress for name in (
	DeliveryAddressLine1,
	DeliveryAddressLine2,
	PostalAddressLine1,
	PostalAddressLine2
	) 
) as u
order by CustomerName

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

select CountryID, CountryName, Code
from (
	
	select 
		c.CountryID,
		c.CountryName,
		convert(nvarchar, c.IsoAlpha3Code) as IsoAlpha3Code,
		convert(nvarchar, c.IsoNumericCode) as IsoNumericCode
	from Application.Countries as c
	
) as CountryCodes
unpivot (
	Code for [Name] in (
	IsoAlpha3Code
	,
	IsoNumericCode
	) 
) as u
order by CountryName

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

select 
c.CustomerID,
c.CustomerName,
oa.StockItemID,
oa.UnitPrice,
oa.InvoiceDate
from Sales.Customers as c
outer apply(
	select top(2) * from (
		select 
		il.StockItemID, 
		il.UnitPrice,
		i.InvoiceDate,
		ROW_NUMBER() over(partition by il.UnitPrice order by il.UnitPrice desc) as rn
		from Sales.Invoices as i
		join Sales.InvoiceLines as il on i.InvoiceID = il.InvoiceID
		where i.CustomerID = c.CustomerID
	) as unit where unit.rn = 1
	order by unit.UnitPrice desc
 ) as oa
 order by c.CustomerName

