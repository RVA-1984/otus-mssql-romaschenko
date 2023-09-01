/*
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
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. ��������� �������� ������, ������� � ���������� ������ ���������� 
��������� ������ �� ���������� ������� � ������� �������� � �������.
� ������� ������ ���� ������ (���� ������ ������), � �������� - �������.
�������� ����� � ID 2-6, ��� ��� ������������� Tailspin Toys.
��� ������� ����� �������� ��� ����� �������� ������ ���������.
��������, �������� �������� "Tailspin Toys (Gasport, NY)" - �� �������� ������ "Gasport, NY".
���� ������ ����� ������ dd.mm.yyyy, ��������, 25.12.2019.
������, ��� ������ ��������� ����������:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT| Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2       |     2
01.02.2013   |      7             |        3           |      4      |      2       |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

; with CTE as (
				select 
				 T1.CustomerNameShort
				,left(i.InvoiceDate,7) as InvoiceMonth
				,count (*) as KolProd
				from Sales.Invoices as i
					join (  select
							 customerID
							,substring(CustomerName,16,(len(substring(CustomerName,16,100))-1)) as CustomerNameShort
							from Sales.Customers as c
							where CustomerID between 2 and 6) T1 on T1.CustomerID = i.CustomerID
				group by T1.CustomerNameShort, left(i.InvoiceDate,7))

select InvoiceMonth, [Sylvanite, MT], [Peeples Valley, AZ], [Medicine Lodge, KS], [Gasport, NY], [Jessie, ND] from CTE
PIVOT (sum(KolProd) for CustomerNameShort IN ([Sylvanite, MT], [Peeples Valley, AZ], [Medicine Lodge, KS], [Gasport, NY], [Jessie, ND])) as pt

/*
2. ��� ���� �������� � ������, � ������� ���� "Tailspin Toys"
������� ��� ������, ������� ���� � �������, � ����� �������.
������ ����������:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

SELECT 
unpvt.CustomerName, unpvt.AddressLine
from (select CustomerName, DeliveryAddressLine1, DeliveryAddressLine2
		from Sales.Customers
		where CustomerName like '%Tailspin Toys%') as T1	
UNPIVOT (AddressLine For id IN ([DeliveryAddressLine1], [DeliveryAddressLine2])) as unpvt


/*
3. � ������� ����� (Application.Countries) ���� ���� � �������� ����� ������ � � ���������.
�������� ������� �� ������, �������� � �� ���� ���, 
����� � ���� � ����� ��� ���� �������� ���� ��������� ���.
������ ����������:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/
select
 unpvt.CountryID
,unpvt.CountryName
,unpvt.Code
from (	select CountryID, CountryName, cast(IsoAlpha3Code as char) IsoAlpha3Code, cast(IsoNumericCode as char) IsoNumericCode
		from Application.Countries) as T1
UNPIVOT (Code FOR id in ([IsoAlpha3Code], [IsoNumericCode])) as unpvt

/*
4. �������� �� ������� ������� ��� ����� ������� ������, ������� �� �������.
� ����������� ������ ���� �� ������, ��� ��������, �� ������, ����, ���� �������.
*/

select
 c.CustomerID
,c.CustomerName
,CA.StockItemID
,CA.UnitPrice
,CA.[���� ������� ��� ������� ������]
from Sales.Customers as c
cross apply (select distinct top 2
				 s.CustomerID
				,o.UnitPrice
				,o.StockItemID
				,max(s.OrderDate) OVER (PARTITION BY s.CustomerID, o.UnitPrice, o.StockItemID order by o.UnitPrice desc) as '���� ������� ��� ������� ������'
				from Sales.OrderLines as o
					join Sales.Orders as s on s.OrderID = o.OrderID
				where c.CustomerID = s.CustomerID
				order by 1 asc, 2 desc) CA;