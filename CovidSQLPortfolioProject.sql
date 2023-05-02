
/*
Covid 19 Data Exploration

Skills utilized: Joins, 
CTE's, 
Temp Tables, 
Windows Functions, 
Aggregate Functions, 
Creating Views, 
Converting data Types.

SELECT *
FROM PortfolioProjects..Coviddeath$
WHERE continent is not null
ORDER BY 3,4


-- Select Data that we are using 

SELECT Location, date, 
total_cases, 
new_cases, 
total_deaths, 
population
FROM PortfolioProjects..Coviddeath$
WHERE Continent is not null
ORDER BY 1,2

--looking at Total Cases vs Total Deaths
--shows the likelihood of dying if one contract Covid in one's country

SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths as float)/CAST(total_cases as float))* 100 as DeathPercentage
FROM PortfolioProjects..Coviddeath$
WHERE location like '%africa%'
AND continent is not null
ORDER BY 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population infected with Covid

SELECT Location, date, population, total_cases, (CAST(total_cases as float)/CAST(population as float))* 100 as PercentPopulationInfected
FROM PortfolioProjects..Coviddeath$
WHERE location like '%africa%'
ORDER BY 1,2


--Looking at Countries with the Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases)/(Population))* 100 as PercentPopulationInfected 
FROM PortfolioProjects..Coviddeath$
--WHERE location like '%africa%' 
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

 -- Showing Countries with Highest Death Count Per Population

SELECT Location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount 
FROM PortfolioProjects..Coviddeath$
--WHERE location like '%africa%'
WHERE continent is not null 
GROUP BY Location
ORDER BY TotalDeathCount  DESC



 --BREAKING DOWN BY CONTINENT

 --Showing continent with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount 
FROM PortfolioProjects..Coviddeath$
--WHERE location like '%africa%'
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- Showing  Total Global Cases and Total Global Death

SELECT SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProjects..Coviddeath$
--WHERE location like '%africa%'
WHERE continent is not null 
--GROUP BY date
ORDER BY 1,2

--Looking at Total Population vs Vaccinations
-- Showing percentage of Population that has received at least one covid vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations 
, SUM(TRY_CONVERT(BIGINT,Vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.Date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)* 100
FROM PortfolioProjects..Coviddeath$ dea
JOIN PortfolioProjects..CovidVaccinations$ vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Using CTE to perform calculation on PARTITION BY in pevious query

WITH PopvsVac (Continent, Location, Date, Population, New_vaccination, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations 
, SUM(TRY_CONVERT(BIGINT,Vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.Date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)* 100
FROM PortfolioProjects..Coviddeath$ dea
Join PortfolioProjects..CovidVaccinations$ vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3 
)
SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM PopvsVac


 --Using TEMO TABLE to perform Calculation on PARTITION BY in previous query

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

 INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations 
, SUM(TRY_CONVERT(BIGINT,Vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
  dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProjects..Coviddeath$ dea
Join PortfolioProjects..CovidVaccinations$ vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
 
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations 
, SUM(TRY_CONVERT(BIGINT,Vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
  dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProjects..Coviddeath$ dea
Join PortfolioProjects..CovidVaccinations$ vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3




