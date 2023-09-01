/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/
SELECT 
datepart(YEAR, FinalizationDate)                 as 'Год продажи'
	,datepart(MONTH, FinalizationDate)                as 'Месяц продажи'
	,cast(avg (TransactionAmount) as decimal (10,2))  as 'Средняя цена за месяц по всем товарам'
	,sum (TransactionAmount)                          as 'Общая сумма продаж за месяц'
from Sales.CustomerTransactions
where IsFinalized = 1                  
	and InvoiceID is not null 
	group by datepart(YEAR, FinalizationDate)
	,datepart(MONTH, FinalizationDate)
order by 1,2

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/
SELECT
DATEPART (yy,FinalizationDate) AS 'Год продажи',
DATEPART (mm,FinalizationDate) AS 'Месяц продажи',
SUM(TransactionAmount) AS 'Общая сумма продаж за месяц'
FROM Sales.CustomerTransactions
where IsFinalized = 1
and InvoiceID is not null
GROUP BY datepart(YEAR, FinalizationDate)
	,datepart(MONTH, FinalizationDate)
HAVING SUM(TransactionAmount)>4600000
order by 1,2
/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select
	 datepart(YEAR, ct.FinalizationDate)   as 'Год продажи'
	,datepart(MONTH, ct.FinalizationDate)  as 'Месяц продажи'
	,si.StockItemName                      as 'Наименование товара'
	,sum (ct.TransactionAmount)            as 'Сумма продаж'
	,min (ct.FinalizationDate)             as 'Дата первой продажи'
	,count (il.StockItemID)                as 'Количество проданного'
from Sales.InvoiceLines as il
	join Sales.CustomerTransactions as ct on il.InvoiceID = ct.InvoiceID
	join Warehouse.StockItems as si on il.StockItemID = si.StockItemID
where ct.IsFinalized = 1 
group by 
	 datepart(YEAR, ct.FinalizationDate)
	,datepart(MONTH, ct.FinalizationDate)
	,si.StockItemName
having count (il.StockItemID) < 50
order by 1,2,


-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/
---опционально 2 задание

select
	 datepart(YEAR, FinalizationDate)                        as 'Год продажи'
	,datepart(MONTH, FinalizationDate)                       as 'Месяц продажи'
	,case
		when sum(TransactionAmount) > 4600000 then sum(TransactionAmount)
		else 0
		end                                                  as 'Общая сумма продаж за месяц'
From Sales.CustomerTransactions
where IsFinalized = 1
and InvoiceID is not null
group by
	 datepart(YEAR, FinalizationDate)
	,datepart(MONTH, FinalizationDate)
--having sum (TransactionAmount) > 4600000
order by 1,2

---опционально 3 задание

select
	 BASE.[Год продажи]
	,BASE.[Месяц продажи]
	,BASE.[Наименование товара]
	,isnull(DETAIL.[Сумма продаж],0)  as 'Сумма продаж'
	,isnull(DETAIL.[Дата первой продажи],' ') as 'Дата первой продажи'
	,isnull(DETAIL.[Количество проданного],0) as 'Количество проданного' 
from (select distinct
			 datepart(YEAR, E.FinalizationDate)   as 'Год продажи'
			,datepart(MONTH, E.FinalizationDate)  as 'Месяц продажи'
			,X.StockItemID                        as 'Наименование товара'
			,left(E.FinalizationDate,7) as r
			from Sales.CustomerTransactions as E
				cross apply (select StockItemID from Warehouse.StockItems) X
			where E.FinalizationDate is not null) BASE
left join (select
				 datepart(YEAR, SCT.FinalizationDate)   as 'Год продажи'
				,datepart(MONTH, SCT.FinalizationDate)  as 'Месяц продажи'
				,WSI.StockItemID                      as 'Наименование товара'
				,sum (SCT.TransactionAmount)            as 'Сумма продаж'
				,min (SCT.FinalizationDate)             as 'Дата первой продажи'
				,count (SIL.StockItemID)                as 'Количество проданного'
			from Sales.InvoiceLines as SIL
				join Sales.CustomerTransactions as SCT on SIL.InvoiceID = SCT.InvoiceID
				join Warehouse.StockItems as WSI on SIL.StockItemID = WSI.StockItemID
			where SCT.IsFinalized = 1
			group by 
				 datepart(YEAR, SCT.FinalizationDate)
				,datepart(MONTH, SCT.FinalizationDate)
				,WSI.StockItemID
			having count (SIL.StockItemID) < 50) DETAIL on BASE.[Месяц продажи] = DETAIL.[Месяц продажи] and BASE.[Год продажи] = DETAIL.[Год продажи] and BASE.[Наименование товара] = DETAIL.[Наименование товара]
order by 1,2,3