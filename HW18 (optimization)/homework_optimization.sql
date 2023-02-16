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
-- Показатели до оптимизации
-- (затронуто строк: 3619)
-- (затронуто строк: 33)
-- (затронута одна строка)
-- Время выполнения: 2023-02-14T21:38:22.8717711+05:00

--Время выполнения клиента	21:43:29		21:43:19		21:38:22		
--Статистика по профилю запроса							
--  Количество инструкций INSERT, DELETE и UPDATE	0		0		0		0.0000
--  Строки, изменяемые инструкциями INSERT, DELETE и UPDATE	0		0		0		0.0000
--  Количество инструкций SELECT 	5		5		4		4.6667
--  Строк, возвращенных инструкциями SELECT	3655		3655		3654		3654.6670
--  Количество транзакций 	0		0		0		0.0000
--Сетевая статистика							
--  Количество циклов обращения к серверу	5		5		4		4.6667
--  TDS-пакетов отправлено клиентом	5		5		4		4.6667
--  TDS-пакетов получено с сервера	69		69		68		68.6667
--  байтов отправлено клиентом	2204		2204		2146		2184.6670
--  байтов получено с сервера	264836		264834		264808		264826.0000
--Статистика по времени							
--  Время обработки клиента	16		70		95		60.3333
--  Общее время выполнения	456		527		541		508.0000
--  Время ожидания при ответе сервера	440		457		446		447.6667