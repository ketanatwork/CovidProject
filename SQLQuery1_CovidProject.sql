SELECT *
FROM ProjectCovid..Covid_death
Where continent is NOT null
order by 3,4

--SELECT *
--FROM ProjectCovid..Covid_vax
--order by 3,4

--SELECT data that we want to use.


SELECT Location, date, total_cases, new_cases,total_deaths, population
FROM ProjectCovid..Covid_death
Where continent is NOT null
order by 1,2

-- Looking at Total cases vs Total deaths
-- shows chances of death if covid == true in NZ
SELECT Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM ProjectCovid..Covid_death
Where continent is NOT null
and location like '%zealand%'
order by 1,2

-- looking at total cases vs population
--shows percent of population got covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 as CovidPopPercentage
FROM ProjectCovid..Covid_death
Where continent is NOT null
--Where location like '%zealand%'
order by 1,2

--Looking at countries with high infection rate in percentage
SELECT Location, population, MAX(total_cases)as HighestInfectionCount, MAX((total_cases/population)*100) as PercentagePopInfected
FROM ProjectCovid..Covid_death
Where continent is NOT null
--Where location like '%zealand%'
GROUP by Location, population 
order by PercentagePopInfected desc

-- Search for countries with highes death count per population
SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM ProjectCovid..Covid_death
--Where location like '%zealand%'
Where continent is NOT null
GROUP by Location 
order by TotalDeathCount desc


-- LET's BREAK things down by CONTINENT
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM ProjectCovid..Covid_death
--WHERE location<>'High income'
--Where location like '%zealand%'
Where continent is null AND location NOT IN ('Upper middle income','Low income','High income','Lower middle income')
GROUP by continent
order by TotalDeathCount desc


--Showing continents with highest Death count
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM ProjectCovid..Covid_death
--WHERE location<>'High income'
--Where location like '%zealand%'
Where continent is NOT null AND location NOT IN ('Upper middle income','Low income','High income','Lower middle income')
GROUP by continent
order by TotalDeathCount desc

-- global numbers
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM ProjectCovid..Covid_death
Where continent is NOT null
-- location like '%zealand%'
group by date
order by 1,2




-- looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaxed 
--, (RollingPeopleVaxed/population)*100
From ProjectCovid..Covid_vax vac
Join ProjectCovid..Covid_death dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is NOT null
order by 2,3

--USE CTE

With PopvsVac (Continent, location, date, population, new_vaccination, RollingPeopleVaxed)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaxed 
--, (RollingPeopleVaxed/population)*100
From ProjectCovid..Covid_vax vac
Join ProjectCovid..Covid_death dea
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is NOT null
--Where dea.location like '%zealand%'
--order by 2,3
)
Select*, (RollingPeopleVaxed/population)*100 as PercentPeopleVax
From PopvsVac



--Temp table

Drop Table if exists PercentPopVax
Create table PercentPopVax
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_Vaccinations numeric,
RollingPeopleVaxed numeric
)


Insert Into PercentPopVax
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaxed 
--, (RollingPeopleVaxed/population)*100
From ProjectCovid..Covid_vax vac
Join ProjectCovid..Covid_death dea
	On dea.location = vac.location
	and dea.date = vac.date
	--Where dea.continent is NOT null
--Where dea.location like '%zealand%'
--order by 2,3

Select*, (RollingPeopleVaxed/population)*100
From PercentPopVax


--creating View to store data for later viz
Create View PercentPopVax# as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaxed 
--, (RollingPeopleVaxed/population)*100
From ProjectCovid..Covid_vax vac
Join ProjectCovid..Covid_death dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is NOT null
--Where dea.location like '%zealand%'
--order by 2,3

--
Select *
From PercentPopVax#
