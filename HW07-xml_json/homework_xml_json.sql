/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.

������� "08 - ������� �� XML � JSON �����".

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

USE WideWorldImporters;

/*
���������� � �������� 1, 2:
* ���� � ��������� � ���� ����� ��������, �� ����� ������� ������ SELECT c ����������� � ���� XML. 
* ���� � ��� � ������� ������������ �������/������ � XML, �� ������ ����� ���� XML � ���� �������.
* ���� � ���� XML ��� ����� ������, �� ������ ����� ����� �������� ������ � ������������� �� � ������� (��������, � https://data.gov.ru).
* ������ ��������/������� � ���� https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. � ������ �������� ���� ���� StockItems.xml.
��� ������ �� ������� Warehouse.StockItems.
������������� ��� ������ � ������� ������� � ������, ������������ Warehouse.StockItems.
����: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

��������� ��� ������ � ������� Warehouse.StockItems: 
������������ ������ � ������� ��������, ������������� �������� (������������ ������ �� ���� StockItemName). 

������� ��� ��������: � ������� OPENXML � ����� XQuery.
*/
--������� OPENXML
Declare @xmlfile XML

Select @xmlfile = bulkcolumn
from openrowset (bulk 'C:\Users\user\Desktop\otus_mssql_2023\HW07-xml_json\StockItems.xml', single_clob) as data

DECLARE @docHandle INT
EXEC sp_xml_preparedocument @docHandle OUTPUT,  @xmlfile

-- ������� ���������� �� ��������� ������� 
	DROP TABLE IF EXISTS #StockItems;

CREATE TABLE #StockItems (
	[StockItemName] NVARCHAR (200),
	[SupplierID] INT,
	[UnitPackageID] INT,
	[OuterPackageID] INT,
	[QuantityPerOuter] INT,
	[TypicalWeightPerUnit] DECIMAL(9,2),
	[LeadTimeDays] INT,
	[IsChillerStock] BIT,
	[TaxRate] DECIMAL(9,2),
	[UnitPrice] DECIMAL(9,2),
	[LastEditedBy] INT
);

INSERT INTO #StockItems
SELECT *
FROM OPENXML(@docHandle, N'/StockItems/Item')
WITH ( 
	[StockItemName] NVARCHAR (200) '@Name',
	[SupplierID] INT 'SupplierID',
	[UnitPackageID] INT 'Package/UnitPackageID',
	[OuterPackageID] INT 'Package/OuterPackageID',
	[QuantityPerOuter] INT 'Package/QuantityPerOuter',
	[TypicalWeightPerUnit] DECIMAL(9,2) 'Package/TypicalWeightPerUnit',
	[LeadTimeDays] INT 'LeadTimeDays',
	[IsChillerStock] BIT 'IsChillerStock',
	[TaxRate] DECIMAL(9,2) 'TaxRate',
	[UnitPrice] DECIMAL(9,2) 'UnitPrice',
	[LastEditedBy] INT 'LastEditedBy');

	--�������� ������� Warehouse.StockItems, ���� � ��� ��������/�������� ������.
	drop table if exists ##WSI
	select
		StockItemName,
		SupplierID,
		UnitPackageID,
		OuterPackageID,
		QuantityPerOuter,
		TypicalWeightPerUnit,
		LeadTimeDays,
		IsChillerStock,
		TaxRate,
		UnitPrice
		LastEditedBy
	into ##WSI
	from Warehouse.StockItems


--���������/��������� ������
	MERGE ##WSI AS WSI
	USING ##StockItems AS SI
	ON (WSI.StockItemName = SI.StockItemName COLLATE database_default)
	WHEN MATCHED THEN UPDATE SET 
							WSI.SupplierID				=SI.SupplierID,
							WSI.UnitPackageID			=SI.UnitPackageID,
							WSI.OuterPackageID			=SI.OuterPackageID,
							WSI.QuantityPerOuter		=SI.QuantityPerOuter,	
							WSI.TypicalWeightPerUnit	=SI.TypicalWeightPerUnit,	
							WSI.LeadTimeDays			=SI.LeadTimeDays,	
							WSI.IsChillerStock			=SI.IsChillerStock,
							WSI.TaxRate					=SI.TaxRate,
							WSI.LastEditedBy            =SI.LastEditedBy
		
	WHEN NOT MATCHED THEN INSERT VALUES(
							SI.StockItemName,
							SI.SupplierID,
							SI.UnitPackageID,
							SI.OuterPackageID,
							SI.QuantityPerOuter,
							SI.TypicalWeightPerUnit,
							SI.LeadTimeDays,
							SI.IsChillerStock,
							SI.TaxRate,
							SI.UnitPrice,
							SI.LastEditedBy)
	OUTPUT $action, inserted.*;


