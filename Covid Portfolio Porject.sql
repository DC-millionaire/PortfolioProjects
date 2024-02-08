SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

-- Select Data that we are going to be using 

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country 
SELECT Location, Date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT)/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, Date, total_cases, population , (CAST(total_cases AS FLOAT)/population)*100 AS PercentofPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at Countries with Highest infection Rate comparet to population
SELECT Location, MAX(total_cases) AS HighestInfectionCount, population , MAX((CAST(total_cases AS FLOAT)/population))*100 AS PercentofPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentofPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population 

SELECT Location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Let's Break things down by Continent
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL Numbers

SELECT sum(new_cases) as Total_Cases, SUM(CAST (new_deaths as int)) As Total_Deaths, SUM(CAST(New_deaths as float))/ SUM(CAST(New_Cases as float)) * 100 as deathpercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
--Group by date 
ORDER BY 1,2


-- Looking at Total Population Vs Vaccinations 
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated,
 --, (ROllingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
	WHERE dea.continent IS NOT NULL
	ORDER BY 2,3

-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
 --, (ROllingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM PopvsVac



-- TEMP Table 
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255), 
Location NVARCHAR(255),
Date Datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
 --, (ROllingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
--WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3



SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM #PercentPopulationVaccinated


--Creating View to store data for late visualization 
Create view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
 --, (ROllingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3

	Select * FROM PercentPopulationVaccinated