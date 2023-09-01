/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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

USE WideWorldImporters

/*
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

    INSERT INTO Sales.Customers
           (CustomerName
           ,BillToCustomerID
           ,CustomerCategoryID
           ,BuyingGroupID
           ,PrimaryContactPersonID
           ,AlternateContactPersonID
           ,DeliveryMethodID
           ,DeliveryCityID
           ,PostalCityID
           ,CreditLimit
           ,AccountOpenedDate
           ,StandardDiscountPercentage
           ,IsStatementSent
           ,IsOnCreditHold
           ,PaymentDays
           ,PhoneNumber
           ,FaxNumber
           ,DeliveryRun
           ,RunPosition
           ,WebsiteURL
           ,DeliveryAddressLine1
           ,DeliveryAddressLine2
           ,DeliveryPostalCode
           ,DeliveryLocation
           ,PostalAddressLine1
           ,PostalAddressLine2
           ,PostalPostalCode
           ,LastEditedBy)
select top (5) 
			CustomerName = CustomerName + ' New'
           ,BillToCustomerID
           ,CustomerCategoryID
           ,BuyingGroupID
           ,PrimaryContactPersonID
           ,AlternateContactPersonID
           ,DeliveryMethodID
           ,DeliveryCityID
           ,PostalCityID
           ,CreditLimit
           ,AccountOpenedDate
           ,StandardDiscountPercentage
           ,IsStatementSent
           ,IsOnCreditHold
           ,PaymentDays
           ,PhoneNumber
           ,FaxNumber
           ,DeliveryRun
           ,RunPosition
           ,WebsiteURL
           ,DeliveryAddressLine1
           ,DeliveryAddressLine2
           ,DeliveryPostalCode
           ,DeliveryLocation
           ,PostalAddressLine1
           ,PostalAddressLine2
           ,PostalPostalCode
           ,LastEditedBy
from Sales.Customers
order by CustomerID desc

	
/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

DELETE TOP (1) FROM Sales.Customers
WHERE CustomerName like '% New';



/*
3. Изменить одну запись, из добавленных через UPDATE
*/

UPDATE Sales.Customers
SET BillToCustomerID = CustomerID
WHERE CustomerID in (	select max(CustomerID)
						from Sales.Customers
						where CustomerName like '% New' );


/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/
--Создание клона таблицы Sales.Customers
DROP TABLE IF exists Sales.CustomersClone
SELECT * INTO Sales.CustomersClone from Sales.Customers

MERGE Sales.Customers		AS T
	USING Sales.CustomersClone	AS S 
	ON (T.CustomerID = S.CustomerID)
	WHEN MATCHED and S.CustomerName like '% New'
	THEN UPDATE SET 
							T.BillToCustomerID = S.CustomerID
	WHEN NOT MATCHED THEN INSERT (
							  CustomerID
							 ,CustomerName
							 ,BillToCustomerID
							 ,CustomerCategoryID
							 ,BuyingGroupID
							 ,PrimaryContactPersonID
							 ,AlternateContactPersonID
							 ,DeliveryMethodID
							 ,DeliveryCityID
							 ,PostalCityID
							 ,CreditLimit
							 ,AccountOpenedDate
							 ,StandardDiscountPercentage
							 ,IsStatementSent
							 ,IsOnCreditHold
							 ,PaymentDays
							 ,PhoneNumber
							 ,FaxNumber
							 ,DeliveryRun
							 ,RunPosition
							 ,WebsiteURL
							 ,DeliveryAddressLine1
							 ,DeliveryAddressLine2
							 ,DeliveryPostalCode
							 ,DeliveryLocation
							 ,PostalAddressLine1
							 ,PostalAddressLine2
							 ,PostalPostalCode
							 ,LastEditedBy
							  )

	VALUES(
							  CustomerID
							 ,S.CustomerName
							 ,S.BillToCustomerID
							 ,S.CustomerCategoryID
							 ,S.BuyingGroupID
							 ,S.PrimaryContactPersonID
							 ,S.AlternateContactPersonID
							 ,S.DeliveryMethodID
							 ,S.DeliveryCityID
							 ,S.PostalCityID
							 ,S.CreditLimit
							 ,S.AccountOpenedDate
							 ,S.StandardDiscountPercentage
							 ,S.IsStatementSent
							 ,S.IsOnCreditHold
							 ,S.PaymentDays
							 ,S.PhoneNumber
							 ,S.FaxNumber
							 ,S.DeliveryRun
							 ,S.RunPosition
							 ,S.WebsiteURL
							 ,S.DeliveryAddressLine1
							 ,S.DeliveryAddressLine2
							 ,S.DeliveryPostalCode
							 ,S.DeliveryLocation
							 ,S.PostalAddressLine1
							 ,S.PostalAddressLine2
							 ,S.PostalPostalCode
							 ,S.LastEditedBy
							 --,S.ValidFrom
							 --,S.ValidTo
							 )
	OUTPUT $action, inserted.*; 
/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

EXEC sp_configure 'show advanced options', 1;
GO 
reconfigure;
GO 
EXEC sp_configure 'xp_cmdshell', 1;
GO 
reconfigure;
GO 

SELECT @@SERVERNAME  --LAPTOP-CQGRG71V\User

exec master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.InvoiceLines" out   "C:\Users\user\Desktop\otus_mssql_2023\HW08-insert,Update,Merge\hw_dml_tasks.txt" -T -w -t"Ckfdbr1984!" -S LAPTOP-CQGRG71V\User'

drop table if exists Sales.InvoiceLinesHW08
CREATE TABLE [Sales].[InvoiceLinesHW08](
	[InvoiceLineID] [int] NOT NULL,
	[InvoiceID] [int] NOT NULL,
	[StockItemID] [int] NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
	[PackageTypeID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[TaxAmount] [decimal](18, 2) NOT NULL,
	[LineProfit] [decimal](18, 2) NOT NULL,
	[ExtendedPrice] [decimal](18, 2) NOT NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Sales_InvoiceLinesHW08] PRIMARY KEY CLUSTERED 
(
	[InvoiceLineID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [USERDATA]
) ON [USERDATA]
GO

BULK INSERT Sales.InvoiceLinesHW08
FROM "C:\Users\user\Desktop\otus_mssql_2023\HW08-insert,Update,Merge\hw_dml_tasks.txt"
WITH (
	BATCHSIZE = 1000,
	DATAFILETYPE = 'widechar',
	FIELDTERMINATOR = 'Ckfdbr1984!',
	ROWTERMINATOR = '\n',
	KEEPNULLS,
	TABLOCK);