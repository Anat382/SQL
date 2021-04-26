/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
SET STATISTICS IO, TIME ON
USE WideWorldImporters
/*
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/
SET STATISTICS XML ON
GO
WITH
Sales as (
	SELECT 
		inv.InvoiceID,
		c.CustomerName,
		sinv.InvoiceDate,
		SUM(inv.Quantity * inv.UnitPrice) as [SumSales]
	FROM [Sales].[InvoiceLines] inv
	LEFT JOIN [Sales].[Invoices] sinv on sinv.InvoiceID=inv.InvoiceID
	LEFT JOIN [Sales].[Customers] c on c.CustomerID=sinv.CustomerID
	WHERE sinv.InvoiceDate >= N'20150101'
	GROUP BY 
		inv.InvoiceID,
		c.CustomerName,
		sinv.InvoiceDate
)
SELECT 
	InvoiceID,
	CustomerName,
	InvoiceDate,
	[SumSales],
	( SELECT 
		SUM([SumSales]) 
	  FROM Sales s2 
	  WHERE 
		s2.InvoiceDate<=EOMONTH(s1.InvoiceDate)	
	) as [Sales]
FROM Sales s1
ORDER BY s1.InvoiceDate 

---------------------------- Использоавние оконки --------- 
;WITH
SalesOver as (
	SELECT 
		inv.InvoiceID,
		c.CustomerName,
		sinv.InvoiceDate,
		SUM(inv.Quantity * inv.UnitPrice) as [SumSales]
	FROM [Sales].[InvoiceLines] inv
	LEFT JOIN [Sales].[Invoices] sinv on sinv.InvoiceID=inv.InvoiceID
	LEFT JOIN [Sales].[Customers] c on c.CustomerID=sinv.CustomerID
	WHERE sinv.InvoiceDate >= N'20150101'
	GROUP BY 
		inv.InvoiceID,
		c.CustomerName,
		sinv.InvoiceDate
)

SELECT 
	InvoiceID,
	CustomerName,
	InvoiceDate,
	[SumSales],
	 SUM([SumSales]) OVER(  ORDER BY  YEAR(InvoiceDate), MONTH(InvoiceDate) ) as [Sales]
FROM SalesOver s1
ORDER BY s1.InvoiceDate 


SET STATISTICS XML OFF
GO


--ПРИ ИСПОЛЬЗОВАНИИ ОКОННОЙ ФУНКЦИИ СТОИМОТЬ ЗАПРОСА ПО ПЛАНУ ЗАПРОСА НИЖЕ 
--- Время ЦП = 65031 мс, затраченное время = 80451 мс.

--(затронуто строк: 31440)
--Таблица "InvoiceLines". Число просмотров 888, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 322, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "InvoiceLines". Считано сегментов 444, пропущено 0.
--Таблица "Worktable". Число просмотров 443, логических чтений 168655, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Workfile". Число просмотров 861, логических чтений 87840, физических чтений 9258, упреждающих чтений 78582, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Invoices". Число просмотров 2, логических чтений 22800, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Customers". Число просмотров 444, логических чтений 17760, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

-- Время работы SQL Server:
--   Время ЦП = 65031 мс, затраченное время = 80451 мс.

--(затронуто строк: 31440)
--Таблица "InvoiceLines". Число просмотров 2, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 161, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "InvoiceLines". Считано сегментов 1, пропущено 0.
--Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Invoices". Число просмотров 1, логических чтений 11400, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Customers". Число просмотров 1, логических чтений 40, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

-- Время работы SQL Server:
--   Время ЦП = 438 мс, затраченное время = 1023 мс.





/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

--------------------------- Дополнительные решения -----------

------ При данном решении c окнной функцией и времянной таблицей запрос отрабатывает быстрее в сравнении с CTE 



DROP TABLE IF EXISTS #Sales
SELECT 
	inv.InvoiceID,
	c.CustomerName,
	sinv.InvoiceDate,
	SUM(inv.Quantity * inv.UnitPrice) as [SumSales]
INTO #Sales
FROM [Sales].[InvoiceLines] inv
LEFT JOIN [Sales].[Invoices] sinv on sinv.InvoiceID=inv.InvoiceID
LEFT JOIN [Sales].[Customers] c on c.CustomerID=sinv.CustomerID
WHERE sinv.InvoiceDate >= N'20150101'
GROUP BY 
	inv.InvoiceID,
	c.CustomerName,
	sinv.InvoiceDate

SELECT 
	InvoiceID,
	CustomerName,
	InvoiceDate,
	[SumSales],
	( SELECT 
		SUM([SumSales]) 
	  FROM #Sales s2 
	  WHERE 
		s2.InvoiceDate<=EOMONTH(s1.InvoiceDate)	
	) as [Sales]
FROM #Sales s1
ORDER BY s1.InvoiceDate 


SELECT 
	InvoiceID,
	CustomerName,
	InvoiceDate,
	[SumSales],
	 SUM([SumSales]) OVER(  ORDER BY YEAR(InvoiceDate), MONTH(InvoiceDate) ) as [Sales]
FROM #Sales s1
ORDER BY s1.InvoiceDate 
DROP TABLE IF EXISTS #Sales


-- Время работы SQL Server:
--   Время ЦП = 0 мс, затраченное время = 1 мс.
--Таблица "InvoiceLines". Число просмотров 2, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 161, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "InvoiceLines". Считано сегментов 1, пропущено 0.
--Таблица "Invoices". Число просмотров 1, логических чтений 11400, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Customers". Число просмотров 1, логических чтений 40, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

-- Время работы SQL Server:
--   Время ЦП = 78 мс, затраченное время = 82 мс.

--(затронуто строк: 31440)
--Время синтаксического анализа и компиляции SQL Server: 
-- время ЦП = 26 мс, истекшее время = 26 мс.

--(затронуто строк: 31440)
--Таблица "#Sales______________________________________________________________________________________________________________000000000009". Число просмотров 50, логических чтений 648, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Worktable". Число просмотров 443, логических чтений 118117, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

-- Время работы SQL Server:
--   Время ЦП = 4028 мс, затраченное время = 666 мс.
--Время синтаксического анализа и компиляции SQL Server: 
-- время ЦП = 0 мс, истекшее время = 1 мс.

--(затронуто строк: 31440)
--Таблица "Worktable". Число просмотров 18, логических чтений 75151, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "#Sales______________________________________________________________________________________________________________000000000009". Число просмотров 1, логических чтений 324, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

-- Время работы SQL Server:
--   Время ЦП = 234 мс, затраченное время = 721 мс.


/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

WITH
Sales as (
	SELECT 
		InvoiceDate, 
		Description, 
		COUNT(*) as [Qty]
	FROM [Sales].[InvoiceLines] inv
	JOIN [Sales].[Invoices] sinv on sinv.InvoiceID=inv.InvoiceID  
		AND YEAR(InvoiceDate) = 2016
	GROUP BY InvoiceDate, Description 
)
SELECT DISTINCT
	s1.InvoiceDate,
	 SalesTop2.Description, 
	 SalesTop2.[Qty]
FROM Sales s1 
CROSS APPLY(
	SELECT TOP 2 
		Description,
		[Qty]
	FROM Sales s2
	WHERE s2.InvoiceDate=s1.InvoiceDate
	ORDER BY s2.InvoiceDate, s2.[Qty] DESC
) as SalesTop2
ORDER BY s1.InvoiceDate, SalesTop2.[Qty] DESC

--SELECT TOP 100 * FROM [Sales].[InvoiceLines] inv
--SELECT TOP 100 * FROM [Sales].[Invoices] sinv



/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

SELECT 
	st.StockItemID,
	st.StockItemName,
	st.Brand,
	st.UnitPrice
	,ROW_NUMBER() OVER ( ORDER BY st.StockItemName )
	,COUNT(*) OVER()
	,COUNT(*) OVER ( ORDER BY LEFT(st.StockItemName, 1) )
	,LEAD(st.StockItemID) OVER ( ORDER BY st.StockItemName )
	,LAG(st.StockItemID) OVER ( ORDER BY st.StockItemName )
	,IIF( st.StockItemName = FIRST_VALUE( st.StockItemName ) OVER ( ORDER BY  st.StockItemName  ROWS 2 PRECEDING), 'No items' , FIRST_VALUE( st.StockItemName ) OVER ( ORDER BY  st.StockItemName  ROWS 2 PRECEDING) ),
	NTILE(30) OVER( ORDER BY TypicalWeightPerUnit ) as [NTILE30]
FROM [Warehouse].[StockItems] st
ORDER BY  [NTILE30]

--SELECT TOP 100 * FROM [Warehouse].[StockItems]

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

WITH
Sales as (
	SELECT  
		sinv.SalespersonPersonID,
		p.FullName,
		sinv.CustomerID,
		c.CustomerName,
		sinv.InvoiceDate,
		SUM(inv.Quantity * inv.UnitPrice ) as [SumSales]
	FROM [Sales].[InvoiceLines] inv
	LEFT JOIN [Sales].[Invoices] sinv on sinv.InvoiceID=inv.InvoiceID  
	LEFT JOIN [Application].[People] p on p.PersonID=sinv.SalespersonPersonID
	LEFT JOIN  [Sales].[Customers] c on c.CustomerID=sinv.CustomerID
	GROUP BY
		sinv.SalespersonPersonID,
		p.FullName,
		sinv.CustomerID,
		c.CustomerName,
		sinv.InvoiceDate
)
,res as (
	SELECT 
		s1.SalespersonPersonID,
		s1.FullName,
		s1.CustomerID,
		s1.CustomerName,
		s1.InvoiceDate,
		s1.[SumSales],
		ROW_NUMBER() OVER( PARTITION BY s1.SalespersonPersonID ORDER BY s1.InvoiceDate desc, s1.[SumSales] desc )  as [ROW_NUMBER]
	FROM Sales s1
)
SELECT 
	SalespersonPersonID,
	FullName,
	CustomerID,
	CustomerName,
	InvoiceDate,
	[SumSales]
FROM res
WHERE [ROW_NUMBER] = 1
ORDER BY  InvoiceDate desc, [SumSales] desc


--SELECT TOP 100 * FROM [Sales].[InvoiceLines] inv
--SELECT TOP 100 * FROM [Sales].[Invoices] sinv
--SELECT TOP 100 * FROM [Sales].[Customers]
--SELECT TOP 100 * FROM [Application].[People]


/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/
--Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 
SET STATISTICS IO, TIME ON

SELECT 
	c.CustomerID, 
	c.CustomerName, 
	inv.StockItemID,
	--inv.Description,
	inv.UnitPrice, 
	inv.[MaxInvoiceDate]
FROM Sales.Customers c
CROSS APPLY(
	SELECT TOP 2 
		s.CustomerID,
		il.StockItemID,
		il.Description,
		il.UnitPrice,
		MAX(s.InvoiceDate) AS [MaxInvoiceDate]
	FROM [Sales].[InvoiceLines] il
	LEFT JOIN  [Sales].[Invoices] s on s.InvoiceID=il.InvoiceID
	WHERE s.CustomerID=c.CustomerID
	GROUP BY
		s.CustomerID,
		il.StockItemID,
		il.Description,
		il.UnitPrice
	ORDER BY 
		il.UnitPrice desc
) as inv
ORDER BY CustomerID, UnitPrice DESC, inv.[MaxInvoiceDate] DESC

----

;WITH
TopProd as (
	SELECT 
		s.CustomerID,
		c.CustomerName,
		il.StockItemID,
		il.UnitPrice,
		MAX(s.InvoiceDate) AS [MaxInvoiceDate]
	FROM [Sales].[InvoiceLines] il
	LEFT JOIN  [Sales].[Invoices] s on s.InvoiceID=il.InvoiceID
	LEFT JOIN Sales.Customers c on c.CustomerID=s.CustomerID
	GROUP BY
		s.CustomerID,
		c.CustomerName,
		il.StockItemID,
		il.UnitPrice
	--ORDER BY s.CustomerID, il.UnitPrice DESC
)
,Res as (
	SELECT 
		CustomerID,
		CustomerName,
		StockItemID,
		UnitPrice,
		[MaxInvoiceDate],
		ROW_NUMBER() OVER( PARTITION BY CustomerID ORDER BY UnitPrice DESC) as [N]
	FROM  TopProd
)
SELECT 
	CustomerID,
	CustomerName,
	StockItemID,
	UnitPrice,
	[MaxInvoiceDate]
FROM Res
WHERE [N] <= 2
ORDER BY CustomerID, UnitPrice DESC



----- Запрос с оконной функией выгоднее 
-- По плану запроса 
--- Без оконки стоимость 88%
--- С оконкой стоимость 12%

---- что также подтверждает статистика 

--Время синтаксического анализа и компиляции SQL Server: 
-- время ЦП = 43 мс, истекшее время = 43 мс.

--(затронуто строк: 1326)
--Таблица "Worktable". Число просмотров 663, логических чтений 149286, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "InvoiceLines". Число просмотров 70510, логических чтений 849439, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Invoices". Число просмотров 1, логических чтений 11400, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Customers". Число просмотров 1, логических чтений 40, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

-- Время работы SQL Server:
--   Время ЦП = 1172 мс, затраченное время = 1238 мс.

--(затронуто строк: 1326)
--Таблица "InvoiceLines". Число просмотров 2, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 161, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "InvoiceLines". Считано сегментов 1, пропущено 0.
--Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Invoices". Число просмотров 1, логических чтений 11400, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Customers". Число просмотров 1, логических чтений 40, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

-- Время работы SQL Server:
--   Время ЦП = 406 мс, затраченное время = 458 мс.


------------------- Дополнительные расчеты для примера по просьбе преподоавтеля -------------------

;WITH
SalesOver as (
	SELECT 
		YEAR(inv.InvoiceID) as [YEAR],
		MONTH(inv.InvoiceID) as [MONTH],
		c.CustomerName,
		SUM(inv.Quantity * inv.UnitPrice) as [SumSales]
	FROM [Sales].[InvoiceLines] inv
	LEFT JOIN [Sales].[Invoices] sinv on sinv.InvoiceID=inv.InvoiceID
	LEFT JOIN [Sales].[Customers] c on c.CustomerID=sinv.CustomerID
	WHERE sinv.InvoiceDate >= N'20150101'
	GROUP BY 
		YEAR(inv.InvoiceID),
		MONTH(inv.InvoiceID),
		c.CustomerName
)

SELECT 
	[YEAR],
	[MONTH],
	CustomerName,
	[SumSales],
	 CUME_DIST () OVER (PARTITION BY [YEAR], [MONTH] ORDER BY [SumSales]) AS CumeDist, --  распределение выборки аналогична PERCENT_RANK за исключением что вес присваивается начиная с первого входного значения  по данному показателю можно фильтровать выборку задавая границу
     PERCENT_RANK() OVER (PARTITION BY [YEAR], [MONTH] ORDER BY [SumSales] ) AS PctRank,  --- распределение выборки  по квантилям (перцентили если перевести в проценты) по данному показателю можно фильтровать выборку задавая границу
     PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY [SumSales])   
                            OVER (PARTITION BY [YEAR], [MONTH]) AS MedianCont, -- завышает медиану
     PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY [SumSales])   
                            OVER (PARTITION BY [YEAR], [MONTH]) AS MedianDisc, -- фактическая медиана 
	 PERCENTILE_DISC(0.9) WITHIN GROUP (ORDER BY [SumSales])   
                            OVER (PARTITION BY [YEAR], [MONTH]) AS [Procentile0.9], -- процентель 0,9 содержится в PERCENT_RANK 
	 AVG([SumSales]) OVER (PARTITION BY  [YEAR], [MONTH] ) AS AvgSalesMonth,
	 STDEV([SumSales]) OVER (PARTITION BY  [YEAR], [MONTH] ) AS StdDeviation,
	 AVG([SumSales]) OVER (PARTITION BY  [YEAR], [MONTH] ) / STDEV([SumSales]) OVER (PARTITION BY  [YEAR], [MONTH] ) as [CoefVariation],  -- вариабельность выборки, более 0,3 высокая
	 ABS([SumSales]  - AVG([SumSales]) OVER (PARTITION BY  [YEAR], [MONTH] ) ) as [Отклонение],
	 IIF( ABS([SumSales]  - AVG([SumSales]) OVER (PARTITION BY  [YEAR], [MONTH] ) ) <  STDEV([SumSales]) OVER (PARTITION BY  [YEAR], [MONTH] ) * 2.5 ,   [SumSales], 0) as [SumSalesLess0.83]  -- Исключаем выбросы

FROM SalesOver s1
ORDER BY s1.[YEAR], [MONTH], CumeDist



