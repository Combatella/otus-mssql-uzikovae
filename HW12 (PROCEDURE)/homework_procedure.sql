-- Написать хранимую процедуру возвращающую
-- Клиента с набольшей разовой суммой покупки. 
-- Использовать таблицы :
-- Sales.Customers
-- Sales.Invoices
-- Sales.InvoiceLines
USE [WideWorldImporters]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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

-- Написать хранимую процедуру с входящим
-- параметром СustomerID, выводящую сумму
-- покупки по этому клиенту.
-- Использовать таблицы :
-- Sales.Customers
-- Sales.Invoices
-- Sales.InvoiceLines

USE [WideWorldImporters]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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