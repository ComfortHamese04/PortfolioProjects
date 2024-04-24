/*
COvid 19 Data Exploration
Skills used :CTE'S,Temp Tables, Windows functions, Aggregate functions, Creating Views ,Converting Data Types
*/


--Select data im going to be working with
SELECT *
FROM PotfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM PotfolioProject..CovidVaccinations
ORDER BY 3,4


----SELECTING DATA I'M GOING TO BE USING
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PotfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage 
FROM PotfolioProject..CovidDeaths
WHERE location LIKE '%Africa%' AND continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location,date,total_cases,population,(total_cases/population)*100 AS PercentagePopulationInfected
FROM PotfolioProject..CovidDeaths
WHERE location LIKE '%Africa%'AND continent IS NOT NULL
ORDER BY 1,2

--Countries with highest infection rate compared to population

SELECT location,population,MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM PotfolioProject.dbo.CovidDeaths
WHERE location LIKE '%Africa%'AND continent IS NOT NULL
GROUP BY location,population
ORDER BY PercentagePopulationInfected ASC

--Countries with the highest Death Count Per Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PotfolioProject.dbo.CovidDeaths
--WHERE location LIKE '%Africa%' AND 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--BREAK THINGS DOWN BY CONTINENT 
-- Showing contintents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PotfolioProject.dbo.CovidDeaths
WHERE continent IS NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Showing continents with the highest death count

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PotfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS
SELECT  SUM(new_cases)AS TotalCases,SUM(CAST(total_deaths AS INT)) AS TotalDeaths ,SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PotfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
SUM(CAST (new_vaccinations AS INT)) OVER (PARTITION BY Dea.location ORDER BY Dea.location,Dea.date ) AS RollingPeopleVaccinated
FROM PotfolioProject..CovidDeaths Dea
JOIN  PotfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location 
	AND
	Dea.date=Vac.date
WHERE  Dea.continent IS NOT NULL
	ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query


WITH PopvsVac(Continent,location,date,population, new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
SUM(CAST (new_vaccinations AS INT)) OVER (PARTITION BY Dea.location ORDER BY Dea.location,Dea.date ) AS RollingPeopleVaccinated
FROM PotfolioProject..CovidDeaths Dea
JOIN  PotfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location 
	AND
	Dea.date=Vac.date
WHERE  Dea.continent IS NOT NULL
	--ORDER BY 2,3
)
SELECT *,RollingPeopleVaccinated/population*100
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent NVARCHAR(255),
Location NVARCHAR (255),
Date DATETIME,
Population NUMERIC ,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)
INSERT INTO  #PercentPopulationVaccinated
SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
SUM(CAST (new_vaccinations AS INT)) OVER (PARTITION BY Dea.location ORDER BY Dea.location,Dea.date ) AS RollingPeopleVaccinated
FROM PotfolioProject..CovidDeaths Dea
JOIN  PotfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location 
	AND
	Dea.date=Vac.date
WHERE  Dea.continent IS NOT NULL
	--ORDER BY 2,3

SELECT *,RollingPeopleVaccinated/population*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
SUM(CAST (new_vaccinations AS INT)) OVER (PARTITION BY Dea.location ORDER BY Dea.location,Dea.date ) AS RollingPeopleVaccinated
FROM PotfolioProject..CovidDeaths Dea
JOIN  PotfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location 
	AND
	Dea.date=Vac.date
WHERE  Dea.continent IS NOT NULL
	--ORDER BY 2,3

	SELECT *
	FROM PercentPopulationVaccinated