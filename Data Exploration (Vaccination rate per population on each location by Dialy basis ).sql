--use projectportflio;

select * from covidDeaths where location like 'Europe' order by date;

select * from covidVaccinations;

-- looking for data that will show total_cases, new_cases,total_deaths and population in order of Location and date 
SELECT location,date,total_cases,new_cases,total_deaths,population from covidDeaths order by 1,2;

--looking deathrate of contracted people in India during in order of date 

SELECT location,date,total_cases as Total_Cases,new_cases as New_cases ,total_deaths as Total_Deaths,
Round((total_deaths)/(total_cases)*100,2) as DeathRate, population from covidDeaths 
where location like 'India'
order by 1,2;

--looking for percentage of people getting effected in India 
SELECT location,date,total_cases as Total_Cases,new_cases as New_cases ,population ,
Round((total_cases)/(population)*100,2) as Infected_People from covidDeaths 
where location like 'India' 
order by 1,2;


--looking for countries with highest infection rate  
Select location,Population, Max(total_cases) as Maximum_number_of_cases, 
Round(Max((total_cases)/(population))*100,2) as Infection_Rate from covidDeaths 
where continent is not null
group by location,population order by Infection_Rate desc;


--looking for countries with highest deathcount per population 
Select location,Population, Max(cast (total_deaths as int)) as Maximum_number_of_deaths from covidDeaths 
where continent is not null
group by location,population order by Maximum_number_of_deaths desc;

--looking for continents with highest deathcount per population 
Select c1.location,c1.population, Max(cast (c1.total_deaths as int)) as Maximum_number_of_deaths from covidDeaths c1 
join covidDeaths c2 on c1.location = c2.continent
group by c1.location,c1.population order by Maximum_number_of_deaths desc;



--Real Data Prep 

-- Overall cases, Deaths, Deathrate globally

Select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_Deaths , sum(cast(new_deaths as int))/sum(new_cases) * 100 
as Death_Rate from covidDeaths
where continent is not null;

-- Overall cases, Deaths, Deathrate globally on Daily bases

Select Date, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_Deaths , sum(cast(new_deaths as int))/sum(new_cases) * 100 
as Death_Rate from covidDeaths
where continent is not null
group by Date
order by 1;

-- Overall cases, Deaths, Deathrate for all continents on Daily bases

Select Continent, Date, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_Deaths , sum(cast(new_deaths as int))/sum(new_cases) * 100 
as Death_Rate from covidDeaths
where continent is not null
group by Date,Continent
order by 1,2;

-- Overall cases, Deaths, Deathrate for all continents 
Select Continent, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_Deaths , sum(cast(new_deaths as int))/sum(new_cases) * 100 
as Death_Rate from covidDeaths
where continent is not null
group by Continent
order by 1;

-- Overall cases, Deaths, Deathrate for all locations 
Select location, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_Deaths , sum(cast(new_deaths as int))/sum(new_cases) * 100 
as Death_Rate from covidDeaths
where continent is not null
group by location
order by 1;

--Joining both tables
Select cd.location, cd.Date, cd.population , cd.new_cases , cd.new_deaths, cv.new_tests, cv.new_vaccinations 
from covidDeaths cd
join covidVaccinations cv
	on cd.location = cv.location and cd.date = cv.date
	where cd.continent is not null 
	order by cd.location;


--providing data with vaccination rate location wise on daily bases 

With Vaccination_rate (location, Date, population , new_cases , new_deaths, new_tests, new_vaccinations,
						Rolling_People_vaccinationated)
as
(
Select cd.location, cd.Date, cd.population , cd.new_cases , cd.new_deaths, cv.new_tests, cv.new_vaccinations,
Sum(convert(float,cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) 
as Rolling_People_vaccinationated
from covidDeaths cd
join covidVaccinations cv
	on cd.location = cv.location 
	and cd.date = cv.date
	where cd.continent is not null 
)
Select *, Rolling_People_vaccinationated/population*100 as Vaccination_Rate 
	from Vaccination_rate 
	order by location, Date;

--Temp Table
Drop Table if exists #Temp_covid_data;
Create table #Temp_covid_data
(
location nvarchar(255), 
Date DateTime ,
population Numeric,
new_cases Numeric,
new_deaths Numeric,
new_tests Numeric,
new_vaccinations Numeric,
Rolling_People_vaccinationated numeric);

Insert into #Temp_covid_data  
Select cd.location, cd.Date, cd.population , cd.new_cases , cd.new_deaths, cv.new_tests, cv.new_vaccinations,
Sum(convert(float,cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) 
as Rolling_People_vaccinationated
from covidDeaths cd
join covidVaccinations cv
	on cd.location = cv.location 
	and cd.date = cv.date
	where cd.continent is not null ;

-- Create Views for 

Create View Vaccination_rate_by_pop as
With Vaccination_rate (location, Date, population , new_cases , new_deaths, new_tests, new_vaccinations,
						Rolling_People_vaccinationated)
as
(
Select cd.location, cd.Date, cd.population , cd.new_cases , cd.new_deaths, cv.new_tests, cv.new_vaccinations,
Sum(convert(float,cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) 
as Rolling_People_vaccinationated
from covidDeaths cd
join covidVaccinations cv
	on cd.location = cv.location 
	and cd.date = cv.date
	where cd.continent is not null 
)
Select *, Rolling_People_vaccinationated/population*100 as Vaccination_Rate 
	from Vaccination_rate;

--Calling out view
Select * from Vaccination_rate_by_pop;