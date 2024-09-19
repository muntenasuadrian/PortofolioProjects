Select *
From PortofolioProject..CovidDeaths$
where continent is not null 
order by 3,4

--Select *
--From PortofolioProject..CovidVaccinations$
--order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortofolioProject..CovidDeaths$
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if u contract Covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
From PortofolioProject..CovidDeaths$
WHERE location like 'Romania'
order by 1,2

-- Looking at Total Cases vs Population 
-- Show what percentage of population got Covid

Select location, total_cases,population, (total_cases/population)*100 DeathPercentage
From PortofolioProject..CovidDeaths$
WHERE location like 'Romania'
order by location

-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) HighestInfectionCount, (Max(total_cases)/population)*100 PercentPopulationInfected
From PortofolioProject..CovidDeaths$
--WHERE location like 'Romania'
Group by population,location
order by PercentPopulationInfected DEsc


-- Showing Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) TotalDeathCount
From PortofolioProject..CovidDeaths$
--WHERE location like 'Romania'
where continent is not null 
Group by location
order by TotalDeathCount DEsc


-- Let's break things down by Continent

Select location, MAX(cast(total_deaths as int)) TotalDeathCount
From PortofolioProject..CovidDeaths$
--WHERE location like 'Romania'
where continent is null 
Group by location
order by TotalDeathCount DEsc

-- Showing the continents with the highest death count

Select continent, MAX(cast(total_deaths as int)) TotalDeathCount
From PortofolioProject..CovidDeaths$
--WHERE location like 'Romania'
where continent is null 
Group by continent
order by TotalDeathCount DEsc


-- Global Numbers

Select date, SUM (new_cases) total_cases, SUM(cast(new_deaths as integer)) total_deaths, sum(cast(new_deaths as integer))/SUM(new_cases)*100  DeathPercentage--total_cases, total_deaths, (total_cases/population)*100 DeathPercentage
From PortofolioProject..CovidDeaths$
--WHERE location like 'Romania'
where continent is not null 
Group by date
order by 1,2

-- Romania Numbers

Select SUM (new_cases) total_cases, SUM(cast(new_deaths as integer)) total_deaths, sum(cast(new_deaths as integer))/SUM(new_cases)*100  DeathPercentage--total_cases, total_deaths, (total_cases/population)*100 DeathPercentage
From PortofolioProject..CovidDeaths$
WHERE location like 'Romania' and continent is not null
Group by date
order by 3 Desc


Select SUM (new_cases) total_cases, SUM(cast(new_deaths as integer)) total_deaths, sum(cast(new_deaths as integer))/SUM(new_cases)*100  DeathPercentage--total_cases, total_deaths, (total_cases/population)*100 DeathPercentage
From PortofolioProject..CovidDeaths$
--WHERE location like 'Romania' and 
where continent is not null
--Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as integer)) over(partition by dea.location Order by dea.location, dea.date) RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
from CovidDeaths$ dea
Join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as integer)) over(partition by dea.location Order by dea.location, dea.date) RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
from CovidDeaths$ dea
Join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100 
From PopvsVac


-- TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as integer)) over(partition by dea.location Order by dea.location, dea.date) RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
from CovidDeaths$ dea
Join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date 
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 
From #PercentPopulationVaccinated

-- Create view to store data for later visualizations


Create View PercentPopulationVaccinated
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as integer)) over(partition by dea.location Order by dea.location, dea.date) RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
from CovidDeaths$ dea
Join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated