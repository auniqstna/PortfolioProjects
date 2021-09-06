--Can refer basic query table here
SELECT * FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT * FROM PortfolioProject..CovidVax
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
ORDER BY 1,2


--CASES AND DEATHS IN MALAYSIA
SELECT 
	location, date, total_cases,
	(total_cases/population)*100 AS InfectedPercentage,
	total_deaths, 
	(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location='Malaysia' 
ORDER BY 2



--CASES AND DEATHS IN EACH COUNTRY
--Highest infection rate and deaths count in each country
SELECT 
	location, 
	population, 
	MAX (total_cases) AS HighestInfectedCount, 
	MAX ((total_cases/population)*100) AS HighestInfectedRate,
	MAX (CAST (total_deaths AS int)) AS HighestDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
GROUP BY location, population
ORDER BY location

--Highest Deaths Count in each country
SELECT
	location, 
	population, 
	MAX (CAST (total_deaths AS int)) AS HighestDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
GROUP BY location, population
ORDER BY HighestDeathsCount DESC



--CASES AND DEATHS IN EACH CONTINENT
--Highest Deaths Count in each Continent
SELECT 
	location AS Continent, 
	MAX (CAST (total_deaths AS int)) AS HighestDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS null
GROUP BY location
ORDER BY HighestDeathsCount DESC



--GLOBAL NUMBERS 
--Calculating total cases and deaths PER DAY globally
SELECT
	date, 
	SUM (new_cases) AS Total_Global_Cases,
	SUM(CAST (new_deaths AS int)) AS Total_Global_Deaths,
	(SUM(CAST (new_deaths AS int))/SUM (new_cases))*100 AS Global_Death_Percentage
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT null
GROUP BY date
ORDER BY 1

--Calculating overall total cases and deaths globally
SELECT 
	SUM (new_cases) AS Total_Global_Cases,
	SUM(CAST (new_deaths AS int)) AS Total_Global_Deaths,
	(SUM(CAST (new_deaths AS int))/SUM (new_cases))*100 AS Overall_Death_Percentage
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT null
ORDER BY 1

--Looking at new vaccination per day
SELECT
	dea.continent, dea.location, dea.date, population, vax.new_vaccinations
FROM 
	PortfolioProject..CovidDeaths AS dea
JOIN 
	PortfolioProject..CovidVax AS vax
ON 
	dea.location=vax.location AND
	dea.date=vax.date
WHERE 
	dea.continent IS NOT null
ORDER BY 1,2,3

--New vaccination per day based on each country
WITH PopvsVax (Continent, Location, Date, Population, New_Vaccinations, CumulativeNewVaccinations)
AS (
	SELECT
		dea.continent, dea.location, dea.date, population, vax.new_vaccinations,
		SUM (CAST (vax.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativeNewVaccinations
	FROM 
		PortfolioProject..CovidDeaths AS dea
	JOIN 
		PortfolioProject..CovidVax AS vax
	ON 
		dea.location=vax.location AND
		dea.date=vax.date
	WHERE 
		dea.continent IS NOT null
	)
SELECT *, (CumulativeNewVaccinations/Population)*100
from PopvsVax



--Creating View to store data for data visualization
CREATE VIEW CovidMalaysia AS
SELECT 
	location, date, total_cases,
	(total_cases/population)*100 AS InfectedPercentage,
	total_deaths, 
	(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location='Malaysia' 

CREATE VIEW CumulativeVaccinated AS
SELECT
	dea.continent, dea.location, dea.date, population, vax.new_vaccinations,
	SUM (CAST (vax.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativeNewVaccinations
FROM 
	PortfolioProject..CovidDeaths AS dea
JOIN 
	PortfolioProject..CovidVax AS vax
ON 
	dea.location=vax.location AND
	dea.date=vax.date
WHERE 
	dea.continent IS NOT null

CREATE VIEW PercentageVaccination AS 
WITH PopvsVax (Continent, Location, Date, Population, New_Vaccinations, CumulativeNewVaccinations)
AS (
	SELECT
		dea.continent, dea.location, dea.date, population, vax.new_vaccinations,
		SUM (CAST (vax.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativeNewVaccinations
	FROM 
		PortfolioProject..CovidDeaths AS dea
	JOIN 
		PortfolioProject..CovidVax AS vax
	ON 
		dea.location=vax.location AND
		dea.date=vax.date
	WHERE 
		dea.continent IS NOT null
	)
SELECT *, (CumulativeNewVaccinations/Population)*100 AS PercentageVaccinated
from PopvsVax

CREATE VIEW CovidGlobal AS
SELECT
	date, 
	SUM (new_cases) AS Total_Global_Cases,
	SUM(CAST (new_deaths AS int)) AS Total_Global_Deaths,
	(SUM(CAST (new_deaths AS int))/SUM (new_cases))*100 AS Global_Death_Percentage
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT null
GROUP BY date

CREATE VIEW CovidContinent AS
SELECT 
	location AS Continent, 
	MAX (CAST (total_deaths AS int)) AS HighestDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS null
GROUP BY location

CREATE VIEW CovidCountry AS
SELECT 
	location, 
	population, 
	MAX (total_cases) AS HighestInfectedCount, 
	MAX ((total_cases/population)*100) AS HighestInfectedRate,
	MAX (CAST (total_deaths AS int)) AS HighestDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
GROUP BY location, population
