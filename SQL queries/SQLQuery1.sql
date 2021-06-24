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
--DECLARE @PickupPointsAll nvarchar(50);

DECLARE @P_CityCode nvarchar(20);

DECLARE @P_DateTimeNow datetime;
DECLARE @P_DateTimePeriodBegin datetime;
DECLARE @P_DateTimePeriodEnd datetime;
DECLARE @P_TimeNow datetime;
DECLARE @P_EmptyDate datetime;
DECLARE @P_MaxDate datetime;

 SET @P_Article1 = '358649'; --��������
 SET @P_Article2 = '424941';
 SET @P_Article3 = '6445627';
 SET @P_Article4 = '5962720';
 SET @P_Article5 = '600017';
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

DECLARE @P_DaysToShow numeric(2);
 Set @P_DaysToShow = 7;

 Set @P_DateTimeNow = '4021-06-24T11:30:00' 
 Set @P_DateTimePeriodBegin = '4021-06-24T00:00:00'
 Set @P_DateTimePeriodEnd = '4021-06-28T00:00:00'
 Set @P_TimeNow = '2001-01-01T11:30:00'
 Set @P_EmptyDate = '2001-01-01T00:00:00'
 Set @P_MaxDate = '5999-11-11T00:00:00'

Create Table #Temp_GoodsRaw  
(	
	Article nvarchar(20), 
	code nvarchar(20), 
    PickupPoint nvarchar(30),
    quantity int
)

INSERT INTO 
	#Temp_GoodsRaw ( 
		Article, code, PickupPoint, quantity 
	)
VALUES
('596784',NULL,NULL,0),
('115257',NULL,NULL,0),
('5994994',NULL,NULL,0),
('115255',NULL,NULL,0),
('382584',NULL,NULL,0),
('974128',NULL,NULL,0),
('5994890',NULL,NULL,0),
('115256',NULL,NULL,0),
('5994543',NULL,NULL,0),
('5981297',NULL,NULL,0),
('930392',NULL,NULL,0),
('538584',NULL,NULL,0),
('538586',NULL,NULL,0),
('5963137',NULL,NULL,0),
('6176760',NULL,NULL,0),
('5994577',NULL,NULL,0),
('376789',NULL,NULL,0),
('921628',NULL,NULL,0),
('115261',NULL,NULL,0),
('115264',NULL,NULL,0),
('115262',NULL,NULL,0),
('6013617',NULL,NULL,0),
('6118716',NULL,NULL,0),
('5994886',NULL,NULL,0),
('5896770',NULL,NULL,0),
('70340',NULL,NULL,0),
('6535926',NULL,NULL,0),
('48642',NULL,NULL,0),
('6341692',NULL,NULL,0),
('69189',NULL,NULL,0),
('115254',NULL,NULL,0),
('70343',NULL,NULL,0),
('48643',NULL,NULL,0),
('6294328',NULL,NULL,0),
('5994901',NULL,NULL,0),
('5994546',NULL,NULL,0),
('6118718',NULL,NULL,0),
('571261',NULL,NULL,0),
('5915892',NULL,NULL,0),
('70341',NULL,NULL,0),
('974115',NULL,NULL,0),
('921646',NULL,NULL,0),
('921639',NULL,NULL,0),
('5994974',NULL,NULL,0),
('478667',NULL,NULL,0),
('930389',NULL,NULL,0),
('921629',NULL,NULL,0),
('43028',NULL,NULL,0),
('382103',NULL,NULL,0),
('921641',NULL,NULL,0),
('5912890',NULL,NULL,0),
('538587',NULL,NULL,0),
('470870',NULL,NULL,0),
('6074879',NULL,NULL,0),
('5985046',NULL,NULL,0),
('5832263',NULL,NULL,0),
('800758',NULL,NULL,0),
('930387',NULL,NULL,0),
('470873',NULL,NULL,0),
('378483',NULL,NULL,0),
	('596784',NULL,'340,388,460,417,234,2',0),
