--drop table if exists #temp
select 
p.winery [Winery],
cast(p.saledate as date) as [Sale Date],
cast(datepart(month,cast(p.saledate as date)) as varchar(2)) + '/' + cast(datepart(year,cast(p.saledate as date)) as varchar(4)) as [Sale Month],
p.customernumber as [Customer Number],
p.winery + p.customernumber as [Unique Customer ID],
p.winery + p.CustomerNumber + cast(p.saledate as varchar(8)) as [Unique Visit ID],
case when p.producttitle like '%tasting%' and productgroup like '%glass/tasting%' then 'Wine Tasting' else producttitle end 
as [Product],
case when productgroup like '%glass/tasting%' and producttitle not like '%tasting%' then 'Glass' 
when productgroup like '%glass/tasting%' and producttitle like '%tasting%' then 'Tasting' 
when productgroup like '%wine bottles%' or productgroup like '%library wines%'  or productgroup like '%wine specials%'
or producttitle like '%upcharge%' or producttitle = 'sparkling duo'  then 'Bottle' 
when producttitle like '%deposit%'  or producttitle like '%payment'  then 'Deposit' 
when productgroup like '%food%'  then 'Food' 
when productgroup like '%merch%' or productgroup like '%farmstore%' then 'Merch' 
when productgroup like '%other%' then 'Club Fees' 
when productgroup like '%events%'  or productgroup like '%nan%' then 'Events' 
else productgroup end as [Product Category],
productgroup
--into #temp
from dbo.salesmaster_pearmund p
inner join (select winery, cast(saledate as date) as saledate, customernumber
	from dbo.salesmaster_pearmund
	where  productgroup like '%glass/tasting%' 
	and producttitle like '%tasting%' ) t 
	on t.winery = p.winery and t.customernumber =  p.CustomerNumber and cast(t.saledate as date) = cast(p.SaleDate as date)

union all

select 
p.winery [Winery],
cast(p.saledate as date) as [Sale Date],
cast(datepart(month,cast(p.saledate as date)) as varchar(2)) + '/' + cast(datepart(year,cast(p.saledate as date)) as varchar(4)) as [Sale Month],
p.customernumber as [Customer Number],
p.winery + p.customernumber as [Unique Customer ID],
p.winery + p.CustomerNumber + cast(p.saledate as varchar(8)) as [Unique Visit ID],
case when p.producttitle like '%tasting%' and productgroup like '%glass/tasting%' then 'Wine Tasting' else producttitle end 
as [Product],
case when productgroup like '%glass/tasting%' and producttitle not like '%tasting%' then 'Glass' 
when productgroup like '%glass/tasting%' and producttitle like '%tasting%' then 'Tasting' 
when productgroup like '%wine bottles%' or productgroup like '%library wines%'  or productgroup like '%wine specials%'
or producttitle like '%upcharge%' or producttitle = 'sparkling duo'  then 'Bottle' 
when producttitle like '%deposit%'  or producttitle like '%payment'  then 'Deposit' 
when productgroup like '%food%'  then 'Food' 
when productgroup like '%merch%' or productgroup like '%farmstore%' then 'Merch' 
when productgroup like '%other%' then 'Club Fees' 
when productgroup like '%events%'  or productgroup like '%nan%' then 'Events' 
else productgroup end as [Product Category],
productgroup
from dbo.salesmaster_effingham p
inner join (select winery, cast(saledate as date) as saledate, customernumber
	from dbo.salesmaster_effingham
	where  productgroup like '%glass/tasting%' 
	and producttitle like '%tasting%' ) t 
	on t.winery = p.winery and t.customernumber =  p.CustomerNumber and cast(t.saledate as date) = cast(p.SaleDate as date)



