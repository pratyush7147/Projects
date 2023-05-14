SELECT * 
FROM PortfolioProject..[Covid Deaths]
where continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations 
--ORDER BY 3,4

--Select the Data the we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population		
FROM PortfolioProject..[Covid Deaths]
where continent is not null
ORDER BY 1,2

--Looking at the Total Cases vs Total Deaths

SELECT Location, date, total_cases,total_deaths, (cast(total_deaths as decimal))/(cast(total_cases as decimal))*100 as DeathPercentage
FROM PortfolioProject..[Covid Deaths]
where location like '%ndia%'
ORDER BY 1,2

--Looking at Total Cases vs Population

SELECT Location, date, population,total_cases, (cast(total_cases as decimal))/(cast(population as decimal))*100 as PercentPopulationInfected
FROM PortfolioProject..[Covid Deaths]
where location like '%ndia%'
ORDER BY 1,2

--Countries with highest infection rate compared to population


SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((cast(total_cases as decimal))/(cast(population as decimal))*100) as 
PercentPopulationInfected
FROM PortfolioProject..[Covid Deaths]
--where location like '%ndia%'
where continent is not null
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

--Countries with Highest Death Counts per Population

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..[Covid Deaths]
--where location like '%ndia%'
where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Breaking down by Continent


--Continents with Highest Death counts per Population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..[Covid Deaths]
--where location like '%ndia%'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC



--GLOBAL NUMBERS
SET ARITHABORT OFF;
SET ANSI_WARNINGS OFF;
SELECT SUM(new_cases), SUM(cast(new_deaths as int)), (SUM(CAST(new_deaths AS INT))/SUM(new_cases )*100) as DeathPercentage
FROM PortfolioProject..[Covid Deaths]
--where location like '%ndia%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2



--Total Populations vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population)*100
FROM PortfolioProject..[Covid Deaths] dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population)*100
FROM PortfolioProject..[Covid Deaths] dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/ population)*100
from PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..[Covid Deaths] dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

CREATE VIEW PercentaPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..[Covid Deaths] dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select * from dbo.PercentPopulationVaccinated