('115257',NULL,'340,388,460,417,234,2',0),
('5994994',NULL,'340,388,460,417,234,2',0),
('115255',NULL,'340,388,460,417,234,2',0),
('382584',NULL,'340,388,460,417,234,2',0),
('974128',NULL,'340,388,460,417,234,2',0),
('5994890',NULL,'340,388,460,417,234,2',0),
('115256',NULL,'340,388,460,417,234,2',0),
('5994543',NULL,'340,388,460,417,234,2',0),
('5981297',NULL,'340,388,460,417,234,2',0),
('930392',NULL,'340,388,460,417,234,2',0),
('538584',NULL,'340,388,460,417,234,2',0),
('538586',NULL,'340,388,460,417,234,2',0),
('5963137',NULL,'340,388,460,417,234,2',0),
('6176760',NULL,'340,388,460,417,234,2',0),
('5994577',NULL,'340,388,460,417,234,2',0),
('376789',NULL,'340,388,460,417,234,2',0),
('921628',NULL,'340,388,460,417,234,2',0),
('115261',NULL,'340,388,460,417,234,2',0),
('115264',NULL,'340,388,460,417,234,2',0),
('115262',NULL,'340,388,460,417,234,2',0),
('6013617',NULL,'340,388,460,417,234,2',0),
('6118716',NULL,'340,388,460,417,234,2',0),
('5994886',NULL,'340,388,460,417,234,2',0),
('5896770',NULL,'340,388,460,417,234,2',0),
('70340',NULL,'340,388,460,417,234,2',0),
('6535926',NULL,'340,388,460,417,234,2',0),
('48642',NULL,'340,388,460,417,234,2',0),
('6341692',NULL,'340,388,460,417,234,2',0),
('69189',NULL,'340,388,460,417,234,2',0),
('115254',NULL,'340,388,460,417,234,2',0),
('70343',NULL,'340,388,460,417,234,2',0),
('48643',NULL,'340,388,460,417,234,2',0),
('6294328',NULL,'340,388,460,417,234,2',0),
('5994901',NULL,'340,388,460,417,234,2',0),
('5994546',NULL,'340,388,460,417,234,2',0),
('6118718',NULL,'340,388,460,417,234,2',0),
('571261',NULL,'340,388,460,417,234,2',0),
('5915892',NULL,'340,388,460,417,234,2',0),
('70341',NULL,'340,388,460,417,234,2',0),
('974115',NULL,'340,388,460,417,234,2',0),
('921646',NULL,'340,388,460,417,234,2',0),
('921639',NULL,'340,388,460,417,234,2',0),
('5994974',NULL,'340,388,460,417,234,2',0),
('478667',NULL,'340,388,460,417,234,2',0),
('930389',NULL,'340,388,460,417,234,2',0),
('921629',NULL,'340,388,460,417,234,2',0),
('43028',NULL,'340,388,460,417,234,2',0),
('382103',NULL,'340,388,460,417,234,2',0),
('921641',NULL,'340,388,460,417,234,2',0),
('5912890',NULL,'340,388,460,417,234,2',0),
('538587',NULL,'340,388,460,417,234,2',0),
('470870',NULL,'340,388,460,417,234,2',0),
('6074879',NULL,'340,388,460,417,234,2',0),
('5985046',NULL,'340,388,460,417,234,2',0),
('5832263',NULL,'340,388,460,417,234,2',0),
('800758',NULL,'340,388,460,417,234,2',0),
('930387',NULL,'340,388,460,417,234,2',0),
('470873',NULL,'340,388,460,417,234,2',0),
('378483',NULL,'340,388,460,417,234,2',0)
	--(@P_Article1,@P_Code1,@PickupPoint3,0),
	--(@P_Article2,@P_Code2,@PickupPoint2,0),
	--(@P_Article1,@P_Code1,NULL,0),
	--(@P_Article3,@P_Code3,@PickupPoint3,0),
	--('843414',NULL,NULL,0),
	--(@P_Article5,NULL,NULL,0)--,
	--('5990264',NULL,NULL,0),
	--('586456',NULL,NULL,0),
	--('5990263',NULL,'340,388,460,417,234,2',0),
	--('586455',NULL,'340,388,460,417,2',0)--,
	--('5990263',NULL,'388',0),
	--('586455',NULL,'388',0),
	--('5990263',NULL,'460',0),
	--('586455',NULL,'460',0),
	--('5990263',NULL,'417',0),
	--('586455',NULL,'417',0),
	--('5990263',NULL,'234',0),
	--('586455',NULL,'234',0),
	--('5990263',NULL,'2',0),
	--('586455',NULL,'2',0)--,
	--(@P5,4),
	--(@P6,3),
	--(@P7,2),
	--(@P8,1)
	;

Select 
	������._IDRRef AS �����������,
	������._Fld19544 AS ERP���������
Into #Temp_PickupPoints
From 
	dbo._Reference226 ������ 
Where ������._Fld19544 in(@PickupPoint1,@PickupPoint2,@PickupPoint3,@PickupPoint4,@PickupPoint5,@PickupPoint6)

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
	SELECT TOP 1
		T3._Fld26708RRef AS Fld26823RRef --������� �� �� ���������������
	FROM (SELECT
			T1._Fld25549 AS Fld25549_,
			MAX(T1._Period) AS MAXPERIOD_ 
		FROM dbo._InfoRg21711 T1 With (NOLOCK)
		WHERE T1._Fld26708RRef <> 0x00 and T1._Fld25549 = @P_CityCode
		GROUP BY T1._Fld25549) T2
	INNER JOIN dbo._InfoRg21711 T3 With (NOLOCK)
	ON T2.Fld25549_ = T3._Fld25549 AND T2.MAXPERIOD_ = T3._Period
	)
OPTION (KEEP PLAN, KEEPFIXED PLAN);

