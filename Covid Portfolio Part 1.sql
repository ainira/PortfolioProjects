Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccination
--order by 3,4

Select Location,date, total_cases,new_cases, total_deaths,population 
From PortfolioProject..CovidDeaths
order by 1,2


--*Total Cases vs Total Deaths*
--Shows likelihood of dying due to Covid
Select Location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'Malaysia'
order by 1,2


--Total cases vs Population
--Percentage of population infected by Covid

Select Location,date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
Where location = 'Malaysia'
order by 1,2

--Countries with highest infectivity rate compared to population
Select Location,population, MAX (total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
Group by location,population
order by InfectedPercentage desc

--Countries with highest death count per Population
Select Location,population, MAX (cast(total_deaths as int)) as HighestDeathCount,Max((total_deaths/population))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location,population
order by HighestDeathCount desc


-- BREAK THINGS DOWN BY CONTINENT

Select continent,MAX (cast(total_deaths as int)) as HighestDeathCount,Max((total_deaths/population))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by HighestDeathCount desc

--GLOBAL NUMBERS

Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
where continent is not null
Group By date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Join Tables

Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3


--Adding up the vaccination count

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER 
(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

-- USE CTE

With PopvsVac (Continent,Location,Date,Population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER 
(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercent
From PopvsVac

-- TEMP TABLE

--DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER 
(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Create View to store data for later visualization

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER 
(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
