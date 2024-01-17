Select *
From PortfolioProject..CovidDeaths
Where continent is not NULL
order by 3, 4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3, 4


-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1, 2


-- Looking at Total Cases vs. Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1, 2


--Looking at Total Cases vs. Population

Select location, date, total_cases, population, (total_cases/population) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1, 2

--Looking at Countries with the highest Ifection Rate compared to Population

Select Location, population, MAX(total_cases as int) as HighestInfectionCount, MAX((total_cases/population))*100
	as PercentPopulationInfected
From CovidDeaths
Where continent is not NULL
group by Location, population
order by PercentPopulationInfected DESC

--Showing countries with the Highest Death Count  per Pop

Select Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not NULL
group by Location
order by TotalDeathCount DESC

-- Let's break things down by continent
--Showing continents with the highest death count per pop

Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not NULL
group by continent
order by TotalDeathCount DESC

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1, 2


-- Looking at Total Population vs. Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) 
	OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
Order by 1, 2, 3


-- Use CTE

With PopvsVac (Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) 
	OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
)--Order by 1, 2, 3

Select *, (RollingPeopleVaccinated/population) * 100
From PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
	as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not NULL
--Order by 1, 2, 3

Select *, (RollingPeopleVaccinated/Population)* 100
From #PercentPopulationVaccinated



-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) 
	OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
--Order by 2, 3



Select * 
From PercentPopulationVaccinated