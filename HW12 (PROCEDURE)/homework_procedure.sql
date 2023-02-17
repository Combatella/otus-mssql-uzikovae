-- Написать функцию возвращающую
-- Клиента с набольшей разовой суммой покупки. 
-- Использовать таблицы :
-- Sales.Customers
-- Sales.Invoices
-- Sales.InvoiceLines
GO
CREATE FUNCTION [Application].[GetCustomerWithMaxSumInvoice] ()
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
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN
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

    END;
END;

-- exec [Application].[GetCustomerWithMaxSumInvoice]

-- Написать хранимую функцию с входящим
-- параметром СustomerID, выводящую сумму
-- покупки по этому клиенту.
-- Использовать таблицы :
-- Sales.Customers
-- Sales.Invoices
-- Sales.InvoiceLines
GO
CREATE FUNCTION [Application].[GetAllSumByCostumerID] (@int CustomerID)
RETURNS float(250)
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
AS
BEGIN
	select sum(il.ExtendedPrice)
	from [WideWorldImporters].[Sales].[Customers] as c
	left join [WideWorldImporters].[Sales].[Invoices] as i on i.CustomerID = c.CustomerID
	left join [WideWorldImporters].[Sales].[InvoiceLines] as il on il.InvoiceID = i.InvoiceID
	where c.CustomerID = @CustomerID
END
GO

--exec [Application].[GetAllSumByCostumerID] 836
--exec [Application].[GetAllSumByCostumerID] 908