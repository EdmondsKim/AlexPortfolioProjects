SELECT *
FROM CovidDeaths$
WHERE continent IS NOT NULL

SELECT Location, date, total_cases, new_cases, total_deaths, population	
FROM CovidDeaths$
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--SHOWS LIKELYHOOD OF DIYING IF YOU CONTRACT COVID IN USA
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 AS DeathPercentage
FROM CovidDeaths$
WHERE location LIKE '%STATES%'
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS POPULATION
SELECT Location, date, total_cases, population, (total_cases/population) *100 AS ContractionPercentage
FROM CovidDeaths$
WHERE location LIKE '%STATES%'
ORDER BY 3 asc

--LOOKING AT COUTNRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) *100 AS PercentPopulationContracted
FROM CovidDeaths$
GROUP BY  Location, population
ORDER BY  PercentPopulationContracted DESC


-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT Location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY  Location, population
ORDER BY  TotalDeathCount DESC

-- BREAKING THINGS DOWN BY CONTINENT
SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL 
GROUP BY  continent
ORDER BY  TotalDeathCount DESC


--SHOWING CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION

SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL 
GROUP BY  continent
ORDER BY  TotalDeathCount DESC

-- DAILY GLOBAL NUMBERS 

SELECT	date, SUM(new_cases) as new_cases, SUM(new_deaths) as new_deaths, SUM(new_deaths)/SUM(NULLIF(new_cases,0))*100 as death_percentatge
FROM CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1

-- TOTAL GLOBAL NUMBERS 

SELECT	SUM(new_cases) as new_cases, SUM(new_deaths) as new_deaths, SUM(new_deaths)/SUM(NULLIF(new_cases,0))*100 as death_percentatge
FROM CovidDeaths$
WHERE continent is not null
ORDER BY 1

-- LOOKING AT TOTAL POPULATION VS VACCINATIONS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.people_vaccinated
, SUM(CONVERT(int,vac.people_vaccinated)) over (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RunningTotalVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--USING CTE
WITH PopvsVac (continent, location, date, population, people_vaccinated, RunningTotalVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.people_vaccinated, SUM(vac.people_vaccinated) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RunningTotalVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RunningTotalVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RunningTotalVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.people_vaccinated, 
SUM(vac.people_vaccinated) OVER (Partition by dea.location Order by dea.location, dea.Date)
as RunningTotalVaccinated
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RunningTotalVaccinated/Population) *100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.people_vaccinated, 
SUM(vac.people_vaccinated) OVER (Partition by dea.location Order by dea.location, dea.Date)
as RunningTotalVaccinated
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL