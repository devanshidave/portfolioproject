Select *
From portfolioproject..coviddeath
order by 3,4

--Select *
--From portfolioproject..covidvaccines
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths,population
From portfolioproject..coviddeath
order by 1,2

-- Looking at Total cases Vs Total deaths
c

-- Looking at Total cases Vs population
-- shows what percentage of population got covid
Select location, date, total_cases, population, (total_cases/population)*100 AS populationpercentage
From portfolioproject..coviddeath
where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population
Select location, Max(total_cases)as highestinfectionrate, population, Max((total_cases/population))*100 AS populationpercentageInfection
From portfolioproject..coviddeath
--where location like '%states%'
group by location, population
order by populationpercentageInfection desc

--showing countries with highest deathcounts per population
-- using cast as int because of varchar data type in column totaldeath
Select location, Max(cast(total_deaths as int)) as Totaldeathcount 
From portfolioproject..coviddeath
--where location like '%states%'
-- data has some location where continents are null
where continent is not NULL
group by location, population
order by Totaldeathcount desc


-- LET'S BREAK THINGS BY CONTINENTS
Select continent, Max(cast(total_deaths as int)) as Totaldeathcount 
From portfolioproject..coviddeath
--where location like '%states%'
-- data has some location where continents are null
where continent is not NULL
group by continent
order by Totaldeathcount desc

-- LET'S TRY WHERE CONTINENT IS NULL
Select location, Max(cast(total_deaths as int)) as Totaldeathcount 
From portfolioproject..coviddeath
--where location like '%states%'
-- data has some location where continents are null
where continent is  NULL
group by location
order by Totaldeathcount desc

-- GLOBAL NUMBERS
Select date, SUM(new_cases)as totalcases,SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/ SUM(new_cases)* 100 as globaldeathepercentage
From portfolioproject..coviddeath
where continent is not null
group by date
order by 1,2

-- LET'S TRY JOINING TABLES

select* 
from portfolioproject..coviddeath dea
JOIN portfolioproject..covidvaccines vac
on  dea.location= vac.location AND dea.date= vac.date

-- LOOKING AT TOTAL POPULATION VS VACCINATIONS

select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) 
OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolioproject..coviddeath dea
JOIN portfolioproject..covidvaccines vac
on  dea.location= vac.location AND dea.date= vac.date
where dea.continent is not null
order by 2,3

-- we will now calculate total population who have vaccinated by dividing rollingpeoplevaccinated/population * 100, but this won't work
-- because you cannot divide alias column name, so we have to use either CTE or temp table for this
-- also make sure number of columns in cte should be same as column is select statement

with PopVSVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) 
OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolioproject..coviddeath dea
JOIN portfolioproject..covidvaccines vac
on  dea.location= vac.location AND dea.date= vac.date
where dea.continent is not null
-- order by 2,3

)
select * , (rollingpeoplevaccinated/population) * 100 from PopVSVac

-- WE CAN NOW DO IT WITH TEMP TABLE

DROP table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar (255), 
location nvarchar (255), 
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) 
OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolioproject..coviddeath dea
JOIN portfolioproject..covidvaccines vac
on  dea.location= vac.location AND dea.date= vac.date
where dea.continent is not null
-- order by 2,3
select * , (rollingpeoplevaccinated/population) * 100 from #percentpopulationvaccinated

-- LET'S CREATE A VIEW TO STORE DATA FOR LATER VISUALIZATION

create view percentpopulationvaccinated1 as 

select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) 
OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolioproject..coviddeath dea
JOIN portfolioproject..covidvaccines vac
on  dea.location= vac.location AND dea.date= vac.date
where dea.continent is not null
-- order by 2,3


