/*first, CovidDeaths and CovidVaccinations Excel files are imported as two tables of PortfolioProject DB*/

-- change datatypes of some columns
ALTER TABLE [dbo].[covidDeaths]
ALTER COLUMN total_cases int;
GO
ALTER TABLE [dbo].[covidDeaths]
ALTER COLUMN total_deaths int;
GO
ALTER TABLE [dbo].[covidDeaths]
ALTER COLUMN new_deaths int;
GO
ALTER TABLE [dbo].[covidDeaths]
ALTER COLUMN [population] int;
GO

--create a View named CovidDeath_UsefullView
CREATE VIEW CovidDeaths_UsefullView AS
SELECT location, date, population, total_cases, total_deaths
FROM covidDeaths;
GO

-- looking at TotalCases Vs TotalDeaths per day
SELECT*, total_deaths/total_cases*100 AS DeathPercentage
FROM covidDeaths
ORDER BY 1,2;
GO

-- looking at TotalCases Vs TotalDeaths per day in IRAN
SELECT*, total_deaths/total_cases*100 AS DeathPercentage
FROM CovidDeaths_UsefullView
WHERE Location like '%iran%'
ORDER BY 1,2;
GO

-- looking at TotalCases Vs TotalDeaths per All of the time in IRAN
SELECT 
	location,
	MAX(total_cases) AS TotalCases,
	MAX(total_deaths) AS TotalDeaths,
	MAX(total_deaths)/MAX(total_cases)*100 AS DeathPercentage
FROM CovidDeaths_UsefullView
WHERE Location LIKE '%iran%'
GROUP BY location;
GO

-- looking at totalcases Vs Population by country 
-- shows what percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentageOfPatients
FROM CovidDeaths_UsefullView
WHERE location LIKE '%iran%'
ORDER BY 2,5;
GO

-- looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS TotalCases, MAX(total_cases/population)*100 AS InfectedPerPopulation
FROM covidDeaths
WHERE continent IS NOT NULL 
GROUP BY location, population
ORDER BY InfectedPerPopulation desc;
GO

-- Showing countries with Highest Death count per Population
SELECT location, population, MAX(total_deaths) AS Totaldeaths, MAX(total_deaths/population)*100 AS DeathPerPopulation
FROM covidDeaths
WHERE continent IS NOT NULL 
GROUP BY location, population
ORDER BY DeathPerPopulation desc;
GO

-- Showing Total deaths by continent
SELECT continent, (SUM(T1.TotalDeaths)) AS TotalDeaths
FROM (
		SELECT continent, location, max(total_deaths) AS TotalDeaths
		FROM covidDeaths 
		WHERE continent IS NOT NULL 
		GROUP BY continent, location
	) T1
GROUP BY continent
ORDER BY TotalDeaths;
GO
-- or below query that's not exact.
SELECT continent, SUM(new_deaths) AS TotalDeaths
FROM covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeaths;
GO

-- Global infected and died Percentage Per Population
DECLARE @WorldPopulation AS float =(select distinct population from covidDeaths where location='world')
SELECT
	   @WorldPopulation AS WorldPopulation,
	   SUM(new_cases) AS TotalCases,
	   SUM(new_cases)/@WorldPopulation*100 AS CasesPerPop,
	   SUM(new_deaths) AS TotalDeaths,
	   SUM(new_deaths)/@WorldPopulation*100 AS DeathsPerPop
FROM covidDeaths
WHERE continent IS NOT NULL;
GO

select*from covidDeaths order by continent, location
-- Global infected and died Percentage Per date
DECLARE @WorldPopulation AS float =(select distinct population from covidDeaths where location='world')
SELECT
	   CAST(date AS date) AS Date,
	   @WorldPopulation AS WorldPopulation,
	   SUM(new_cases) AS TotalCases,
	   SUM(new_cases)/@WorldPopulation*100 AS CasesPerPop,
	   SUM(new_deaths) AS TotalDeaths,
	   SUM(new_deaths)/@WorldPopulation*100 AS DeathsPerPop
FROM covidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;
GO

-- First, modify datatype of some column in CovidVaccinations table
ALTER TABLE [dbo].[CovidVaccinations]
ALTER COLUMN [total_tests] bigint;
GO
ALTER TABLE [dbo].[CovidVaccinations]
ALTER COLUMN [new_tests] bigint;
GO
ALTER TABLE [dbo].[CovidVaccinations]
ALTER COLUMN [new_vaccinations] bigint;
GO
-- Looking at Total Population Vs Vaccination with create CTE
WITH C1 AS
	(
		SELECT 
			cv.continent,
			cd.location, 
			CD.date,
			CD.population, 
			CV.new_vaccinations,
			SUM(CV.new_vaccinations) OVER(PARTITION BY CV.location ORDER BY CD.location, CD.date) AS RollingPeopleVaccinated
		FROM covidDeaths CD
		JOIN CovidVaccinations CV
		ON CD.location = CV.location AND CD.date=CV.date
		WHERE CD.continent IS NOT NULL
	)
SELECT*FROM C1

-- Create PercentPopulationVaccinated Table

CREATE TABLE PercentPopulationVaccinated
	(
	 Continent nvarchar(50),
	 Location nvarchar(50),
	 [Date] Date,
	 Population numeric,
	 NewVaccinations numeric,
	 RollingPeopleVaccinated numeric
	)

INSERT INTO PercentPopulationVaccinated
SELECT 
	cv.continent,
	cd.location, 
	CD.date,
	CD.population, 
	CV.new_vaccinations,
	SUM(CV.new_vaccinations) OVER(PARTITION BY CV.location ORDER BY CD.location, CD.date) AS RollingPeopleVaccinated
FROM covidDeaths CD
JOIN CovidVaccinations CV
ON CD.location = CV.location AND CD.date=CV.date
WHERE CD.continent IS NOT NULL

--