DECLARE @P_Article1 nvarchar(20);
DECLARE @P_Article2 nvarchar(20);
DECLARE @P_Article3 nvarchar(20);
DECLARE @P_Article4 nvarchar(20);
DECLARE @P_Article5 nvarchar(20);
DECLARE @P_Article6 nvarchar(20);
DECLARE @P_Article7 nvarchar(20);
DECLARE @P_Article8 nvarchar(20);

DECLARE @P_Code1 nvarchar(20);
DECLARE @P_Code2 nvarchar(20);
DECLARE @P_Code3 nvarchar(20);
DECLARE @P_Code4 nvarchar(20);
DECLARE @P_Code5 nvarchar(20);
DECLARE @P_Code6 nvarchar(20);
DECLARE @P_Code7 nvarchar(20);
DECLARE @P_Code8 nvarchar(20);

DECLARE @PickupPoint1 nvarchar(10);
DECLARE @PickupPoint2 nvarchar(10);
DECLARE @PickupPoint3 nvarchar(10);
DECLARE @PickupPoint4 nvarchar(10);
DECLARE @PickupPoint5 nvarchar(10);
DECLARE @PickupPoint6 nvarchar(10);

DECLARE @P_CityCode nvarchar(20);

DECLARE @P_DateTimeNow datetime;
DECLARE @P_DateTimePeriodBegin datetime;
DECLARE @P_DateTimePeriodEnd datetime;
DECLARE @P_TimeNow datetime;
DECLARE @P_EmptyDate datetime;
DECLARE @P_MaxDate datetime;

 SET @P_Article1 = '358649'; --��������
 SET @P_Article2 = '424941';
 SET @P_Article3 = '1020938';
 SET @P_Article4 = '5962720';
 SET @P_Article5 = '6167903';
 SET @P_Article6 = '6167903';
 SET @P_Article7 = '380386';
 SET @P_Article8 = '358619';

 SET @P_Code1 = '00-00444697'; --���� ��� ������
 SET @P_Code2 = '00-00527933';
 SET @P_Code3 = NULL;
 SET @P_Code4 = NULL;
 SET @P_Code5 = NULL;
 SET @P_Code6 = NULL;
 SET @P_Code7 = NULL;
 SET @P_Code8 = NULL;

SET @PickupPoint1 = '340';
SET @PickupPoint2 = '388';
SET @PickupPoint3 = '460';
SET @PickupPoint4 = '417';
SET @PickupPoint5 = '234';
SET @PickupPoint6 = '2';

 Set @P_CityCode = '17030' --��� ������

 Set @P_DateTimeNow = '4021-05-07T12:00:00' 
 Set @P_DateTimePeriodBegin = '4021-05-07T00:00:00'
 Set @P_DateTimePeriodEnd = '4021-05-11T00:00:00'
 Set @P_TimeNow = '2001-01-01T12:00:00'
 Set @P_EmptyDate = '2001-01-01T00:00:00'
 Set @P_MaxDate = '5999-11-11T00:00:00'

Select
	IsNull(_Reference114_VT23370._Fld23372RRef,�������._Fld23104RRef) As �����������,
	������������._ParentIDRRef As ��������������������������,
	�������._IDRRef As �������
Into #Temp_GeoData
From dbo._Reference114 ������� With (NOLOCK)
	Inner Join _Reference114_VT23370 With (NOLOCK)
	on _Reference114_VT23370._Reference114_IDRRef = �������._IDRRef
	Inner Join _Reference99 ������������ With (NOLOCK)
	on �������._Fld2847RRef = ������������._IDRRef
where �������._IDRRef IN (
	Select Top 1 --�� ������ � ��������� ������� �������
	��������._Fld2785RRef 
	From dbo._Reference112 �������� With (NOLOCK)
	Where ��������._Fld25552 = @P_CityCode)
OPTION (KEEP PLAN, KEEPFIXED PLAN)

DECLARE @Temp_GoodsRaw Table  
(	
	Article nvarchar(20), 
	code nvarchar(20), 
    PickupPoint nvarchar(10)
)

INSERT INTO 
	@Temp_GoodsRaw ( 
		Article, code, PickupPoint
	)
