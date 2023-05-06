select * from CovidAnalysis..['covidDeaths']

select location,population, date, total_cases,new_cases,total_deaths
from
CovidAnalysis..['covidDeaths']

-- Analyzing total cases vs Total Deaths

select location,date,total_cases, total_deaths, (total_deaths/cast(total_cases as decimal))*100 as deathPercentage 
from CovidAnalysis..['covidDeaths']
where location like '%India%' and continent is not null
order by 1,2

-- Analyzing total cases Vs Population
-- Displays how much percent of the total population infected with covid 
select location,date, population, total_cases, (total_cases/population)*100 as InfectedPercentage 
from CovidAnalysis..['covidDeaths']
where location like '%India%' 
and continent is not null
order by 1,2


--Looking at Countries with Highest Infection rate compared to Population
select location, population, max(total_cases) as HighestInfectedCount, 
max((total_cases/population))*100 as PercentPopulationInfected
from CovidAnalysis..['covidDeaths']
 --where location like '%India%'
where continent is not null
group by location,population
order by PercentPopulationInfected desc

--showing countries with Highest Death Count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidAnalysis..['covidDeaths']
--where location like '%India%'
where continent is not null
group by location
order by TotalDeathCount desc

--showing continents with the highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidAnalysis..['covidDeaths']
--where location like '%India%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global death percentage date wise
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from CovidAnalysis..['covidDeaths']
where continent is not null
group by date
order by 1,2

--Overall Global Death Percentage Year wise
select  YEAR(date),sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from CovidAnalysis..['covidDeaths']
where continent is not null 
group by YEAR(date)
order by 1,2

--Finding out how many percentage of population of world has been vaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from 
CovidAnalysis..['covidDeaths'] dea 
join 
CovidAnalysis..['covidVaccinations'] vac
on dea.date=vac.date
and dea.location=vac.location
where dea.continent is not null
order by 2,3

--Using CTE
with PopvsVac (Continent, location, date,population,new_vaccinations,RollingPeopleVaccinated)
as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from 
CovidAnalysis..['covidDeaths'] dea 
join 
CovidAnalysis..['covidVaccinations'] vac
on dea.date=vac.date
and dea.location=vac.location
where dea.continent is not null
--order by 2,3
)

--Finding Vaccinated people percentage date wise
select *,(RollingPeopleVaccinated/population)*100 as vaccinationPercentage
from PopvsVac

--Temp Table

drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent varchar(255), 
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from 
CovidAnalysis..['covidDeaths'] dea 
join 
CovidAnalysis..['covidVaccinations'] vac
on dea.date=vac.date
and dea.location=vac.location
where dea.continent is not null

select  *,(RollingPeopleVaccinated/population)*100 as vaccinationPercentage
from #PercentPopulationVaccinated

--creating view

create view PercentPoepleVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from 
CovidAnalysis..['covidDeaths'] dea 
join 
CovidAnalysis..['covidVaccinations'] vac
on dea.date=vac.date
and dea.location=vac.location
where dea.continent is not null

select * from PercentPoepleVaccinated