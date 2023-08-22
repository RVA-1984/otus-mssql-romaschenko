/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.
������� "03 - ����������, CTE, ��������� �������".
������� ����������� � �������������� ���� ������ WideWorldImporters.
����� �� ����� ������� ������:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
����� WideWorldImporters-Full.bak
�������� WideWorldImporters �� Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- ������� - �������� ������� ��� ��������� ��������� ���� ������.
-- ��� ���� �������, ��� ��������, �������� ��� �������� ��������:
--  1) ����� ��������� ������
--  2) ����� WITH (��� ����������� ������)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. �������� ����������� (Application.People), ������� �������� ������������ (IsSalesPerson), 
� �� ������� �� ����� ������� 04 ���� 2015 ����. 
������� �� ���������� � ��� ������ ���. 
������� �������� � ������� Sales.Invoices.
*/

SELECT P.PersonID, P.FullName
FROM [Application].People AS P
	JOIN
	(SELECT SalespersonPersonID, Count(InvoiceId) AS SalesCount
	FROM Sales.Invoices
	WHERE InvoiceDate = '2015-07-04'
	GROUP BY SalespersonPersonID) AS I
		ON P.PersonID = I.SalespersonPersonID

SELECT P.PersonID, P.FullName
FROM [Application].People AS P
where IsSalesPerson = 1 and PersonID not in (select distinct SalespersonPersonID
from Sales.Invoices where InvoiceDate = '2015-07-04'
)

with cte as (select 
P.PersonID, P.FullName
FROM [Application].People AS P
where IsSalesPerson = 1 and PersonID not in (select distinct SalespersonPersonID
from Sales.Invoices where InvoiceDate = '2015-07-04'
))
select * from cte
/*
2. �������� ������ � ����������� ����� (�����������). �������� ��� �������� ����������. 
�������: �� ������, ������������ ������, ����.
*/

SELECT StockItemID, StockItemName, UnitPrice 
FROM Warehouse.StockItems
WHERE UnitPrice <= ALL (
	SELECT UnitPrice 
	FROM Warehouse.StockItems);

SELECT StockItemID, StockItemName, UnitPrice 
FROM Warehouse.StockItems
WHERE UnitPrice = (SELECT min(UnitPrice) FROM Warehouse.StockItems);

/*
3. �������� ���������� �� ��������, ������� �������� �������� ���� ������������ �������� 
�� Sales.CustomerTransactions. 
����������� ��������� �������� (� ��� ����� � CTE). 
*/
SELECT top 5
	p.PersonId, 
	p.FullName, 
	MAX (TransactionAmount) as TransactionAmount
FROM Application.People p
JOIN Sales.CustomerTransactions c ON c.CustomerTransactionID = p.PersonID
GROUP BY p.PersonID, p.FullName
order by TransactionAmount desc

select 
CustomerTransactionID,
CustomerID,
TransactionAmount
from Sales.CustomerTransactions
where CustomerTransactionID in (
select top 5
CustomerTransactionID
from Sales.CustomerTransactions
order by TransactionAmount desc)

/*
4. �������� ������ (�� � ��������), � ������� ���� ���������� ������, 
�������� � ������ ����� ������� �������, � ����� ��� ����������, 
������� ����������� �������� ������� (PackedByPersonID).
*/

select distinct
CityID,
CityName,
FullName
from Application.Cities cities
JOIN Sales.Customers b ON b.DeliveryCityID = cities.CityID
JOIN Sales.Invoices invoice on Invoice.CustomerID = b.CustomerID
JOIN Application.People people ON people.PersonID=invoice.PackedByPersonID
JOIN Sales.Orderlines stock ON stock.OrderID = Invoice.OrderID
JOIN (
select top 3
StockItemID,
SUM (UnitPrice) AS UnitPrice
FROM Warehouse.StockItems
GROUP BY StockItemID
ORDER BY UnitPrice desc) price ON price.StockItemID = stock.StockItemID

--�te � ���������
WITH cte AS (select distinct
CityID,
CityName,
FullName,
StockItemID
from Application.Cities
JOIN Sales.Customers b ON b.DeliveryCityID = cities.CityID
JOIN Sales.Invoices invoice on Invoice.CustomerID = b.CustomerID
JOIN Application.People people ON people.PersonID=invoice.PackedByPersonID
JOIN Sales.Orderlines stock ON stock.OrderID = Invoice.OrderID)
select distinct
CityID,
CityName,
FullName
from cte
WHERE StockItemID in (
select StockItemID
FROM (select top 3 StockItemID, SUM (UnitPrice) AS UnitPrice from Warehouse.StockItems
GROUP BY StockItemID
ORDER BY UnitPrice desc) c)
ORDER BY FullName asc

-- ---------------------------------------------------------------------------
-- ������������ �������
-- ---------------------------------------------------------------------------
-- ����� ��������� ��� � ������� ��������� ������������� �������, 
-- ��� � � ������� ��������� �����\���������. 
-- �������� ������������������ �������� ����� ����� SET STATISTICS IO, TIME ON. 
-- ���� ������� � ������� ��������, �� ����������� �� (����� � ������� ����� ��������� �����). 
-- �������� ���� ����������� �� ������ �����������. 

-- 5. ���������, ��� ������ � ������������� ������

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --
