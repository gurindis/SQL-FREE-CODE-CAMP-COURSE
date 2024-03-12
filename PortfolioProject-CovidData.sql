Select top 5*
From PortfolioProject..CovidDeaths
order by 3,4

Select top 5*
From PortfolioProject..CovidVaccinations
order by 3,4

Select top 5 location,date, total_cases, new_cases, total_deaths,population
From PortfolioProject..CovidDeaths
order by 1,2

--Look at total cases vs. total deaths for USA
Select top 5 location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%States%'
order by 3 desc,4 desc

--Look at total cases vs. population

--Look at total cases vs. total deaths for USA
Select top 5 location, date, total_cases,population,(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%States%'
order by 3 desc,4 desc

--Countries with highest infection rates vs. population
Select location, population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population)*100) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location !=continent
group by location,population
order by PercentPopulationInfected desc

--Countries with highest death rates vs. population
Select location, population, MAX(total_deaths) as HighestDeathCount,MAX((cast(total_deaths as int)/cast(population as int))*100) as PercentPopulationDeath
From PortfolioProject..CovidDeaths
where location !=continent and total_deaths is not null
group by location,population
order by PercentPopulationDeath desc

--Global Numbers/Data grouped weekly
Select date,SUM(new_cases) as TotalCases,SUM(new_deaths) as TotalDeaths,(SUM(new_deaths)/SUM(new_cases)*100) as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null and new_cases > 0
group by date
order by 1,2

--Total cases & Total Deaths in the Word
Select SUM(new_cases) as TotalCases,SUM(new_deaths) as TotalDeaths,(SUM(new_deaths)/SUM(new_cases)*100) as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null and new_cases > 0
order by 1,2

--Join CovidDeath & CovidVaccination Tables
Select *
From PortfolioProject..CovidVaccinations as cvac
Join PortfolioProject..CovidDeaths as cdeath
On cvac.location = cdeath.location and cvac.date = cdeath.date

--Look at total population vs. vaccinations
Select top 5 cdeath.continent,cdeath.location,cdeath.date,cdeath.population,cvac.new_vaccinations
From PortfolioProject..CovidVaccinations as cvac
Join PortfolioProject..CovidDeaths as cdeath
On cvac.location = cdeath.location and cvac.date = cdeath.date
where cdeath.continent is not null
order by 1,2,3

--Creates new column with a Rolling Sum of People Vaccinated
Select top 5 cdeath.continent,cdeath.location,cdeath.date,cdeath.population,cvac.new_vaccinations,
SUM(cvac.new_vaccinations) OVER (Partition by cdeath.location Order by cdeath.location,
cdeath.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations as cvac
Join PortfolioProject..CovidDeaths as cdeath
On cvac.location = cdeath.location and cvac.date = cdeath.date
where cdeath.continent is not null
order by 1,2,3

--CTE
With PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select cdeath.continent,cdeath.location,cdeath.date,cdeath.population,cvac.new_vaccinations,
SUM(CAST(cvac.new_vaccinations as int)) OVER (Partition by cdeath.location Order by cdeath.location,
cdeath.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations as cvac
Join PortfolioProject..CovidDeaths as cdeath
On cvac.location = cdeath.location and cvac.date = cdeath.date
where cdeath.continent is not null
)
Select *, (RollingPeopleVaccinated/population)* 100
From PopvsVac

--Temp Tables
DROP TABLE if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated 

Select cdeath.continent,cdeath.location,cdeath.date,cdeath.population,cvac.new_vaccinations,
SUM(CAST(cvac.new_vaccinations as int)) OVER (Partition by cdeath.location Order by cdeath.location,
cdeath.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations as cvac
Join PortfolioProject..CovidDeaths as cdeath
On cvac.location = cdeath.location and cvac.date = cdeath.date
where cdeath.continent is not null


Select *, (RollingPeopleVaccinated/population)* 100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select cdeath.continent,cdeath.location,cdeath.date,cdeath.population,cvac.new_vaccinations,
SUM(CAST(cvac.new_vaccinations as int)) OVER (Partition by cdeath.location Order by cdeath.location,
cdeath.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations as cvac
Join PortfolioProject..CovidDeaths as cdeath
On cvac.location = cdeath.location and cvac.date = cdeath.date
where cdeath.continent is not null
