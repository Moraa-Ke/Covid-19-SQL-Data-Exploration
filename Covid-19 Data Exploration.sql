/** Covid 19 data exploration as at 4th May 2024

Skills used: Joins, CTE's, Windows Functions, Aggregate Functions, Filtering and Sorting, Creating Views, Converting Data Types**/


SELECT * 
FROM PortfolioProject.dbo.Coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

--SELECT * 
--FROM PortfolioProject.dbo.Covidvaccinations
--ORDER BY 3,4;

--RETRIEVING DATA FOR USE
SELECT location,date, total_cases,new_cases,total_deaths,population
FROM  PortfolioProject.dbo.Coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--TOTAL CASES VS TOTAL DEATHS
SELECT location,date, total_cases,total_deaths--,(total_deaths/total_cases)
FROM  PortfolioProject.dbo.Coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

SELECT location, date, total_cases, total_deaths,
    CASE 
        WHEN total_deaths IS NOT NULL AND total_cases IS NOT NULL AND TRY_CONVERT(INT, total_cases) <> 0 THEN 
            (TRY_CONVERT(FLOAT, total_deaths) / TRY_CONVERT(FLOAT, total_cases)) * 100 
        ELSE 
            NULL 
    END AS DeathPercentage
FROM PortfolioProject.dbo.Coviddeaths
WHERE continent IS NOT NULL
--AND WHERE location LIKE '%Kenya%'
ORDER BY 1,2;


--TOTAL CASES VS POPULATION
SELECT location, date,population, total_cases, 
    CASE 
        WHEN total_cases IS NOT NULL AND population IS NOT NULL AND TRY_CONVERT(INT, total_cases) <> 0 THEN 
            (TRY_CONVERT(FLOAT, total_cases) / TRY_CONVERT(FLOAT, population)) * 100 
        ELSE 
            NULL 
    END AS PopulationPercentInfected
FROM PortfolioProject.dbo.Coviddeaths
WHERE continent IS NOT NULL
--AND WHERE location LIKE '%Kenya%'
ORDER BY 1,2 DESC;


--COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location, population, MAX(total_cases)AS HighestInfectionCount, 
    CASE 
        WHEN MAX(total_cases) IS NOT NULL AND population IS NOT NULL AND TRY_CONVERT(INT, MAX(total_cases)) <> 0 THEN 
            (TRY_CONVERT(FLOAT, MAX(total_cases)) / TRY_CONVERT(FLOAT, population)) * 100 
        ELSE 
            NULL 
    END AS PercentPopulationInfected
FROM PortfolioProject.dbo.Coviddeaths
WHERE continent IS NOT NULL
--AND WHERE location LIKE '%Kenya%'
GROUP BY location, population
ORDER BY 4 DESC;


--COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION
SELECT location,  MAX(CAST (total_deaths AS INT))AS TotalDeathCount 
FROM PortfolioProject.dbo.Coviddeaths
WHERE continent IS NOT NULL
--AND WHERE location LIKE '%Kenya%'
GROUP BY location
ORDER BY TotalDeathCount DESC;


--CONTINENT WITH THE HIGHEST DEATH COUNT PER POPULATION
SELECT continent,  MAX(CAST (total_deaths AS INT))AS TotalDeathCount 
FROM PortfolioProject.dbo.Coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


--GLOBAL NUMBERS
--NEW CASES VS NEW DEATHS
SELECT date, 
    SUM(CAST(new_cases AS BIGINT)) AS TotalNewCases,
    SUM(CAST(new_deaths AS FLOAT)) AS TotalNewDeaths,
    SUM(CAST(new_deaths AS FLOAT)) / NULLIF(SUM(CAST(new_cases AS BIGINT)), 0) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.Coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

--TOTAL NEW CASES VS TOTAL NEW DEATHS
SELECT  
    SUM(CAST(new_cases AS BIGINT)) AS TotalNewCases,
    SUM(CAST(new_deaths AS FLOAT)) AS TotalNewDeaths,
    SUM(CAST(new_deaths AS FLOAT)) / NULLIF(SUM(CAST(new_cases AS BIGINT)), 0) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.Coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--TOTAL POPULATION VS VACCINATIONS
Select location--, COUNT(1) AS Occure
From PortfolioProject.dbo.Coviddeaths
GROUP BY location
--HAVING COUNT(1)>=1;


SELECT ADB.continent,ADB.location,ADB.date,population,new_vaccinations,
SUM(CAST(new_vaccinations AS BIGINT)) OVER(PARTITION BY ADB.location ORDER BY ADB.location,ADB.date) 
										AS TotalNewVac
FROM PortfolioProject.dbo.Covidvaccinations AS ADP
JOIN PortfolioProject.dbo.Coviddeaths AS ADB
ON ADP.location = ADB.location
AND ADP.date = ADB.date
WHERE ADB.location NOT IN ('Africa','Oceania','South America','Asia','North America','Europe',
							'Lower middle income','Western Sahara','Upper middle income',
							'European Union','High income',
							'Low income','World')
ORDER BY 1,2,3;

--Select continent--, COUNT(1) AS Occure
--From PortfolioProject.dbo.Coviddeaths
--WHERE continent IS NOT NULL
--GROUP BY continent
----HAVING COUNT(1)>=1;



--Using CTE to perform Calculation on Partition By in previous query
WITH POPVSVAC (continent,location,date,population,new_vaccinations,TotalNewVac)
as
(
SELECT ADB.continent,ADB.location,ADB.date,population,new_vaccinations,
SUM(CAST(new_vaccinations AS BIGINT)) OVER(PARTITION BY ADB.location ORDER BY ADB.location,ADB.date) 
										AS TotalNewVac
FROM PortfolioProject.dbo.Covidvaccinations AS ADP
JOIN PortfolioProject.dbo.Coviddeaths AS ADB
ON ADP.location = ADB.location
AND ADP.date = ADB.date
--WHERE ADB.location NOT IN ('Africa','Oceania','South America','Asia','North America','Europe',
--							'Lower middle income','Western Sahara','Upper middle income',
--							'European Union','High income',
--							'Low income','World')
--ORDER BY 1,2,3;
)
SELECT * ,(TotalNewVac/population) 
FROM POPVSVAC

-- Creating View to store data for later visualizations
CREATE VIEW DeathPercentage AS
SELECT location, date, total_cases, total_deaths,
    CASE 
        WHEN total_deaths IS NOT NULL AND total_cases IS NOT NULL AND TRY_CONVERT(INT, total_cases) <> 0 THEN 
            (TRY_CONVERT(FLOAT, total_deaths) / TRY_CONVERT(FLOAT, total_cases)) * 100 
        ELSE 
            NULL 
    END AS DeathPercentage
FROM PortfolioProject.dbo.Coviddeaths
WHERE continent IS NOT NULL
--AND WHERE location LIKE '%Kenya%'
--ORDER BY 1,2;

SELECT * FROM DeathPercentage