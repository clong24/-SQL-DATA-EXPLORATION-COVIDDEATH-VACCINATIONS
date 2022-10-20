--SELECT *
-- FROM [Portfolio].[dbo].[CovidDeaths]
-- ORDER BY location,date

-- SELECT *
-- FROM [Portfolio].[dbo].[CovidVaccinations]
-- ORDER BY location,date

--Select the data we are using

 SELECT Location,date,total_cases,new_cases,total_deaths,population
 FROM [Portfolio].[dbo].[CovidDeaths]
 Order by Location,date


 --Death Rate: Total cases vs Total Deaths (How likely you will be dead if you are positive in China)

 SELECT Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DEATHRATE
 FROM [Portfolio].[dbo].[CovidDeaths]
 WHERE location = 'China'
 Order by Location,date


 --Positive/Infection Rate: Total cases vs Population

 SELECT Location,date,total_cases,population, (total_cases/population)*100 AS POSITIVERATE
 FROM [Portfolio].[dbo].[CovidDeaths]
 WHERE location = 'China'
 Order by Location,date


 --Countries with the highest infection rate compared to population

 SELECT Location,Population,MAX(total_cases) as HIGHESTINFECTIONCOUNT, MAX((total_cases/population))*100 AS POSITIVERATE
 FROM [Portfolio].[dbo].[CovidDeaths]
 GROUP BY Location,Population 
 Order by POSITIVERATE DESC


 --Countries with the highest death rate if you are positive to Covid 19

 SELECT Location,Population,MAX(cast(total_deaths as int)) as HIGHESTDEATHCOUNT, MAX((total_deaths/population))*100 AS DEATHRATE
 FROM [Portfolio].[dbo].[CovidDeaths]
 WHERE continent is not null
 GROUP BY Location,Population 
 Order by HIGHESTDEATHCOUNT DESC


 --Continents with the highest deaths count

 SELECT Location,MAX(cast(total_deaths as int)) as HIGHESTDEATHCOUNT, MAX((total_deaths/population))*100 AS DEATHRATE
 FROM [Portfolio].[dbo].[CovidDeaths]
 WHERE continent is null
 GROUP BY Location 
 Order by HIGHESTDEATHCOUNT DESC


 --Global Numbers of TOTALCASESCOUNT,TOTALDEATHCOUNT AND DEATHRATE

 SELECT date,sum(new_cases) AS TOTALCASESCOUNT,sum(cast(new_deaths as int)) AS TOTALDEATHSCOUNT, sum(cast(new_deaths as int))/sum(new_cases) AS DEATHRATE
 FROM [Portfolio].[dbo].[CovidDeaths]
 WHERE continent is NOT null
 GROUP BY date
 ORDER BY date

 SELECT sum(new_cases) AS TOTALCASESCOUNT,sum(cast(new_deaths as int)) AS TOTALDEATHSCOUNT, sum(cast(new_deaths as int))/sum(new_cases) AS DEATHRATE
 FROM [Portfolio].[dbo].[CovidDeaths]
 WHERE continent is NOT null
 

 --Vaccinations Rate

 SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations
 ,sum(CONVERT(INT,v.new_vaccinations)) OVER (partition by d.location Order by d.location, d.Date) as total_vaccinations
 FROM [Portfolio].[dbo].[CovidDeaths] d
 JOIN [Portfolio].[dbo].[CovidVaccinations] v
    ON d.location = v.location
	and d.date = v.date
 WHERE d.continent is not null
 ORDER BY d.location, d.date

 --use CTE

 with Populationvsvaccinations (Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
 as
 (
 SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations
 ,sum(CONVERT(INT,v.new_vaccinations)) OVER (partition by d.location Order by d.location, d.Date) as total_vaccinations
 FROM [Portfolio].[dbo].[CovidDeaths] d
 JOIN [Portfolio].[dbo].[CovidVaccinations] v
    ON d.location = v.location
	and d.date = v.date
 WHERE d.continent is not null
 )
 SELECT *,(RollingPeopleVaccinated/Population)*100
FROM Populationvsvaccinations


--Use TEMP TABLE

Create Table #PERCENTPOPULATIONVACCINATED
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)



Insert into #PERCENTPOPULATIONVACCINATED
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations
 ,sum(CONVERT(INT,v.new_vaccinations)) OVER (partition by d.location Order by d.location, d.Date) as total_vaccinations
 FROM [Portfolio].[dbo].[CovidDeaths] d
 JOIN [Portfolio].[dbo].[CovidVaccinations] v
    ON d.location = v.location
	and d.date = v.date
 WHERE d.continent is not null

 SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PERCENTPOPULATIONVACCINATED



-- CREATING VIEW TO STORE DATA FOR DATA VISUALIZATIONS

Create View PERCENTPOPULATIONVACCINATED as
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations
 ,sum(CONVERT(INT,v.new_vaccinations)) OVER (partition by d.location Order by d.location, d.Date) as total_vaccinations
 FROM [Portfolio].[dbo].[CovidDeaths] d
 JOIN [Portfolio].[dbo].[CovidVaccinations] v
    ON d.location = v.location
	and d.date = v.date
 WHERE d.continent is not null

 SELECT *
 FROM PERCENTPOPULATIONVACCINATED