Select *
From 
	PortfolioProject.dbo.CovidDeaths
Where 
	continent is not Null
order by 3,4

--Select *
--From PortfolioProject.dbo.CovidVaccinations
--order by 3,4

Select 
	location 
	,date 
	,new_cases
	,total_deaths 
	,population
From 
	PortfolioProject.dbo.CovidDeaths
Where 
	continent is not Null
order by 1,2


-- Percentage of Deaths from Covid per Date by Country
Select 
	location
	,date
	,population
	,total_cases
	,total_deaths
	,(total_deaths/total_cases)*100 as DeathPercentage
From 
	PortfolioProject.dbo.CovidDeaths
--Where location like '%Indonesia%'
Where 
	continent is not Null
order by 1,2



-- Percentage of Covid Cases in Indonesia
Select 
	location
	,date
	,population
	,total_cases, round((total_cases/population)*100,5) as CasesPercentage
From 
	PortfolioProject.dbo.CovidDeaths
Where 
	location like '%Indonesia%'
	and continent is not Null
order by 1,2


-- Highest Infection Rate by Country
Select 
	location
	,population
	,Max(total_cases) as TotalInfection
	,round(Max(total_cases/population)*100,5) as PopulationInfectedPercentage
From 
	PortfolioProject.dbo.CovidDeaths
Where 
	continent is not Null
Group by 
	location
	,population
order by 
	PopulationInfectedPercentage desc


-- The Highest Total Death Covid Cases by location/country
Select 
	location
	,population
	,Max(cast(total_cases as int)) as TotalCases
	,Max(cast(total_deaths as int)) as TotalDeathCount
From
	PortfolioProject.dbo.CovidDeaths
Where 
	continent is not Null
Group by 
	location
	,population
order by 
	TotalDeathCount desc


-- The Highest Total Death Covid Cases by Continent
Select 
	continent
	,Max(population) as Population
	,Max(cast(total_cases as int)) as TotalCases
	,Max(cast(total_deaths as int)) as TotalDeathCount
From
	PortfolioProject.dbo.CovidDeaths
Where 
	continent is not Null
Group by 
	continent
order by
	continent asc,
	TotalDeathCount desc


-- Percentage of Deaths from Covid per Date by Global
Select 
	date
	,SUM(new_cases) as TotalCases
	,SUM(cast(new_deaths as int)) as TotalDeaths
	,SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From 
	PortfolioProject.dbo.CovidDeaths
Where 
	continent is not Null
	--location like '%Indonesia%'
Group by date
order by 1,2


--Joinning two tables
Select *
From
	PortfolioProject..CovidDeaths as death
Join
	PortfolioProject..CovidVaccinations as vac
	On death.location = vac.location
	and death.date = vac.date

-- Counting People Vaccination per Day by Country
Select
	death.continent 
	,death.location
	,death.date
	,death.population
	,vac.new_vaccinations
	,SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by death.location Order By death.location, death.date) as VaccinationCount
From
	PortfolioProject..CovidDeaths as death
Join
	PortfolioProject..CovidVaccinations as vac
	On death.location = vac.location
	and death.date = vac.date
Where
	death.continent is not null
order by 2,3


-- Counting People Vaccinatied per Day by Country (with CTE)
With PepVac(
	continent
	,location
	,date
	,population
	,new_cases
	,CasesCount
	,new_vaccination
	,VaccinationCount)
AS 
(
Select
	death.continent 
	,death.location
	,death.date
	,death.population
	,death.new_cases
	,SUM(death.new_cases) OVER (Partition by death.location Order By death.location, death.date) as CasesCount
	,vac.new_vaccinations
	,SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by death.location Order By death.location, death.date) as VaccinationCount
From
	PortfolioProject..CovidDeaths as death
Join
	PortfolioProject..CovidVaccinations as vac
	On death.location = vac.location
	and death.date = vac.date
Where
	death.continent is not null
)

Select *
	,VaccinationCount/population*100 as VaccinationRate
From PepVac
Order by 2,3



-- TEMP TABLE
DROP TABLE if exists PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
	continent nvarchar (255)
	,location nvarchar(255)
	,date date
	,population numeric
	,new_cases numeric
	,CasesCount numeric
	,new_vaccination numeric
	,VaccinationCount numeric
	)

Insert into #PercentagePopulationVaccinated
Select
	death.continent 
	,death.location
	,death.date
	,death.population
	,death.new_cases
	,SUM(death.new_cases) OVER (Partition by death.location Order By death.location, death.date) as CasesCount
	,vac.new_vaccinations
	,SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by death.location Order By death.location, death.date) as VaccinationCount
From
	PortfolioProject..CovidDeaths as death
Join
	PortfolioProject..CovidVaccinations as vac
	On death.location = vac.location
	and death.date = vac.date

Select *
	,VaccinationCount/population*100 as VaccinationRate
From #PercentagePopulationVaccinated
Order by 2,3



-- Creating View
Create View PercentagePopulationVaccinated as
Select
	death.continent 
	,death.location
	,death.date
	,death.population
	,new_cases
	,SUM(death.new_cases) OVER (Partition by death.location Order By death.location, death.date) as CasesCount
	,vac.new_vaccinations
	,SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by death.location Order By death.location, death.date) as VaccinationCount
From
	PortfolioProject..CovidDeaths as death
Join
	PortfolioProject..CovidVaccinations as vac
	On death.location = vac.location
	and death.date = vac.date
Where
	death.continent is not null


Select * 
From
	PercentagePopulationVaccinated