-- ������� XQuery

Declare @xml XML;
Set @xml = (select * from openrowset (bulk 'C:\Users\user\Desktop\otus_mssql_2023\HW07-xml_json\StockItems.xml', single_clob) as d)

select 
	t.Item.value('(@Name)[1]', 'nvarchar(200)')							as StockItemName,
	t.Item.value('(SupplierID)[1]',	'int')								as SupplierID,
	t.Item.value('(Package/UnitPackageID)[1]', 'int')					as UnitPackageID,
	t.Item.value('(Package/OuterPackageID)[1]',	'int')					as OuterPackageID,
	t.Item.value('(Package/QuantityPerOuter)[1]', 'int')				as QuantityPerOuter,
	t.Item.value('(Package/TypicalWeightPerUnit)[1]', 'decimal(9,2)')	as TypicalWeightPerUnit,
	t.Item.value('(LeadTimeDays)[1]', 'int')							as LeadTimeDays,
	t.Item.value('(IsChillerStock)[1]', 'int')							as IsChillerStock,
	t.Item.value('(TaxRate)[1]', 'decimal(9,2)')						as TaxRate,
	t.Item.value('(UnitPrice)[1]', 'decimal(9,2)')						as UnitPrice,
	t.Item.value('(LastEditedBy)[1]', 'int')                            as LastEditedBy
from @xml.nodes('/StockItems/Item') as t(Item);

/*
2. ��������� ������ �� ������� StockItems � ����� �� xml-����, ��� StockItems.xml
*/

SELECT  
[StockItemName]			as [@Name]							,
[SupplierID]			as [SupplierID]						,
[UnitPackageID]			as [Package/UnitPackageID]			,
[OuterPackageID]		as [Package/OuterPackageID]			,
[QuantityPerOuter]		as [Package/QuantityPerOuter]		,
[TypicalWeightPerUnit]	as [Package/TypicalWeightPerUnit]	,
[LeadTimeDays]			as [LeadTimeDays]					,
[IsChillerStock]		as [IsChillerStock]					,
[TaxRate]				as [TaxRate]						,
[UnitPrice]				as [UnitPrice]	
FROM Warehouse.StockItems
FOR XML PATH ('ItemName'), ROOT ('StockItems');	

/*
3. � ������� Warehouse.StockItems � ������� CustomFields ���� ������ � JSON.
�������� SELECT ��� ������:
- StockItemID
- StockItemName
- CountryOfManufacture (�� CustomFields)
- FirstTag (�� ���� CustomFields, ������ �������� �� ������� Tags)
*/

select 
StockItemID,
StockItemName,
CustomFields,
JSON_VALUE (CustomFields,'$.CountryOfManufacture') as CountryOfManufacture,
JSON_VALUE (CustomFields,'$.Tags[0]') as FirstTag
FROM Warehouse.StockItems


/*
4. ����� � StockItems ������, ��� ���� ��� "Vintage".
�������: 
- StockItemID
- StockItemName
- (�����������) ��� ���� (�� CustomFields) ����� ������� � ����� ����

���� ������ � ���� CustomFields, � �� � Tags.
������ �������� ����� ������� ������ � JSON.
��� ������ ������������ ���������, ������������ LIKE ���������.

������ ���� � ����� ����:
... where ... = 'Vintage'

��� ������� �� �����:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/

select 
StockItemID,
StockItemName
FROM Warehouse.StockItems
CROSS APPLY OPENJSON (CustomFields, '$.Tags') 
WHERE VALUE = 'Vintage';


