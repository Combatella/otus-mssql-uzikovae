-- при различных вариантах не удалось улучшить план, в основном получалось только изменять время ЦП 
Select 
	ord.CustomerID, 
	det.StockItemID, 
	SUM(det.UnitPrice), 
	SUM(det.Quantity), 
	COUNT(ord.OrderID)
FROM Sales.Orders AS ord
JOIN Sales.OrderLines AS det ON det.OrderID = ord.OrderID
JOIN Sales.Invoices AS Inv ON Inv.OrderID = ord.OrderID
JOIN Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = Inv.InvoiceID
JOIN Warehouse.StockItemTransactions AS ItemTrans ON ItemTrans.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
AND (
	Select 
		SupplierId
	FROM Warehouse.StockItems AS It
	Where It.StockItemID = det.StockItemID) = 12
	AND (
		SELECT 
			SUM(Total.UnitPrice*Total.Quantity)
		FROM Sales.OrderLines AS Total
		Join Sales.Orders AS ordTotal On ordTotal.OrderID = Total.OrderID
		WHERE ordTotal.CustomerID = Inv.CustomerID
		) > 250000
	AND 
		DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID
--(затронуто строк: 3619)
--Таблица "StockItemTransactions". Число просмотров 1, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 29, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "StockItemTransactions". Считано сегментов 1, пропущено 0.
--Таблица "OrderLines". Число просмотров 4, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 331, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "OrderLines". Считано сегментов 2, пропущено 0.
--Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "CustomerTransactions". Число просмотров 5, логических чтений 261, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Orders". Число просмотров 2, логических чтений 822, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Invoices". Число просмотров 1, логических чтений 44525, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "StockItems". Число просмотров 1, логических чтений 2, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

-- Время работы SQL Server:
--   Время ЦП = 406 мс, затраченное время = 521 мс.


-- можно ограничить индексы
Select 
	Inv.BillToCustomerID, 
	ord.CustomerID, 
	det.StockItemID, 
	SUM(det.UnitPrice), 
	SUM(det.Quantity), 
	COUNT(ord.OrderID)
FROM Sales.Orders AS ord
JOIN Sales.OrderLines AS det  ON det.OrderID = ord.OrderID 
JOIN Sales.Invoices AS Inv ON Inv.OrderID = ord.OrderID
JOIN Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = Inv.InvoiceID
JOIN Warehouse.StockItemTransactions AS ItemTrans ON ItemTrans.StockItemID = det.StockItemID
join Warehouse.StockItems as si on si.StockItemID = det.StockItemID
WHERE 
	(Inv.BillToCustomerID = 1 or Inv.BillToCustomerID = 401) 
	and ord.CustomerID != 1 
	and ord.CustomerID != 401
	and si.SupplierID = 12
	AND (
		SELECT SUM(Total.UnitPrice*Total.Quantity) FROM Sales.OrderLines AS Total
		Join Sales.Orders AS ordTotal On ordTotal.OrderID = Total.OrderID
		WHERE ordTotal.CustomerID = Inv.CustomerID
		) > 250000
	AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY Inv.BillToCustomerID, ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID
--(затронуто строк: 3619)
--Таблица "StockItemTransactions". Число просмотров 1, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 29, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "StockItemTransactions". Считано сегментов 1, пропущено 0.
--Таблица "OrderLines". Число просмотров 4, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 331, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "OrderLines". Считано сегментов 2, пропущено 0.
--Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "CustomerTransactions". Число просмотров 5, логических чтений 261, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Orders". Число просмотров 2, логических чтений 822, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Invoices". Число просмотров 2, логических чтений 136318, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "StockItems". Число просмотров 1, логических чтений 2, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

-- Время работы SQL Server:
--   Время ЦП = 297 мс, затраченное время = 377 мс.

SELECT 
	ord.CustomerID,
	det.StockItemID,
	SUM(det.UnitPrice),
	SUM(det.Quantity),
	COUNT(ord.OrderID)
FROM Sales.Orders AS ord WITH (FORCESEEK)
INNER JOIN Sales.OrderLines AS det ON det.OrderID = ord.OrderID
INNER JOIN Sales.Invoices AS Inv WITH (INDEX (0))
ON Inv.BillToCustomerID != ord.CustomerID
	AND DATEDIFF (dd , Inv.InvoiceDate , ord.OrderDate) = 0
	AND Inv.OrderID = ord.OrderID
INNER JOIN Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = Inv.InvoiceID
INNER JOIN Warehouse.StockItemTransactions AS ItemTrans ON ItemTrans.StockItemID = det.StockItemID
WHERE (
	SELECT SupplierId FROM Warehouse.StockItems AS It
    Where It.StockItemID = det.StockItemID
	) = 12
AND (
	SELECT SUM(Total.UnitPrice * Total.Quantity)
	FROM Sales.OrderLines AS Total, Sales.Orders AS ordTotal
	WHERE ordTotal.CustomerID = Inv.CustomerID AND ordTotal.OrderID = Total.OrderID
	) > 250000
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID
--Время ЦП чутка лучше

SELECT 
	ord.CustomerID, 
	det.StockItemID, 
	SUM(det.UnitPrice), 
	SUM(det.Quantity), 
	COUNT(ord.OrderID) 
FROM Sales.Orders AS ord 
JOIN Sales.OrderLines AS det ON det.OrderID = ord.OrderID 
JOIN Sales.Invoices AS Inv ON Inv.BillToCustomerID != ord.CustomerID
	AND DATEDIFF (dd , Inv.InvoiceDate , ord.OrderDate) = 0 
	AND Inv.OrderID = ord.OrderID 
JOIN Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = Inv.InvoiceID 
JOIN Warehouse.StockItemTransactions AS ItemTrans ON ItemTrans.StockItemID = det.StockItemID 
WHERE (
	SELECT SupplierId FROM Warehouse.StockItems AS It Where It.StockItemID = det.StockItemID
	) = 12 
AND (
	SELECT SUM(Total.UnitPrice * Total.Quantity) FROM Sales.OrderLines AS Total, Sales.Orders AS ordTotal 
	WHERE ordTotal.CustomerID = Inv.CustomerID AND ordTotal.OrderID = Total.OrderID
	) > 250000 
GROUP BY ord.CustomerID, det.StockItemID 
ORDER BY ord.CustomerID, det.StockItemID 
OPTION (FORCE ORDER, MAXDOP 1)