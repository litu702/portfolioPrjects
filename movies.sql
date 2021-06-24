select * from movies

select count(*) from movies
-----------------------------------------------------------
select * from movies where budget =0 order by gross desc
select count(*) from movies where budget =0
select median(budget) from movies
-------------------------------------------------------------------
select * from movies where year =&year order by gross desc
------------------------------------------------------------
--looking for top 10 companies by gross revenue
select *from (
select company,sum(gross) as total from movies 
group by company
order by total desc)
where rownum<=10
-----------------------------------------------

--looking for top 10 movies by gross revenue
select *from (
select name,sum(gross) as total from movies 
group by name
order by total desc)
where rownum<=10
---------------------------------------

--looking for top 10 low budget movies
select *from (
select name,sum(budget) as total from movies 
group by name
order by total)
where rownum<=10
-----------------------------------------------

--looking for the yearly top 10 movies by means of revenue
select *from (
select year,name,sum(gross) as total from movies 
--where year=&year
group by year,name
order by total desc)
where rownum<=10
--order by year

------------------------------------------------------------------
--correlation between numerical columns
select round(corr(budget,gross),2)
from movies 
----------------------------------------------------------