With Temp_GoodsRawParsed AS
(
select 
	t1.Article, 
	t1.code, 
	value AS PickupPoint 
from #Temp_GoodsRaw t1
	cross apply 
		string_split(IsNull(t1.PickupPoint,'-'), ',')
)
Select 
	������������._IDRRef AS ������������������,
	������������._Code AS code,
	������������._Fld3480 AS article,
	������������._Fld3489RRef AS ����������������,
	������������._Fld3526RRef AS ��������,
	#Temp_PickupPoints.����������� AS ��������������,
	��������._IDRRef AS ��������������,
	��������._Fld6000 AS ���,
	��������._Fld6006 AS �����
INTO #Temp_GoodsBegin
From
	Temp_GoodsRawParsed T1
	Inner Join 	dbo._Reference149 ������������ With (NOLOCK) 
		ON T1.code is NULL and T1.Article = ������������._Fld3480
	Left Join #Temp_PickupPoints  
		ON T1.PickupPoint = #Temp_PickupPoints.ERP���������
	Inner Join dbo._Reference256 �������� With (NOLOCK)
		On 
		��������._OwnerID_TYPE = 0x08  
		AND ��������.[_OwnerID_RTRef] = 0x00000095
		AND 
		������������._IDRRef = ��������._OwnerID_RRRef		
		And ��������._Fld6003RRef = ������������._Fld3489RRef
		AND ��������._Marked = 0x00
union
Select 
	������������._IDRRef,
	������������._Code,
	������������._Fld3480,
	������������._Fld3489RRef,
	������������._Fld3526RRef,
	#Temp_PickupPoints.�����������,
	��������._IDRRef AS ��������������,
	��������._Fld6000 AS ���,
	��������._Fld6006 AS �����
From 
	Temp_GoodsRawParsed T1
	Inner Join 	dbo._Reference149 ������������ With (NOLOCK) 
		ON T1.code is not NULL and T1.code = ������������._Code
	Left Join #Temp_PickupPoints  
		ON T1.PickupPoint = #Temp_PickupPoints.ERP���������
	Inner Join dbo._Reference256 �������� With (NOLOCK)
		On 
		��������._OwnerID_TYPE = 0x08  
		AND ��������.[_OwnerID_RTRef] = 0x00000095
		AND 
		������������._IDRRef = ��������._OwnerID_RRRef		
		And ��������._Fld6003RRef = ������������._Fld3489RRef
		AND ��������._Marked = 0x00
OPTION (KEEP PLAN, KEEPFIXED PLAN);

Select 
	������������.������������������ AS ������������������,
	������������.article AS article,
	������������.code AS code,
	������������.�������������� AS �����������,
	������������.�������������� AS ��������������,--��������._IDRRef AS ��������������,
	1 As ����������,
	������������.��� AS ���,--��������._Fld6000 AS ���,
	������������.����� AS �����,--��������._Fld6006 AS �����,
	10 AS �������������������,
	IsNull(������������������._IDRRef, 0x00000000000000000000000000000000) AS ������������������,
	IsNull(������������������._Description, '') AS ������������������������������,
	IsNull(������������������._Fld25519, @P_EmptyDate) AS ����������������������������������
INTO #Temp_Goods
From 
	#Temp_GoodsBegin ������������
	--Inner Join dbo._Reference256 �������� With (NOLOCK)
	--	On 
	--	��������._OwnerID_TYPE = 0x08  
	--	AND ��������.[_OwnerID_RTRef] = 0x00000095
	--	AND 
	--	������������.������������������ = ��������._OwnerID_RRRef		
	--	And ��������._Fld6003RRef = ������������.����������������
	--	AND ��������._Marked = 0x00
	Left Join dbo._Reference23294 ������������������ With (NOLOCK)
		Inner Join dbo._Reference23294_VT23309 With (NOLOCK)
			on ������������������._IDRRef = _Reference23294_VT23309._Reference23294_IDRRef
			and _Reference23294_VT23309._Fld23311RRef in (Select �������������������������� From #Temp_GeoData)
		On 
		������������������._Fld23302RRef IN (Select ����������� From #Temp_GeoData) --�����
		AND ������������������._Fld25141 = 0x01--��������� � ������� ��������
		AND (������������������._Fld23301RRef = ������������.�������� OR (������������.�������� = 0xAC2CBF86E693F63444670FFEB70264EE AND ������������������._Fld23301RRef= 0xAD3F7F5FC4F15DAD4F693CAF8365EC0D) ) --��������
		AND ������������������._Marked = 0x00
OPTION (KEEP PLAN, KEEPFIXED PLAN);

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
        AND T2._Fld21410_RRRef = ����._Fld21410_RRRef
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
OPTION (OPTIMIZE FOR (@P_DateTimeNow='4021-06-24T00:00:00'),KEEP PLAN, KEEPFIXED PLAN);

Drop table #Temp_GoodsRaw
Drop table #Temp_PickupPoints
Drop table #Temp_GeoData
Drop table #Temp_GoodsBegin
Drop table #Temp_Goods
Drop table #Temp_Remains
