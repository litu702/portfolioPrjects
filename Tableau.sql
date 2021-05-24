--1
select sum(new_cases) as TotalNewCases,sum(cast(new_deaths as int)) as "Total_Deaths",
sum(cast(new_deaths as int))/(sum(cast(new_cases as int)))*100 as "Death_Rate"
from COVID_DEATH
where continent is not null
--having sum(new_cases) is not null
--group by dt
order by 1,2
-----------------2
select location,SUM(cast(new_deaths as int)) as "TotalDeathCount"--max((total_cases/population)*100) as "Affected_rate"
from COVID_DEATH
where continent is null
and location not in ('World','European Union','International')
group by location
order by 1 
-----------------------------------------------------------3
select location,population, max(total_cases) as "Highest Infection",max((total_cases/population)*100) as "Affected_rate"
from COVID_DEATH
group by location,population
order by 4 desc
-----------------------------------------------4
select location,population,dt, max(total_cases) as "Highest Infection",max((total_cases/population)*100) as "Affected_rate"
from COVID_DEATH
group by location,population,dt
order by 4 desc
------------------------------------------------
