Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths)/NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%hungary%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select location, date,population, total_cases,(CONVERT(float, total_cases)/NULLIF(CONVERT(float, population), 0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%hungary%'
order by 1,2


-- Looking at Countries with highest infection rate compared to population

Select location ,population, MAX(total_cases) as HighestInfectionCount, Max(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location ,population
order by PercentPopulationInfected desc

-- Break things down by continent
-- We have to cast or convert it to int in order to avoid error !!
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Showing Countries with Highest Death Count per Population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc


-- Showing continents with the highest death count per population

Select continent, Max(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0))*100 as MostDeathPerPopulation
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by MostDeathPerPopulation desc

-- GLOBAL Numbers

Select SUM(new_cases) as 'new cases', SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- We give alias names in the end of the row like " dea or vac ", so we don t have to write long names over and over
-- Looking at Total Population vs Vaccinations
-- USE CTE
With PopvsVac ( Continent, Location, Date , Population, New_Vaccinations, RollingPeopleVaccinated)
	as
	(
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, ( RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
	)
	Select *, ( RollingPeopleVaccinated/Population)*100
	From PopvsVac

	-- TEMP TABLE

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

Insert into	#PercentPopulationVaccinated
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, ( RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3

Select *, ( RollingPeopleVaccinated/Population)*100
	From #PercentPopulationVaccinated



-- Creating View to store data for later visualisations

-- Nem működik ez!! :(
Create View PercentPopulationVaccinated as 
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--, ( RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

Select *
From PercentPopulationVaccinated


	


