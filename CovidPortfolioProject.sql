

Select * from PortfolioProject_Covid..CovidDeaths
Order by 3,4

--Select * from PortfolioProject_Covid..CovidVaccinations
--Order by 3,4

-- Selecting the data we will be using

Select location, date, population, total_cases, new_cases, total_deaths
From PortfolioProject_Covid..CovidDeaths
Order by 1,2


-- total cases Vs total deaths

Select location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject_Covid..CovidDeaths
Order by 1,2

-- Filtering for India
-- Death Percentage showing the likelihood of dying if one contracts Covid
Select location, date, population, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as DeathPercentage
From PortfolioProject_Covid..CovidDeaths
Where location like '%India%'
Order by 1,2

-- Observation : There is 1.2% likelihood of dying if one contracts covid currently

-- Total cases Vs Population
-- Percentage of people contracted Covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject_Covid..CovidDeaths
Where location like '%India%'
Order by 1,2

-- Observation : Currently 2.08% of population has been infected

-- Countries with highest infection rate compared to Population
Select location, population, Max(total_cases) as highestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject_Covid..CovidDeaths
Group by location, population
Order by 4 desc


-- Countries with highest death count per Population
Select location, Max(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject_Covid..CovidDeaths
Where continent is not Null
Group by location
Order by 2 desc


-- Continents Wise information

-- Continents with highest death count per Population
Select location, Max(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject_Covid..CovidDeaths
Where continent is Null
Group by location
Order by 2 desc

Select continent, Max(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject_Covid..CovidDeaths
Where continent is not Null
Group by continent
Order by 2 desc


-- Continents with highest death count per population

--Select continent, Max(CAST(total_deaths as int)) as TotalDeathCount, 
--From PortfolioProject_Covid..CovidDeaths
--Where continent is not Null
--Group by continent
--Order by 2 desc

-- Global (across the world) Numbers

Select date, SUM(new_cases) as Total_cases, SUM(CAST(new_deaths as int)) as Total_deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject_Covid..CovidDeaths
where continent is not Null
Group by date
Order by 1,2

-- total cases

Select SUM(new_cases) as Total_cases, SUM(CAST(new_deaths as int)) as Total_deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject_Covid..CovidDeaths
where continent is not Null
-- Group by date
--Order by 1,2


-------------*****Covid Vaccinations Data Exploration*****-------------

Select * 
From PortfolioProject_Covid..CovidVaccinations

-- Joining these two tables
Select * 
From PortfolioProject_Covid..CovidDeaths as dea
Join PortfolioProject_Covid..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date

-- Total populations vs Vaccinated population

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject_Covid..CovidDeaths as dea
Join PortfolioProject_Covid..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null
Order by 2,3

-- Rolling summation of people getting vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject_Covid..CovidDeaths as dea
Join PortfolioProject_Covid..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null
Order by 2,3

-- Finding rolling % of people got vaccinated 

-- Using CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject_Covid..CovidDeaths as dea
Join PortfolioProject_Covid..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac
Order by 2,3

-- Using Temp table

Drop Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated 
(
Continent nVarchar(255),
Location nVarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject_Covid..CovidDeaths as dea
Join PortfolioProject_Covid..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating a view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject_Covid..CovidDeaths as dea
Join PortfolioProject_Covid..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated