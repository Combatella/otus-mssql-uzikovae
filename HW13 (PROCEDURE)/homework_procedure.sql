-- Написать функцию возвращающую
-- Клиента с набольшей разовой суммой покупки. 
-- Использовать таблицы :
-- Sales.Customers
-- Sales.Invoices
-- Sales.InvoiceLines
GO
CREATE FUNCTION [Application].[FnGetCustomerWithMaxSumInvoice]()
RETURNS VARCHAR(250)
WITH EXECUTE AS CALLER
AS BEGIN
    DECLARE @name VARCHAR(250)
    
		select @name = [CustomerName] from (
			select top(1) 
			il.InvoiceID,
			sum(il.ExtendedPrice) over(partition by il.InvoiceID) summa,
			i.CustomerID,
			c.CustomerName
			from [WideWorldImporters].[Sales].[InvoiceLines] as il
			left join [WideWorldImporters].[Sales].[Invoices] as i on il.InvoiceID=i.InvoiceID
			left join [WideWorldImporters].[Sales].[Customers] as c on i.CustomerID = c.CustomerID
			order by summa desc
		) q1

    RETURN @name
END

-- Написать хранимую процедуру возвращающую
-- Клиента с набольшей разовой суммой покупки. 
-- Использовать таблицы :
-- Sales.Customers
-- Sales.Invoices
-- Sales.InvoiceLines
GO
CREATE PROCEDURE [Application].[GetCustomerWithMaxSumInvoice]
WITH EXECUTE AS CALLER
AS
BEGIN
    SET NOCOUNT ON

		select [CustomerName] from (
			select top(1) 
			il.InvoiceID,
			sum(il.ExtendedPrice) over(partition by il.InvoiceID) summa,
			i.CustomerID,
			c.CustomerName
			from [WideWorldImporters].[Sales].[InvoiceLines] as il
			left join [WideWorldImporters].[Sales].[Invoices] as i on il.InvoiceID=i.InvoiceID
			left join [WideWorldImporters].[Sales].[Customers] as c on i.CustomerID = c.CustomerID
			order by summa desc
		) q1
END

-- Написать хранимую функцию с входящим
-- параметром СustomerID, выводящую сумму
-- покупки по этому клиенту.
-- Использовать таблицы :
-- Sales.Customers
-- Sales.Invoices
-- Sales.InvoiceLines
GO
CREATE FUNCTION [Application].[FnGetAllSumByCostumerID] (@CustomerID int)
RETURNS float(53)
WITH EXECUTE AS CALLER
AS BEGIN
    DECLARE @sum float
    
	select @sum = sum(il.ExtendedPrice)
	from [WideWorldImporters].[Sales].[Customers] as c
	left join [WideWorldImporters].[Sales].[Invoices] as i on i.CustomerID = c.CustomerID
	left join [WideWorldImporters].[Sales].[InvoiceLines] as il on il.InvoiceID = i.InvoiceID
	where c.CustomerID = @CustomerID

    RETURN @sum
END

-- Написать хранимую процедуру с входящим
-- параметром СustomerID, выводящую сумму
-- покупки по этому клиенту.
-- Использовать таблицы :
-- Sales.Customers
-- Sales.Invoices
-- Sales.InvoiceLines
GO
CREATE PROCEDURE [Application].[GetAllSumByCostumerID]
	@CustomerID int
WITH EXECUTE AS CALLER
AS
BEGIN
	select sum(il.ExtendedPrice)
	from [WideWorldImporters].[Sales].[Customers] as c
	left join [WideWorldImporters].[Sales].[Invoices] as i on i.CustomerID = c.CustomerID
	left join [WideWorldImporters].[Sales].[InvoiceLines] as il on il.InvoiceID = i.InvoiceID
	where c.CustomerID = @CustomerID
END
GO

set statistics time on
select [Application].[FnGetCustomerWithMaxSumInvoice]() 
--Время синтаксического анализа и компиляции SQL Server: 
-- время ЦП = 0 мс, истекшее время = 0 мс.
--(затронута одна строка)
-- Время работы SQL Server:
--   Время ЦП = 94 мс, затраченное время = 86 мс.
--Время выполнения: 2023-02-17T19:34:04.2153636+05:00

exec [Application].[GetCustomerWithMaxSumInvoice]
--Время синтаксического анализа и компиляции SQL Server: 
-- время ЦП = 0 мс, истекшее время = 0 мс.
--Время синтаксического анализа и компиляции SQL Server: 
-- время ЦП = 0 мс, истекшее время = 0 мс.
-- Время работы SQL Server:
--   Время ЦП = 0 мс, затраченное время = 0 мс.
-- Время работы SQL Server:
--   Время ЦП = 78 мс, затраченное время = 78 мс.
-- Время работы SQL Server:
--   Время ЦП = 78 мс, затраченное время = 78 мс.
--Время выполнения: 2023-02-17T19:34:28.6358095+05:00

select [Application].[FnGetAllSumByCostumerID](836) as Sum
--Время синтаксического анализа и компиляции SQL Server: 
-- время ЦП = 0 мс, истекшее время = 0 мс.
--(затронута одна строка)
-- Время работы SQL Server:
--   Время ЦП = 16 мс, затраченное время = 26 мс.
--Время выполнения: 2023-02-17T19:37:11.6888183+05:00

exec [Application].[GetAllSumByCostumerID] 836
--Время синтаксического анализа и компиляции SQL Server: 
-- время ЦП = 0 мс, истекшее время = 0 мс.
--Время синтаксического анализа и компиляции SQL Server: 
-- время ЦП = 0 мс, истекшее время = 0 мс.
--(затронута одна строка)
-- Время работы SQL Server:
--   Время ЦП = 31 мс, затраченное время = 30 мс.
-- Время работы SQL Server:
--   Время ЦП = 31 мс, затраченное время = 30 мс.
--Время выполнения: 2023-02-17T19:37:35.2609817+05:00



-- Заказы (с датой комплектации) с ценой товара более @overprice $ 
GO
CREATE FUNCTION [Application].[GetOrdersOverprice] (@overprice int)  
RETURNS TABLE  
AS  
RETURN   
(  
    select 
	o.OrderID, 
	format(o.OrderDate, 'dd.MM.yyyy') as OrderDate, 
	datename(month, o.OrderDate) as NameMonth, 
	datename(quarter, o.OrderDate) as Quartal,
	ceiling(cast(month(o.OrderDate) as decimal(3,1)) / 12 * 3) as Trimester,	
	c.CustomerName 
	from Sales.Orders as o
	join Sales.OrderLines as ol on o.OrderID = ol.OrderID
	join Sales.Customers as c on o.CustomerID = c.CustomerID
	where ol.UnitPrice > @overprice and ol.PickingCompletedWhen is not null
)
GO

-- обработка каждой строки с помощью курсора
DECLARE mycursor CURSOR
FOR SELECT OrderDate, CustomerName FROM [Application].[GetOrdersOverprice] (100)
OPEN mycursor

declare @counter int
declare @date DateTime2
declare @name varchar(100)
set @counter = 0

fetch next from mycursor INTO  @date, @name

while @@FETCH_STATUS = 0
begin
	set @counter = @counter + 1
	print @counter
	print @date
	print @name
fetch next from mycursor INTO  @date, @name
end
close mycursor
deallocate mycursor
