drop table if exists #spendingtemp
select
winery as [Winery], 
customernumber as [Customer Number],
winery + customernumber as [Unique Customer ID],
winery + customernumber + cast(cast(saledate as date) as varchar(20)) as [Unique Visit ID],
case when customerclass like '%barrel%' then 'Barrel Club'
when customerclass like '%wine club%' then 'Wine Club'
when customerclass like '%partner%' or customerclass like '%investor%' then 'Investor'
else customerclass end as [Customer Type],
cast(saledate as date) as [Sale Date],
concat(datepart(month,cast(saledate as date)), '/' ,datepart(year,cast(saledate as date))) as [Sale Month],
cast(ProductNetRevenue as float) as [Net Revenue],
cast(ProductDiscount as float) as [Discount],
producttitle as [Product],
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
into #spendingtemp
from dbo.salesmaster_effingham 


union all

select
winery as [Winery], 
customernumber as [Customer Number],
winery + customernumber as [Unique Customer ID],
winery + customernumber + cast(cast(saledate as date) as varchar(20)) as [Unique Visit ID],
case when customerclass like '%barrel%' then 'Barrel Club'
when customerclass like '%wine club%' then 'Wine Club'
when customerclass like '%partner%' or customerclass like '%investor%' then 'Investor'
else customerclass end as [Customer Type],
cast(saledate as date) as [Sale Date],
concat(datepart(month,cast(saledate as date)), '/' ,datepart(year,cast(saledate as date))) as [Sale Month],
cast(ProductNetRevenue as float) as [Net Revenue],
cast(ProductDiscount as float) as [Discount],
producttitle as [Product],
case when productgroup like '%glass/tasting%' and producttitle not like '%tasting%' then 'Glass' 
when productgroup like '%glass/tasting%' and producttitle like '%tasting%' then 'Tasting' 
when productgroup like '%wine bottles%' or productgroup like '%library wines%'  or productgroup like '%wine specials%'
or producttitle like '%upcharge%' or producttitle = 'sparkling duo' then 'Bottle'  
when producttitle like '%deposit%' or producttitle like '%payment' then 'Deposit' 
when productgroup like '%food%'  then 'Food' 
when productgroup like '%merch%' or productgroup like '%farmstore%' then 'Merch' 
when productgroup like '%other%' then 'Club Fees' 
when productgroup like '%events%' or productgroup like '%nan%' then 'Events' 
else productgroup end as [Product Category],
productgroup
from dbo.salesmaster_pearmund





/*
case 
when productgroup like '%glass/tasting%' then 'Glass' 
when productgroup like '%wine bottles%' and (producttitle like '%wine club release%' or producttitle like '%wc%q%') then 'Wine Club Bottles'
when productgroup like '%wine bottles%' or productgroup like '%library wines%'  
or productgroup like '%wine specials%' or producttitle = 'reserve upcharge' then 'Bottle' 
when productgroup like '%food%'  then 'Food' 
when productgroup like '%events%' or producttitle like '%deposit%' then 'Events'
when productgroup like '%merch%'  then 'Merch'
when producttitle like '%deposit%' then 'Deposits'
when productgroup like '%farmstore%' then 'Farmstore' 
when productgroup like 'other%' then 'Other' else productgroup end as [Product Category]
*/