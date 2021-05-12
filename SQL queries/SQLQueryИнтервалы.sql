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

DECLARE @P_AdressCode nvarchar(20);

DECLARE @P_DateTimeNow datetime2(3);
DECLARE @P_DateTimePeriodBegin datetime2(3);
DECLARE @P_DateTimePeriodEnd datetime2(3);
DECLARE @P_TimeNow datetime2(3);
DECLARE @P_EmptyDate datetime2(3);
DECLARE @P_MaxDate datetime2(3);


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
  
 Set @P_AdressCode = '47175'--'47175000000'--'3298156' --��� ������
 
 Set @P_DateTimeNow = '4021-04-30 10:11:00'
 Set @P_DateTimePeriodBegin = '4021-04-30 00:00:00'
 Set @P_DateTimePeriodEnd = '4021-05-05 00:00:00'
 Set @P_TimeNow = '2001-01-01 10:11:00'
 Set @P_EmptyDate = '2001-01-01 00:00:00'
 Set @P_MaxDate = '5999-11-11 00:00:00'


 DECLARE @P_Credit numeric(2);
 Set @P_Credit = 1;

 DECLARE @P_Floor numeric(2);
 Set @P_Floor = 4;

 DECLARE @P_DaysToShow numeric(2);
 Set @P_DaysToShow = 7;

  DECLARE @P_GeoCode nvarchar(4);
 Set @P_GeoCode = '2';

Select
	IsNull(_Reference114_VT23370._Fld23372RRef,�������._Fld23104RRef) As �����������,
	������������._ParentIDRRef As ��������������������������,
	��������������������._Description AS ��������������������������������,
	�������._IDRRef As �������
Into #Temp_GeoData
From dbo._Reference114 ������� With (NOLOCK)
	Inner Join _Reference114_VT23370 With (NOLOCK)
	on _Reference114_VT23370._Reference114_IDRRef = �������._IDRRef
	Inner Join _Reference99 ������������ With (NOLOCK)
	on �������._Fld2847RRef = ������������._IDRRef
	Inner Join _Reference99 �������������������� With (NOLOCK)
	on ������������._ParentIDRRef = ��������������������._IDRRef
where
	(@P_GeoCode = '' AND 
�������._IDRRef IN (
	Select Top 1 --�� ������ ������� �������
	��������._Fld2785RRef 
	From dbo._Reference112 �������� With (NOLOCK)
	Where ��������._Fld25155 = @P_AdressCode))
OR �������._Fld21249 = @P_GeoCode 

/*�������� ������� ������� � �� ���������� ������� �� ��*/
Create Table #Temp_GoodsBegin 
(	
	Article nvarchar(20), 
	code nvarchar(20), 
    quantity int
)

INSERT INTO 
	#Temp_GoodsBegin ( 
		Article, code, quantity
	)
VALUES
	(@P_Article1,@P_Code1,1),
	(@P_Article2,@P_Code2,2)
	--(@P3,3),
	--(@P5,4),
	--(@P6,3),
	--(@P7,2),
	--(@P8,1)
	;


