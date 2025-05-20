select * from PortfolioProject..CovidDeaths$
where continent is not null
ORDER BY 3, 4;
------------------------------------------------------------------------------------------------------------------


--SELECTING DATA THAT IS GOING TO BE USED

Select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2
------------------------------------------------------------------------------------------------------------------

--SHOWS DEATH POSSIBILITY DUE TO COVID CONTRACTION IN THE UNITED STATES

Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2
------------------------------------------------------------------------------------------------------------------

--TOTAL CASES VS THE POPULATION
--SHOWS PERCENTAGE OF PEOPLE CONTRACTED WITH COVID

Select Location,date,total_cases,population,(total_cases/population)*100 as Percentage_Population_Infected
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2 
------------------------------------------------------------------------------------------------------------------

--COMPARISON OF COUNTRIES WITH HIGHEST INFECTION RATE WIHT POPULATION

Select location,MAX(total_cases) as Highest_Infection_count,population,max(total_cases/population)*100 as Percentage_Population_Infected
from PortfolioProject..CovidDeaths$
where continent is not null
group by location,population
order by Percentage_Population_Infected desc
------------------------------------------------------------------------------------------------------------------

--COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

select location,max(cast(total_Deaths as int))as Total_death_count
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by Total_death_count desc
------------------------------------------------------------------------------------------------------------------

--CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION

select continent,max(cast(total_Deaths as int))as Total_death_count
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by Total_death_count desc
------------------------------------------------------------------------------------------------------------------

--GLOBAL NUMBERS

Select date,SUM(new_cases) as total_cases,sum(cast(new_deaths as int))as total_Deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY DATE
order by 1,2
------------------------------------------------------------------------------------------------------------------

select * 
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
------------------------------------------------------------------------------------------------------------------

--TOTAL POPULATION VS VACCINATIONS

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
-----------------------------------------------------------------------------------------------------------------
  
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as People_Vaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
-----------------------------------------------------------------------------------------------------------------

--USE CTE

with population_vs_vaccinations (continent,location,date,population,new_vaccinations,People_Vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as People_Vaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select* ,(people_vaccinated/population)*100 as Percent_Vac
from population_vs_vaccinations
-----------------------------------------------------------------------------------------------------------------

--TEMP TABLE

drop table if exists PopVaccinated
create table PopVaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population int,
new_vaccinations int,
People_vaccinated int
)

insert into PopVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as People_Vaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select* ,(people_vaccinated/population)*100 as Percent_Vac
from PopVaccinated
-----------------------------------------------------------------------------------------------------------------

--QUERIES FOR VISUALIZATIONS

--1. TOTAL CASES VS TOTAL DEATHS

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

-----------------------------------------------------------------------------------------------------------------

--2. TOTAL DEATH COUNT IN EACH CONTINENT

select location, sum(cast(new_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is null
and location not in ('World','European Union','International')
group by location
order by TotalDeathCount desc

-----------------------------------------------------------------------------------------------------------------

--3. HIGHEST NUMBER OF INFECTIONS IN DIFFERENT COUNTRIES 

select Location ,Population ,max(total_cases) as  HighestInfectionCount, Max((total_cases/population))*100 as
PercentPopulationInfected
from PortfolioProject..CovidDeaths$
group by Location,Population
order by PercentPopulationInfected desc

-----------------------------------------------------------------------------------------------------------------

--4. DATEWISE COVID INFECTION STATISTICS

select Location ,Population ,date, max(total_cases) as  HighestInfectionCount, Max((total_cases/population))*100 as
PercentPopulationInfected
from PortfolioProject..CovidDeaths$
group by Location,Population,date
order by PercentPopulationInfected desc

-----------------------------------------------------------------------------------------------------------------