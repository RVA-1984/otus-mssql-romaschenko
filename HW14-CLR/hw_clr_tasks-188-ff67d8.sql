/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "13 - CLR".
*/

Варианты ДЗ (сделать любой один):

1) Взять готовую dll, подключить ее и продемонстрировать использование. 
Например, https://sqlsharp.com

-- Включаем CLR
EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO

EXEC sp_configure 'clr enabled', 1;
EXEC sp_configure 'clr strict security', 0;
GO

RECONFIGURE;
GO

ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON; 

-- Подключаем dll 
CREATE ASSEMBLY sbscmp1
FROM 'C:\Windows\Microsoft.NET\Framework64\sbscmp10.dll'
WITH PERMISSION_SET = SAFE

2) Взять готовые исходники из какой-нибудь статьи, скомпилировать, подключить dll, продемонстрировать использование.
Например, 
https://www.sqlservercentral.com/articles/xlsexport-a-clr-procedure-to-export-proc-results-to-excel

https://www.mssqltips.com/sqlservertip/1344/clr-string-sort-function-in-sql-server/

https://habr.com/ru/post/88396/

3) Написать полностью свое (что-то одно):
* Тип: JSON с валидацией, IP / MAC - адреса, ...
* Функция: работа с JSON, ...
* Агрегат: аналог STRING_AGG, ...
* (любой ваш вариант)

Результат ДЗ:
* исходники (если они есть), желательно проект Visual Studio
* откомпилированная сборка dll
* скрипт подключения dll
* демонстрация использования

SELECT * FROM sys.dm_clr_properties