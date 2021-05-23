select * from COVID_DEATH
--where continent is null
order by 3,4
-- select data that we are going to be using
select location, dt, total_cases, new_cases, total_deaths,population
from COVID_DEATH
--where total_deaths is null
--and new_cases is null
order by 1,2
----------------------------------
--looking at total case vs total deaths
select location, dt, total_cases,total_deaths,(total_deaths/total_cases)*100 as "Death%",population
from COVID_DEATH
where location like '%Bangladesh%'
order by dt 
----------------------------------------
--convert dt column data type into date
/*Easiest way is probably to convert from a VARCHAR to a DATE; 
then format it back to a VARCHAR again in the format you want;*/
select location, TO_CHAR(TO_DATE(DT,'MM/DD/YYYY'), 'DD/MON/YYYY') as dt, total_cases,total_deaths,(total_deaths/total_cases)*100 as "Death%",population
from COVID_DEATH
where location like '%Bangladesh%'
order by 1,2
---------------------------------------
----looking at total cases vs population
select location, TO_CHAR(TO_DATE(DT,'MM/DD/YYYY'), 'DD/MON/YYYY') as dt, total_cases,(total_cases/population)*100 as "Affected_rate",population
from COVID_DEATH
where location like '%Bangladesh%'
order by 3 desc
-----------------------
--Looking at countries with highest infection rate
select location,population, max(total_cases) as "Highest Infection",max((total_cases/population)*100) as "Affected_rate"
from COVID_DEATH
group by location,population
order by 4 desc
---------------------------------------------
--Showing countries with highes death count
select location,population, max(cast(total_deaths as int)) as "Highest Death"--max((total_cases/population)*100) as "Affected_rate"
from COVID_DEATH
--where continent is not null
group by location,population
order by 1
---------------
/*in the result from the above command shows  Asia, europe, Africa, world etc. which we dont want 
we want only the locations. from the first command we see that the locations column are filled by the continent values
where the continent values are null. so if we take the not null values of continent then we get the locations*/
select location,population, max(cast(total_deaths as int)) as "Highest_Death"--max((total_cases/population)*100) as "Affected_rate"
from COVID_DEATH
where continent is not null
group by location,population
order by 3 desc
------------------
--looking the previous result by continent
select continent,max(cast(total_deaths as int)) as "Highest_Death"--max((total_cases/population)*100) as "Affected_rate"
from COVID_DEATH
where continent is not null
group by continent
order by 2 desc
----------------------
--Global NUmbers
select dt,sum(new_cases),sum(cast(new_deaths as int)) as "Total_Deaths",
sum(cast(new_deaths as int))/nullif(sum(new_cases)*100,0) as "Death_Rate"
from COVID_DEATH
having sum(new_cases) is not null
group by dt
order by 4 desc
--------------------
--Joining covid_death and covid_vac tables
select dea.continent,dea.location, dea.dt, dea.population, vac.NEW_VACCINATIONS
from covid_death dea
join covid_vac vac
on dea.location=vac.location
and dea.dt=vac.dt
where vac.new_vaccinations is not null
and dea.continent is not null
order by 2
------------------------
--looking at toatl population vs vaccinations
select dea.continent,dea.location, dea.dt, dea.population, vac.NEW_VACCINATIONS,
sum(cast(vac.NEW_VACCINATIONS as int)) over (partition  by dea.location order by dea.location,dea.dt) as RolingPeopleVaccinated
from covid_death dea
join covid_vac vac
on dea.location=vac.location
and dea.dt=vac.dt
where dea.continent is not null
--and vac.new_vaccinations is not null
order by 2
-----------------
--Create view
create or replace view PopvsVac (continent,locations,dt,population,new_vac,RolingPeopleVaccinated) as 
select dea.continent,dea.location, dea.dt, dea.population, vac.NEW_VACCINATIONS,
sum(cast(vac.NEW_VACCINATIONS as int)) over (partition  by dea.location order by dea.location,dea.dt) as RolingPeopleVaccinated
from covid_death dea
join covid_vac vac
on dea.location=vac.location
and dea.dt=vac.dt
where dea.continent is not null
--and vac.new_vaccinations is not null
--order by 2

select * from popvsvac order by locations

select continent,locations,dt,population,RolingPeopleVaccinated,(RolingPeopleVaccinated/population)*100 
from popvsvac order by locations
------------------------------------------------------------------

--create views for later visualization
create or replace view PerofPopvsVac as
select continent,locations,dt,population,RolingPeopleVaccinated,(RolingPeopleVaccinated/population)*100 as Perofpopvac 
from popvsvac order by locations
select * from PEROFPOPVSVAC

create or replace view DeathpercentageofBD as
select location, dt, total_cases,total_deaths,(total_deaths/total_cases)*100 as "Death%",population
from COVID_DEATH
where location like '%Bangladesh%'
order by dt 
select * from DeathpercentageofBD

create or replace view GlobalNumbers as
select dt,sum(new_cases) as TotalNewCases,sum(cast(new_deaths as int)) as "Total_Deaths",
sum(cast(new_deaths as int))/nullif(sum(new_cases)*100,0) as "Death_Rate"
from COVID_DEATH
having sum(new_cases) is not null
group by dt
order by 4 desc

select * from globalnumbers
commit