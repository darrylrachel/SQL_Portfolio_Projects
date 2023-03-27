/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
-- Create Database PortfolioProjects

Select *
  From CovidDeaths
  Where continent Is Not Null
  Order By 3, 4

-- Select *
--   From CovidVaccinations
--   Order By 3, 4


-- Select data that's going to be used
Select location, date, total_cases, new_cases, total_deaths, population
  From CovidDeaths
  Where continent Is Not Null
  Order By 1, 2

-- total_cases vs total_deaths
-- Shows the likelihood of dying if you contract Covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 As DeathPercentage
  From CovidDeaths
  Where location Like '%states%'
  And continent Is Not Null
  Order By 1, 2

-- total_cases vs population
-- Shows what percentage of population contracted Covid
Select location, date, population, total_cases, (total_cases/population) * 100 As InfectedPercentage
  From CovidDeaths
  Where location Like '%states%'
  And continent Is Not Null
  Order By 1, 2


-- Countries with highest infection rate compared to population
Select location, population, Max(total_cases) As HighestInfectionCount, Max((total_cases/population)) * 100 As PercentPopulationInfected
  From CovidDeaths
  -- Where location Like '%states%'
  Where continent Is Not Null
  Group By location, population
  Order By PercentPopulationInfected desc


-- Countries with highest death count per population
Select location, Max(Cast(total_deaths As Int)) As TotalDeathCount
  From CovidDeaths
  -- Where location Like '%states%'
  Where continent Is Not Null
  Group By location
  Order By TotalDeathCount desc

-- BREAKING DOWN BY CONTINENT

-- Add to visuals
-- Select location, Max(Cast(total_deaths As Int)) As TotalDeathCount
--   From CovidDeaths
--   -- Where location Like '%states%'
--   Where continent Is Null
--   Group By location
--   Order By TotalDeathCount desc


-- Continents with the highest death count
Select continent, Max(Cast(total_deaths As Int)) As TotalDeathCount
  From CovidDeaths
  -- Where location Like '%states%'
  Where continent Is Not Null
  Group By continent
  Order By TotalDeathCount desc

-- Global Numbers

Select date, Sum(new_cases) As total_cases, Sum(Cast(new_deaths As Int)) As total_deaths, Sum(Cast(new_deaths As Int)) / NullIf(Sum(new_cases), 0) * 100 As DeathPercentage
  From CovidDeaths
  -- Where location Like '%states%'
  Where continent Is Not Null
  Group By date
  Order By 1, 2

-- Total across the world
Select Sum(new_cases) As total_cases, Sum(Cast(new_deaths As Int)) As total_deaths, Sum(Cast(new_deaths As Int)) / NullIf(Sum(new_cases), 0) * 100 As DeathPercentage
  From CovidDeaths
  -- Where location Like '%states%'
  Where continent Is Not Null
  --Group By date
  Order By 1, 2

Select * 
  From CovidVaccinations

-- Total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Cast(vac.new_vaccinations As Float)) Over (Partition By dea.location Order By dea.location, dea.date) As RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
  From CovidDeaths dea
  Join CovidVaccinations vac
  On dea.location = vac.location
  And dea.date = vac.date
  Where dea.continent Is Not Null
  Order By 2, 3

-- Use CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
As (
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Cast(vac.new_vaccinations As Float)) Over (Partition By dea.location Order By dea.location, dea.date) As RollingPeopleVaccinated
  From CovidDeaths dea
  Join CovidVaccinations vac
  On dea.location = vac.location
  And dea.date = vac.date
  Where dea.continent Is Not Null
  -- Order By 2, 3
)

Select *, (RollingPeopleVaccinated / population) * 100
  From PopvsVac


-- temp table
Drop Table If Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated (
  continent Nvarchar(255),
  location NvarChar(255),
  date Datetime,
  population Numeric,
  new_vaccinations Numeric,
  RollingPeopleVaccinated Numeric
)
Insert Into #PercentPopulationVaccinated
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Cast(vac.new_vaccinations As Float)) Over (Partition By dea.location Order By dea.location, dea.date) As RollingPeopleVaccinated
  From CovidDeaths dea
  Join CovidVaccinations vac
  On dea.location = vac.location
  And dea.date = vac.date
  Where dea.continent Is Not Null

Select *, (RollingPeopleVaccinated / population) * 100
  From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated As
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Cast(vac.new_vaccinations As Float)) Over (Partition By dea.location Order By dea.location, dea.date) As RollingPeopleVaccinated
  From CovidDeaths dea
  Join CovidVaccinations vac
  On dea.location = vac.location
  And dea.date = vac.date
  Where dea.continent Is Not Null