VALUES
	(@P_Article1,@P_Code1,@PickupPoint3),
	(@P_Article2,@P_Code2,@PickupPoint2),
	(@P_Article1,@P_Code1,NULL)
	--(@P_Article2,@P_Code2,@PickupPoint2),
	--(@P_Article2,@P_Code2,NULL)
	--(@P3,3),
	--(@P5,4),
	--(@P6,3),
	--(@P7,2),
	--(@P8,1)
	;

Select 
	������������._IDRRef AS ������������������,
	������._IDRRef AS ��������������
INTO #Temp_GoodsBegin
From
	@Temp_GoodsRaw T1
	Inner Join 	dbo._Reference149 ������������ With (NOLOCK) 
		ON T1.code is NULL and T1.Article = ������������._Fld3480
	Left Join dbo._Reference226 ������ 
		ON T1.PickupPoint = ������._Fld19544
union
Select 
	������������._IDRRef,
	������._IDRRef
From 
	@Temp_GoodsRaw T1
	Inner Join 	dbo._Reference149 ������������ With (NOLOCK) 
		ON T1.code is not NULL and T1.code = ������������._Code
	Left Join dbo._Reference226 ������ 
		ON T1.PickupPoint = ������._Fld19544
OPTION (KEEP PLAN, KEEPFIXED PLAN)
;

Select 
	������������._IDRRef AS ������������������,
	������������._Fld3480 AS article,
	������������._Code AS code,
	#Temp_GoodsBegin.�������������� AS �����������,
	��������._IDRRef AS ��������������,
	1 As ����������,
	��������._Fld6000 AS ���,
	��������._Fld6006 AS �����,
	10 AS �������������������,
	IsNull(������������������._IDRRef, 0x00000000000000000000000000000000) AS ������������������,
	IsNull(������������������._Description, '') AS ������������������������������,
	IsNull(������������������._Fld25519, @P_EmptyDate) AS ����������������������������������
