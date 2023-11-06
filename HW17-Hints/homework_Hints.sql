--���������� ��� ���� ���������� ������ ��� ����������� �������� �������.
--������� 1.
--�� ������ ����� ������ �� ����� ������ � ������ � ��������, ��� ���� �� �����������, ����� ������� �� ���������, � ��� ����� �����.
--� ���� ������ ����� ��������� ����� �������, ���������� ���� � ���������� �� ������� � ��������� �����\������ �� ����������� � ����� �����������.
--������� ������ ��� ����������� ��� �����������.


select * from dbo.loan_portfolio as lp
select * from dbo.client as cl

--������ �� �����������:
SET STATISTICS io, time on;

SELECT lp.id_agreement, lp.id_client, lp.client_name, SUM(lp.amount_agreement) AS clientwhichgetcredit, cl.id_client AS clientfrombase
FROM dbo.loan_portfolio as lp
JOIN dbo.client as cl
ON lp.id_client = cl.id_client
WHERE cl.id_client = 111
GROUP BY lp.id_agreement, lp.id_client, lp.client_name,cl.id_client


--������������ ��������� ������ �� �������: id_client = 111

SET STATISTICS io, time on;

DECLARE @id_client INT = 111;

SELECT lp.id_agreement, lp.id_client, lp.client_name, SUM(lp.amount_agreement) AS clientwhichgetcredit, cl.id_client AS clientfrombase
FROM dbo.loan_portfolio as lp
JOIN dbo.client as cl
ON lp.id_client = cl.id_client
WHERE cl.id_client = @id_client 
GROUP BY lp.id_agreement, lp.id_client, lp.client_name,cl.id_client

OPTION (OPTIMIZE FOR (@id_client = 111), MAXDOP 1);

--����� ���������� �� ����������� �������:
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 49 ms.

(��������� ���� ������)
Table 'loan_portfolio'. Scan count 1, logical reads 2, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'client'. Scan count 0, logical reads 2, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.

--����� ���������� ����� ����������� �������:

SQL Server parse and compile time: 
   CPU time = 4 ms, elapsed time = 4 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.

(��������� ���� ������)
Table 'loan_portfolio'. Scan count 1, logical reads 2, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'client'. Scan count 0, logical reads 2, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.

--��������:
--� ���������� ������ ����� ����������� ��������� �������, ��� ������ �� �����������.

--������� 2.
--������������� ������ �� �� WorldWideImporters.
--��������� ����� ������� �� ������������ �� ������� � ��������� ����� ������, ������� ������ ��� ����������� ��� �����������.

SET STATISTICS io, time on;

Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)
FROM Sales.Orders AS ord
JOIN Sales.OrderLines AS det
ON det.OrderID = ord.OrderID
JOIN Sales.Invoices AS Inv
ON Inv.OrderID = ord.OrderID
JOIN Sales.CustomerTransactions AS Trans
ON Trans.InvoiceID = Inv.InvoiceID
JOIN Warehouse.StockItemTransactions AS ItemTrans
ON ItemTrans.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
AND (Select SupplierId
FROM Warehouse.StockItems AS It
Where It.StockItemID = det.StockItemID) = 12
AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
FROM Sales.OrderLines AS Total
Join Sales.Orders AS ordTotal
On ordTotal.OrderID = Total.OrderID
WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID

--���������������� ������
SET STATISTICS io, time on;

DECLARE @StockItemID INT = 12;

Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)
FROM Sales.Orders AS ord
JOIN Sales.OrderLines AS det
ON det.OrderID = ord.OrderID
JOIN Sales.Invoices AS Inv
ON Inv.OrderID = ord.OrderID
JOIN Sales.CustomerTransactions AS Trans
ON Trans.InvoiceID = Inv.InvoiceID
JOIN Warehouse.StockItemTransactions AS ItemTrans
ON ItemTrans.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
AND (Select SupplierId
FROM Warehouse.StockItems AS It
Where It.StockItemID = @StockItemID) = 12
AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
FROM Sales.OrderLines AS Total
Join Sales.Orders AS ordTotal
On ordTotal.OrderID = Total.OrderID
WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID

OPTION (OPTIMIZE FOR (@StockItemID = 12), MAXDOP 1);

--����� ���������� �� ����������� �������:
SQL Server parse and compile time: 
   CPU time = 110 ms, elapsed time = 131 ms.

(��������� �����: 3619)
Table 'StockItemTransactions'. Scan count 1, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 29, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'StockItemTransactions'. Segment reads 1, segment skipped 0.
Table 'OrderLines'. Scan count 4, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 331, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'OrderLines'. Segment reads 2, segment skipped 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'CustomerTransactions'. Scan count 5, logical reads 261, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Orders'. Scan count 2, logical reads 883, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Invoices'. Scan count 1, logical reads 44525, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'StockItems'. Scan count 1, logical reads 2, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 562 ms,  elapsed time = 657 ms.

--����� ���������� ����� ����������� �������:

SQL Server parse and compile time: 
   CPU time = 250 ms, elapsed time = 254 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.

(��������� �����: 52235)
Table 'StockItemTransactions'. Scan count 1, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 29, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'StockItemTransactions'. Segment reads 1, segment skipped 0.
Table 'OrderLines'. Scan count 4, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 331, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'OrderLines'. Segment reads 2, segment skipped 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Orders'. Scan count 2, logical reads 883, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'CustomerTransactions'. Scan count 5, logical reads 261, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Invoices'. Scan count 1, logical reads 11400, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'StockItems'. Scan count 0, logical reads 2, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 10250 ms,  elapsed time = 10898 ms.

--��������:
--� �������� ����������� �� ������ ���� �������: StockItemID=12. � ���������� ������ �� ����������� ��������� �������, ��� ������ ����� �����������.
