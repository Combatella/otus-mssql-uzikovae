/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

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

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/

-- данное решение нужно переписать для всех клиентов с использованием динамического запроса
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
