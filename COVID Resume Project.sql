Select *
From PortfolioProject..CovidDeaths
where continent is not null
Order By 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2



-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in India
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%india%'
and continent is not null
Order by 1,2


-- Looking at Total cases vs population
-- Shows what percentage of population got Covid
Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%india%'
Order by 1,2


-- Looking at countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%india%'
Group by Location, population
Order by PercentPopulationInfected desc


-- Showing countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%india%'
where continent is not null
Group by Location
Order by TotalDeathCount desc



-- Let's break things down by continent


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%india%'
where continent is not null
Group by continent
Order by TotalDeathCount desc



-- showing the continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%india%'
where continent is not null
Group by continent
Order by TotalDeathCount desc



-- Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage  
From PortfolioProject..CovidDeaths
--Where location like '%india%'
where continent is not null
--group by date
Order by 1,2







-- Working on covid vaccinations


Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


-- looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations 
, SUM(CONVERT(int, vac.new_vaccinations)) 
OVER(Partition by dea.location Order by dea.location, dea.date ) as RollingPeoplVaccinated
--, (RollingPeopleVaccinated/population) * 100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3


--Use CTE

With PopvsVac (continent, location, date, population, new_vacccination, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations 
, SUM(CONVERT(int, vac.new_vaccinations)) 
OVER(Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select * , (RollingPeopleVaccinated/population)*100
From PopvsVac



-- TEMP Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)



Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations 
, SUM(Cast(vac.new_vaccinations as bigint)) 
OVER(Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3


Select * , (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated





-- Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations 
, SUM(Cast(vac.new_vaccinations as bigint)) 
OVER(Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated