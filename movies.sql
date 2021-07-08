select * from movies

select count(distinct name) from movies
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
select round(corr(votes,gross),2)
from movies 
select round(corr(budget,gross),2)
from movies 
----------------------------------------------------------
--count the movie types
select genre,count(*) as Num_of_movies from movies group by genre order by Num_of_movies desc 
------------------------------------------------------------------------
--looking for the yearly top 5 types of movies by means of revenue
select *from (
select genre,sum(budget) as budget_total,sum(gross) as total_income from movies 
group by genre
order by total_income desc)
where rownum<=5
-------------------------------------------------------------
--looking for the top 5 types of movies by means of revenue along with net income ratio 
select *from (
select genre,sum(budget) as budget_total,sum(gross) as total_income, 
sum(gross)-sum(budget) as net_income, 
round(((sum(gross)-sum(budget))/sum(budget))*100,2) as income_ratio, sum(votes) as total_votes from movies 
having sum(budget)>0--we have zero budget in war types movie
group by genre
order by income_ratio desc)
where rownum<=5
--------------------------------------------------------------------------------------------------
--looking for the yearly top 5 types of movies by means of revenue along with net income ratio 
select *from (
select year,genre,sum(budget) as budget_total,sum(gross) as total_income, 
sum(gross)-sum(budget) as net_income, 
round(((sum(gross)-sum(budget))/sum(budget))*100,2) as income_ratio, sum(votes) as total_votes from movies 
having sum(budget)>0--we have zero budget in war types movie
group by year,genre
order by income_ratio desc)
where rownum<=5