Select 
	������������._IDRRef AS ������������������,
	��������._IDRRef AS ��������������,
	Sum(#Temp_GoodsBegin.quantity) As ����������	
INTO #Temp_Goods
From 
	#Temp_GoodsBegin 
	Inner Join 	dbo._Reference149 ������������ With (NOLOCK) 
		ON #Temp_GoodsBegin.code is NULL and #Temp_GoodsBegin.Article = ������������._Fld3480
	Inner Join dbo._Reference256 �������� With (NOLOCK)
		On 
		��������._OwnerID_TYPE = 0x08  
		AND ��������.[_OwnerID_RTRef] = 0x00000095
		AND ������������._IDRRef = ��������._OwnerID_RRRef		
		And ��������._Fld6003RRef = ������������._Fld3489RRef
		AND ��������._Marked = 0x00
Group By 
	������������._IDRRef,
	��������._IDRRef
union
Select 
	������������._IDRRef,
	��������._IDRRef,
	Sum(#Temp_GoodsBegin.quantity)	
From 
	#Temp_GoodsBegin 
	Inner Join 	dbo._Reference149 ������������ With (NOLOCK) 
		ON #Temp_GoodsBegin.code is not NULL and #Temp_GoodsBegin.code = ������������._Code
	Inner Join dbo._Reference256 �������� With (NOLOCK)
		On 
		��������._OwnerID_TYPE = 0x08  
		AND ��������.[_OwnerID_RTRef] = 0x00000095
		AND ������������._IDRRef = ��������._OwnerID_RRRef		
		And ��������._Fld6003RRef = ������������._Fld3489RRef
		AND ��������._Marked = 0x00
Group By 
	������������._IDRRef,
	��������._IDRRef

;
/*����� �������*/

/*������� ������� � ����� ��� ������� ���������*/
SELECT
CAST(SUM((T2._Fld6000 * T1.����������)) AS NUMERIC(36, 6)) AS ���,
CAST(SUM((T2._Fld6006 * T1.����������)) AS NUMERIC(38, 8)) AS �����,
MAX(T2._Fld6001) AS ������,
MAX(T2._Fld6002) AS �������,
MAX(T2._Fld6009) AS ������,
0x00000000000000000000000000000000  AS �������
Into #Temp_Size
FROM #Temp_Goods T1 WITH(NOLOCK)
INNER JOIN dbo._Reference256 T2 With (NOLOCK) 
ON (T2._IDRRef = T1.��������������) AND (T1.�������������� <> 0x00000000000000000000000000000000)

/*������� ������� �����*/
SELECT
    TOP 1 CASE
        WHEN (
            ISNULL(
                T1.�������,
                0x00000000000000000000000000000000
            ) <> 0x00000000000000000000000000000000
        ) THEN T1.�������
        WHEN (T4._Fld21339 > 0)
        AND (T1.��� >= T4._Fld21339)
        AND (T5._Fld21337 > 0)
        AND (T1.����� >= T5._Fld21337) THEN 0xAD3F7F5FC4F15DAD4F693CAF8365EC0D --��� � ���
        WHEN (T2._Fld21168 > 0)
        AND (T1.��� >= T2._Fld21168) THEN 0xAD3F7F5FC4F15DAD4F693CAF8365EC0D --���
        WHEN (T3._Fld21166 > 0)
        AND (T1.����� >= T3._Fld21166) THEN 0xAD3F7F5FC4F15DAD4F693CAF8365EC0D --���
        WHEN (T6._Fld21580 > 0)
        AND (T1.������ > 0)
        AND (T1.������� > 0)
        AND (T1.������ >0) THEN CASE
            WHEN (T1.������ >= T6._Fld21580) OR (T1.������� >= T6._Fld21580) OR (T1.������ >= T6._Fld21580) THEN 0xAD3F7F5FC4F15DAD4F693CAF8365EC0D --���
            ELSE 0x8AB421D483ABE88A4C4C9928262FFB0D --���
        END
        ELSE 0x8AB421D483ABE88A4C4C9928262FFB0D --���
    END AS �������
Into #Temp_Dimensions
FROM
    #Temp_Size T1 WITH(NOLOCK)
    INNER JOIN dbo._Const21167 T2 ON 1 = 1
    INNER JOIN dbo._Const21165 T3 ON 1 = 1
    INNER JOIN dbo._Const21338 T4 ON 1 = 1
    INNER JOIN dbo._Const21336 T5 ON 1 = 1
    INNER JOIN dbo._Const21579 T6 ON 1 = 1

SELECT
    COUNT_BIG(T1.������������������) AS ���������������,
    T1.������������������ AS ������������������,
    T2._Fld6000 * T1.���������� AS ���,
    T2._Fld6006 * T1.���������� AS �����,
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
    END  AS �������������������������
Into #Temp_Weight
FROM
    #Temp_Goods T1 WITH(NOLOCK)
    LEFT OUTER JOIN dbo._Reference256 T2 With (NOLOCK) ON (
        0x08 = T2._OwnerID_TYPE
        AND 0x00000095 = T2._OwnerID_RTRef
        AND T1.�������������� = T2._IDRRef
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
    T1.������������������,
    T2._Fld6000 * T1.����������,
    T2._Fld6006 * T1.����������,
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
        WHEN (IsNull(T2.�������,0x8AB421D483ABE88A4C4C9928262FFB0D) = 0x8AB421D483ABE88A4C4C9928262FFB0D) THEN 7 --���
        ELSE 14
    END AS ���������������,
    CASE
        WHEN (@P_Credit = 1) --������ ���������
            THEN T3.Fld24103_
        ELSE 0
    END AS �������������������,
    CASE
        WHEN (T1.�������������������������������� LIKE '%�����%') --������������ ���� ��������
        AND (IsNull(T2.�������,0x8AB421D483ABE88A4C4C9928262FFB0D) = 0x8AB421D483ABE88A4C4C9928262FFB0D) THEN T3.Fld24091_ --���
        WHEN (T1.�������������������������������� LIKE '%�����%')
        AND (IsNull(T2.�������,0x8AB421D483ABE88A4C4C9928262FFB0D) = 0xAD3F7F5FC4F15DAD4F693CAF8365EC0D) THEN T3.Fld24092_ --���
        ELSE 0
    END AS ���������������
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
    T2.Fld24090_ * SUM(T1.���������������) AS ����������������������,
    CASE
        WHEN SUM(T1.�����) < 0.8
			AND SUM(T1.���) < 5.0 THEN T2.Fld24094_
        WHEN SUM(T1.�����) < 0.8
			AND SUM(T1.���) >= 5.0
			AND SUM(T1.���) < 20.0 THEN T2.Fld24095_
        WHEN SUM(T1.�����) < 0.8
			AND SUM(T1.���) >= 20.0
			AND SUM(T1.���) < 65.0 THEN T2.Fld24096_
        WHEN SUM(T1.�����) < 0.8
			AND SUM(T1.���) >= 65.0
			AND SUM(T1.���) < 120.0 THEN T2.Fld24097_
        WHEN SUM(T1.�����) < 0.8
			AND SUM(T1.���) >= 120.0
			AND SUM(T1.���) < 250.0 THEN T2.Fld24098_
        WHEN SUM(T1.�����) < 0.8
			AND SUM(T1.���) >= 250.0
			AND SUM(T1.���) < 400.0 THEN T2.Fld26611_
        WHEN SUM(T1.�����) < 0.8
			AND SUM(T1.���) >= 400.0 THEN T2.Fld26612_
        WHEN SUM(T1.�����) >= 0.8
			AND SUM(T1.���) < 120.0 THEN T2.Fld24099_
        WHEN SUM(T1.�����) >= 0.8
			AND SUM(T1.���) >= 120.0
			AND SUM(T1.���) < 250.0 THEN T2.Fld24100_
        WHEN SUM(T1.�����) >= 0.8
			AND SUM(T1.���) >= 250.0
			AND SUM(T1.���) < 600.0 THEN T2.Fld26613_
        WHEN SUM(T1.�����) >= 0.8
			AND SUM(T1.���) >= 600.0 THEN T2.Fld26614_
    END As ���������������,
    T2.Fld24089_ As ����������������,
    SUM(T1.�������������������������) As �������������������
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
/*����� ������������ �������� ���� � ��� �������� �����*/
SELECT
    ISNULL(T2.����������������, 0) + ISNULL(T2.����������������������, 0) + ISNULL(T1.���������������, 0) + ISNULL(T2.�������������������, 0) + ISNULL(T2.���������������, 0) + ISNULL(T1.�������������������, 0) AS ���������������
Into #Temp_TimeService
FROM
    #Temp_TimeByOrders T1 WITH(NOLOCK)
    LEFT OUTER JOIN #Temp_Time1 T2 WITH(NOLOCK)
    ON 1 = 1
;

/*������ ������������*/
Select ������������������._IDRRef AS ������������������,
	������������������._Fld23302RRef AS �����,
	������������������._Fld25137 AS �������������������������,
	������������������._Fld25138 AS �����������������,
	������������������._Fld25139 AS ������������������������,
	������������������._Fld25140 AS ����������������,
	IsNull(������������������._Fld25519, @P_EmptyDate)AS ����������������������������������,
	1 AS ��������
Into #Temp_PlanningGroups
From
dbo._Reference23294 ������������������ With (NOLOCK)
	Inner Join dbo._Reference23294_VT23309 With (NOLOCK)
		on ������������������._IDRRef = _Reference23294_VT23309._Reference23294_IDRRef
		and _Reference23294_VT23309._Fld23311RRef in (Select �������������������������� From #Temp_GeoData)
	--AND 
	--������������������._Fld23302RRef IN (Select ��������������� From #Temp_DateAvailable) --�����
	AND ������������������._Fld25141 = 0x01--��������� � ������� ��������
	AND ������������������._Fld23301RRef IN (Select ������� From #Temp_Dimensions With (NOLOCK))  --��������
	AND ������������������._Marked = 0x00
UNION ALL
Select 
	�������������._IDRRef AS ������������������,
	������������������._Fld23302RRef AS �����,
	�������������._Fld25137 AS �������������������������,
	�������������._Fld25138 AS �����������������,
	�������������._Fld25139 AS ������������������������,
	�������������._Fld25140 AS ����������������,
	IsNull(�������������._Fld25519, @P_EmptyDate)AS ����������������������������������,
	0
From
	dbo._Reference23294 ������������������ With (NOLOCK)
	Inner Join dbo._Reference23294_VT23309	With (NOLOCK)	
		on ������������������._IDRRef = _Reference23294_VT23309._Reference23294_IDRRef
		and _Reference23294_VT23309._Fld23311RRef in (Select �������������������������� From #Temp_GeoData)
	Left Join dbo._Reference23294_VT26527 With (NOLOCK)
		Inner Join dbo._Reference23294 �������������
			On  _Reference23294_VT26527._Fld26529RRef = �������������._IDRRef 
		on ������������������._IDRRef = _Reference23294_VT26527._Reference23294_IDRRef

Where 
	--������������������._Fld23302RRef IN (Select ��������������� From #Temp_DateAvailable) --�����
	--AND 
	������������������._Fld25141 = 0x01--��������� � ������� ��������
	AND ������������������._Fld23301RRef IN (Select ������� From #Temp_Dimensions)  --��������
	AND ������������������._Marked = 0x00
	AND NOT �������������._IDRRef = NULL

;
/*������ ���������� ������� ��������� ����������� ���� ��������*/
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
		Inner Join Temp_ExchangeRates 
			On ����._Fld21443RRef = Temp_ExchangeRates.������ 
		On T2._Fld21408RRef = ����._Fld21408RRef
		AND T2._Fld21410_RTRef = ����._Fld21410_RTRef
		AND T2._Fld21410_RRRef = ����._Fld21410_RRRef
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
            OR (T2._Fld21424 >= @P_DateTimeNow)
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

SELECT Distinct
    T1._Fld23831RRef AS ��������������,
    T1._Fld23832 AS �����������,
    T1._Fld23834 AS ������������,
    T1._Fld23833RRef AS ���������������
Into #Temp_WarehouseDates
FROM
    dbo._InfoRg23830 T1 With (NOLOCK)
	Inner Join #Temp_Remains
	ON T1._Fld23831RRef = #Temp_Remains.��������������
	AND T1._Fld23832 = #Temp_Remains.�����������
	AND T1._Fld23833RRef IN (Select ����������� From #Temp_GeoData)


   
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
		AND T1._Fld23832 > @P_DateTimeNow
		AND T1._Fld23832 <= DateAdd(DAY,2,@P_DateTimeNow)
		AND 
		T1._Fld23833RRef IN (Select ����������� From #Temp_GeoData)
GROUP BY T1._Fld23831RRef,
T1._Fld23833RRef
OPTION (OPTIMIZE FOR (@P_DateTimeNow='4021-04-14 15:43:00'));

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
	DATEADD(SECOND, DATEDIFF(SECOND, @P_EmptyDate, IsNull(#Temp_PlanningGroups.����������������������������������,@P_EmptyDate)), T5.������������),
    --T5.������������,
    2,
    T5.���������������
FROM
    #Temp_Remains T4 WITH(NOLOCK)
    INNER JOIN #Temp_WarehouseDates T5 WITH(NOLOCK)
    ON (T4.�������������� = T5.��������������)
    AND (T4.����������� = T5.�����������)
	Left Join #Temp_PlanningGroups On T5.��������������� = #Temp_PlanningGroups.�����
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
	DATEADD(SECOND, DATEDIFF(SECOND, @P_EmptyDate, IsNull(#Temp_PlanningGroups.����������������������������������,@P_EmptyDate)), T7.������������),
    --T7.������������,
    3,
    T7.���������������
FROM
    #Temp_Remains T6 WITH(NOLOCK)
    INNER JOIN #Temp_WarehouseDates T7 WITH(NOLOCK)
    ON (T6.�������������� = T7.��������������)
    AND (T6.����������� = T7.�����������)
	Left Join #Temp_PlanningGroups With (NOLOCK) On T7.��������������� = #Temp_PlanningGroups.�����
WHERE
    NOT T6.�����������_RRRef IS NULL
	And T6.��������_RTRef = 0x00000153
;



;
With TempSourcesGrouped AS
(
Select
	T1.������������������ AS ������������������,
	Sum(T1.����������) AS ����������,
	T1.��������������� AS ���������������,
	T1.��������������� AS ���������������
From
	#Temp_Sources T1
	
Group by
	T1.������������������,
	T1.���������������,
	T1.���������������
)
Select
	���������1.������������������ AS ������������,
	���������1.��������������� AS ���������������,
	���������1.��������������� AS ���������������,
	Sum(��������2.����������) AS ����������
Into #Temp_AvailableGoods
From
	TempSourcesGrouped AS ���������1
		Left Join TempSourcesGrouped AS ��������2
		On ���������1.������������������ = ��������2.������������������
		AND ���������1.��������������� = ��������2.���������������
			AND ���������1.��������������� >= ��������2.���������������
	
Group by
	���������1.������������������,
	���������1.���������������,
	���������1.���������������
;


With Temp_ExchangeRates AS (
SELECT
	T1._Period AS ������,
	T1._Fld14558RRef AS ������,
	T1._Fld14559 AS ����,
	T1._Fld14560 AS ���������
FROM _InfoRgSL26678 T1
	)
SELECT
    T1.������������������,
	T1.����������,
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
    INNER JOIN dbo._AccumRg21407 �������������� With (NOLOCK)
    LEFT OUTER JOIN Temp_ExchangeRates T3 WITH(NOLOCK)
    ON (��������������._Fld21443RRef = T3.������) ON (T1.������������������ = ��������������._Fld21408RRef)
    AND (
        T1.��������_TYPE = 0x08
        AND T1.��������_RTRef = ��������������._RecorderTRef
        AND T1.��������_RRRef = ��������������._RecorderRRef
    )
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

SELECT
    T1.������������������,
	T1.����������,
    T1.��������_TYPE,
    T1.��������_RTRef,
    T1.��������_RRRef,
    T1.��������������,
    T1.���������������,
    T1.�����������,
    ISNULL(T2.���������������1, T1.���������������) AS ���������������,
    T1.������������
Into #Temp_SourcesCorrectedDate
FROM
    #Temp_Sources T1 WITH(NOLOCK)
    LEFT OUTER JOIN #Temp_BestPriceAfterClosestDate T2 WITH(NOLOCK)
    ON (T1.������������������ = T2.������������������)
    AND (T1.��������������� = T2.���������������)
    AND (T1.��������������� = T2.���������������)
    AND (T1.������������ = 3)
;
With Temp_ClosestDate AS
(SELECT
T1.������������������,
T1.���������������,
MIN(T1.���������������) AS ���������������
FROM #Temp_Sources T1 WITH(NOLOCK)
GROUP BY T1.������������������,
T1.���������������
)
Select 
	T4.������������������ AS ������������������,
	T4.��������������� AS ���������������,
	Min(T4.�������������) AS �������������
into #Temp_ClosestDatesByGoods
From 
(SELECT
    T1.������������������,
    ISNULL(T3.���������������, T2.���������������) AS ���������������,
    MIN(ISNULL(T3.���������������, T2.���������������)) AS �������������

FROM
    #Temp_Goods T1 WITH(NOLOCK)
    LEFT OUTER JOIN #Temp_SourcesCorrectedDate T2 WITH(NOLOCK)
    ON (T1.������������������ = T2.������������������)
    LEFT OUTER JOIN (
        SELECT
            T4.������������������,
            T4.���������������,
            T4.���������������,
            T5.��������������� AS �������������
        FROM
            #Temp_Sources T4 WITH(NOLOCK)
            LEFT OUTER JOIN Temp_ClosestDate T5 WITH(NOLOCK)
            ON (T4.������������������ = T5.������������������)
            AND (T4.��������������� = T5.���������������)
            AND (T4.������������ = 1)
    ) T3 ON (T1.������������������ = T3.������������������)
    AND (
        T3.��������������� <= DATEADD(DAY, 4, T3.�������������) --��� �������� ���������������������
    )
	Where T1.���������� = 1
GROUP BY
    T1.������������������,
    ISNULL(T3.���������������, T2.���������������)
Union ALL
Select 
	#Temp_Goods.������������������,
	#Temp_AvailableGoods.���������������,
	Min(#Temp_AvailableGoods.���������������)
From #Temp_Goods With (NOLOCK)
	Left Join #Temp_AvailableGoods With (NOLOCK) 
		On #Temp_Goods.������������������ = #Temp_AvailableGoods.������������
		AND #Temp_Goods.���������� <= #Temp_AvailableGoods.����������
Where
	#Temp_Goods.���������� > 1
Group By
	#Temp_Goods.������������������,
	#Temp_AvailableGoods.���������������) T4
Group by 
	T4.������������������,
	T4.���������������

Select
    Top 1 
	Max(#Temp_ClosestDatesByGoods.�������������) AS DateAvailable, 
��������������� AS ���������������
Into #Temp_DateAvailable
from #Temp_ClosestDatesByGoods With (NOLOCK)
Group by ���������������
Order by DateAvailable ASC
/*��� ���������� ������� ����������� ����. ����� ���������� ����� ���� ����� ���������� �� �������*/

/*�������� ��������*/
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
Into #Temp_DeliveryPower
FROM
    dbo._AccumRg25104 ���������������� With (NOLOCK),
	--Inner Join #Temp_DateAvailable On CAST(CAST(����������������._Period  AS DATE) AS DATETIME) >= CAST(CAST(#Temp_DateAvailable.DateAvailable  AS DATE) AS DATETIME),
	#Temp_Size With (NOLOCK),
	#Temp_TimeService With (NOLOCK)

WHERE
    ����������������._Period >= @P_DateTimePeriodBegin
    AND ����������������._Period <= @P_DateTimePeriodEnd
	AND ����������������._Fld25105RRef IN (Select �������������������������� From  #Temp_GeoData)
GROUP BY
	CAST(CAST(����������������._Period  AS DATE) AS DATETIME),
	#Temp_Size.���,
	#Temp_Size.�����,
	#Temp_TimeService.���������������
Having 
	SUM(
            CASE
                WHEN (����������������._RecordKind = 0.0) THEN ����������������._Fld25107
                ELSE -(����������������._Fld25107)
            END
        ) > #Temp_Size.���
	AND 
	SUM(
            CASE
                WHEN (����������������._RecordKind = 0.0) THEN ����������������._Fld25108
                ELSE -(����������������._Fld25108)
            END
        ) > #Temp_Size.�����
	And 
	SUM(
            CASE
                WHEN (����������������._RecordKind = 0.0) THEN ����������������._Fld25201
                ELSE -(����������������._Fld25201)
            END
        ) > #Temp_TimeService.���������������	
OPTION (OPTIMIZE FOR (@P_DateTimePeriodBegin='4021-04-14 00:00:00',@P_DateTimePeriodEnd='4021-04-19 00:00:00'));

CREATE CLUSTERED INDEX ix_tempCIndexAft11 ON #Temp_DeliveryPower(����); 


/*��� ���������� ���������, ������� ������������*/
SELECT 
    T1._Period AS ������,
    T1._Fld25111RRef AS �������,
	T1._Fld25112RRef AS ������������������,
	T2.�������� AS ���������,
	T1._Fld25202 AS ��������������������,
	T1._Fld25203 AS �����������������������,
	DATEADD(
        SECOND,
        CAST(
            DATEDIFF(SECOND, @P_EmptyDate, T1._Fld25202) AS NUMERIC(12)
        ),
        T1._Period
    ) AS �����������,
	DATEADD(
        SECOND,
        CAST(
            DATEDIFF(SECOND, @P_EmptyDate, T1._Fld25203) AS NUMERIC(12)
        ),
        T1._Period
    ) AS ��������������,
	SUM(
                CASE
                    WHEN (T1._RecordKind = 0.0) THEN T1._Fld25113
                    ELSE -(T1._Fld25113)
                END
            ) AS ����������������������������������
Into #Temp_Intervals
FROM
    dbo._AccumRg25110 T1 With (NOLOCK)
    INNER JOIN #Temp_PlanningGroups T2 With (NOLOCK) ON (T1._Fld25112RRef = T2.������������������)
	AND T2.����� IN (select ��������������� From #Temp_DateAvailable)
    AND (T1._Fld25202 >= T2.�������������������������)
    AND (NOT (((@P_TimeNow >= T2.�����������������))))
	--Inner Join #Temp_GeoData ON T1._Fld25111RRef = #Temp_GeoData.�������
WHERE
    T1._Period = @P_DateTimePeriodBegin
	AND T1._Period IN (Select ���� From #Temp_DeliveryPower)
	AND T1._Fld25111RRef IN (Select ������� From #Temp_GeoData)
GROUP BY
    T1._Period,
    T1._Fld25111RRef,
	T1._Fld25112RRef,
    T1._Fld25202,
	T1._Fld25203,
	T2.��������
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
OPTION (OPTIMIZE FOR (@P_DateTimePeriodBegin='4021-04-14 00:00:00'));
--option (recompile)
--UNION
--ALL
INsert into #Temp_Intervals
SELECT
    T3._Period,
    T3._Fld25111RRef,
	T3._Fld25112RRef,
	T4.��������,
	T3._Fld25202 AS ��������������������,
	T3._Fld25203 AS �����������������������,
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
    INNER JOIN #Temp_PlanningGroups T4 With (NOLOCK) ON (T3._Fld25112RRef = T4.������������������)
	AND T4.����� IN (select ��������������� From #Temp_DateAvailable)
    AND (
        (@P_TimeNow < T4.����������������)
        OR (T3._Fld25202 >= T4.������������������������)
    )
WHERE
    T3._Period = DATEADD(DAY, 1, @P_DateTimePeriodBegin) --bigin +1
	AND T3._Period IN (Select ���� From #Temp_DeliveryPower)
    AND T3._Fld25111RRef in (Select ������� From #Temp_GeoData)
GROUP BY
    T3._Period,
    T3._Fld25111RRef,
	T3._Fld25112RRef,
    T3._Fld25202,
	T3._Fld25203,
	T4.��������
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
OPTION (OPTIMIZE FOR (@P_DateTimePeriodBegin='4021-04-14 00:00:00'));
--option (recompile)
--UNION
--ALL
INsert into #Temp_Intervals
SELECT
    T5._Period,
    T5._Fld25111RRef,
	T5._Fld25112RRef,
	T4.��������,
	T5._Fld25202 AS ��������������������,
	T5._Fld25203 AS �����������������������,
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
	INNER JOIN #Temp_PlanningGroups T4 With (NOLOCK) ON (T5._Fld25112RRef = T4.������������������)
	AND T4.����� IN (select ��������������� From #Temp_DateAvailable)
WHERE
    T5._Period >= DATEADD(DAY, 2, @P_DateTimePeriodBegin) --begin +2
    AND T5._Period <= @P_DateTimePeriodEnd --end
	AND T5._Period IN (Select ���� From #Temp_DeliveryPower)
    AND T5._Fld25111RRef in (Select ������� From #Temp_GeoData) 
GROUP BY
    T5._Period,
    T5._Fld25111RRef,
	T5._Fld25112RRef,
    T5._Fld25202,
	T5._Fld25203,
	T4.��������
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
OPTION (OPTIMIZE FOR (@P_DateTimePeriodBegin='4021-04-14 00:00:00',@P_DateTimePeriodEnd='4021-04-19 00:00:00'));
;
/*���� ����������� ������������ ���������*/

WITH T(date) AS (
    /*��� ��������� ������ ��� ���������� ����� ���� ��������� �������*/
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
/*��� �� �������� ���� �� ��������*/
select 
	DATEADD(
        SECOND,
        CAST(
            DATEDIFF(SECOND, @P_EmptyDate, �������������������������._Fld25128) AS NUMERIC(12)
        ),
        #Temp_Intervals.������
    ) As �����������,
	DATEADD(
        SECOND,
        CAST(
            DATEDIFF(SECOND, @P_EmptyDate, �������������������������._Fld25129) AS NUMERIC(12)
        ),
        #Temp_Intervals.������
    ) As ��������������,
	SUM(
	#Temp_Intervals.����������������������������������
	) 
	AS ���������������������������������� 
From
#Temp_Intervals With (NOLOCK)
Inner Join #Temp_DateAvailable With (NOLOCK) 
    On #Temp_Intervals.����������� >= #Temp_DateAvailable.DateAvailable
Inner Join _Reference114_VT25126 ������������������������� With (NOLOCK)
    On #Temp_Intervals.������� = �������������������������._Reference114_IDRRef
	And #Temp_Intervals.�������������������� >= �������������������������._Fld25128
	And #Temp_Intervals.�������������������� < �������������������������._Fld25129
Inner Join #Temp_TimeService With (NOLOCK) On 1=1 
Group By 
	�������������������������._Fld25128,
	�������������������������._Fld25129,
	#Temp_Intervals.������,
	#Temp_TimeService.���������������
Having Min(#Temp_Intervals.�����������) <=  DATEADD(
        SECOND,
        CAST(
            DATEDIFF(SECOND, @P_EmptyDate, �������������������������._Fld25128) AS NUMERIC(12)
        ),
        #Temp_Intervals.������
    ) 
	AND SUM(#Temp_Intervals.����������������������������������) > #Temp_TimeService.���������������

Union
All
/*� ��� �� �������� ���� ��� ������� ��� �� ����������*/
SELECT
	DATEADD(
        SECOND,
        CAST(
            DATEDIFF(SECOND, @P_EmptyDate, �������������������������._Fld25128) AS NUMERIC(12)
        ),
        date
    ) As �����������,
	DATEADD(
        SECOND,
        CAST(
            DATEDIFF(SECOND, @P_EmptyDate, �������������������������._Fld25129) AS NUMERIC(12)
        ),
        date
    ) As ��������������,
	0 AS ����������������������������������
FROM
    T 
	Inner Join _Reference114_VT25126 AS �������������������������  With (NOLOCK) On �������������������������._Reference114_IDRRef In (Select ������� From #Temp_GeoData)
	Inner Join #Temp_DateAvailable On DATEADD(
        SECOND,
        CAST(
            DATEDIFF(SECOND, @P_EmptyDate, �������������������������._Fld25128) AS NUMERIC(12)
        ),
        date
    ) >= #Temp_DateAvailable.DateAvailable 

Order by �����������

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
Drop TABLE #Temp_Intervals