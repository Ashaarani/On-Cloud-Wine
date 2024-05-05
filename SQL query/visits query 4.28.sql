SELECT 
winery + customernumber as [Unique Customer ID],
winery [Winery],
customernumber [Customer Number],
billfirstname + ' ' + billlastname as [Customer Name],
case when max(customerclass) like '%barrel%' then 'Barrel Club' 
when max(customerclass) like '%wine club%' then 'Wine Club' 
when max(customerclass) like '%partner%' then 'Investor' else max(customerclass) end as [Customer Type],
cast(saledate as date) as [Sale Date],
concat(datepart(month,cast(saledate as date)), '/' ,datepart(year,cast(saledate as date))) as [Sale Month],
RANK() OVER (PARTITION BY customernumber ORDER BY cast(saledate as date)  ASC) AS Rank,
COUNT(*) OVER (PARTITION BY customernumber, month(cast(saledate as date))) AS [Month Visit Count],
  LAG(cast(saledate as date)) OVER (PARTITION BY customernumber ORDER BY cast(saledate as date)) AS [Previous Visit Date],
    --case when RANK() OVER (PARTITION BY customernumber ORDER BY cast(saledate as date)  ASC) =1 then 
	--datediff(day,'1/1/2024', cast(saledate as date))
	--else
 case when month(LAG(cast(saledate as date)) OVER (PARTITION BY customernumber ORDER BY cast(saledate as date))) = month(cast(saledate as date)) then
 DATEDIFF(
    DAY,
    LAG(cast(saledate as date)) OVER (PARTITION BY customernumber ORDER BY cast(saledate as date)),
    cast(saledate as date)
  ) 
  else null end AS [Days between Visits]
FROM dbo.salesmaster_pearmund
group by 
winery,
customernumber,
billfirstname,
billlastname,
--customerclass,
cast(saledate as date)

union all

SELECT 
winery + customernumber as [Unique Customer ID],
winery [Winery],
customernumber [Customer Number],
billfirstname + ' ' + billlastname as [Customer Name],
case when max(customerclass) like '%barrel%' then 'Barrel Club' 
when max(customerclass) like '%wine club%' then 'Wine Club' 
when max(customerclass) like '%partner%' then 'Investor' else max(customerclass) end as [Customer Type],
cast(saledate as date) as [Sale Date],
concat(datepart(month,cast(saledate as date)), '/' ,datepart(year,cast(saledate as date))) as [Sale Month],
RANK() OVER (PARTITION BY customernumber ORDER BY cast(saledate as date)  ASC) AS Rank,
COUNT(*) OVER (PARTITION BY customernumber, month(cast(saledate as date))) AS [Month Visit Count],
  LAG(cast(saledate as date)) OVER (PARTITION BY customernumber ORDER BY cast(saledate as date)) AS [Previous Visit Date],
    --case when RANK() OVER (PARTITION BY customernumber ORDER BY cast(saledate as date)  ASC) =1 then 
	--datediff(day,'1/1/2024', cast(saledate as date))
	--else
 case when month(LAG(cast(saledate as date)) OVER (PARTITION BY customernumber ORDER BY cast(saledate as date))) = month(cast(saledate as date)) then
 DATEDIFF(
    DAY,
    LAG(cast(saledate as date)) OVER (PARTITION BY customernumber ORDER BY cast(saledate as date)),
    cast(saledate as date)
  ) 
  else null end AS [Days between Visits]
FROM dbo.salesmaster_effingham
group by 
winery,
customernumber,
billfirstname,
billlastname,
--customerclass,
cast(saledate as date)