INTO #Temp_Goods
From 
	dbo._Reference149 ������������ With (NOLOCK)
	inner join #Temp_GoodsBegin on ������������._IDRRef = #Temp_GoodsBegin.������������������
	Inner Join dbo._Reference256 �������� With (NOLOCK)
		On 
		��������._OwnerID_TYPE = 0x08  
		AND ��������.[_OwnerID_RTRef] = 0x00000095
		AND ������������._IDRRef = ��������._OwnerID_RRRef		
		And ��������._Fld6003RRef = ������������._Fld3489RRef
		AND ��������._Marked = 0x00
	Left Join dbo._Reference23294 ������������������ With (NOLOCK)
		Inner Join dbo._Reference23294_VT23309 With (NOLOCK)
			--Inner Join #Temp_GeoData ON _Reference23294_VT23309._Fld23311RRef = #Temp_GeoData.��������������������������
			on ������������������._IDRRef = _Reference23294_VT23309._Reference23294_IDRRef
			and _Reference23294_VT23309._Fld23311RRef in (Select �������������������������� From #Temp_GeoData)
		--Inner Join #Temp_GeoData T1 ON ������������������._Fld23302RRef = T1.�����������
		On 
		������������������._Fld23302RRef IN (Select ����������� From #Temp_GeoData) --�����
		AND ������������������._Fld25141 = 0x01--��������� � ������� ��������
		AND (������������������._Fld23301RRef = ������������._Fld3526RRef OR (������������._Fld3526RRef = 0xAC2CBF86E693F63444670FFEB70264EE AND ������������������._Fld23301RRef= 0xAD3F7F5FC4F15DAD4F693CAF8365EC0D) ) --��������
		AND ������������������._Marked = 0x00
OPTION (KEEP PLAN, KEEPFIXED PLAN)
;


With Temp_ExchangeRates AS (
SELECT
	T1._Period AS ������,
	T1._Fld14558RRef AS ������,
	T1._Fld14559 AS ����,
	T1._Fld14560 AS ���������
FROM _InfoRgSL26678 T1 With (NOLOCK)
	)
SELECT
    T2._Fld21408RRef AS ������������������,
    T2._Fld21410_TYPE AS ��������_TYPE,
	T2._Fld21410_RTRef AS ��������_RTRef,
	T2._Fld21410_RRRef AS ��������_RRRef,
	����._Fld21410_TYPE AS �����������_TYPE,
    ����._Fld21410_RTRef AS �����������_RTRef,
    ����._Fld21410_RRRef AS �����������_RRRef,
    T2._Fld23568RRef AS ��������������,
    T2._Fld21424 AS �����������,
    SUM(T2._Fld21411) - SUM(T2._Fld21412) AS ����������
Into #Temp_Remains
FROM
    dbo._AccumRgT21444 T2 With (NOLOCK)
	Left Join _AccumRg21407 ���� With (NOLOCK)
		Inner Join Temp_ExchangeRates With (NOLOCK)
			On ����._Fld21443RRef = Temp_ExchangeRates.������ 
		On T2._Fld21408RRef = ����._Fld21408RRef
		AND T2._Fld21410_RTRef = 0x00000153
		AND ����._Fld21410_RTRef = 0x00000153 --����.����������� ������ ��������.��������������������������
		And ����._Fld21442<>0 AND (����._Fld21442 * Temp_ExchangeRates.���� / Temp_ExchangeRates.��������� >= ����._Fld21982 OR ����._Fld21411 >= ����._Fld21616)
		And ����._Fld21408RRef IN(SELECT
                ������������������
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
                TNomen.������������������
            FROM
                #Temp_Goods TNomen WITH(NOLOCK))) AND (T2._Fld21412 <> 0 OR T2._Fld21411 <> 0)
GROUP BY
    T2._Fld21408RRef,
    T2._Fld21410_TYPE,
    T2._Fld21410_RTRef,
    T2._Fld21410_RRRef,
	����._Fld21410_TYPE,
	����._Fld21410_RTRef,
	����._Fld21410_RRRef,
    T2._Fld23568RRef,
    T2._Fld21424
HAVING
    (SUM(T2._Fld21412) <> 0.0
    OR SUM(T2._Fld21411) <> 0.0)
	AND SUM(T2._Fld21412) - SUM(T2._Fld21411) <> 0.0
OPTION (OPTIMIZE FOR (@P_DateTimeNow='4021-05-07T00:00:00'),KEEP PLAN, KEEPFIXED PLAN)
;

SELECT Distinct
    T1._Fld23831RRef AS ��������������,
    T1._Fld23832 AS �����������,
    T1._Fld23834 AS ������������,
    T1._Fld23833RRef AS ���������������
Into #Temp_WarehouseDates
FROM
    dbo._InfoRg23830 T1 With (NOLOCK)
	Inner Join #Temp_Remains With (NOLOCK)
	ON T1._Fld23831RRef = #Temp_Remains.��������������
	AND T1._Fld23832 = #Temp_Remains.�����������
	AND T1._Fld23833RRef IN (Select ����������� From #Temp_GeoData UNION ALL Select ����������� From #Temp_Goods) 
OPTION (KEEP PLAN, KEEPFIXED PLAN)
;

SELECT
	T1._Fld23831RRef AS ��������������,
	T1._Fld23833RRef AS ���������������,
	MIN(T1._Fld23834) AS ������������ 
Into #Temp_MinimumWarehouseDates
FROM
    dbo._InfoRg23830 T1 With (NOLOCK)
WHERE
    T1._Fld23831RRef IN (
        SELECT
            T2.�������������� AS ��������������
        FROM
            #Temp_Remains T2 WITH(NOLOCK)) 
		AND T1._Fld23832 >= @P_DateTimeNow
		AND T1._Fld23832 <= DateAdd(DAY,2,@P_DateTimeNow)
		AND T1._Fld23833RRef IN (Select ����������� From #Temp_GeoData UNION ALL Select ����������� From #Temp_Goods)
GROUP BY T1._Fld23831RRef,
T1._Fld23833RRef
OPTION (OPTIMIZE FOR (@P_DateTimeNow='4021-05-07T00:00:00'),KEEP PLAN, KEEPFIXED PLAN);

;

SELECT
    T1.������������������,
    T1.����������,
    T1.��������_TYPE,
    T1.��������_RTRef,
    T1.��������_RRRef,
    T1.��������������,
    T1.�����������,
    ISNULL(T3.������������, T2.������������) AS ���������������,
    1 AS ������������,
    ISNULL(T3.���������������, T2.���������������) AS ���������������
INTO #Temp_Sources
FROM
    #Temp_Remains T1 WITH(NOLOCK)
    LEFT OUTER JOIN #Temp_WarehouseDates T2 WITH(NOLOCK)
    ON (T1.�������������� = T2.��������������)
    AND (T1.����������� = T2.�����������)
    LEFT OUTER JOIN #Temp_MinimumWarehouseDates T3 WITH(NOLOCK)
    ON (T1.�������������� = T3.��������������)
    AND (T1.����������� = '2001-01-01 00:00:00')
WHERE
    T1.��������_RTRef = 0x000000E2 OR T1.��������_RTRef = 0x00000150

UNION
ALL
SELECT
    T4.������������������,
    T4.����������,
    T4.��������_TYPE,
    T4.��������_RTRef,
    T4.��������_RRRef,
    T4.��������������,
    T4.�����������,
    T5.������������,
    2,
    T5.���������������
FROM
    #Temp_Remains T4 WITH(NOLOCK)
    INNER JOIN #Temp_WarehouseDates T5 WITH(NOLOCK)
    ON (T4.�������������� = T5.��������������)
    AND (T4.����������� = T5.�����������)
WHERE
    T4.��������_RTRef = 0x00000141

UNION
ALL
SELECT
    T6.������������������,
    T6.����������,
    T6.��������_TYPE,
    T6.��������_RTRef,
    T6.��������_RRRef,
    T6.��������������,
    T6.�����������,
    T7.������������,
    3,
    T7.���������������
FROM
    #Temp_Remains T6 WITH(NOLOCK)
    INNER JOIN #Temp_WarehouseDates T7 WITH(NOLOCK)
    ON (T6.�������������� = T7.��������������)
    AND (T6.����������� = T7.�����������)
WHERE
    NOT T6.�����������_RRRef IS NULL
	And T6.��������_RTRef = 0x00000153
OPTION (KEEP PLAN, KEEPFIXED PLAN)
;

With Temp_ExchangeRates AS (
SELECT
	T1._Period AS ������,
	T1._Fld14558RRef AS ������,
	T1._Fld14559 AS ����,
	T1._Fld14560 AS ���������
FROM _InfoRgSL26678 T1 With (NOLOCK)
	)
SELECT
    T1.������������������,
    T1.��������_TYPE,
    T1.��������_RTRef,
    T1.��������_RRRef,
    T1.��������������,
    T1.���������������,
    T1.�����������,
    T1.���������������,
    CAST(
        (
            CAST(
                (��������������._Fld21442 * T3.����) AS NUMERIC(27, 8)
            ) / T3.���������
        ) AS NUMERIC(15, 2)
    )  AS ����
Into #Temp_SourcesWithPrices
FROM
    #Temp_Sources T1 WITH(NOLOCK)
    INNER JOIN dbo._AccumRg21407 �������������� WITH(NOLOCK)
    LEFT OUTER JOIN Temp_ExchangeRates T3 WITH(NOLOCK)
		ON (��������������._Fld21443RRef = T3.������) 
	ON (T1.������������������ = ��������������._Fld21408RRef)
    AND (
        T1.��������_TYPE = 0x08
        AND T1.��������_RTRef = ��������������._RecorderTRef
        AND T1.��������_RRRef = ��������������._RecorderRRef
    )
OPTION (KEEP PLAN, KEEPFIXED PLAN)
;
With Temp_SupplyDocs AS
(
SELECT
    T1.������������������,
    T1.���������������,
    T1.���������������,
    DATEADD(DAY, 4.0, T1.���������������) AS �������������������, --��� �������� ���������������������
    MIN(T1.����) AS �������������,
    MIN(T1.���� / 100.0 * (100 - 3.0)) AS ������������������ --��� �������� ������������������
FROM
    #Temp_SourcesWithPrices T1 WITH(NOLOCK)
WHERE
    T1.���� <> 0
    AND T1.��������_RTRef = 0x00000153    
GROUP BY
    T1.������������������,
    T1.���������������,
    T1.���������������,
    DATEADD(DAY, 4.0, T1.���������������)--��� �������� ���������������������
)
SELECT
    T2.������������������,
    T2.���������������,
    T2.���������������,
    T2.�������������������,
    T2.�������������,
    T2.������������������,
    MIN(T1.���������������) AS ���������������1,
    MIN(T1.����) AS ����1
Into #Temp_BestPriceAfterClosestDate
FROM
    #Temp_SourcesWithPrices T1 WITH(NOLOCK)
    INNER JOIN Temp_SupplyDocs T2 WITH(NOLOCK)
    ON (T1.������������������ = T2.������������������)
    AND (T1.��������������� >= T2.���������������)
    AND (T1.��������������� <= T2.�������������������)
    AND (T1.���� <= T2.������������������)
    AND (T1.���� <> 0)
GROUP BY
    T2.������������������,
    T2.���������������,
    T2.�������������������,
    T2.�������������,
    T2.������������������,
    T2.���������������
OPTION (KEEP PLAN, KEEPFIXED PLAN)

SELECT
    T1.������������������,
    T1.���������������,
    Min(ISNULL(T2.���������������1, T1.���������������)) AS ���������������
Into #Temp_SourcesCorrectedDate
FROM
    #Temp_Sources T1 WITH(NOLOCK)
    LEFT OUTER JOIN #Temp_BestPriceAfterClosestDate T2 WITH(NOLOCK)
    ON (T1.������������������ = T2.������������������)
    AND (T1.��������������� = T2.���������������)
    AND (T1.��������������� = T2.���������������)
    AND (T1.������������ = 3)
GROUP BY
	T1.������������������,
	T1.���������������
OPTION (KEEP PLAN, KEEPFIXED PLAN)
;

With Temp_ClosestDate AS
(SELECT
T1.������������������,
T1.���������������,
Cast(MIN(T1.���������������)as datetime) AS ���������������
FROM #Temp_Sources T1 WITH(NOLOCK)
GROUP BY T1.������������������,
T1.���������������
)
SELECT
            T4.������������������,
            Min(T4.���������������)AS ���������������,
            T4.���������������
		Into #Temp_T3
        FROM
            #Temp_Sources T4 WITH(NOLOCK)
            LEFT OUTER JOIN Temp_ClosestDate T5 WITH(NOLOCK)
            ON (T4.������������������ = T5.������������������)
            AND (T4.��������������� = T5.���������������)
            AND (T4.������������ = 1)
			AND T4.��������������� <= DATEADD(DAY, 4, T5.���������������)
Group by T4.������������������, T4.���������������
OPTION (KEEP PLAN, KEEPFIXED PLAN)


SELECT
    T1.������������������,
	T1.article,
	T1.code,
    ISNULL(T3.���������������, T2.���������������) AS ���������������,
    MIN(ISNULL(T3.���������������, T2.���������������)) AS �������������,
    1 AS ����������,
    T1.���,
    T1.�����,
    T1.�������������������,
    T1.������������������,
	T1.����������������������������������,
	0 AS PickUp
into #Temp_ClosestDatesByGoods
FROM
    #Temp_Goods T1 WITH(NOLOCK)	
    LEFT JOIN #Temp_SourcesCorrectedDate T2 WITH(NOLOCK)
		LEFT JOIN  #Temp_T3 T3 ON (T2.������������������ = T3.������������������) 
			And T2.��������������� = T3.���������������
    ON (T1.������������������ = T2.������������������) 
		AND ISNULL(T3.���������������, T2.���������������) IN (Select ����������� From #Temp_GeoData) 
Where 
	T1.����������� IS NULL
GROUP BY
    T1.������������������,
	T1.article,
	T1.code,
	ISNULL(T3.���������������, T2.���������������),
    T1.���,
    T1.�����,
    T1.�������������������,
    T1.����������,
    T1.������������������,
	T1.����������������������������������
UNION ALL
SELECT
    T1.������������������,
	T1.article,
	T1.code,
    ISNULL(T3.���������������, T2.���������������) AS ���������������,
    MIN(ISNULL(T3.���������������, T2.���������������)) AS �������������,
    1 AS ����������,
    T1.���,
    T1.�����,
    T1.�������������������,
    T1.������������������,
	T1.����������������������������������,
	1 AS PickUp
FROM
    #Temp_Goods T1 WITH(NOLOCK)	
    LEFT JOIN #Temp_SourcesCorrectedDate T2 WITH(NOLOCK)
		LEFT JOIN  #Temp_T3 T3 ON (T2.������������������ = T3.������������������) 
			And T2.��������������� = T3.���������������
    ON (T1.������������������ = T2.������������������) 
		AND T1.����������� = ISNULL(T3.���������������, T2.���������������)
Where 
	NOT T1.����������� IS NULL
GROUP BY
    T1.������������������,
	T1.article,
	T1.code,
	ISNULL(T3.���������������, T2.���������������),
    T1.���,
    T1.�����,
    T1.�������������������,
    T1.����������,
    T1.������������������,
	T1.����������������������������������
OPTION (KEEP PLAN, KEEPFIXED PLAN)

SELECT
    T1.������������������,
	T1.article,
	T1.code,
    T1.���������������,
    T1.���,
    T1.�����,
    T1.�������������������,
    T1.������������������,
    MIN(
        CASE
            WHEN T2.��������_RTRef = 0x00000141
            OR T2.��������_RTRef = 0x00000153
                THEN DATEADD(SECOND, DATEDIFF(SECOND, @P_EmptyDate, T1.����������������������������������), T1.�������������)
            ELSE T1.�������������
        END        
    ) AS ���������������,
	T1.PickUp
Into #Temp_ShipmentDates
FROM
    #Temp_ClosestDatesByGoods T1 WITH(NOLOCK)
    LEFT OUTER JOIN #Temp_Sources T2 WITH(NOLOCK)
    ON (T1.������������������ = T2.������������������)
    AND (T1.��������������� = T2.���������������)
    AND (T1.������������� = T2.���������������)
Where 
	NOT T1.������������� IS NULL
GROUP BY
    T1.������������������,
	T1.article,
	T1.code,
    T1.���������������,
    T1.���,
    T1.�����,
    T1.�������������������,
    T1.������������������,
	T1.PickUp
OPTION (KEEP PLAN, KEEPFIXED PLAN)



SELECT
    T1.������������������,
	T1.article,
	T1.code,
    MIN(T1.���������������) AS ������������,
    T1.���,
    T1.�����,
    T1.�������������������,
    T1.������������������,
	T1.PickUp
Into #Temp_ShipmentDatesDeliveryCourier
FROM 
    #Temp_ShipmentDates T1 WITH(NOLOCK)
Where T1.PickUp = 0
GROUP BY
    T1.������������������,
	T1.article,
	T1.code,
    T1.���,
    T1.�����,
    T1.�������������������,
    T1.������������������,
	T1.PickUp
OPTION (KEEP PLAN, KEEPFIXED PLAN)

SELECT
    T1.������������������,
	T1.article,
	T1.code,
    MIN(T1.���������������) AS ������������,
	T1.���������������
Into #Temp_ShipmentDatesPickUp
FROM 
    #Temp_ShipmentDates T1 WITH(NOLOCK)
Where T1.PickUp = 1
GROUP BY
    T1.������������������,
	T1.article,
	T1.code,
	T1.���������������
OPTION (KEEP PLAN, KEEPFIXED PLAN);


--Select * From _Reference23612_VT23613
--Inner Join _Reference23612 On _IDRRef = _Reference23612_IDRRef
--Left Join dbo._Reference226 ������ ON ������._Fld23620RRef = _Reference23612._IDRRef
--Where ������._IDRRef IN (Select ��������������� From #Temp_ShipmentDatesPickUp)

WITH Tdate(date1) AS (
    /*��� ��������� ������ ��� ���������� ����� ���� ��������� �������*/
    SELECT 
        Case When @P_DateTimePeriodEnd > CAST(CAST(#Temp_ShipmentDatesPickUp.������������  AS DATE) AS DATETIME) Then
		DateAdd(day, 1,
		@P_DateTimePeriodEnd
		)
		else 
		CAST(CAST(#Temp_ShipmentDatesPickUp.������������  AS DATE) AS DATETIME) 
		End
	From #Temp_ShipmentDatesPickUp
    UNION
    ALL
    SELECT 
        DateAdd(day, 1, Tdate.date1)
    FROM
        Tdate
		Inner Join #Temp_ShipmentDatesPickUp 
		ON Tdate.date1 < DateAdd(DAY, 10, CAST(CAST(#Temp_ShipmentDatesPickUp.������������  AS DATE) AS DATETIME))
	
)
Select * From Tdate

--WITH Tdate(date1) AS (
--    /*��� ��������� ������ ��� ���������� ����� ���� ��������� �������*/
--    SELECT
--        Case When @P_DateTimePeriodEnd > CAST(CAST(#Temp_ShipmentDatesPickUp.������������  AS DATE) AS DATETIME) Then
--		DateAdd(day, 1,
--		@P_DateTimePeriodEnd
--		)
--		else 
--		CAST(CAST(#Temp_ShipmentDatesPickUp.������������  AS DATE) AS DATETIME) 
--		End
--	From #Temp_ShipmentDatesPickUp
--    UNION
--    ALL
--    SELECT
--        DateAdd(day, 1, Tdate.date1)
--    FROM
--        Tdate
--		Inner Join #Temp_ShipmentDatesPickUp 
--		ON Tdate.date1 < DateAdd(DAY, 10, CAST(CAST(#Temp_ShipmentDatesPickUp.������������  AS DATE) AS DATETIME)) 
--)
--SELECT
--	#Temp_ShipmentDatesPickUp.������������������,
--	#Temp_ShipmentDatesPickUp.article,
--	#Temp_ShipmentDatesPickUp.code,
--	#Temp_ShipmentDatesPickUp.������������,
--	#Temp_ShipmentDatesPickUp.���������������,
--	DATEADD(
--        SECOND,
--        CAST(
--            DATEDIFF(SECOND, @P_EmptyDate, ���������������._Fld23617) AS NUMERIC(12)
--        ),
--        date1
--    ) As �����������,
--	DATEADD(
--        SECOND,
--        CAST(
--            DATEDIFF(SECOND, @P_EmptyDate, ���������������._Fld23618) AS NUMERIC(12)
--        ),
--        date1
--    ) As ��������������
--FROM
--    #Temp_ShipmentDatesPickUp 
--		Inner Join Tdate
--			Inner Join _Reference23612_VT23613 As ��������������� 
--			ON (case when DATEPART ( dw , Tdate.date1 ) = 1 then 7 else DATEPART ( dw , Tdate.date1 ) -1 END) = ���������������._Fld23615
--				AND ���������������._Fld25265 = 0x00 --�� ��������
--			Inner Join _Reference23612 On _IDRRef = _Reference23612_IDRRef
--			Left Join dbo._Reference226 ������ ON ������._Fld23620RRef = _Reference23612._IDRRef
--		On DATEADD(
--			SECOND,
--			CAST(
--            DATEDIFF(SECOND, @P_EmptyDate, ���������������._Fld23618) AS NUMERIC(12)
--			),
--			Tdate.date1) > #Temp_ShipmentDatesPickUp.������������ 
--			AND ������._IDRRef = #Temp_ShipmentDatesPickUp.���������������




select * from #Temp_ShipmentDatesPickUp



;
SELECT 
    T1._Period AS ������,
    T1._Fld25112RRef AS ������������������,
	DATEADD(
        SECOND,
        CAST(
            DATEDIFF(SECOND, @P_EmptyDate, T1._Fld25202) AS NUMERIC(12)
        ),
        T1._Period
    ) AS �����������
Into #Temp_Intervals
FROM
    dbo._AccumRg25110 T1 With (NOLOCK)
    INNER JOIN dbo._Reference23294 T2 With (NOLOCK) ON (T1._Fld25112RRef = T2._IDRRef)
    AND (T1._Fld25202 >= T2._Fld25137)
    AND (NOT (((@P_TimeNow >= T2._Fld25138))))
	Inner Join #Temp_GeoData ON T1._Fld25111RRef = #Temp_GeoData.�������
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
OPTION (OPTIMIZE FOR (@P_DateTimePeriodBegin='4021-05-07T00:00:00'),KEEP PLAN, KEEPFIXED PLAN);


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
    AND T3._Fld25111RRef in (Select ������� From #Temp_GeoData)
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
OPTION (OPTIMIZE FOR (@P_DateTimePeriodBegin='4021-05-07T00:00:00'),KEEP PLAN, KEEPFIXED PLAN);

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
    AND T5._Fld25111RRef in (Select ������� From #Temp_GeoData) 
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
OPTION (OPTIMIZE FOR (@P_DateTimePeriodBegin='4021-05-07T00:00:00'),KEEP PLAN, KEEPFIXED PLAN);
;

With Temp_DeliveryPower AS
(
SELECT
    CAST(
        SUM(
            CASE
                WHEN (����������������._RecordKind = 0.0) THEN ����������������._Fld25107
                ELSE -(����������������._Fld25107)
            END
        ) AS NUMERIC(16, 3)
    ) AS �����������,
    CAST(
        SUM(
            CASE
                WHEN (����������������._RecordKind = 0.0) THEN ����������������._Fld25108
                ELSE -(����������������._Fld25108)
            END
        ) AS NUMERIC(16, 3)
    ) AS �����������,
    CAST(
        SUM(
            CASE
                WHEN (����������������._RecordKind = 0.0) THEN ����������������._Fld25201
                ELSE -(����������������._Fld25201)
            END
        ) AS NUMERIC(16, 2)
    ) AS �������������������������,
    CAST(CAST(����������������._Period  AS DATE) AS DATETIME) AS ����
FROM
    dbo._AccumRg25104 ���������������� With (NOLOCK)
	--Inner Join #Temp_GeoData ON ����������������._Fld25105RRef = #Temp_GeoData.��������������������������
WHERE
    ����������������._Period >= @P_DateTimePeriodBegin
    AND ����������������._Period <= @P_DateTimePeriodEnd
	AND ����������������._Fld25105RRef IN (Select �������������������������� From  #Temp_GeoData)
GROUP BY
    CAST(CAST(����������������._Period  AS DATE) AS DATETIME)
)
SELECT
    T1.article,
	T1.code,
    MIN(
        ISNULL(
            T3.�����������,
CASE
                WHEN (T1.������������ > DATEADD(SECOND,-1,@P_DateTimePeriodEnd)) THEN DATEADD(
                    DAY,
                    1.0,
                    CAST(CAST(T1.������������ AS DATE) AS DATETIME)
                )
                ELSE DATEADD(DAY,1,@P_DateTimePeriodEnd)
            END
        )
    ) AS available_date_courier,
    MIN(ISNULL(T4.���������������,@P_MaxDate)) AS available_date_self
FROM
    #Temp_ShipmentDatesDeliveryCourier T1 WITH(NOLOCK)
    Left JOIN Temp_DeliveryPower T2 WITH(NOLOCK)
    Inner JOIN #Temp_Intervals T3 WITH(NOLOCK)
		ON (T3.������ = T2.����) 
	ON (T2.����������� >= T1.���)
    AND (T2.����������� >= T1.�����)
    AND (T2.������������������������� >= T1.�������������������)
    AND (
        T2.���� >= 
		CAST(CAST(T1.������������ AS DATE) AS DATETIME)
    )
    AND (T3.������������������ = T1.������������������)
    AND (T3.����������� >= T1.������������)
	AND T1.PickUp = 0
    Left JOIN #Temp_ShipmentDates T4 WITH(NOLOCK)
    ON (T1.������������������ = T4.������������������)
    AND (T4.��������������� IN (NULL)) --������ ���
GROUP BY
    T1.article,
	T1.code
OPTION (OPTIMIZE FOR (@P_DateTimePeriodBegin='4021-05-07T00:00:00',@P_DateTimePeriodEnd='4021-05-11T00:00:00'),KEEP PLAN, KEEPFIXED PLAN);


DROP TABLE #Temp_GeoData
DROP TABLE #Temp_WarehouseDates
DROP TABLE #Temp_MinimumWarehouseDates
DROP TABLE #Temp_GoodsBegin
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
DROP TABLE #Temp_ShipmentDatesPickUp