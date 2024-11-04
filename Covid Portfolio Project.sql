
select * from PortfolioProject..CovidDeaths where continent is not null order by 3,4;

select * from PortfolioProject..CovidVaccinations order by 3,4;

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
select Location, date, MAX(total_cases) AS total_cases, MAX(total_deaths) AS total_deaths, 
	(MAX(total_deaths) / NULLIF(MAX(total_cases), 0)) * 100 AS DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
group by location, date
order by 1,2;

--looking at total cases vs the population
select Location, date,  MAX(population) AS population, MAX(total_cases) AS total_cases, 
	(MAX(total_cases) / NULLIF(MAX(population), 0))*100 AS PopulationPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
group by location, date
order by 1,2;

--which country has the highest infection rate
select location, MAX(total_cases) as Total_Cases from PortfolioProject..CovidDeaths 
where total_cases is not NULL
group by location
order by total_cases desc;

--which country has the highest infection rate
select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as InfectedPopulationPercentage
from PortfolioProject..CovidDeaths
group by location, population
order by HighestInfectionCount desc

--showing countries with highest death count per population
select Location, MAX(cast(total_deaths as int)) AS Deaths
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by Deaths desc;

--showing locations with highest death count per population
select Location, MAX(cast(total_deaths as int)) AS Deaths
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by Deaths desc;

--showing continent with highest death count
select continent, MAX(cast(total_deaths as int)) AS Deaths
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by Deaths desc;

--calculate aroung the world
select SUM(new_cases) AS total_cases, SUM(CAST (new_deaths as int)) AS total_deaths, 
	SUM(CAST(new_deaths as int)) / (SUM(new_cases))* 100 AS DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2;

--total number of people in world that are vaccinated

--use CTE
with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select d1.continent, d1.location, d1.date, d1.population, v1.new_vaccinations, 
SUM(cast(v1.new_vaccinations as int)) over (Partition by d1.location order by d1.location, d1.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths d1
join PortfolioProject..CovidVaccinations v1
on d1.location = v1.location
and d1.date = v1.date
where d1.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100 from PopVsVac;

--temp table
drop table if exists #PercentPopulationVaccinated;
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

insert into #PercentPopulationVaccinated
select d1.continent, d1.location, d1.date, d1.population, v1.new_vaccinations, 
SUM(cast(v1.new_vaccinations as numeric)) over (Partition by d1.location order by d1.location, d1.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths d1
join PortfolioProject..CovidVaccinations v1
on d1.location = v1.location
and d1.date = v1.date
--where d1.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/nullif(population,0))*100 as PercentPopulationVaccinated from #PercentPopulationVaccinated;

--view - create view to store data for later visualization
Create View PercentPopulationVaccinated as 
select d1.continent, d1.location, d1.date, d1.population, v1.new_vaccinations, 
SUM(cast(v1.new_vaccinations as numeric)) over (Partition by d1.location order by d1.location, d1.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths d1
join PortfolioProject..CovidVaccinations v1
on d1.location = v1.location
and d1.date = v1.date
where d1.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated