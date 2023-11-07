/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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

USE WideWorldImporters;

/*
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/
--вариант OPENXML
Declare @xmlfile XML

Select @xmlfile = bulkcolumn
from openrowset (bulk 'C:\Users\user\Desktop\otus_mssql_2023\HW07-xml_json\StockItems.xml', single_clob) as data

DECLARE @docHandle INT
EXEC sp_xml_preparedocument @docHandle OUTPUT,  @xmlfile

-- вставка результата во временную таблицу 
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

	--копируем таблицу Warehouse.StockItems, чтоб в нее вставить/обновить записи.
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


--Вставляем/обновляем записи
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


-- вариант XQuery

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
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
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
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

select 
StockItemID,
StockItemName,
CustomFields,
JSON_VALUE (CustomFields,'$.CountryOfManufacture') as CountryOfManufacture,
JSON_VALUE (CustomFields,'$.Tags[0]') as FirstTag
FROM Warehouse.StockItems


/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/

select 
StockItemID,
StockItemName
FROM Warehouse.StockItems
CROSS APPLY OPENJSON (CustomFields, '$.Tags') 
WHERE VALUE = 'Vintage';


