select * from [PortfolioProjects ]..CovidDeaths$
order by 3, 4;

select * from [PortfolioProjects ]..CovidVaccinations$
order by 3, 4;

select location, date, total_cases, new_cases, total_deaths, population 
from [PortfolioProjects ]..CovidDeaths$
order by 1, 2;

-- Looking at total deaths vs total cases 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage 
from [PortfolioProjects ]..CovidDeaths$
order by 1,2

-- looking at total deaths vs total cases in United States 
-- shows likelihood of dying in your country if you contct covid
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage 
from [PortfolioProjects ]..CovidDeaths$ 
where location like '%United States%'
order by 1,2

-- looking at total deaths vs total polulation
-- shows what percentage of population got covid 

select location, date, population, total_cases, (total_cases/population)*100 as Covid_percentage 
from [PortfolioProjects ]..CovidDeaths$
where location like '%United States%'
order by 1,2


-- lookng at countires with highest infection rate compared to population
select location, population, Max(total_cases) as highest_infection_rate, Max((total_cases/population)*100) as covid_percentage
from [PortfolioProjects ]..CovidDeaths$
group by population, location 
order by covid_percentage desc;

-- showing countires with highest death count per population
select location, max(cast(total_deaths as int)) as total_death_count
from [PortfolioProjects ]..CovidDeaths$
where continent is not null
group by location
order by total_death_count desc

-- Showing continents with the highest death count 
select location, max(cast(total_deaths as int)) as total_death_count 
from [PortfolioProjects ]..CovidDeaths$
where continent is null
group by location
order by total_death_count desc

--Global Numbers 
select date, sum(cast(new_cases as int)),sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum (new_cases) *100 as DeathPerc 
from [PortfolioProjects ]..CovidDeaths$
where continent is not null
group by date 
order by date desc

-- looking at total population vs vaccinations
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
over (partition by dea.location order by dea.location, dea.date) as rollingCount
from [PortfolioProjects ]..CovidDeaths$	dea
join [PortfolioProjects ]..CovidVaccinations$ vac
	on dea.location=vac.location and
	dea.date=vac.date
where dea.continent is not null
order by 2,3

--Use CTE
with popVsvac (continent, location, date, population, new_vaccinations, rollingCount) as 
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
over (partition by dea.location order by dea.location, dea.date) as rollingCount
from [PortfolioProjects ]..CovidDeaths$	dea
join [PortfolioProjects ]..CovidVaccinations$ vac
	on dea.location=vac.location and
	dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingCount/population)*100
from popVsvac

-- Temp Table 
drop table if exists #PercentPopulationVaccinated 
create table #PercentPopulationVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingCount numeric 
)
Insert into #PercentPopulationVaccinated

select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
over (partition by dea.location order by dea.location, dea.date) as rollingCount
from [PortfolioProjects ]..CovidDeaths$	dea
join [PortfolioProjects ]..CovidVaccinations$ vac
	on dea.location=vac.location and
	dea.date=vac.date
--where dea.continent is not null
--order by 2,3
select *, (rollingCount/population)*100
from #PercentPopulationVaccinated