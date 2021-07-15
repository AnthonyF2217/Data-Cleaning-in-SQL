
-- Selct data that I will be using

SELECT Location, Date, Total_Cases, New_Cases, Total_Deaths, Population
FROM CovidDeaths
ORDER BY Location, Date

-- Looking at total cases vs. total deaths
-- Shows probability of dying if you contract COVID in your country

SELECT Location, Date, Total_Cases, Total_Deaths, (Total_Deaths/Total_Cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE Location = 'United States'
ORDER BY Location, Date

-- Looking at total cases vs. population
-- Shows what percentage of population contracted COVID

SELECT Location, Date, Population, Total_Cases,(Total_Cases/Population)*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE Location = 'United States'
ORDER BY Location, Date

-- Looking at countries with highest infection rate compared to population
-- Shows what percentage of a countries population contracted COVID

SELECT Location, Population, MAX(Total_Cases) AS InfectionCount, Max((Total_Cases/Population))*100 AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Showing the countries with the highest death count per population

SELECT Location, MAX(CAST(Total_Deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Breaking things down by continent

SELECT Continent, MAX(CAST(Total_Deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC

-- Showing the continents with the highest death count per population

SELECT Continent, MAX(CAST(Total_Deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC

-- All Global numbers

SELECT Date, SUM(New_Cases) AS TotalCases, SUM(CAST(New_Deaths AS int)) AS TotalDeaths, SUM(CAST(New_Deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Date
ORDER BY 1,2

-- Total Global Numbers

SELECT SUM(New_Cases) AS TotalCases, SUM(CAST(New_Deaths AS int)) AS TotalDeaths, SUM(CAST(New_Deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 1,2

-- Looking at total population vs. vaccinations

SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
, SUM(CONVERT(int, vac.New_Vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM CovidDeaths AS Dea
JOIN CovidVaccinations AS Vac
	ON Dea.Location = Vac.Location
	AND Dea.Date = Vac.Date
WHERE dea.Continent IS NOT NULL
ORDER BY 2, 3

-- USING CTE

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
, SUM(CONVERT(int, vac.New_Vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM CovidDeaths AS Dea
JOIN CovidVaccinations AS Vac
	ON Dea.Location = Vac.Location
	AND Dea.Date = Vac.Date
WHERE dea.Continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac

-- Using temp table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
, SUM(CONVERT(int, vac.New_Vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM CovidDeaths AS Dea
JOIN CovidVaccinations AS Vac
	ON Dea.Location = Vac.Location
	AND Dea.Date = Vac.Date
WHERE dea.Continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
, SUM(CONVERT(int, vac.New_Vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM CovidDeaths AS Dea
JOIN CovidVaccinations AS Vac
	ON Dea.Location = Vac.Location
	AND Dea.Date = Vac.Date
WHERE dea.Continent IS NOT NULL
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated