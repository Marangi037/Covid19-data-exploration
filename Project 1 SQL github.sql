select * 
from CovidDeaths

--standardizing date format

alter table CovidDeaths
add  DateConverted date

update CovidDeaths
set DateConverted = convert(date, [date])

--removing the useless column
alter table CovidDeaths
drop column [date] 

--adding a year column

select YEAR(DateConverted) as year
from CovidDeaths

alter table CovidDeaths
add  [YEAR] int

update CovidDeaths
set [YEAR] = YEAR(DateConverted)

select sum(total_cases)
from CovidDeaths
where total_cases <> 'NULL'


--total cases per year
select [YEAR], sum(convert(float ,total_cases))as total_cases
from CovidDeaths
where total_cases <> 'NULL'
group by [YEAR]
order by 2 desc

--total deaths per year
select [YEAR], sum(convert(float, total_deaths)) total_deaths
from CovidDeaths
where total_deaths <> 'NULL'
group by [YEAR]
order by 2 desc


--total cases per location
select location, sum(convert(float,total_cases)) as total_cases
from CovidDeaths
where location <> continent and location is not NULL
group by location
order by 2 desc
-- total deaths per location
select location, sum(convert(float, total_deaths)) total_deaths
from CovidDeaths
where location <> continent
group by location
order by 2 desc


--Looking at total cases vs total deaths
--Looking the percent of people dying from covid from my area

select location, DateConverted, population, total_cases, total_deaths, (CONVERT(float,total_deaths)/total_cases)*100 [Death Percentage]
from CovidDeaths
where location = 'Kenya'

--Total cases vs population
--Looking at the percentage of population that contracted covid

select location, DateConverted, population, total_cases, (total_cases / population)*100 as [Percentage of Population infected]
from CovidDeaths

order by location, DateConverted desc
--Looking at countries with the highest infection rate

select location, population, MAX(total_cases) [highest infection count], MAX(total_cases / population)*100 as [Percentage of Population infected]
from CovidDeaths
group by location, population
order by [Percentage of Population infected] desc

--Looking at countries with the highest number of deaths

select location, MAX(total_deaths) total_death_count
from CovidDeaths
group by location
order by total_death_count desc

--Breaking things down by continent
--Showing continents with highest number of deaths per population

select continent, sum(convert(float,total_deaths)) as [Total Death Count]
from CovidDeaths
where continent IS NOT NULL
group by continent
order by [Total Death Count] DESC

select continent, [YEAR], sum(convert(float,total_cases))
from CovidDeaths
group by [YEAR], continent


--GLOBAL NUMBERS

--percentage of deaths in the world
select SUM(new_cases)[total cases], SUM(new_deaths) [total deaths] , (SUM(new_deaths)/SUM(new_cases))*100 [ death percentage]
from CovidDeaths
where continent IS NOT NULL

--vaccination tables
select *
from Covid_Vaccination

--standardizing date format

alter table Covid_Vaccination
add DateConverted date

update Covid_Vaccination
set DateConverted = convert(date, [date])

 -- adding a year column
alter table Covid_Vaccination
add [Year] int

update Covid_Vaccination
set [Year] = YEAR(DateConverted)

alter table Covid_Vaccination
drop column [date]
-- total vaccinations per year
Select [Year], sum(convert(float, total_vaccinations)) as total_Vaccinations
from Covid_Vaccination
group by [Year]
order by 2 desc

select [Year], total_vaccinations
from Covid_Vaccination

--Percentage of population vaccinated globally

select sum(convert(float,total_cases)) [total cases], sum(convert(float, total_vaccinations))[total vaccinations], sum(vaccine.population) [total_population], (sum(convert(float, total_vaccinations))/sum(vaccine.population))*100 [Percent of population vaccinated]
from CovidDeaths death
join Covid_Vaccination vaccine
on death.location = vaccine. location
and death.DateConverted = vaccine.DateConverted
where death.continent is not null




--Looking at number of people vaccinated each day

select death.continent, death.location, death.DateConverted, death.population, vaccine.new_vaccinations, SUM(CONVERT(float,new_vaccinations)) OVER (PARTITION BY death.location
order by death.location, death.DateConverted) as [Rolling people vaccinated]
from CovidDeaths death
join Covid_Vaccination vaccine
on death.location = vaccine. location
and death.DateConverted = vaccine.DateConverted
where death.continent is not null
order by death.continent, death.location

--Using CTE


WITH vaccinevspopulationCTE as(select death.continent, death.location, death.DateConverted, death.population, vaccine.new_vaccinations, SUM(CONVERT(numeric,new_vaccinations)) OVER (PARTITION BY death.location
order by death.location, death.DateConverted) as [Rolling people vaccinated]
from CovidDeaths death
join Covid_Vaccination vaccine
on death.location = vaccine. location
and death.DateConverted = vaccine.DateConverted
where death.continent is not null)

select *, ([Rolling people vaccinated] / population)[Percent of people vaccinated]
from vaccinevspopulationCTE



--Creating views to store data for later visualization
CREATE VIEW PercentPopulationVaccinated AS
(SELECT death.continent, death.location, death.DateConverted, death.population, vaccine.new_vaccinations,
SUM(vaccine.new_vaccinations) OVER (PARTITION BY death.location ORDER BY dea.location, death.DateConverted) AS RollingPeopleVaccinated
FROM CovidDeaths AS death
JOIN covidvaccinations AS vaccine
ON death.location = vaccine.location
and death.DeathConverted = vaccine.DeathConverted
WHERE death.continent IS NOT NULL);

SELECT * FROM PercentPopulationVaccinated