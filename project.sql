use ytProject
select * from dbo.deaths
select * from [dbo].[vaccinations]


select location,date,total_cases, new_cases,total_deaths,population
from [dbo].[deaths] 
order by 1,2

--death percentage
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from [dbo].[deaths] 
order by 1,2

--death percentage in india
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from [dbo].[deaths] 
where location='India'
order by 1,2

--percentage of people who got covid in india
select location,date,total_cases,population,(total_cases/population)*100 as Percentage_of_people_with_covid
from [dbo].[deaths] 
where location='India'
order by total_cases desc

--countries with highest infection rate  --finds the max cases in each country
select continent, location, population, MAX(total_cases) as highest_cases
from [dbo].[deaths]
where continent is not null
group by continent, location, population
--location, population
 
-- Countries with Highest Infection Rate compared to Population
select location, population, MAX(total_cases) as highest_cases, MAX(total_cases/population)*100 as highest_infection_percentage
from [dbo].[deaths]
group by location, population
order by highest_infection_percentage desc

-- Countries with Highest Death Count per Population
-- type cast death to int as it was given as varchar and in data at some places continent was null so make it not null
select location,max(cast(total_deaths as int)) as death_count
from [dbo].[deaths]
where continent is not null
group by location
order by death_count desc

 --contintents with the highest death count per population
 select continent, max(cast(total_deaths as int)) as deathCountByContinent
 from [dbo].[deaths]
 where continent is not null
 group by continent
 order by deathCountByContinent desc;

 --sum of new cases throughout the world on each day
 select date, sum(new_cases) as total_new_cases_everyday
 from [dbo].[deaths]
 where continent is not null
 group by date
 order by date

 --sum of new cases compared with sum of new deaths everyday
 select date, sum(cast(new_deaths as int)) as tot_new_deaths, sum(new_cases) as tot_new_cases, (sum(cast(new_deaths as int))/sum(new_cases))*100 as Percentage_of_new_deaths
 from [dbo].[deaths]
 where continent is not null
 group by date
 order by date

 select* from [dbo].[vaccinations]

 --join tables on location and date
 select* from [dbo].[deaths] dea
 join [dbo].[vaccinations] vac
 on dea.date=vac.date 
 and dea.location=vac.location

 --number of new vaccinations based on death location and in increasing oreder of date
 select dea.continent,dea.location,dea.date, dea.population,convert(bigint,vac.new_vaccinations) new_vaccinations,
 sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.date, dea.location) newVaccinesOnLocation
 from [dbo].[deaths] dea join [dbo].[vaccinations] vac
 on dea.date=vac.date
 and dea.location=vac.location
 where dea.continent is not null

--percentage of new vaccinations based on death location and in increasing oreder of date
select dea.continent,dea.location,dea.date, dea.population,convert(bigint,vac.new_vaccinations) new_vaccinations,
 sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.date, dea.location) newVaccinesOnLocation,
 (newVaccinesOnLocation/dea.population)*100 --this gives error as newly added col doesnt belong to any table sp we cant use it in calculation s use CTE
 from [dbo].[deaths] dea join [dbo].[vaccinations] vac
 on dea.date=vac.date
 and dea.location=vac.location
 where dea.continent is not null

 --cte acts as a temp table and cte mein no. of cols should be same as uske andar no. of cols
 with NewVaccOnLocation(continent,location,date,population,new_vaccinations,newVaccinesOnLocation) as(
 select dea.continent,dea.location,dea.date, dea.population,convert(bigint,vac.new_vaccinations) new_vaccinations,
 sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.date, dea.location) newVaccinesOnLocation
 from [dbo].[deaths] dea join [dbo].[vaccinations] vac
 on dea.date=vac.date
 and dea.location=vac.location
 where dea.continent is not null
 )
 select*,(newVaccinesOnLocation/population)*100 as percentnewVaccinesOnLocation
 from NewVaccOnLocation

 --running above query using temp table
 --delete it if a table of that name exists already

 drop table if exists #temp
 create table #temp
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 newVaccinesOnLocation numeric
 )
 insert into #temp
 select dea.continent,dea.location,dea.date, dea.population,convert(bigint,vac.new_vaccinations) new_vaccinations,
 sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.date, dea.location) newVaccinesOnLocation
 from [dbo].[deaths] dea join [dbo].[vaccinations] vac
 on dea.date=vac.date
 and dea.location=vac.location
 
 select*,(newVaccinesOnLocation/population)*100 as percentnewVaccinesOnLocation
 from #temp


 ---- Creating View to store data for later visualizations
 create view pop_vaccinated_percent 
 as 
 select dea.continent,dea.location,dea.date, dea.population,convert(bigint,vac.new_vaccinations) new_vaccinations,
 sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.date, dea.location) newVaccinesOnLocation
 from [dbo].[deaths] dea join [dbo].[vaccinations] vac
 on dea.date=vac.date
 and dea.location=vac.location
 where dea.continent is not null

 select* from pop_vaccinated_percent 