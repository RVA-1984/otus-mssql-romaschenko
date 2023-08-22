/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

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

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/

declare @dml as nvarchar (max)
declare @columnName as nvarchar (max)

select @columnName = ISNULL (@columnName +',','') + c.CustomerName
from
(select distinct CustomerName
from Sales.Invoices as s
join (select  CustomerID,
CustomerName = '[' + CustomerName + ']'
from Sales.Customers) c on c.CustomerID = s.CustomerID
group by c.CustomerName, left (s.InvoiceDate,7)) c

set @dml = 
N' select YearMonth = format(YFM, ''dd.MM.yyyy'')
, ' + @columnname + ' from (select 
c.CustomerName
,YFM = datefromparts (year(s.InvoiceDate), month (s.InvoiceDate),1)
, s.InvoiceID as CountProduct
from Sales.Invoices as s
join (select CustomerID, CustomerName
from Sales.Customers) c on c.CustomerID = s.CustomerID
group by datefromparts (year(s.InvoiceDate), month (s.InvoiceDate),1), s.InvoiceID, c.CustomerName) as t

PIVOT (count(CountProduct) for CustomerName IN ('+ @columnName +')) as pt
Order by YFM'

Exec sp_executesql @dml






  
   

 
 