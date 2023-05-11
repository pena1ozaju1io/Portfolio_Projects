/*
**Check to see if our data Imported Correctly
SELECT * 
FROM ..Covid_Deaths$ 
ORDER BY 3,4

SELECT * 
FROM ..Covid_Vaccinations$
ORDER BY 3,4
*/

--SELECT DATA WE ARE GOING TO BE USING
SELECT
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM ..Covid_Deaths$
ORDER BY 1,2

--TOTAL CASES VS TOTAL DEATHS AS A PERCENTAGE--
SELECT
	location, 
	date, 
	total_cases,  
	total_deaths,
	(total_deaths/total_cases)*100 AS [Death_Percentage]
FROM ..Covid_Deaths$
WHERE location LIKE '%States%'
ORDER BY 3,4

--TOTAL CASES VS TOTAL DEATHS ORDERED BY HIGHEST DEATH PERCENTAGE DESCENDING ORDER
SELECT
	location, 
	date, 
	total_cases,  
	total_deaths,
	(total_deaths/total_cases)*100 AS [Death_Percentage]
FROM ..Covid_Deaths$
WHERE location LIKE '%States%'
ORDER BY Death_Percentage DESC

--PERCENTAGE OF POPULATION THAT HAS GOTTEN COVID--
SELECT
	location, 
	date, 
	total_cases,  
	population,
	(total_cases/population)*100 AS [Infection_Rate]
FROM ..Covid_Deaths$
WHERE location LIKE '%States%'
ORDER BY 1,2 DESC
--SAME QUERY BUT WE WILL FITLER OUT NULLS IN TOTAL_CASES
SELECT
	location, 
	date, 
	total_cases,  
	population,
	(total_cases/population)*100 AS [Infection_Rate]
FROM ..Covid_Deaths$
WHERE location LIKE '%States%' AND total_cases IS NOT NULL
ORDER BY 1,2 DESC

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE VS POP ORDERED BY INFECTION RATE
SELECT
	location,  
	MAX(total_cases) AS [Highest_Infection_Count],  
	population,
	MAX((total_cases/population))*100 AS [Infection_Rate]
FROM ..Covid_Deaths$
GROUP BY Location, population
ORDER BY Infection_Rate DESC

--LOOKING AT COUNTRIES WITH THE HIGHEST DEATH COUNT PER POP--
SELECT
	location,  
	MAX(total_deaths) AS [Total_Death_Count]
FROM ..Covid_Deaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC

--LOOKING AT COUNTRIES WITH THE HIGHEST DEATH COUNT BY CONTINENT--
/* https://youtu.be/qfyynHBFOsM?list=PLUaB-1hjhk8H48Pj32z4GZgGWyylqv85f&t=2452 */
SELECT
	location,  
	MAX(total_deaths) AS [Total_Death_Count]
FROM ..Covid_Deaths$
WHERE continent IS NULL
GROUP BY location 
ORDER BY Total_Death_Count DESC

--GLOBAL NUMBERS
SELECT 
	date, 
	SUM(new_cases) AS [New_Cases],
	SUM(cast(new_deaths as int)) AS [Total_Deaths],
	SUM(cast(new_deaths as int))/SUM(New_Cases)*100 AS [Death_Percentage]
FROM ..Covid_Deaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2
--CHAT GTP used to find why I was getting an error
--https://youtu.be/qfyynHBFOsM?list=PLUaB-1hjhk8H48Pj32z4GZgGWyylqv85f&t=2912 
--GLOBAL DEATHS PER DAY 
SELECT 
	date, 
	SUM(new_cases) AS [Total_Cases],
	SUM(cast(new_deaths as int)) AS [Total_Deaths],
	CASE 
		WHEN SUM(New_Cases) = 0 THEN 0 
		ELSE SUM(cast(New_Deaths as int))/SUM(New_Cases)*100 
	END AS [Death_Percentage]
FROM ..Covid_Deaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--TOTAL DEATH PERCENTAGE GLOBALLY AND UP TO DATE 
SELECT 
	SUM(new_cases) AS [Total_Cases],
	SUM(cast(new_deaths as int)) AS [Total_Deaths],
	CASE 
		WHEN SUM(New_Cases) = 0 THEN 0 
		ELSE SUM(cast(New_Deaths as int))/SUM(New_Cases)*100 
	END AS [Death_Percentage]
FROM ..Covid_Deaths$
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--PREVIEW OUR VACCINE DATA
SELECT *
FROM..Covid_Vaccinations$

--JOIN OUR DATA 
SELECT *
	FROM Portfolio_Project..Covid_Deaths$ dea 
JOIN Portfolio_Project..Covid_Vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	ORDER BY 1,2
--TOTAL POPULATION vs VACCINATIONS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	FROM Portfolio_Project..Covid_Deaths$ dea 
JOIN Portfolio_Project..Covid_Vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL 
	ORDER BY 2,3
--TOTAL POPULATION vs VACCINATIONS WITH FILTER FOR USA
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	FROM Portfolio_Project..Covid_Deaths$ dea 
JOIN Portfolio_Project..Covid_Vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.location LIKE '%States%' AND dea.continent IS NOT NULL 
	ORDER BY 2,3
--https://youtu.be/qfyynHBFOsM?list=PLUaB-1hjhk8H48Pj32z4GZgGWyylqv85f
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT( int,vac.new_vaccinations)) OVER (partition by dea.location)
	FROM Portfolio_Project..Covid_Deaths$ dea 
JOIN Portfolio_Project..Covid_Vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL 
	ORDER BY 2,3
--top Query errored out so based of cummunity feedback modified to to convert(bigint,new_vaccinations
------https://youtu.be/qfyynHBFOsM?list=PLUaB-1hjhk8H48Pj32z4GZgGWyylqv85f&t=3613------------------
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT( bigint,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM Portfolio_Project..Covid_Deaths$ dea 
JOIN Portfolio_Project..Covid_Vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL 
	ORDER BY 2,3
--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT( bigint,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM Portfolio_Project..Covid_Deaths$ dea 
JOIN Portfolio_Project..Covid_Vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	)
	SELECT *, (RollingPeopleVaccinated/Population)*100 
	FROM PopvsVac 

	--US only

	With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT( bigint,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM Portfolio_Project..Covid_Deaths$ dea 
JOIN Portfolio_Project..Covid_Vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	)
	SELECT *, (RollingPeopleVaccinated/Population)*100 
	FROM PopvsVac 
	WHERE location LIKE '%States%'

--TEMP Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinted numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT( bigint,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM Portfolio_Project..Covid_Deaths$ dea 
JOIN Portfolio_Project..Covid_Vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--order by 2,3

	SELECT *, (RollingPeopleVaccinted/Population)*100 
	FROM #PercentPopulationVaccinated


--Creating View to Store data for later visualization--
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT( bigint,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM Portfolio_Project..Covid_Deaths$ dea 
JOIN Portfolio_Project..Covid_Vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3

--Created View to store date regarding US Infection Rate
CREATE VIEW UnitedStatesInfectionRate AS
SELECT
	location, 
	date, 
	total_cases,  
	population,
	(total_cases/population)*100 AS [Infection_Rate]
FROM ..Covid_Deaths$
WHERE location LIKE '%States%'
--ORDER BY 1,2 DESC

--Creating A New View - Total Death Count by Continent
CREATE VIEW DeathCountByContinent AS
SELECT
	location,  
	MAX(total_deaths) AS [Total_Death_Count]
FROM ..Covid_Deaths$
WHERE continent IS NULL
GROUP BY location 
--ORDER BY Total_Death_Count DESC
