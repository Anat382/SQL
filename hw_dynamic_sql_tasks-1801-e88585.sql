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
--SET STATISTICS IO, TIME ON

DECLARE @dml AS NVARCHAR(MAX)
DECLARE @ColumnName AS NVARCHAR(MAX)

DROP TABLE IF EXISTS #person

-- продажи по клинетам в разрезе дат
SELECT 
	FORMAT(s.InvoiceDate, 'dd.MM.yyyy') as InvoiceMonth, 
	SUBSTRING( c.CustomerName, CHARINDEX('(',c.CustomerName) + 1 , LEN(c.CustomerName) - CHARINDEX('(',c.CustomerName) - 1 ) as [Client]
INTO #person
FROM Sales.Customers c
LEFT JOIN [Sales].[Invoices] s on s.CustomerID=c.CustomerID 
	WHERE s.InvoiceDate IS NOT NULL

------ Создаю список имен клиентов в переменную @ColumnName
SELECT @ColumnName= ISNULL(@ColumnName + ',','') 
       + QUOTENAME([Client])  --QUOTENAME квадратные скобки
FROM (
	SELECT  DISTINCT [Client]
         FROM #person
) AS Months
ORDER BY [Client]

--- Создаю пивот таблицу
SET @dml = 
  N'  
	;WITH
	PivotTab as (
		SELECT InvoiceMonth, ' + @ColumnName + ' FROM #person   -- Можно не перечислять поля и указать *
		PIVOT(
		COUNT([Client])
			   FOR Client IN (' + @ColumnName + ')
		) AS PVTTable
	)
	SELECT *
	FROM PivotTab
	ORDER BY CAST( SUBSTRING(InvoiceMonth, 7,4) as int),  CAST( SUBSTRING(InvoiceMonth, 4,2) as int), CAST( SUBSTRING(InvoiceMonth, 0,2) as int)

	DROP TABLE IF EXISTS #person
	'
EXEC sp_executesql @dml;





