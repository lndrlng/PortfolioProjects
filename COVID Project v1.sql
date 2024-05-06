SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to use
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2


-- Looking at Total Cases vs Deaths
-- Shows the Likelihood of dying when you contract covid in Germany
SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE 'Germany'
order by 1,2


-- Looking at the total Cases vs Population
-- Shows what percentage of population got covid
SELECT Location, date, total_cases, population new_cases, (total_cases/population)*100 as InfectionRate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2


-- Looking at Countries with the highest Infectionrate compared to the Population
SELECT Location, population new_cases, MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population)*100) as InfectionRate
FROM PortfolioProject..CovidDeaths
Group by population, location
order by InfectionRate desc


-- Showing the highest Death Count per Population 
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
Group by location
order by TotalDeathCount desc


-- Breakting things Down by continent

-- Showing Continents with the highest Death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
order by 1,2


-- Total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
	, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--	, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not NULL
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
	, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--	, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not NULL
-- order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
	, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--	, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date
-- WHERE dea.continent is not NULL
-- order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Createing View to stare Date for Vizualisation

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
	, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--	, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not NULL
-- order by 2,3

SELECT * 
FROM PercentPopulationVaccinated
