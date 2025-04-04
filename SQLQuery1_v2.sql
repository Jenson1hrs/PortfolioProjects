SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE location like 'Malaysia'
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
SELECT Location, date, Population,total_cases, (total_cases/Population)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE location like 'Malaysia'
ORDER BY 1,2

--Looking at Total Population vs Vaccinations
--BIGINT because dataset too big otherwise use int
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast (vac.new_vaccinations as BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.Date) as CFPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Using Temp Table
--To see the percentage of vaccinated people out of the whole population
DROP TABLE  if exists #PercentPopulationvacinnated
CREATE TABLE #PercentPopulationvacinnated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
CFPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationvacinnated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast (vac.new_vaccinations as BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.Date) as CFPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (CFPeopleVaccinated/Population)*100
FROM #PercentPopulationvacinnated


-- Creating View to store data for later visualizations

CREATE View PercentPopulationvacinnated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast (vac.new_vaccinations as BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.Date) as CFPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationvacinnated