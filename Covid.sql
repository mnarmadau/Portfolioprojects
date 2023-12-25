
USE PortfolioProject;
SELECT * FROM coviddeaths
ORDER BY 3,4;

-- SELECT * FROM covidvaccinations
-- ORDER BY 3,4;
SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM coviddeaths
ORDER BY 1,2;

-- Total Cases vs Total Deaths
-- Likelihood of death if you contract Covid in your country

SELECT 
    location,
date,
    total_cases,
    total_deaths,
(total_deaths/total_cases)*100 as death_percentage
FROM coviddeaths
where location like "%India%"
ORDER BY 1,2;

-- Total Cases vs Population
-- What percentage of population contracted covid
SELECT 
    location,
date,
    total_cases,
    population,
(total_cases/population)*100 as percentage_population_affected
FROM coviddeaths
where location like "%India%"
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population
SELECT 
    location,
    max(total_cases) as highest_infection_count,
    population,
max((total_cases/population))*100 as percentage_population_affected
FROM coviddeaths
group by location, population
ORDER BY percentage_population_affected desc;

-- Showing countries with highest death count per population

SELECT
    location,
    population,
    MAX(CAST(total_deaths AS SIGNED)) AS total_death_count
--    MAX(CAST(total_deaths AS SIGNED) / population) * 100 AS highest_death_per_population
FROM coviddeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY total_death_count DESC;

-- LOOKING AT TOTAL DEATH COUNT BY CONTINENT

SELECT
    continent,
    MAX(CAST(total_deaths AS SIGNED)) AS total_death_count
--    MAX(CAST(total_deaths AS SIGNED) / population) * 100 AS highest_death_per_population
FROM coviddeaths
-- WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC;

-- GLOBAL NUMBERS
SELECT 
    date,
    SUM(new_cases) as total_cases,
    SUM(CAST(new_deaths as signed)) as total_deaths,
(SUM(CAST(new_deaths as signed))/SUM(new_cases))*100 as death_percentage
FROM coviddeaths
-- where location like "%India%" and
where continent is not null
GROUP BY date
ORDER BY 1,2;

-- DEATH PERCENTAGE ACROSS THE WORLD
SELECT 
    SUM(new_cases) as total_cases,
    SUM(CAST(new_deaths as signed)) as total_deaths,
(SUM(CAST(new_deaths as signed))/SUM(new_cases))*100 as death_percentage
FROM coviddeaths
-- where location like "%India%" and
where continent is not null
ORDER BY 1,2;

-- JOINING TABLES coviddeaths and covidvaccinations

SELECT * 
from coviddeaths dea
Join covidvaccinations vac ON dea.location = vac.location
and dea.date = vac.date;

-- Looking at total percentage of population who are vaccinated
-- Creating a temporary table

WITH PopvsVac ( continent, location, date,population,new_vaccinations,Rollingpeoplevaccinated)
as
(
SELECT dea.continent,
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as signed)) OVER (Partition by dea.location order by dea.location, dea.date)
as Rollingpeoplevaccinated /* this will cumulatively add the new_vaccinations count */
-- (Rollingpeoplevaccinated/Population) * 100
from coviddeaths dea
Join covidvaccinations vac ON dea.location = vac.location
and dea.date = vac.date
-- ORDER BY 2,3;
)
 -- SELECT * from PopvsVac;

SELECT 
	*, (Rollingpeoplevaccinated/Population) * 100 as PercentPopulationvaccinated
    FROM PopvsVac;
    

-- CREATE TEMP TABLE (Method 2)

DROP TABLE IF EXISTS PercentagePopulationVaccinated;
CREATE TABLE PercentagePopulationVaccinated
 (
continent varchar(255),
location varchar(255),
date datetime,
population int,
new_vaccinations int,
Rolling_people_vaccinated int
);

INSERT INTO PercentagePopulationVaccinated (continent,location,date,population,new_vaccinations,Rolling_people_vaccinated)
SELECT 
dea.continent,
dea.location, 
dea.date, 
dea.population, 
NULLIF(vac.new_vaccinations,'') as new_vaccinations,
SUM(cast(vac.new_vaccinations as signed)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated 
	from coviddeaths dea
	Join 
		covidvaccinations vac ON dea.location = vac.location and dea.date = vac.date;

SELECT 
	*, (Rolling_people_vaccinated/Population) * 100 as PercentPopulationvaccinated
    FROM PercentagePopulationVaccinated;
    
    -- CREATING VIEW TO STORE DATA FOR VISUALISATIONS LATER
    
    DROP VIEW IF EXISTS PercentagePopulationVaccinated;
    CREATE VIEW NewPercentagePopulationVaccinated as
    SELECT 
dea.continent,
dea.location, 
dea.date, 
dea.population, 
NULLIF(vac.new_vaccinations,'') as new_vaccinations,
SUM(cast(vac.new_vaccinations as signed)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated 
	from coviddeaths dea
	Join 
		covidvaccinations vac ON dea.location = vac.location and dea.date = vac.date;
   
  
   
  