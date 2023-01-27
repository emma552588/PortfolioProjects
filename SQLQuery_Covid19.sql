Select *
From Project_Covid19..covid_death
Where continent is not null 
order by 3,4

---Looking at countries with highest infection rate compared to population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM Project_Covid19..covid_death
--WHERE location = 'Taiwan'
Where continent is not null 
GROUP BY Location, population
ORDER BY 4 DESC;

---Countries with Highest Death Count
 SELECT location, MAX(CAST(total_deaths AS int)) AS HighestDeathCount
 FROM Project_Covid19..covid_death
 Where continent is not null 
 GROUP BY location
 ORDER BY 2 DESC;

---BREAKING THINGS DOWN BY CONTINENT
 SELECT continent, MAX(CAST(total_deaths AS int)) AS HighestDeathCount
 FROM Project_Covid19..covid_death
 Where continent is not null 
 GROUP BY continent
 ORDER BY 2 DESC;
-----This outcome is not correct because it doesn't have numbers with continent is null.
 SELECT location, MAX(CAST(total_deaths AS int)) AS HighestDeathCount
 FROM Project_Covid19..covid_death
 Where continent is null 
 GROUP BY location
 ORDER BY 2 DESC;

---Showing contintents with the highest death count per population
SELECT continent, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM Project_Covid19..covid_death
--Where location like '%states%'
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC;

---GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, 
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM Project_Covid19..covid_death
--Where location like '%states%'
WHERE continent is not null 
Group By date
ORDER BY 1;

---GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Project_Covid19..covid_death
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

---Combine two tables
SELECT * FROM Project_Covid19..covid_death D
INNER JOIN Project_Covid19..covid_vaccinations V
	ON D.date = V.date 
	AND D.location = V.location

---Looking at total populations and vaccinations (RollingPeopleVaccinated)
SELECT D.continent,D.location, D.date, D.population, V.new_vaccinations,
SUM(CAST(V.new_vaccinations AS bigint)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 *not allowed to use this, should use CTE
FROM Project_Covid19..covid_death D
INNER JOIN Project_Covid19..covid_vaccinations V
	ON D.date = V.date 
	AND D.location = V.location
WHERE D.continent IS NOT NULL
ORDER BY 2,3

---Looking at total populations and vaccinations (TotalPeopleVaccinated)
SELECT D.continent,D.location, D.date, D.population, V.new_vaccinations,
SUM(CAST(V.new_vaccinations AS bigint)) OVER (PARTITION BY D.location) AS TotalPeopleVaccinated
FROM Project_Covid19..covid_death D
INNER JOIN Project_Covid19..covid_vaccinations V
	ON D.date = V.date 
	AND D.location = V.location
WHERE D.continent IS NOT NULL
AND D.location = 'Canada'
ORDER BY 2,3

---Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(SELECT D.continent,D.location, D.date, D.population, V.new_vaccinations,
SUM(CAST(V.new_vaccinations AS bigint)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM Project_Covid19..covid_death D
INNER JOIN Project_Covid19..covid_vaccinations V
	ON D.date = V.date 
	AND D.location = V.location
WHERE D.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS 'RollingPeopleVaccinated/population'
FROM PopvsVac

---Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(50),
location nvarchar(50),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT D.continent,D.location, D.date, D.population, V.new_vaccinations,
SUM(CAST(V.new_vaccinations AS bigint)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM Project_Covid19..covid_death D
INNER JOIN Project_Covid19..covid_vaccinations V
	ON D.date = V.date 
	AND D.location = V.location
WHERE D.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 AS 'RollingPeopleVaccinated/population'
FROM #PercentPopulationVaccinated

---Creating view to store data for later visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT D.continent,D.location, D.date, D.population, V.new_vaccinations,
SUM(CAST(V.new_vaccinations AS bigint)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM Project_Covid19..covid_death D
INNER JOIN Project_Covid19..covid_vaccinations V
	ON D.date = V.date 
	AND D.location = V.location
WHERE D.continent IS NOT NULL
