﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DateTimeService.Data
{
    public class Queries
    {
        public const string IntervalList = @"Select
	IsNull(_Reference114_VT23370._Fld23372RRef,Геозона._Fld23104RRef) As СкладСсылка,
	ЗоныДоставки._ParentIDRRef As ЗонаДоставкиРодительСсылка,
	ЗоныДоставкиРодитель._Description AS ЗонаДоставкиРодительНаименование,
	Геозона._IDRRef As Геозона
Into #Temp_GeoData
From dbo._Reference114 Геозона With (NOLOCK)
	Inner Join _Reference114_VT23370 With (NOLOCK)
	on _Reference114_VT23370._Reference114_IDRRef = Геозона._IDRRef
	Inner Join _Reference99 ЗоныДоставки With (NOLOCK)
	on Геозона._Fld2847RRef = ЗоныДоставки._IDRRef
	Inner Join _Reference99 ЗоныДоставкиРодитель With (NOLOCK)
	on ЗоныДоставки._ParentIDRRef = ЗоныДоставкиРодитель._IDRRef
where Геозона._IDRRef IN (
	Select Top 1 --по адресу находим геозону
	ГеоАдрес._Fld2785RRef 
	From dbo._Reference112 ГеоАдрес With (NOLOCK)
	Where ГеоАдрес._Fld25155 = @P4)

CREATE CLUSTERED INDEX ix_tempCIndexAft ON #Temp_GeoData(СкладСсылка,ЗонаДоставкиРодительСсылка,Геозона asc);

/*Создание таблицы товаров и ее наполнение данными из БД*/
Create Table #Temp_GoodsBegin 
(	
	code nvarchar(20), 
    quantity int
)

INSERT INTO 
	#Temp_GoodsBegin ( 
		code, quantity
	)
VALUES
	{0}
	;

Select 
	Номенклатура._IDRRef AS НоменклатураСсылка,
	Упаковки._IDRRef AS УпаковкаСсылка,
	Sum(#Temp_GoodsBegin.quantity) As Количество	
INTO #Temp_Goods
From 
	#Temp_GoodsBegin 
	Inner Join 	dbo._Reference149 Номенклатура With (NOLOCK) ON #Temp_GoodsBegin.code = Номенклатура._Fld3480
	Inner Join dbo._Reference256 Упаковки With (NOLOCK)
		On 
		Упаковки._OwnerID_TYPE = 0x08  
		AND Упаковки.[_OwnerID_RTRef] = 0x00000095
		AND Номенклатура._IDRRef = Упаковки._OwnerID_RRRef		
		And Упаковки._Fld6003RRef = Номенклатура._Fld3489RRef
		AND Упаковки._Marked = 0x00
Group By 
	Номенклатура._IDRRef,
	Упаковки._IDRRef

;
/*Конец товаров*/

/*Размеры корзины в целом для расчета габаритов*/
SELECT
CAST(SUM((T2._Fld6000 * T1.Количество)) AS NUMERIC(36, 6)) AS Вес,
CAST(SUM((T2._Fld6006 * T1.Количество)) AS NUMERIC(38, 8)) AS Объем,
MAX(T2._Fld6001) AS Высота,
MAX(T2._Fld6002) AS Глубина,
MAX(T2._Fld6009) AS Ширина,
0x00000000000000000000000000000000  AS Габарит
Into #Temp_Size
FROM #Temp_Goods T1 WITH(NOLOCK)
INNER JOIN dbo._Reference256 T2 With (NOLOCK) 
ON (T2._IDRRef = T1.УпаковкаСсылка) AND (T1.УпаковкаСсылка <> 0x00000000000000000000000000000000)

/*Габарит корзины общий*/
SELECT
    TOP 1 CASE
        WHEN (
            ISNULL(
                T1.Габарит,
                0x00000000000000000000000000000000
            ) <> 0x00000000000000000000000000000000
        ) THEN T1.Габарит
        WHEN (T4._Fld21339 > 0)
        AND (T1.Вес >= T4._Fld21339)
        AND (T5._Fld21337 > 0)
        AND (T1.Объем >= T5._Fld21337) THEN 0xAD3F7F5FC4F15DAD4F693CAF8365EC0D --хбт в кбт
        WHEN (T2._Fld21168 > 0)
        AND (T1.Вес >= T2._Fld21168) THEN 0xAD3F7F5FC4F15DAD4F693CAF8365EC0D --кбт
        WHEN (T3._Fld21166 > 0)
        AND (T1.Объем >= T3._Fld21166) THEN 0xAD3F7F5FC4F15DAD4F693CAF8365EC0D --кбт
        WHEN (T6._Fld21580 > 0)
        AND (T1.Высота > 0)
        AND (T1.Глубина > 0)
        AND (T1.Ширина >0) THEN CASE
            WHEN (T1.Высота >= T6._Fld21580) OR (T1.Глубина >= T6._Fld21580) OR (T1.Ширина >= T6._Fld21580) THEN 0xAD3F7F5FC4F15DAD4F693CAF8365EC0D --кбт
            ELSE 0x8AB421D483ABE88A4C4C9928262FFB0D --мбт
        END
        ELSE 0x8AB421D483ABE88A4C4C9928262FFB0D --мбт
    END AS Габарит
Into #Temp_Dimensions
FROM
    #Temp_Size T1 WITH(NOLOCK)
    INNER JOIN dbo._Const21167 T2 ON 1 = 1
    INNER JOIN dbo._Const21165 T3 ON 1 = 1
    INNER JOIN dbo._Const21338 T4 ON 1 = 1
    INNER JOIN dbo._Const21336 T5 ON 1 = 1
    INNER JOIN dbo._Const21579 T6 ON 1 = 1

SELECT
    COUNT_BIG(T1.НоменклатураСсылка) AS КоличествоСтрок,
    T1.НоменклатураСсылка AS НоменклатураСсылка,
    T2._Fld6000 * T1.Количество AS Вес,
    T2._Fld6006 * T1.Количество AS Объем,
    CASE
        WHEN (
            (T2._Fld6006 > 0.8)
            OR (T2._Fld6002 > 1.85)
            OR (T2._Fld6001 > 1.85)
            OR (T2._Fld6009 > 1.85)
        )
        AND (T2._Fld6000 < 120.0)
        AND (T2._Fld6000 >= 50.0) THEN (T3.Fld24101_ * @P_Floor)
        WHEN (
            (T2._Fld6006 > 0.8)
            OR (T2._Fld6002 > 1.85)
            OR (T2._Fld6001 > 1.85)
            OR (T2._Fld6009 > 1.85)
        )
        AND (T2._Fld6000 >= 120.0) THEN (T3.Fld24102_ * @P_Floor)
        WHEN (
            (T2._Fld6006 > 0.8)
            OR (T2._Fld6002 > 1.85)
            OR (T2._Fld6001 > 1.85)
            OR (T2._Fld6009 > 1.85)
        )
        AND (T2._Fld6000 < 5.0) THEN (T3.Fld26615_ * @P_Floor)
        WHEN (
            (T2._Fld6006 > 0.8)
            OR (T2._Fld6002 > 1.85)
            OR (T2._Fld6001 > 1.85)
            OR (T2._Fld6009 > 1.85)
        )
        AND (T2._Fld6000 >= 5.0)
        AND (T2._Fld6000 < 50.0) THEN (T3.Fld26616_ * @P_Floor)
        ELSE 0.0
    END  AS УсловиеЭтажМассаПоТоварам
Into #Temp_Weight
FROM
    #Temp_Goods T1 WITH(NOLOCK)
    LEFT OUTER JOIN dbo._Reference256 T2 With (NOLOCK) ON (
        0x08 = T2._OwnerID_TYPE
        AND 0x00000095 = T2._OwnerID_RTRef
        AND T1.УпаковкаСсылка = T2._IDRRef
    )
    INNER JOIN (
        SELECT
            T6._Fld24101 AS Fld24101_,
            T6._Fld24102 AS Fld24102_,
            T6._Fld26615 AS Fld26615_,
            T6._Fld26616 AS Fld26616_
        FROM
            (
                SELECT
                    MAX(T5._Period) AS MAXPERIOD_
                FROM
                    dbo._InfoRg24088 T5
            ) T4
            INNER JOIN dbo._InfoRg24088 T6 ON T4.MAXPERIOD_ = T6._Period
    ) T3 ON 1 = 1
GROUP BY
    T1.НоменклатураСсылка,
    T2._Fld6000 * T1.Количество,
    T2._Fld6006 * T1.Количество,
    CASE
        WHEN (
            (T2._Fld6006 > 0.8)
            OR (T2._Fld6002 > 1.85)
            OR (T2._Fld6001 > 1.85)
            OR (T2._Fld6009 > 1.85)
        )
        AND (T2._Fld6000 < 120.0)
        AND (T2._Fld6000 >= 50.0) THEN (T3.Fld24101_ * @P_Floor)
        WHEN (
            (T2._Fld6006 > 0.8)
            OR (T2._Fld6002 > 1.85)
            OR (T2._Fld6001 > 1.85)
            OR (T2._Fld6009 > 1.85)
        )
        AND (T2._Fld6000 >= 120.0) THEN (T3.Fld24102_ * @P_Floor)
        WHEN (
            (T2._Fld6006 > 0.8)
            OR (T2._Fld6002 > 1.85)
            OR (T2._Fld6001 > 1.85)
            OR (T2._Fld6009 > 1.85)
        )
        AND (T2._Fld6000 < 5.0) THEN (T3.Fld26615_ * @P_Floor)
        WHEN (
            (T2._Fld6006 > 0.8)
            OR (T2._Fld6002 > 1.85)
            OR (T2._Fld6001 > 1.85)
            OR (T2._Fld6009 > 1.85)
        )
        AND (T2._Fld6000 >= 5.0)
        AND (T2._Fld6000 < 50.0) THEN (T3.Fld26616_ * @P_Floor)
        ELSE 0.0
    END
;

SELECT Distinct
    CASE
        WHEN (IsNull(T2.Габарит,0x8AB421D483ABE88A4C4C9928262FFB0D) = 0x8AB421D483ABE88A4C4C9928262FFB0D) THEN 7 --мбт
        ELSE 14
    END AS УсловиеГабариты,
    CASE
        WHEN (@P_Credit = 1) --кредит рассрочка
            THEN T3.Fld24103_
        ELSE 0
    END AS УсловиеСпособОплаты,
    CASE
        WHEN (T1.ЗонаДоставкиРодительНаименование LIKE '%Минск%') --наименование зоны доставки
        AND (IsNull(T2.Габарит,0x8AB421D483ABE88A4C4C9928262FFB0D) = 0x8AB421D483ABE88A4C4C9928262FFB0D) THEN T3.Fld24091_ --мбт
        WHEN (T1.ЗонаДоставкиРодительНаименование LIKE '%Минск%')
        AND (IsNull(T2.Габарит,0x8AB421D483ABE88A4C4C9928262FFB0D) = 0xAD3F7F5FC4F15DAD4F693CAF8365EC0D) THEN T3.Fld24092_ --кбт
        ELSE 0
    END AS УсловиеМинскЧас
Into #Temp_TimeByOrders
FROM
    #Temp_GeoData T1 WITH(NOLOCK)
	Left Join #Temp_Dimensions T2 On 1=1
    INNER JOIN (
        SELECT
            T5._Fld24103 AS Fld24103_,
            T5._Fld24091 AS Fld24091_,
            T5._Fld24092 AS Fld24092_
        FROM
            (
                SELECT
                    MAX(T4._Period) AS MAXPERIOD_
                FROM
                    dbo._InfoRg24088 T4
            ) T3
            INNER JOIN dbo._InfoRg24088 T5 ON T3.MAXPERIOD_ = T5._Period
    ) T3 ON 1 = 1
;

SELECT
    T2.Fld24090_ * SUM(T1.КоличествоСтрок) AS УсловиеКоличествоСтрок,
    CASE
        WHEN SUM(T1.Объем) < 0.8
			AND SUM(T1.Вес) < 5.0 THEN T2.Fld24094_
        WHEN SUM(T1.Объем) < 0.8
			AND SUM(T1.Вес) >= 5.0
			AND SUM(T1.Вес) < 20.0 THEN T2.Fld24095_
        WHEN SUM(T1.Объем) < 0.8
			AND SUM(T1.Вес) >= 20.0
			AND SUM(T1.Вес) < 65.0 THEN T2.Fld24096_
        WHEN SUM(T1.Объем) < 0.8
			AND SUM(T1.Вес) >= 65.0
			AND SUM(T1.Вес) < 120.0 THEN T2.Fld24097_
        WHEN SUM(T1.Объем) < 0.8
			AND SUM(T1.Вес) >= 120.0
			AND SUM(T1.Вес) < 250.0 THEN T2.Fld24098_
        WHEN SUM(T1.Объем) < 0.8
			AND SUM(T1.Вес) >= 250.0
			AND SUM(T1.Вес) < 400.0 THEN T2.Fld26611_
        WHEN SUM(T1.Объем) < 0.8
			AND SUM(T1.Вес) >= 400.0 THEN T2.Fld26612_
        WHEN SUM(T1.Объем) >= 0.8
			AND SUM(T1.Вес) < 120.0 THEN T2.Fld24099_
        WHEN SUM(T1.Объем) >= 0.8
			AND SUM(T1.Вес) >= 120.0
			AND SUM(T1.Вес) < 250.0 THEN T2.Fld24100_
        WHEN SUM(T1.Объем) >= 0.8
			AND SUM(T1.Вес) >= 250.0
			AND SUM(T1.Вес) < 600.0 THEN T2.Fld26613_
        WHEN SUM(T1.Объем) >= 0.8
			AND SUM(T1.Вес) >= 600.0 THEN T2.Fld26614_
    END As УсловиеВесОбъем,
    T2.Fld24089_ As МинимальноеВремя,
    SUM(T1.УсловиеЭтажМассаПоТоварам) As УсловиеЭтажМассаОбщ
INTO #Temp_Time1
FROM
    #Temp_Weight T1 WITH(NOLOCK)
    INNER JOIN (
        SELECT
            T5._Fld24090 AS Fld24090_,
            T5._Fld24094 AS Fld24094_,
            T5._Fld24095 AS Fld24095_,
            T5._Fld24096 AS Fld24096_,
            T5._Fld24097 AS Fld24097_,
            T5._Fld24098 AS Fld24098_,
            T5._Fld26611 AS Fld26611_,
            T5._Fld26612 AS Fld26612_,
            T5._Fld24099 AS Fld24099_,
            T5._Fld24100 AS Fld24100_,
            T5._Fld26613 AS Fld26613_,
            T5._Fld26614 AS Fld26614_,
            T5._Fld24089 AS Fld24089_
        FROM
            (
                SELECT
                    MAX(T4._Period) AS MAXPERIOD_
                FROM
                    dbo._InfoRg24088 T4
            ) T3
            INNER JOIN dbo._InfoRg24088 T5 ON T3.MAXPERIOD_ = T5._Period
    ) T2 ON 1 = 1
GROUP BY
    T2.Fld24090_,
    T2.Fld24089_,
    T2.Fld24094_,
    T2.Fld24095_,
    T2.Fld24096_,
    T2.Fld24097_,
    T2.Fld24098_,
    T2.Fld26611_,
    T2.Fld26612_,
    T2.Fld26613_,
    T2.Fld26614_,
    T2.Fld24099_,
    T2.Fld24100_
;
/*Время обслуживания началось выше и тут итоговая цифра*/
SELECT
    ISNULL(T2.МинимальноеВремя, 0) + ISNULL(T2.УсловиеКоличествоСтрок, 0) + ISNULL(T1.УсловиеМинскЧас, 0) + ISNULL(T2.УсловиеЭтажМассаОбщ, 0) + ISNULL(T2.УсловиеВесОбъем, 0) + ISNULL(T1.УсловиеСпособОплаты, 0) AS ВремяВыполнения
Into #Temp_TimeService
FROM
    #Temp_TimeByOrders T1 WITH(NOLOCK)
    LEFT OUTER JOIN #Temp_Time1 T2 WITH(NOLOCK)
    ON 1 = 1
;

/*Группа планирования*/
Select ГруппыПланирования._IDRRef AS ГруппаПланирования,
	ГруппыПланирования._Fld23302RRef AS Склад,
	ГруппыПланирования._Fld25137 AS ВремяДоступностиНаСегодня,
	ГруппыПланирования._Fld25138 AS ВремяСтопаСегодня,
	ГруппыПланирования._Fld25139 AS ВремяДоступностиНаЗавтра,
	ГруппыПланирования._Fld25140 AS ВремяСтопаЗавтра,
	IsNull(ГруппыПланирования._Fld25519, @P_EmptyDate)AS ГруппаПланированияДобавляемоеВремя,
	1 AS Основная
Into #Temp_PlanningGroups
From
dbo._Reference23294 ГруппыПланирования With (NOLOCK)
	Inner Join dbo._Reference23294_VT23309 With (NOLOCK)
		on ГруппыПланирования._IDRRef = _Reference23294_VT23309._Reference23294_IDRRef
		and _Reference23294_VT23309._Fld23311RRef in (Select ЗонаДоставкиРодительСсылка From #Temp_GeoData)
	--AND 
	--ГруппыПланирования._Fld23302RRef IN (Select СкладНазначения From #Temp_DateAvailable) --склад
	AND ГруппыПланирования._Fld25141 = 0x01--участвует в расчете мощности
	AND ГруппыПланирования._Fld23301RRef IN (Select Габарит From #Temp_Dimensions With (NOLOCK))  --габариты
	AND ГруппыПланирования._Marked = 0x00
UNION ALL
Select 
	ПодчиненнаяГП._IDRRef AS ГруппаПланирования,
	ГруппыПланирования._Fld23302RRef AS Склад,
	ПодчиненнаяГП._Fld25137 AS ВремяДоступностиНаСегодня,
	ПодчиненнаяГП._Fld25138 AS ВремяСтопаСегодня,
	ПодчиненнаяГП._Fld25139 AS ВремяДоступностиНаЗавтра,
	ПодчиненнаяГП._Fld25140 AS ВремяСтопаЗавтра,
	IsNull(ПодчиненнаяГП._Fld25519, @P_EmptyDate)AS ГруппаПланированияДобавляемоеВремя,
	0
From
	dbo._Reference23294 ГруппыПланирования With (NOLOCK)
	Inner Join dbo._Reference23294_VT23309	With (NOLOCK)	
		on ГруппыПланирования._IDRRef = _Reference23294_VT23309._Reference23294_IDRRef
		and _Reference23294_VT23309._Fld23311RRef in (Select ЗонаДоставкиРодительСсылка From #Temp_GeoData)
	Left Join dbo._Reference23294_VT26527 With (NOLOCK)
		Inner Join dbo._Reference23294 ПодчиненнаяГП
			On  _Reference23294_VT26527._Fld26529RRef = ПодчиненнаяГП._IDRRef 
		on ГруппыПланирования._IDRRef = _Reference23294_VT26527._Reference23294_IDRRef

Where 
	--ГруппыПланирования._Fld23302RRef IN (Select СкладНазначения From #Temp_DateAvailable) --склад
	--AND 
	ГруппыПланирования._Fld25141 = 0x01--участвует в расчете мощности
	AND ГруппыПланирования._Fld23301RRef IN (Select Габарит From #Temp_Dimensions)  --габариты
	AND ГруппыПланирования._Marked = 0x00
	AND NOT ПодчиненнаяГП._IDRRef = NULL

;
/*Отсюда начинается процесс получения оптимальной даты отгрузки*/
With Temp_ExchangeRates AS (
SELECT
	T1._Period AS Период,
	T1._Fld14558RRef AS Валюта,
	T1._Fld14559 AS Курс,
	T1._Fld14560 AS Кратность
FROM _InfoRgSL26678 T1 With (NOLOCK)
	)
SELECT
    T2._Fld21408RRef AS НоменклатураСсылка,
    T2._Fld21410_TYPE AS Источник_TYPE,
	T2._Fld21410_RTRef AS Источник_RTRef,
	T2._Fld21410_RRRef AS Источник_RRRef,
	Цены._Fld21410_TYPE AS Регистратор_TYPE,
    Цены._Fld21410_RTRef AS Регистратор_RTRef,
    Цены._Fld21410_RRRef AS Регистратор_RRRef,
    T2._Fld23568RRef AS СкладИсточника,
    T2._Fld21424 AS ДатаСобытия,
    SUM(T2._Fld21411) - SUM(T2._Fld21412) AS Количество
Into #Temp_Remains
FROM
    dbo._AccumRgT21444 T2 With (NOLOCK)
	Left Join _AccumRg21407 Цены With (NOLOCK)
		Inner Join Temp_ExchangeRates 
			On Цены._Fld21443RRef = Temp_ExchangeRates.Валюта 
		On T2._Fld21408RRef = Цены._Fld21408RRef
		AND T2._Fld21410_RTRef = Цены._Fld21410_RTRef
		AND T2._Fld21410_RRRef = Цены._Fld21410_RRRef
		AND Цены._Fld21410_RTRef = 0x00000153 --Цены.Регистратор ССЫЛКА Документ.мегапрайсРегистрацияПрайса
		And Цены._Fld21442<>0 AND (Цены._Fld21442 * Temp_ExchangeRates.Курс / Temp_ExchangeRates.Кратность >= Цены._Fld21982 OR Цены._Fld21411 >= Цены._Fld21616)
		And Цены._Fld21408RRef IN(SELECT
                НоменклатураСсылка
            FROM
                #Temp_Goods)

WHERE
    T2._Period = '5999-11-01 00:00:00'
    AND (
        (
            (T2._Fld21424 = '2001-01-01 00:00:00')
            OR (T2._Fld21424 >= @P_DateTimeNow)
        )
        AND T2._Fld21408RRef IN (
            SELECT
                TNomen.НоменклатураСсылка
            FROM
                #Temp_Goods TNomen WITH(NOLOCK))) AND (T2._Fld21412 <> 0 OR T2._Fld21411 <> 0)
GROUP BY
    T2._Fld21408RRef,
    T2._Fld21410_TYPE,
    T2._Fld21410_RTRef,
    T2._Fld21410_RRRef,
	Цены._Fld21410_TYPE,
    Цены._Fld21410_RTRef,
    Цены._Fld21410_RRRef,
    T2._Fld23568RRef,
    T2._Fld21424
HAVING
    (SUM(T2._Fld21412) <> 0.0
    OR SUM(T2._Fld21411) <> 0.0)
	AND SUM(T2._Fld21412) - SUM(T2._Fld21411) <> 0.0
	
CREATE CLUSTERED INDEX ix_tempCIndexAft1 ON #Temp_Remains (НоменклатураСсылка,СкладИсточника, Источник_RRRef,ДатаСобытия);

SELECT Distinct
    T1._Fld23831RRef AS СкладИсточника,
    T1._Fld23832 AS ДатаСобытия,
    T1._Fld23834 AS ДатаПрибытия,
    T1._Fld23833RRef AS СкладНазначения
Into #Temp_WarehouseDates
FROM
    dbo._InfoRg23830 T1 With (NOLOCK)
	Inner Join #Temp_Remains
	ON T1._Fld23831RRef = #Temp_Remains.СкладИсточника
	AND T1._Fld23832 = #Temp_Remains.ДатаСобытия
	AND T1._Fld23833RRef IN (Select СкладСсылка From #Temp_GeoData)


   
;

SELECT
	T1._Fld23831RRef AS СкладИсточника,
	T1._Fld23833RRef AS СкладНазначения,
	MIN(T1._Fld23834) AS ДатаПрибытия 
Into #Temp_MinimumWarehouseDates
FROM 
    dbo._InfoRg23830 T1 With (NOLOCK)
WHERE
    T1._Fld23831RRef IN (
        SELECT
            T2.СкладИсточника AS СкладИсточника
        FROM
            #Temp_Remains T2 WITH(NOLOCK)) 
		AND T1._Fld23832 > @P_DateTimeNow
		AND T1._Fld23832 <= DateAdd(DAY,2,@P_DateTimeNow)
		AND 
		T1._Fld23833RRef IN (Select СкладСсылка From #Temp_GeoData)
GROUP BY T1._Fld23831RRef,
T1._Fld23833RRef
OPTION (OPTIMIZE FOR (@P_DateTimeNow='{1}'));

SELECT
    T1.НоменклатураСсылка,
    T1.Количество,
    T1.Источник_TYPE,
    T1.Источник_RTRef,
    T1.Источник_RRRef,
    T1.СкладИсточника,
    T1.ДатаСобытия,
    ISNULL(T3.ДатаПрибытия, T2.ДатаПрибытия) AS ДатаДоступности,
    1 AS ТипИсточника,
    ISNULL(T3.СкладНазначения, T2.СкладНазначения) AS СкладНазначения
INTO #Temp_Sources
FROM
    #Temp_Remains T1 WITH(NOLOCK)
    LEFT OUTER JOIN #Temp_WarehouseDates T2 WITH(NOLOCK)
    ON (T1.СкладИсточника = T2.СкладИсточника)
    AND (T1.ДатаСобытия = T2.ДатаСобытия)
    LEFT OUTER JOIN #Temp_MinimumWarehouseDates T3 WITH(NOLOCK)
    ON (T1.СкладИсточника = T3.СкладИсточника)
    AND (T1.ДатаСобытия = '2001-01-01 00:00:00')
WHERE
    T1.Источник_RTRef = 0x000000E2 OR T1.Источник_RTRef = 0x00000150

UNION
ALL
SELECT
    T4.НоменклатураСсылка,
    T4.Количество,
    T4.Источник_TYPE,
    T4.Источник_RTRef,
    T4.Источник_RRRef,
    T4.СкладИсточника,
    T4.ДатаСобытия,
	DATEADD(SECOND, DATEDIFF(SECOND, @P_EmptyDate, IsNull(#Temp_PlanningGroups.ГруппаПланированияДобавляемоеВремя,@P_EmptyDate)), T5.ДатаПрибытия),
    --T5.ДатаПрибытия,
    2,
    T5.СкладНазначения
FROM
    #Temp_Remains T4 WITH(NOLOCK)
    INNER JOIN #Temp_WarehouseDates T5 WITH(NOLOCK)
    ON (T4.СкладИсточника = T5.СкладИсточника)
    AND (T4.ДатаСобытия = T5.ДатаСобытия)
	Left Join #Temp_PlanningGroups On T5.СкладНазначения = #Temp_PlanningGroups.Склад
WHERE
    T4.Источник_RTRef = 0x00000141

UNION
ALL
SELECT
    T6.НоменклатураСсылка,
    T6.Количество,
    T6.Источник_TYPE,
    T6.Источник_RTRef,
    T6.Источник_RRRef,
    T6.СкладИсточника,
    T6.ДатаСобытия,
	DATEADD(SECOND, DATEDIFF(SECOND, @P_EmptyDate, IsNull(#Temp_PlanningGroups.ГруппаПланированияДобавляемоеВремя,@P_EmptyDate)), T7.ДатаПрибытия),
    --T7.ДатаПрибытия,
    3,
    T7.СкладНазначения
FROM
    #Temp_Remains T6 WITH(NOLOCK)
    INNER JOIN #Temp_WarehouseDates T7 WITH(NOLOCK)
    ON (T6.СкладИсточника = T7.СкладИсточника)
    AND (T6.ДатаСобытия = T7.ДатаСобытия)
	Left Join #Temp_PlanningGroups With (NOLOCK) On T7.СкладНазначения = #Temp_PlanningGroups.Склад
WHERE
    NOT T6.Регистратор_RRRef IS NULL
	And T6.Источник_RTRef = 0x00000153
;



;
With TempSourcesGrouped AS
(
Select
	T1.НоменклатураСсылка AS НоменклатураСсылка,
	Sum(T1.Количество) AS Количество,
	T1.ДатаДоступности AS ДатаДоступности,
	T1.СкладНазначения AS СкладНазначения
From
	#Temp_Sources T1
	
Group by
	T1.НоменклатураСсылка,
	T1.ДатаДоступности,
	T1.СкладНазначения
)
Select
	Источники1.НоменклатураСсылка AS Номенклатура,
	Источники1.СкладНазначения AS СкладНазначения,
	Источники1.ДатаДоступности AS ДатаДоступности,
	Sum(Источник2.Количество) AS Количество
Into #Temp_AvailableGoods
From
	TempSourcesGrouped AS Источники1
		Left Join TempSourcesGrouped AS Источник2
		On Источники1.НоменклатураСсылка = Источник2.НоменклатураСсылка
		AND Источники1.СкладНазначения = Источник2.СкладНазначения
			AND Источники1.ДатаДоступности >= Источник2.ДатаДоступности
	
Group by
	Источники1.НоменклатураСсылка,
	Источники1.ДатаДоступности,
	Источники1.СкладНазначения
;


With Temp_ExchangeRates AS (
SELECT
	T1._Period AS Период,
	T1._Fld14558RRef AS Валюта,
	T1._Fld14559 AS Курс,
	T1._Fld14560 AS Кратность
FROM _InfoRgSL26678 T1
	)
SELECT
    T1.НоменклатураСсылка,
	T1.Количество,
    T1.Источник_TYPE,
    T1.Источник_RTRef,
    T1.Источник_RRRef,
    T1.СкладИсточника,
    T1.СкладНазначения,
    T1.ДатаСобытия,
    T1.ДатаДоступности,
    CAST(
        (
            CAST(
                (Резервирование._Fld21442 * T3.Курс) AS NUMERIC(27, 8)
            ) / T3.Кратность
        ) AS NUMERIC(15, 2)
    )  AS Цена
Into #Temp_SourcesWithPrices
FROM
    #Temp_Sources T1 WITH(NOLOCK)
    INNER JOIN dbo._AccumRg21407 Резервирование With (NOLOCK)
    LEFT OUTER JOIN Temp_ExchangeRates T3 WITH(NOLOCK)
    ON (Резервирование._Fld21443RRef = T3.Валюта) ON (T1.НоменклатураСсылка = Резервирование._Fld21408RRef)
    AND (
        T1.Источник_TYPE = 0x08
        AND T1.Источник_RTRef = Резервирование._RecorderTRef
        AND T1.Источник_RRRef = Резервирование._RecorderRRef
    )
;
With Temp_SupplyDocs AS
(
SELECT
    T1.НоменклатураСсылка,
    T1.СкладНазначения,
    T1.ДатаДоступности,
    DATEADD(DAY, {4}, T1.ДатаДоступности) AS ДатаДоступностиПлюс, --это параметр КоличествоДнейАнализа
    MIN(T1.Цена) AS ЦенаИсточника,
    MIN(T1.Цена / 100.0 * (100 - {5})) AS ЦенаИсточникаМинус --это параметр ПроцентДнейАнализа
FROM
    #Temp_SourcesWithPrices T1 WITH(NOLOCK)
WHERE
    T1.Цена <> 0
    AND T1.Источник_RTRef = 0x00000153
    
GROUP BY
    T1.НоменклатураСсылка,
    T1.ДатаДоступности,
    T1.СкладНазначения,
    DATEADD(DAY, {4}, T1.ДатаДоступности)--это параметр КоличествоДнейАнализа
)

SELECT
    T2.НоменклатураСсылка,
    T2.ДатаДоступности,
    T2.СкладНазначения,
    T2.ДатаДоступностиПлюс,
    T2.ЦенаИсточника,
    T2.ЦенаИсточникаМинус,
    MIN(T1.ДатаДоступности) AS ДатаДоступности1,
    MIN(T1.Цена) AS Цена1
Into #Temp_BestPriceAfterClosestDate
FROM
    #Temp_SourcesWithPrices T1 WITH(NOLOCK)
    INNER JOIN Temp_SupplyDocs T2 WITH(NOLOCK)
    ON (T1.НоменклатураСсылка = T2.НоменклатураСсылка)
    AND (T1.ДатаДоступности >= T2.ДатаДоступности)
    AND (T1.ДатаДоступности <= T2.ДатаДоступностиПлюс)
    AND (T1.Цена <= T2.ЦенаИсточникаМинус)
    AND (T1.Цена <> 0)
GROUP BY
    T2.НоменклатураСсылка,
    T2.СкладНазначения,
    T2.ДатаДоступностиПлюс,
    T2.ЦенаИсточника,
    T2.ЦенаИсточникаМинус,
    T2.ДатаДоступности

SELECT
    T1.НоменклатураСсылка,
	T1.Количество,
    T1.Источник_TYPE,
    T1.Источник_RTRef,
    T1.Источник_RRRef,
    T1.СкладИсточника,
    T1.СкладНазначения,
    T1.ДатаСобытия,
    ISNULL(T2.ДатаДоступности1, T1.ДатаДоступности) AS ДатаДоступности,
    T1.ТипИсточника
Into #Temp_SourcesCorrectedDate
FROM
    #Temp_Sources T1 WITH(NOLOCK)
    LEFT OUTER JOIN #Temp_BestPriceAfterClosestDate T2 WITH(NOLOCK)
    ON (T1.НоменклатураСсылка = T2.НоменклатураСсылка)
    AND (T1.ДатаДоступности = T2.ДатаДоступности)
    AND (T1.СкладНазначения = T2.СкладНазначения)
    AND (T1.ТипИсточника = 3)
;
With Temp_ClosestDate AS
(SELECT
T1.НоменклатураСсылка,
T1.СкладНазначения,
MIN(T1.ДатаДоступности) AS ДатаДоступности
FROM #Temp_Sources T1 WITH(NOLOCK)
GROUP BY T1.НоменклатураСсылка,
T1.СкладНазначения
)
Select 
	T4.НоменклатураСсылка AS НоменклатураСсылка,
	T4.СкладНазначения AS СкладНазначения,
	Min(T4.БлижайшаяДата) AS БлижайшаяДата
into #Temp_ClosestDatesByGoods
From 
(SELECT
    T1.НоменклатураСсылка,
    ISNULL(T3.СкладНазначения, T2.СкладНазначения) AS СкладНазначения,
    MIN(ISNULL(T3.ДатаДоступности, T2.ДатаДоступности)) AS БлижайшаяДата

FROM
    #Temp_Goods T1 WITH(NOLOCK)
    LEFT OUTER JOIN #Temp_SourcesCorrectedDate T2 WITH(NOLOCK)
    ON (T1.НоменклатураСсылка = T2.НоменклатураСсылка)
    LEFT OUTER JOIN (
        SELECT
            T4.НоменклатураСсылка,
            T4.ДатаДоступности,
            T4.СкладНазначения,
            T5.ДатаДоступности AS БлижайшаяДата
        FROM
            #Temp_Sources T4 WITH(NOLOCK)
            LEFT OUTER JOIN Temp_ClosestDate T5 WITH(NOLOCK)
            ON (T4.НоменклатураСсылка = T5.НоменклатураСсылка)
            AND (T4.СкладНазначения = T5.СкладНазначения)
            AND (T4.ТипИсточника = 1)
    ) T3 ON (T1.НоменклатураСсылка = T3.НоменклатураСсылка)
    AND (
        T3.ДатаДоступности <= DATEADD(DAY, {4}, T3.БлижайшаяДата) --это параметр КоличествоДнейАнализа
    )
	Where T1.Количество = 1
GROUP BY
    T1.НоменклатураСсылка,
    ISNULL(T3.СкладНазначения, T2.СкладНазначения)
Union ALL
Select 
	#Temp_Goods.НоменклатураСсылка,
	#Temp_AvailableGoods.СкладНазначения,
	Min(#Temp_AvailableGoods.ДатаДоступности)
From #Temp_Goods With (NOLOCK)
	Left Join #Temp_AvailableGoods With (NOLOCK) 
		On #Temp_Goods.НоменклатураСсылка = #Temp_AvailableGoods.Номенклатура
		AND #Temp_Goods.Количество <= #Temp_AvailableGoods.Количество
Where
	#Temp_Goods.Количество > 1
Group By
	#Temp_Goods.НоменклатураСсылка,
	#Temp_AvailableGoods.СкладНазначения) T4
Group by 
	T4.НоменклатураСсылка,
	T4.СкладНазначения

Select
    Top 1 
	Max(#Temp_ClosestDatesByGoods.БлижайшаяДата) AS DateAvailable, 
СкладНазначения AS СкладНазначения
Into #Temp_DateAvailable
from #Temp_ClosestDatesByGoods With (NOLOCK)
Group by СкладНазначения
Order by DateAvailable ASC
/*Тут закончился процесс оптимальной даты. Склад назначения нужен чтоб потом правильную ГП выбрать*/

/*Мощности доставки*/
SELECT
    CAST(
        SUM(
            CASE
                WHEN (МощностиДоставки._RecordKind = 0.0) THEN МощностиДоставки._Fld25107
                ELSE -(МощностиДоставки._Fld25107)
            END
        ) AS NUMERIC(16, 3)
    ) AS МассаОборот,
    CAST(
        SUM(
            CASE
                WHEN (МощностиДоставки._RecordKind = 0.0) THEN МощностиДоставки._Fld25108
                ELSE -(МощностиДоставки._Fld25108)
            END
        ) AS NUMERIC(16, 3)
    ) AS ОбъемОборот,
    CAST(
        SUM(
            CASE
                WHEN (МощностиДоставки._RecordKind = 0.0) THEN МощностиДоставки._Fld25201
                ELSE -(МощностиДоставки._Fld25201)
            END
        ) AS NUMERIC(16, 2)
    ) AS ВремяНаОбслуживаниеОборот,
	CAST(CAST(МощностиДоставки._Period  AS DATE) AS DATETIME) AS Дата
Into #Temp_DeliveryPower
FROM
    dbo._AccumRg25104 МощностиДоставки With (NOLOCK),
	--Inner Join #Temp_DateAvailable On CAST(CAST(МощностиДоставки._Period  AS DATE) AS DATETIME) >= CAST(CAST(#Temp_DateAvailable.DateAvailable  AS DATE) AS DATETIME),
	#Temp_Size With (NOLOCK),
	#Temp_TimeService With (NOLOCK)

WHERE
    МощностиДоставки._Period >= @P_DateTimePeriodBegin
    AND МощностиДоставки._Period <= @P_DateTimePeriodEnd
	AND МощностиДоставки._Fld25105RRef IN (Select ЗонаДоставкиРодительСсылка From  #Temp_GeoData)
GROUP BY
	CAST(CAST(МощностиДоставки._Period  AS DATE) AS DATETIME),
	#Temp_Size.Вес,
	#Temp_Size.Объем,
	#Temp_TimeService.ВремяВыполнения
Having 
	SUM(
            CASE
                WHEN (МощностиДоставки._RecordKind = 0.0) THEN МощностиДоставки._Fld25107
                ELSE -(МощностиДоставки._Fld25107)
            END
        ) > #Temp_Size.Вес
	AND 
	SUM(
            CASE
                WHEN (МощностиДоставки._RecordKind = 0.0) THEN МощностиДоставки._Fld25108
                ELSE -(МощностиДоставки._Fld25108)
            END
        ) > #Temp_Size.Объем
	And 
	SUM(
            CASE
                WHEN (МощностиДоставки._RecordKind = 0.0) THEN МощностиДоставки._Fld25201
                ELSE -(МощностиДоставки._Fld25201)
            END
        ) > #Temp_TimeService.ВремяВыполнения	
OPTION (OPTIMIZE FOR (@P_DateTimePeriodBegin='{2}',@P_DateTimePeriodEnd='{3}'));

CREATE CLUSTERED INDEX ix_tempCIndexAft11 ON #Temp_DeliveryPower(Дата); 




/*Тут начинаются интервалы, которые рассчитанные*/
SELECT 
    T1._Period AS Период,
    T1._Fld25111RRef AS Геозона,
	T1._Fld25112RRef AS ГруппаПланирования,
	T2.Основная AS Приоритет,
	T1._Fld25202 AS ВремяНачалаНачальное,
	T1._Fld25203 AS ВремяОкончанияНачальное,
	DATEADD(
        SECOND,
        CAST(
            DATEDIFF(SECOND, @P_EmptyDate, T1._Fld25202) AS NUMERIC(12)
        ),
        T1._Period
    ) AS ВремяНачала,
	DATEADD(
        SECOND,
        CAST(
            DATEDIFF(SECOND, @P_EmptyDate, T1._Fld25203) AS NUMERIC(12)
        ),
        T1._Period
    ) AS ВремяОкончания,
	SUM(
                CASE
                    WHEN (T1._RecordKind = 0.0) THEN T1._Fld25113
                    ELSE -(T1._Fld25113)
                END
            ) AS КоличествоЗаказовЗаИнтервалВремени
Into #Temp_Intervals
FROM
    dbo._AccumRg25110 T1 With (NOLOCK)
    INNER JOIN #Temp_PlanningGroups T2 With (NOLOCK) ON (T1._Fld25112RRef = T2.ГруппаПланирования)
	AND T2.Склад IN (select СкладНазначения From #Temp_DateAvailable)
    AND (T1._Fld25202 >= T2.ВремяДоступностиНаСегодня)
    AND (NOT (((@P_TimeNow >= T2.ВремяСтопаСегодня))))
	--Inner Join #Temp_GeoData ON T1._Fld25111RRef = #Temp_GeoData.Геозона
WHERE
    T1._Period = @P_DateTimePeriodBegin
	AND T1._Period IN (Select Дата From #Temp_DeliveryPower)
	AND T1._Fld25111RRef IN (Select Геозона From #Temp_GeoData)
GROUP BY
    T1._Period,
    T1._Fld25111RRef,
	T1._Fld25112RRef,
    T1._Fld25202,
	T1._Fld25203,
	T2.Основная
HAVING
    (
        CAST(
            SUM(
                CASE
                    WHEN (T1._RecordKind = 0.0) THEN T1._Fld25113
                    ELSE -(T1._Fld25113)
                END
            ) AS NUMERIC(16, 0)
        ) > 0.0
    )
OPTION (OPTIMIZE FOR (@P_DateTimePeriodBegin='{2}'));
--option (recompile)
--UNION
--ALL
INsert into #Temp_Intervals
SELECT
    T3._Period,
    T3._Fld25111RRef,
	T3._Fld25112RRef,
	T4.Основная,
	T3._Fld25202 AS ВремяНачалаНачальное,
	T3._Fld25203 AS ВремяОкончанияНачальное,
    DATEADD(
        SECOND,
        CAST(
            DATEDIFF(SECOND, @P_EmptyDate, T3._Fld25202) AS NUMERIC(12)
        ),
        T3._Period
    ),
	DATEADD(
        SECOND,
        CAST(
            DATEDIFF(SECOND, @P_EmptyDate, T3._Fld25203) AS NUMERIC(12)
        ),
        T3._Period
    ),
	SUM(
                CASE
                    WHEN (T3._RecordKind = 0.0) THEN T3._Fld25113
                    ELSE -(T3._Fld25113)
                END
            )
FROM
    dbo._AccumRg25110 T3 With (NOLOCK)
    INNER JOIN #Temp_PlanningGroups T4 With (NOLOCK) ON (T3._Fld25112RRef = T4.ГруппаПланирования)
	AND T4.Склад IN (select СкладНазначения From #Temp_DateAvailable)
    AND (
        (@P_TimeNow < T4.ВремяСтопаЗавтра)
        OR (T3._Fld25202 >= T4.ВремяДоступностиНаЗавтра)
    )
WHERE
    T3._Period = DATEADD(DAY, 1, @P_DateTimePeriodBegin) --bigin +1
	AND T3._Period IN (Select Дата From #Temp_DeliveryPower)
    AND T3._Fld25111RRef in (Select Геозона From #Temp_GeoData)
GROUP BY
    T3._Period,
    T3._Fld25111RRef,
	T3._Fld25112RRef,
    T3._Fld25202,
	T3._Fld25203,
	T4.Основная
HAVING
    (
        CAST(
            SUM(
                CASE
                    WHEN (T3._RecordKind = 0.0) THEN T3._Fld25113
                    ELSE -(T3._Fld25113)
                END
            ) AS NUMERIC(16, 0)
        ) > 0.0
    )
OPTION (OPTIMIZE FOR (@P_DateTimePeriodBegin='{2}'));
--option (recompile)
--UNION
--ALL
INsert into #Temp_Intervals
SELECT
    T5._Period,
    T5._Fld25111RRef,
	T5._Fld25112RRef,
	T4.Основная,
	T5._Fld25202 AS ВремяНачалаНачальное,
	T5._Fld25203 AS ВремяОкончанияНачальное,
    DATEADD(
        SECOND,
        CAST(
            DATEDIFF(SECOND, @P_EmptyDate, T5._Fld25202) AS NUMERIC(12)
        ),
        T5._Period
    ),
	DATEADD(
        SECOND,
        CAST(
            DATEDIFF(SECOND, @P_EmptyDate, T5._Fld25203) AS NUMERIC(12)
        ),
        T5._Period
    ),
	SUM(
                CASE
                    WHEN (T5._RecordKind = 0.0) THEN T5._Fld25113
                    ELSE -(T5._Fld25113)
                END
            )
FROM
    dbo._AccumRg25110 T5 With (NOLOCK)
	INNER JOIN #Temp_PlanningGroups T4 With (NOLOCK) ON (T5._Fld25112RRef = T4.ГруппаПланирования)
	AND T4.Склад IN (select СкладНазначения From #Temp_DateAvailable)
WHERE
    T5._Period >= DATEADD(DAY, 2, @P_DateTimePeriodBegin) --begin +2
    AND T5._Period <= @P_DateTimePeriodEnd --end
	AND T5._Period IN (Select Дата From #Temp_DeliveryPower)
    AND T5._Fld25111RRef in (Select Геозона From #Temp_GeoData) 
GROUP BY
    T5._Period,
    T5._Fld25111RRef,
	T5._Fld25112RRef,
    T5._Fld25202,
	T5._Fld25203,
	T4.Основная
HAVING
    (
        CAST(
            SUM(
                CASE
                    WHEN (T5._RecordKind = 0.0) THEN T5._Fld25113
                    ELSE -(T5._Fld25113)
                END
            ) AS NUMERIC(16, 0)
        ) > 0.0
    )
OPTION (OPTIMIZE FOR (@P_DateTimePeriodBegin='{2}',@P_DateTimePeriodEnd='{3}'));
;
/*Выше закончились рассчитанные интервалы*/

WITH T(date) AS (
    /*Это получение списка дат интервалов после даты окончания расчета*/
    SELECT
        Case When @P_DateTimePeriodEnd > CAST(CAST(#Temp_DateAvailable.DateAvailable  AS DATE) AS DATETIME) Then
		DateAdd(day, 1,
		@P_DateTimePeriodEnd
		)
		else 
		CAST(CAST(#Temp_DateAvailable.DateAvailable  AS DATE) AS DATETIME) 
		End
	From #Temp_DateAvailable
    UNION
    ALL
    SELECT
        DateAdd(day, 1, T.date)
    FROM
        T
		Inner Join #Temp_DateAvailable 
		ON T.date < DateAdd(DAY, @P_DaysToShow, CAST(CAST(#Temp_DateAvailable.DateAvailable  AS DATE) AS DATETIME)) 
)
/*Тут мы выбираем даты из регистра*/
select 
	DATEADD(
        SECOND,
        CAST(
            DATEDIFF(SECOND, @P_EmptyDate, ГеоЗонаВременныеИнтервалы._Fld25128) AS NUMERIC(12)
        ),
        #Temp_Intervals.Период
    ) As ВремяНачала,
	DATEADD(
        SECOND,
        CAST(
            DATEDIFF(SECOND, @P_EmptyDate, ГеоЗонаВременныеИнтервалы._Fld25129) AS NUMERIC(12)
        ),
        #Temp_Intervals.Период
    ) As ВремяОкончания,
	SUM(
	#Temp_Intervals.КоличествоЗаказовЗаИнтервалВремени
	) 
	AS КоличествоЗаказовЗаИнтервалВремени 
From
#Temp_Intervals With (NOLOCK)
Inner Join #Temp_DateAvailable With (NOLOCK) 
    On #Temp_Intervals.ВремяНачала >= #Temp_DateAvailable.DateAvailable
Inner Join _Reference114_VT25126 ГеоЗонаВременныеИнтервалы With (NOLOCK)
    On #Temp_Intervals.Геозона = ГеоЗонаВременныеИнтервалы._Reference114_IDRRef
	And #Temp_Intervals.ВремяНачалаНачальное >= ГеоЗонаВременныеИнтервалы._Fld25128
	And #Temp_Intervals.ВремяНачалаНачальное < ГеоЗонаВременныеИнтервалы._Fld25129
Inner Join #Temp_TimeService With (NOLOCK) On 1=1 
Group By 
	ГеоЗонаВременныеИнтервалы._Fld25128,
	ГеоЗонаВременныеИнтервалы._Fld25129,
	#Temp_Intervals.Период,
	#Temp_TimeService.ВремяВыполнения
Having Min(#Temp_Intervals.ВремяНачала) <=  DATEADD(
        SECOND,
        CAST(
            DATEDIFF(SECOND, @P_EmptyDate, ГеоЗонаВременныеИнтервалы._Fld25128) AS NUMERIC(12)
        ),
        #Temp_Intervals.Период
    ) 
	AND SUM(#Temp_Intervals.КоличествоЗаказовЗаИнтервалВремени) > #Temp_TimeService.ВремяВыполнения

Union
All
/*А тут мы выбираем даты где логисты еще не рассчитали*/
SELECT
	DATEADD(
        SECOND,
        CAST(
            DATEDIFF(SECOND, @P_EmptyDate, ГеоЗонаВременныеИнтервалы._Fld25128) AS NUMERIC(12)
        ),
        date
    ) As ВремяНачала,
	DATEADD(
        SECOND,
        CAST(
            DATEDIFF(SECOND, @P_EmptyDate, ГеоЗонаВременныеИнтервалы._Fld25129) AS NUMERIC(12)
        ),
        date
    ) As ВремяОкончания,
	0 AS КоличествоЗаказовЗаИнтервалВремени
FROM
    T 
	Inner Join _Reference114_VT25126 AS ГеоЗонаВременныеИнтервалы  With (NOLOCK) On ГеоЗонаВременныеИнтервалы._Reference114_IDRRef In (Select Геозона From #Temp_GeoData)
	Inner Join #Temp_DateAvailable On DATEADD(
        SECOND,
        CAST(
            DATEDIFF(SECOND, @P_EmptyDate, ГеоЗонаВременныеИнтервалы._Fld25128) AS NUMERIC(12)
        ),
        date
    ) >= #Temp_DateAvailable.DateAvailable 

Order by ВремяНачала

Drop table #Temp_GeoData
Drop table #Temp_GoodsBegin
Drop table #Temp_Goods
Drop table #Temp_Dimensions
Drop table #Temp_Size
Drop Table #Temp_Weight
Drop Table #Temp_TimeByOrders
Drop Table #Temp_Time1
Drop Table #Temp_TimeService
Drop table #Temp_Remains
Drop table #Temp_WarehouseDates
Drop table #Temp_MinimumWarehouseDates
Drop table #Temp_Sources
Drop table #Temp_AvailableGoods
DROP TABLE #Temp_SourcesWithPrices
DROP TABLE #Temp_BestPriceAfterClosestDate
DROP TABLE #Temp_SourcesCorrectedDate
DROP TABLE #Temp_ClosestDatesByGoods
DROP TABLE #Temp_DateAvailable
DROP TABLE #Temp_DeliveryPower
Drop TABLE #Temp_PlanningGroups
Drop TABLE #Temp_Intervals";


        public const string AvailableDate = @"Select
	IsNull(_Reference114_VT23370._Fld23372RRef,Геозона._Fld23104RRef) As СкладСсылка,
	ЗоныДоставки._ParentIDRRef As ЗонаДоставкиРодительСсылка,
	Геозона._IDRRef As Геозона
Into #Temp_GeoData
From dbo._Reference114 Геозона With (NOLOCK)
	Inner Join _Reference114_VT23370 With (NOLOCK)
	on _Reference114_VT23370._Reference114_IDRRef = Геозона._IDRRef
	Inner Join _Reference99 ЗоныДоставки With (NOLOCK)
	on Геозона._Fld2847RRef = ЗоныДоставки._IDRRef
where Геозона._IDRRef IN (
	Select Top 1 --по городу в геоадресе находим геозону
	ГеоАдрес._Fld2785RRef 
	From dbo._Reference112 ГеоАдрес With (NOLOCK)
	Where ГеоАдрес._Fld25552 = @P4)

CREATE CLUSTERED INDEX ix_tempCIndexAft ON #Temp_GeoData(СкладСсылка,ЗонаДоставкиРодительСсылка,Геозона asc);

Select 
	Номенклатура._IDRRef AS НоменклатураСсылка,
    Номенклатура._Fld3480 AS article,
	Упаковки._IDRRef AS УпаковкаСсылка,
	1 As Количество,
	Упаковки._Fld6000 AS Вес,
	Упаковки._Fld6006 AS Объем,
	10 AS ВремяНаОбслуживание,
	IsNull(ГруппыПланирования._IDRRef, 0x00000000000000000000000000000000) AS ГруппаПланирования,
	IsNull(ГруппыПланирования._Description, '') AS ГруппаПланированияНаименование,
	IsNull(ГруппыПланирования._Fld25519, @P_EmptyDate) AS ГруппаПланированияДобавляемоеВремя
INTO #Temp_Goods
From 
	dbo._Reference149 Номенклатура With (NOLOCK)
	Inner Join dbo._Reference256 Упаковки With (NOLOCK)
		On 
		Упаковки._OwnerID_TYPE = 0x08  
		AND Упаковки.[_OwnerID_RTRef] = 0x00000095
		AND Номенклатура._IDRRef = Упаковки._OwnerID_RRRef		
		And Упаковки._Fld6003RRef = Номенклатура._Fld3489RRef
		AND Упаковки._Marked = 0x00
	Left Join dbo._Reference23294 ГруппыПланирования With (NOLOCK)
		Inner Join dbo._Reference23294_VT23309 With (NOLOCK)
			on ГруппыПланирования._IDRRef = _Reference23294_VT23309._Reference23294_IDRRef
			and _Reference23294_VT23309._Fld23311RRef in (Select ЗонаДоставкиРодительСсылка From #Temp_GeoData)
		On 
		ГруппыПланирования._Fld23302RRef IN (Select СкладСсылка From #Temp_GeoData) --склад
		AND ГруппыПланирования._Fld25141 = 0x01--участвует в расчете мощности
		AND (ГруппыПланирования._Fld23301RRef = Номенклатура._Fld3526RRef OR (Номенклатура._Fld3526RRef = 0xAC2CBF86E693F63444670FFEB70264EE AND ГруппыПланирования._Fld23301RRef= 0xAD3F7F5FC4F15DAD4F693CAF8365EC0D) ) --габариты
		AND ГруппыПланирования._Marked = 0x00
Where
	Номенклатура._Fld3480 IN ({0})

CREATE CLUSTERED INDEX ix_tempCIndexAft1 ON #Temp_Goods (НоменклатураСсылка,УпаковкаСсылка,ГруппаПланирования);


With Temp_ExchangeRates AS (
SELECT
	T1._Period AS Период,
	T1._Fld14558RRef AS Валюта,
	T1._Fld14559 AS Курс,
	T1._Fld14560 AS Кратность
FROM _InfoRgSL26678 T1 With (NOLOCK)
	)
SELECT
    T2._Fld21408RRef AS НоменклатураСсылка,
    T2._Fld21410_TYPE AS Источник_TYPE,
	T2._Fld21410_RTRef AS Источник_RTRef,
	T2._Fld21410_RRRef AS Источник_RRRef,
	Цены._Fld21410_TYPE AS Регистратор_TYPE,
    Цены._Fld21410_RTRef AS Регистратор_RTRef,
    Цены._Fld21410_RRRef AS Регистратор_RRRef,
    T2._Fld23568RRef AS СкладИсточника,
    T2._Fld21424 AS ДатаСобытия,
    SUM(T2._Fld21411) - SUM(T2._Fld21412) AS Количество
Into #Temp_Remains
FROM
    dbo._AccumRgT21444 T2 With (NOLOCK)
	Left Join _AccumRg21407 Цены With (NOLOCK)
		Inner Join Temp_ExchangeRates With (NOLOCK)
			On Цены._Fld21443RRef = Temp_ExchangeRates.Валюта 
		On T2._Fld21408RRef = Цены._Fld21408RRef
		AND T2._Fld21410_RTRef = Цены._Fld21410_RTRef
		AND Цены._Fld21410_RTRef = 0x00000153 --Цены.Регистратор ССЫЛКА Документ.мегапрайсРегистрацияПрайса
		And Цены._Fld21442<>0 AND (Цены._Fld21442 * Temp_ExchangeRates.Курс / Temp_ExchangeRates.Кратность >= Цены._Fld21982 OR Цены._Fld21411 >= Цены._Fld21616)
		And Цены._Fld21408RRef IN(SELECT
                НоменклатураСсылка
            FROM
                #Temp_Goods)
WHERE
    T2._Period = '5999-11-01 00:00:00'
    AND (
        (
            (T2._Fld21424 = '2001-01-01 00:00:00')
            OR (Cast(T2._Fld21424 AS datetime)>= @P_DateTimeNow)
        )
        AND T2._Fld21408RRef IN (
            SELECT
                TNomen.НоменклатураСсылка
            FROM
                #Temp_Goods TNomen WITH(NOLOCK))) AND (T2._Fld21412 <> 0 OR T2._Fld21411 <> 0)
GROUP BY
    T2._Fld21408RRef,
    T2._Fld21410_TYPE,
    T2._Fld21410_RTRef,
    T2._Fld21410_RRRef,
	Цены._Fld21410_TYPE,
	Цены._Fld21410_RTRef,
	Цены._Fld21410_RRRef,
    T2._Fld23568RRef,
    T2._Fld21424
HAVING
    (SUM(T2._Fld21412) <> 0.0
    OR SUM(T2._Fld21411) <> 0.0)
	AND SUM(T2._Fld21412) - SUM(T2._Fld21411) <> 0.0
OPTION (OPTIMIZE FOR (@P_DateTimeNow='{1}'));
;

CREATE CLUSTERED INDEX ix_tempCIndexAft2 ON #Temp_Remains (НоменклатураСсылка,СкладИсточника,ДатаСобытия);

SELECT Distinct
    T1._Fld23831RRef AS СкладИсточника,
    T1._Fld23832 AS ДатаСобытия,
    T1._Fld23834 AS ДатаПрибытия,
    T1._Fld23833RRef AS СкладНазначения
Into #Temp_WarehouseDates
FROM
    dbo._InfoRg23830 T1 With (NOLOCK)
	Inner Join #Temp_Remains With (NOLOCK)
	ON T1._Fld23831RRef = #Temp_Remains.СкладИсточника
	AND T1._Fld23832 = #Temp_Remains.ДатаСобытия
	AND T1._Fld23833RRef IN (Select СкладСсылка From #Temp_GeoData)   
;

SELECT
	T1._Fld23831RRef AS СкладИсточника,
	T1._Fld23833RRef AS СкладНазначения,
	MIN(T1._Fld23834) AS ДатаПрибытия 
Into #Temp_MinimumWarehouseDates
FROM
    dbo._InfoRg23830 T1 With (NOLOCK)
WHERE
    T1._Fld23831RRef IN (
        SELECT
            T2.СкладИсточника AS СкладИсточника
        FROM
            #Temp_Remains T2 WITH(NOLOCK)) 
		AND T1._Fld23832 >= @P_DateTimeNow
		AND T1._Fld23832 <= DateAdd(DAY,2,@P_DateTimeNow)
		AND T1._Fld23833RRef IN (Select СкладСсылка From #Temp_GeoData)
GROUP BY T1._Fld23831RRef,
T1._Fld23833RRef
OPTION (OPTIMIZE FOR (@P_DateTimeNow='{1}'));

;

SELECT
    T1.НоменклатураСсылка,
    T1.Количество,
    T1.Источник_TYPE,
    T1.Источник_RTRef,
    T1.Источник_RRRef,
    T1.СкладИсточника,
    T1.ДатаСобытия,
    ISNULL(T3.ДатаПрибытия, T2.ДатаПрибытия) AS ДатаДоступности,
    1 AS ТипИсточника,
    ISNULL(T3.СкладНазначения, T2.СкладНазначения) AS СкладНазначения
INTO #Temp_Sources
FROM
    #Temp_Remains T1 WITH(NOLOCK)
    LEFT OUTER JOIN #Temp_WarehouseDates T2 WITH(NOLOCK)
    ON (T1.СкладИсточника = T2.СкладИсточника)
    AND (T1.ДатаСобытия = T2.ДатаСобытия)
    LEFT OUTER JOIN #Temp_MinimumWarehouseDates T3 WITH(NOLOCK)
    ON (T1.СкладИсточника = T3.СкладИсточника)
    AND (T1.ДатаСобытия = '2001-01-01 00:00:00')
WHERE
    T1.Источник_RTRef = 0x000000E2 OR T1.Источник_RTRef = 0x00000150

UNION
ALL
SELECT
    T4.НоменклатураСсылка,
    T4.Количество,
    T4.Источник_TYPE,
    T4.Источник_RTRef,
    T4.Источник_RRRef,
    T4.СкладИсточника,
    T4.ДатаСобытия,
    T5.ДатаПрибытия,
    2,
    T5.СкладНазначения
FROM
    #Temp_Remains T4 WITH(NOLOCK)
    INNER JOIN #Temp_WarehouseDates T5 WITH(NOLOCK)
    ON (T4.СкладИсточника = T5.СкладИсточника)
    AND (T4.ДатаСобытия = T5.ДатаСобытия)
WHERE
    T4.Источник_RTRef = 0x00000141

UNION
ALL
SELECT
    T6.НоменклатураСсылка,
    T6.Количество,
    T6.Источник_TYPE,
    T6.Источник_RTRef,
    T6.Источник_RRRef,
    T6.СкладИсточника,
    T6.ДатаСобытия,
    T7.ДатаПрибытия,
    3,
    T7.СкладНазначения
FROM
    #Temp_Remains T6 WITH(NOLOCK)
    INNER JOIN #Temp_WarehouseDates T7 WITH(NOLOCK)
    ON (T6.СкладИсточника = T7.СкладИсточника)
    AND (T6.ДатаСобытия = T7.ДатаСобытия)
WHERE
    NOT T6.Регистратор_RRRef IS NULL
	And T6.Источник_RTRef = 0x00000153
;

With Temp_ExchangeRates AS (
SELECT
	T1._Period AS Период,
	T1._Fld14558RRef AS Валюта,
	T1._Fld14559 AS Курс,
	T1._Fld14560 AS Кратность
FROM _InfoRgSL26678 T1 With (NOLOCK)
	)
SELECT
    T1.НоменклатураСсылка,
    T1.Источник_TYPE,
    T1.Источник_RTRef,
    T1.Источник_RRRef,
    T1.СкладИсточника,
    T1.СкладНазначения,
    T1.ДатаСобытия,
    T1.ДатаДоступности,
    CAST(
        (
            CAST(
                (Резервирование._Fld21442 * T3.Курс) AS NUMERIC(27, 8)
            ) / T3.Кратность
        ) AS NUMERIC(15, 2)
    )  AS Цена
Into #Temp_SourcesWithPrices
FROM
    #Temp_Sources T1 WITH(NOLOCK)
    INNER JOIN dbo._AccumRg21407 Резервирование WITH(NOLOCK)
    LEFT OUTER JOIN Temp_ExchangeRates T3 WITH(NOLOCK)
        ON (Резервирование._Fld21443RRef = T3.Валюта) 
    ON (T1.НоменклатураСсылка = Резервирование._Fld21408RRef)
    AND (
        T1.Источник_TYPE = 0x08
        AND T1.Источник_RTRef = Резервирование._RecorderTRef
        AND T1.Источник_RRRef = Резервирование._RecorderRRef
    )
;
With Temp_SupplyDocs AS
(
SELECT
    T1.НоменклатураСсылка,
    T1.СкладНазначения,
    T1.ДатаДоступности,
    DATEADD(DAY, {4}, T1.ДатаДоступности) AS ДатаДоступностиПлюс, --это параметр КоличествоДнейАнализа
    MIN(T1.Цена) AS ЦенаИсточника,
    MIN(T1.Цена / 100.0 * (100 - {5})) AS ЦенаИсточникаМинус --это параметр ПроцентДнейАнализа
FROM
    #Temp_SourcesWithPrices T1 WITH(NOLOCK)
WHERE
    T1.Цена <> 0
    AND T1.Источник_RTRef = 0x00000153    
GROUP BY
    T1.НоменклатураСсылка,
    T1.ДатаДоступности,
    T1.СкладНазначения,
    DATEADD(DAY, {4}, T1.ДатаДоступности)
)
SELECT
    T2.НоменклатураСсылка,
    T2.ДатаДоступности,
    T2.СкладНазначения,
    T2.ДатаДоступностиПлюс,
    T2.ЦенаИсточника,
    T2.ЦенаИсточникаМинус,
    MIN(T1.ДатаДоступности) AS ДатаДоступности1,
    MIN(T1.Цена) AS Цена1
Into #Temp_BestPriceAfterClosestDate
FROM
    #Temp_SourcesWithPrices T1 WITH(NOLOCK)
    INNER JOIN Temp_SupplyDocs T2 WITH(NOLOCK)
    ON (T1.НоменклатураСсылка = T2.НоменклатураСсылка)
    AND (T1.ДатаДоступности >= T2.ДатаДоступности)
    AND (T1.ДатаДоступности <= T2.ДатаДоступностиПлюс)
    AND (T1.Цена <= T2.ЦенаИсточникаМинус)
    AND (T1.Цена <> 0)
GROUP BY
    T2.НоменклатураСсылка,
    T2.СкладНазначения,
    T2.ДатаДоступностиПлюс,
    T2.ЦенаИсточника,
    T2.ЦенаИсточникаМинус,
    T2.ДатаДоступности

SELECT
    T1.НоменклатураСсылка,
    T1.Источник_TYPE,
    T1.Источник_RTRef,
    T1.Источник_RRRef,
    T1.СкладИсточника,
    T1.СкладНазначения,
    T1.ДатаСобытия,
    ISNULL(T2.ДатаДоступности1, T1.ДатаДоступности) AS ДатаДоступности,
    T1.ТипИсточника
Into #Temp_SourcesCorrectedDate
FROM
    #Temp_Sources T1 WITH(NOLOCK)
    LEFT OUTER JOIN #Temp_BestPriceAfterClosestDate T2 WITH(NOLOCK)
    ON (T1.НоменклатураСсылка = T2.НоменклатураСсылка)
    AND (T1.ДатаДоступности = T2.ДатаДоступности)
    AND (T1.СкладНазначения = T2.СкладНазначения)
    AND (T1.ТипИсточника = 3)
;

With Temp_ClosestDate AS
(SELECT
T1.НоменклатураСсылка,
T1.СкладНазначения,
Cast(MIN(T1.ДатаДоступности)as datetime) AS ДатаДоступности
FROM #Temp_Sources T1 WITH(NOLOCK)
GROUP BY T1.НоменклатураСсылка,
T1.СкладНазначения
)
SELECT
            T4.НоменклатураСсылка,
            T4.ДатаДоступности,
            T4.СкладНазначения,
            T5.ДатаДоступности AS БлижайшаяДата
		Into #Temp_T3
        FROM
            #Temp_Sources T4 WITH(NOLOCK)
            LEFT OUTER JOIN Temp_ClosestDate T5 WITH(NOLOCK)
            ON (T4.НоменклатураСсылка = T5.НоменклатураСсылка)
            AND (T4.СкладНазначения = T5.СкладНазначения)
            AND (T4.ТипИсточника = 1)
			AND T4.ДатаДоступности <= DATEADD(DAY, 4, T5.ДатаДоступности)


SELECT
    T1.НоменклатураСсылка,
    T1.article,
    ISNULL(T3.СкладНазначения, T2.СкладНазначения) AS СкладНазначения,
    MIN(ISNULL(T3.ДатаДоступности, T2.ДатаДоступности)) AS БлижайшаяДата,
    1 AS Количество,
    T1.Вес,
    T1.Объем,
    T1.ВремяНаОбслуживание,
    T1.ГруппаПланирования,
	T1.ГруппаПланированияДобавляемоеВремя
into #Temp_ClosestDatesByGoods
FROM
    #Temp_Goods T1 WITH(NOLOCK)
    LEFT JOIN #Temp_SourcesCorrectedDate T2 WITH(NOLOCK)
        LEFT JOIN  #Temp_T3 T3 ON (T2.НоменклатураСсылка = T3.НоменклатураСсылка) 
			And T2.СкладНазначения = T3.СкладНазначения
    ON (T1.НоменклатураСсылка = T2.НоменклатураСсылка)
    
GROUP BY
    T1.НоменклатураСсылка,
    T1.article,
    ISNULL(T3.СкладНазначения, T2.СкладНазначения),
    T1.Вес,
    T1.Объем,
    T1.ВремяНаОбслуживание,
    T1.Количество,
    T1.ГруппаПланирования,
	T1.ГруппаПланированияДобавляемоеВремя

SELECT
    T1.НоменклатураСсылка,
    T1.article,
    T1.СкладНазначения,
    T1.Вес,
    T1.Объем,
    T1.ВремяНаОбслуживание,
    T1.ГруппаПланирования,
    MIN(
        CASE
            WHEN T2.Источник_RTRef = 0x00000141
            OR T2.Источник_RTRef = 0x00000153
                THEN DATEADD(SECOND, DATEDIFF(SECOND, @P_EmptyDate, T1.ГруппаПланированияДобавляемоеВремя), T1.БлижайшаяДата)
            ELSE T1.БлижайшаяДата
        END
    ) AS ДатаДоступности
Into #Temp_ShipmentDates
FROM
    #Temp_ClosestDatesByGoods T1 WITH(NOLOCK)
    LEFT OUTER JOIN #Temp_Sources T2 WITH(NOLOCK)
    ON (T1.НоменклатураСсылка = T2.НоменклатураСсылка)
    AND (T1.СкладНазначения = T2.СкладНазначения)
    AND (T1.БлижайшаяДата = T2.ДатаДоступности)
Where 
	NOT T1.БлижайшаяДата IS NULL
GROUP BY
    T1.НоменклатураСсылка,
    T1.article,
    T1.СкладНазначения,
    T1.Вес,
    T1.Объем,
    T1.ВремяНаОбслуживание,
    T1.ГруппаПланирования



SELECT
    T1.НоменклатураСсылка,
    T1.article,
    MIN(T1.ДатаДоступности) AS ДатаСоСклада,
    T1.Вес,
    T1.Объем,
    T1.ВремяНаОбслуживание,
    T1.ГруппаПланирования
Into #Temp_ShipmentDatesDeliveryCourier
FROM
    #Temp_ShipmentDates T1 WITH(NOLOCK)
--WHERE
--    T1.СкладНазначения IN (@P1, @P2) --пока не имеет значения ибо в запросе не используются склады ПВЗ
GROUP BY
    T1.НоменклатураСсылка,
    T1.article,
    T1.Вес,
    T1.Объем,
    T1.ВремяНаОбслуживание,
    T1.ГруппаПланирования

;
SELECT 
    T1._Period AS Период,
    T1._Fld25112RRef AS ГруппаПланирования,
	DATEADD(
        SECOND,
        CAST(
            DATEDIFF(SECOND, @P_EmptyDate, T1._Fld25202) AS NUMERIC(12)
        ),
        T1._Period
    ) AS ВремяНачала
Into #Temp_Intervals
FROM
    dbo._AccumRg25110 T1 With (NOLOCK)
    INNER JOIN dbo._Reference23294 T2 With (NOLOCK) ON (T1._Fld25112RRef = T2._IDRRef)
    AND (T1._Fld25202 >= T2._Fld25137)
    AND (NOT (((@P_TimeNow >= T2._Fld25138))))
	Inner Join #Temp_GeoData ON T1._Fld25111RRef = #Temp_GeoData.Геозона
WHERE
    T1._Period = @P_DateTimePeriodBegin
GROUP BY
    T1._Period,
    T1._Fld25112RRef,
    T1._Fld25202
HAVING
    (
        CAST(
            SUM(
                CASE
                    WHEN (T1._RecordKind = 0.0) THEN T1._Fld25113
                    ELSE -(T1._Fld25113)
                END
            ) AS NUMERIC(16, 0)
        ) > 0.0
    )
OPTION (OPTIMIZE FOR (@P_DateTimePeriodBegin='{2}'));
--option (recompile)
--UNION
--ALL
INsert into #Temp_Intervals
SELECT
    T3._Period,
    T3._Fld25112RRef,    
    DATEADD(
        SECOND,
        CAST(
            DATEDIFF(SECOND, @P_EmptyDate, T3._Fld25202) AS NUMERIC(12)
        ),
        T3._Period
    )
FROM
    dbo._AccumRg25110 T3 With (NOLOCK)
    INNER JOIN dbo._Reference23294 T4 With (NOLOCK) ON (T3._Fld25112RRef = T4._IDRRef)
    AND (
        (@P_TimeNow < T4._Fld25140)
        OR (T3._Fld25202 >= T4._Fld25139)
    )
WHERE
    T3._Period = DATEADD(DAY, 1, @P_DateTimePeriodBegin) --bigin +1
    AND T3._Fld25111RRef in (Select Геозона From #Temp_GeoData)
GROUP BY
    T3._Period,
    T3._Fld25112RRef,
    T3._Fld25202
HAVING
    (
        CAST(
            SUM(
                CASE
                    WHEN (T3._RecordKind = 0.0) THEN T3._Fld25113
                    ELSE -(T3._Fld25113)
                END
            ) AS NUMERIC(16, 0)
        ) > 0.0
    )
OPTION (OPTIMIZE FOR (@P_DateTimePeriodBegin='{2}'));
--option (recompile)
--UNION
--ALL
INsert into #Temp_Intervals
SELECT
    T5._Period,
    T5._Fld25112RRef,    
    DATEADD(
        SECOND,
        CAST(
            DATEDIFF(SECOND, @P_EmptyDate, T5._Fld25202) AS NUMERIC(12)
        ),
        T5._Period
    )
FROM
    dbo._AccumRg25110 T5 With (NOLOCK)
WHERE
    T5._Period >= DATEADD(DAY, 2, @P_DateTimePeriodBegin) --begin +2
    AND T5._Period <= @P_DateTimePeriodEnd --end
    AND T5._Fld25111RRef in (Select Геозона From #Temp_GeoData) 
GROUP BY
    T5._Period,
    T5._Fld25112RRef,
    T5._Fld25202
HAVING
    (
        CAST(
            SUM(
                CASE
                    WHEN (T5._RecordKind = 0.0) THEN T5._Fld25113
                    ELSE -(T5._Fld25113)
                END
            ) AS NUMERIC(16, 0)
        ) > 0.0
    )
OPTION (OPTIMIZE FOR (@P_DateTimePeriodBegin='{2}'));
--option (recompile)
;

CREATE CLUSTERED INDEX ix_tempCIndexIntervals ON #Temp_Intervals(Период,ГруппаПланирования,ВремяНачала asc);

With Temp_DeliveryPower AS
(
SELECT
    CAST(
        SUM(
            CASE
                WHEN (МощностиДоставки._RecordKind = 0.0) THEN МощностиДоставки._Fld25107
                ELSE -(МощностиДоставки._Fld25107)
            END
        ) AS NUMERIC(16, 3)
    ) AS МассаОборот,
    CAST(
        SUM(
            CASE
                WHEN (МощностиДоставки._RecordKind = 0.0) THEN МощностиДоставки._Fld25108
                ELSE -(МощностиДоставки._Fld25108)
            END
        ) AS NUMERIC(16, 3)
    ) AS ОбъемОборот,
    CAST(
        SUM(
            CASE
                WHEN (МощностиДоставки._RecordKind = 0.0) THEN МощностиДоставки._Fld25201
                ELSE -(МощностиДоставки._Fld25201)
            END
        ) AS NUMERIC(16, 2)
    ) AS ВремяНаОбслуживаниеОборот,
    CAST(CAST(МощностиДоставки._Period  AS DATE) AS DATETIME) AS Дата
FROM
    dbo._AccumRg25104 МощностиДоставки With (NOLOCK)
	--Inner Join #Temp_GeoData ON МощностиДоставки._Fld25105RRef = #Temp_GeoData.ЗонаДоставкиРодительСсылка
WHERE
    МощностиДоставки._Period >= @P_DateTimePeriodBegin
    AND МощностиДоставки._Period <= @P_DateTimePeriodEnd
    AND МощностиДоставки._Fld25105RRef IN (Select ЗонаДоставкиРодительСсылка From  #Temp_GeoData)
GROUP BY
    CAST(CAST(МощностиДоставки._Period  AS DATE) AS DATETIME)
)
SELECT
    T1.article AS nomenclature_id,
    MIN(
        ISNULL(
            T3.ВремяНачала,
CASE
                WHEN (T1.ДатаСоСклада > DATEADD(SECOND,-1,@P_DateTimePeriodEnd)) THEN DATEADD(
                    DAY,
                    1.0,
                    CAST(CAST(T1.ДатаСоСклада AS DATE) AS DATETIME)
                )
                ELSE DATEADD(DAY,1,@P_DateTimePeriodEnd)
            END
        )
    ) AS available_date_courier,
    MIN(ISNULL(T4.ДатаДоступности,@P_MaxDate)) AS available_date_self
FROM
    #Temp_ShipmentDatesDeliveryCourier T1 WITH(NOLOCK)
    Left JOIN Temp_DeliveryPower T2 WITH(NOLOCK)
    Inner JOIN #Temp_Intervals T3 WITH(NOLOCK)
    ON (T3.Период = T2.Дата) 
	ON (T2.МассаОборот >= T1.Вес)
    AND (T2.ОбъемОборот >= T1.Объем)
    AND (T2.ВремяНаОбслуживаниеОборот >= T1.ВремяНаОбслуживание)
    AND (
        T2.Дата >=
        CAST(CAST(T1.ДатаСоСклада AS DATE) AS DATETIME)
    )
    AND (T3.ГруппаПланирования = T1.ГруппаПланирования)
    AND (T3.ВремяНачала >= T1.ДатаСоСклада)
    Left JOIN #Temp_ShipmentDates T4 WITH(NOLOCK)
    ON (T1.НоменклатураСсылка = T4.НоменклатураСсылка)
    AND (T4.СкладНазначения IN (NULL)) --склады ПВЗ
GROUP BY
    T1.article
OPTION (OPTIMIZE FOR (@P_DateTimePeriodBegin='{2}',@P_DateTimePeriodEnd='{3}'));
--option (recompile)

DROP TABLE #Temp_GeoData
DROP TABLE #Temp_WarehouseDates
DROP TABLE #Temp_MinimumWarehouseDates
DROP TABLE #Temp_Goods
DROP TABLE #Temp_Remains
DROP TABLE #Temp_Sources
DROP TABLE #Temp_SourcesWithPrices
DROP TABLE #Temp_BestPriceAfterClosestDate
DROP TABLE #Temp_SourcesCorrectedDate
DROP TABLE #Temp_ClosestDatesByGoods
DROP TABLE #Temp_ShipmentDates
DROP TABLE #Temp_ShipmentDatesDeliveryCourier
DROP TABLE #Temp_Intervals
Drop Table #Temp_T3
";

        public const string DatebaseBalancingReplicaFull = @"select datediff(ms, last_commit_time, getdate())
from [master].[sys].[dm_hadr_database_replica_states]";

        public const string DatebaseBalancingMain = @"select top (1) _IDRRef from dbo._Reference112";

        public const string DatebaseBalancingReplicaTables = @"SELECT name
FROM sys.databases
WHERE OBJECT_ID(name+'.dbo.MSreplication_objects') IS NOT NULL
";
    }
}