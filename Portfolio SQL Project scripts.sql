-- Title = Portfolio SQL Project
-- Author = Syed Muhammad Hamza
-- Date = 19 March 2022
---------------------------------------------------------------------------

--Select *
--from [Portfolio Project]..CovidDeaths
--where continent is not null
--order by 3


-- Data that I am going to be primarily exploring 
--Select location, date, total_cases, new_cases, total_deaths, population
--from [Portfolio Project]..CovidDeaths
--where continent is not null
--order by 1,2 

-- Lets take a look at Total deaths with respect to the total diagnosed cases
-- Shows the likelihood of dying by contracting Covid
--Select location, date, total_cases, total_deaths, Round((total_deaths/total_cases)*100, 3) as PercentageDeaths
--from [Portfolio Project]..CovidDeaths
--where location = 'United States'
--order by 2

-- Now, lets look at the percentage of population that contracted Covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentageInfected
from [Portfolio Project]..CovidDeaths
where location = 'United Kingdom'
order by location, date 

-- Looking at Max Infection Count as compared to the respective population, ordered by HighestInfectionCount
Select TOP 5 location, population, MAX (total_cases) as HighestInfectionCount, Round(MAX ((total_cases/population))*100, 5) as PercentagePoplutionInfected
from [Portfolio Project]..CovidDeaths
where continent is not null
group by location, population
order by HighestInfectionCount desc

-- Looking at Max Infection Count as compared to the respective population, ordered by PercentagePoplutionInfected
Select TOP 10 location, population, MAX (total_cases) as HighestInfectionCount, Round(MAX ((total_cases/population))*100, 5) as PercentagePoplutionInfected
from [Portfolio Project]..CovidDeaths
where continent is not null
group by location, population
order by PercentagePoplutionInfected desc

-- Insight: We have constantly see USA, India and Brazil as the top 3 countries that have the highest amount of cases so far. 
-- However, something that I found really interesting was that if we look at the countries where the majority of the population 
-- were infected, we would see countries like Denmark, Iceland and Netherland among the top 10. This trend indicates that although 
-- USA, India and Brazil may have had the most cases by far, they also have a population that is much much bigger than the countries
-- mentioned above. An argument can be made that countries like USA and India may have the most number of cases but as compared
-- to a lot of other 1st world country with much smaller population, they handled the pandemic much better which led to a much 
-- smaller percentage of their population being infected from Covid. In comparison, other countries with smaller countries handled
-- the pandemic much worse leading to extremely infection rates as compared to their population.

-- Exploring Death Count per population
Select location, MAX (CAST(total_deaths AS int)) as TotalDeathCount, Round(MAX ((total_deaths/population))*100, 3) as PercentagePoplutionDied
from [Portfolio Project]..CovidDeaths
where continent is not null 
group by location
order by PercentagePoplutionDied desc

-- Here we are calculating death count by continent
-- Note: we are taking the correct and overall numbers in the date where the locations were put as whole continents, thats why we are specifically looking for data where it says continent is null
Select location, MAX(CAST(total_deaths AS int)) as TotalDeathCount 
from [Portfolio Project]..CovidDeaths
where continent is null AND location != 'High income' AND location != 'Upper middle income' AND location != 'Lower middle income' AND location != 'Low income' -- where continent is null, continent names themselves show up in locations and thats how we get continent-only numbers; additionally to isolate continents, we have removed other counts that had been added in to the data
group by location
order by TotalDeathCount desc


-- GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, Round( (sum(cast(new_deaths as int)) / sum(new_cases))*100 , 7)  as PercentageDeaths
from [Portfolio Project]..CovidDeaths
where continent is not null
group by date
order by 1


-- How many of the total population were vaccinated? 
-- Also the accumulated/daily increasing vaccinations are also calculated for each day in each country
select cdeaths.continent , cdeaths.location, cdeaths.date, cdeaths.population, cvacs.new_vaccinations , SUM(cast(cvacs.new_vaccinations as float)) Over (partition by cdeaths.location Order by cdeaths.date) as AccumulatedVaccinations
from [Portfolio Project]..CovidDeaths as cdeaths
Join [Portfolio Project]..CovidVaccinations as cvacs
	on cdeaths.location = cvacs.location
	and cdeaths.date = cvacs.date
where cdeaths.continent is not null
order by cdeaths.location, cdeaths.date


-- Using CTE (Common Table Expression) aka, a better temp table to s
with PopsVacTemp (Continent, Location, Date, Population, New_vaccinations, AccumulatedVaccinations) as
(
select cdeaths.continent , cdeaths.location, cdeaths.date, cdeaths.population, cvacs.new_vaccinations , SUM(cast(cvacs.new_vaccinations as float)) Over (partition by cdeaths.location Order by cdeaths.date) as AccumulatedVaccinations
from [Portfolio Project]..CovidDeaths as cdeaths
Join [Portfolio Project]..CovidVaccinations as cvacs
	on cdeaths.location = cvacs.location
	and cdeaths.date = cvacs.date
where cdeaths.continent is not null
-- order by cdeaths.location, cdeaths.date !!! the order by clause cant be in there
)
select * , Round((AccumulatedVaccinations/Population)*100, 7) 
from PopsVacTemp

-- DROP view AccumlatedVaccPercent

-- Creating a View to store data for visualizations later
use [Portfolio Project]
GO
Create View PercentAccumlatedVaccs as
select cdeaths.continent , cdeaths.location, cdeaths.date, cdeaths.population, cvacs.new_vaccinations , SUM(cast(cvacs.new_vaccinations as float)) Over (partition by cdeaths.location Order by cdeaths.date) as AccumulatedVaccinations
from [Portfolio Project]..CovidDeaths as cdeaths
Join [Portfolio Project]..CovidVaccinations as cvacs
	on cdeaths.location = cvacs.location
	and cdeaths.date = cvacs.date
where cdeaths.continent is not null
-- order by cdeaths.location, cdeaths.date !!! the order by clause cant be in there


-- Testing to access the view
select *
from PercentAccumlatedVaccs