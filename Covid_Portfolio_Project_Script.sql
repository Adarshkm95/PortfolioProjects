select * 
from PortfolioProject.dbo.Covid_Deaths
where continent is not null
order by 3,4

--select * 
--from PortfolioProject.dbo.Covid_Vaccinations
--order by 3,4 

--select the data that we are going to be using

select location, date , total_cases , new_cases , total_deaths , population_density
from PortfolioProject.dbo.Covid_Deaths
order by 1,2


---Looking at total cases vs total deaths
--Shows the likelyhood dieing if you get contract civid in your country

select location, date , total_cases , total_deaths , (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject.dbo.Covid_Deaths
where continent is not null
order by 5

--Looking at total cases against population
--Shows what percentage of population got covid

select location, date ,population, total_cases , (total_cases/population)*100 as percent_population_infected
from PortfolioProject.dbo.Covid_Deaths
where continent is not null
order by 1,2

--What country has a highesst infection rate compared to population


select location,population, max(total_cases) as highest_infection_count ,
max((total_cases/population))*100 as percent_population_infected
from PortfolioProject.dbo.Covid_Deaths
where continent is not null
group by location,population
order by percent_population_infected desc


---Looking at countries with highest death count per population

select location, max(cast(total_deaths as int)) as total_death_count 
from PortfolioProject.dbo.Covid_Deaths
where continent is not null
group by location
order by total_death_count desc


---LETS BREAK THINGS BY CONTINENT
select location, max(cast(total_deaths as int)) as total_death_count 
from PortfolioProject.dbo.Covid_Deaths
where continent is not null
group by location
order by total_death_count desc


--Showing the continents with the highest death count per population

select location, max(cast(total_deaths as int)) as total_death_count 
from PortfolioProject.dbo.Covid_Deaths
where continent is not null
group by location
order by total_death_count desc



--Global Numbers

select sum(new_cases) as total_new_cases,sum(new_deaths)as total_new_deaths, 
(sum(new_deaths)/sum(new_cases))*100 as Death_percentage
from PortfolioProject.dbo.Covid_Deaths
where continent is not null and new_cases !=0
--group by date
order by 1,2

--Looking at total population against vaccination
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
from PortfolioProject.dbo.Covid_Deaths cd
	join PortfolioProject.dbo.Covid_Vaccinations cv
	on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null 
order by 1,2,3

--(rolling people vaccinated)

select cd.continent,cd.location,cd.date,cd.population ,cv.new_vaccinations,
sum(convert(float,cv.new_vaccinations)) OVER(partition by cd.location order by cd.location, cd.date) as rolling_people_vaccinated
from PortfolioProject.dbo.Covid_Deaths cd
	inner join PortfolioProject.dbo.covid_vac cv
	on cd.location=cv.location 
	and cd.date=cv.date
where cd.continent is not null and cv.new_vaccinations is not null 
order by 2,3

--Looking at total population vs vaccination
--use cte
with popvsVacc(continent,location,date,population ,new_vaccinations,rolling_people_vaccinated)
as
(
select cd.continent,cd.location,cd.date,cd.population ,cv.new_vaccinations,
sum(convert(float,cv.new_vaccinations)) OVER(partition by cd.location order by cd.location, cd.date) as rolling_people_vaccinated
from PortfolioProject.dbo.Covid_Deaths cd
	inner join PortfolioProject.dbo.covid_vac cv
	on cd.location=cv.location 
	and cd.date=cv.date
where cd.continent is not null and cv.new_vaccinations is not null 

)

select *,(rolling_people_vaccinated/population)*100
from popvsVacc




--TEMP TABLE
create table  #percentpopvaccinated
(continent nvarchar(255),
location nvarchar(255) ,
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

insert into #percentpopvaccinated 
select cd.continent,cd.location,cd.date,cd.population ,cv.new_vaccinations,
sum(convert(float,cv.new_vaccinations)) OVER(partition by cd.location order by cd.location, cd.date) as rolling_people_vaccinated
from PortfolioProject.dbo.Covid_Deaths cd
	join PortfolioProject.dbo.covid_vac cv
	on cd.location=cv.location 
	and cd.date=cv.date
where cd.continent is not null and cv.new_vaccinations is not null


select *,(rolling_people_vaccinated/population)*100
from #percentpopvaccinated


---Creating view to store data for later visualization

create view percentpopvac as 
select cd.continent,cd.location,cd.date,cd.population ,cv.new_vaccinations,
sum(convert(float,cv.new_vaccinations)) OVER(partition by cd.location order by cd.location, cd.date) as rolling_people_vaccinated
from PortfolioProject.dbo.Covid_Deaths cd
	join PortfolioProject.dbo.covid_vac cv
	on cd.location=cv.location 
	and cd.date=cv.date
where cd.continent is not null and cv.new_vaccinations is not null
--order by 2,3

select * from percentpopvac