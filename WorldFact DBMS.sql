                           --World Data Factbook Database Management Project --

create database WorldFacts;
use WorldFacts;

-- load the datasets via using sql server import export wizard or you can simple write the
-- following query which i am mentioning for a file

--Create the table first 
Create table Country_comparison_area (Number int, Country nvarchar(100), Area bigint);

--import the file
Bulk insert dbo.Country_comparison_area
from "C:\Users\win10\Desktop\WorldData\datasets\country_comparison_area.csv" --FilePath--
with
(
	format = 'CSV',
	Firstrow=2


)
go

-- I'll do rest of the files via SQL Server import export wizard which is a easy method --
--load the raw data files as per as your project needs--

--First International Debt Statistics Analysis--

--1. What is the total amount of money countries owe to the world bank.? $

select sum(External_debt) as Total_Money_owe_By_Countries from debt_external;

--2. Which country has the highest debt given and how much is that?

select top 1 country,External_debt as Maximum_Debt from debt_external
order by External_debt desc;

-- World population analysis with birth_rate and death rate--

Create view Vw_World_population_data
as
select A.number,A.country Country ,a.Population , f.Area, e.Population_growth_rate,B.Birth_rate,C.Death_Rate,D.[Migration_Rate ] from Country_comparison_population A
inner join Country_comparison_birth_rate B
on A.country = B.country
inner join Country_comparison_death_rate C
on B.country = c.country
inner join Country_comparison_net_migration_rate D
on c.country = D.country
inner join country_comparison_population_growth_rate E
on D.country = E.country
inner join Country_comparison_area F
on E.country = F.Country;

select * from Vw_World_population_data;

---1. Which country has the highest population?

select Country,Population from Vw_World_population_data
where population = (select max(population) from Vw_World_population_data);

---2. Which country has the least number of people ?

select Country,Population from Vw_World_population_data
where population = (select min(population) from Vw_World_population_data);

---3. Which country is witnessing highest population growth? in %

select Country,Population_growth_rate from Vw_World_population_data
where Population_growth_rate = (select max(Population_growth_rate) from Vw_World_population_data);

---4. Which country has an extraordinary number for the population?

select Country,Population from Vw_World_population_data
where population > (select  Avg(population) from Vw_World_population_data)
and Population_growth_rate > (select Avg(Population_growth_rate) from Vw_World_population_data) ;

---5. add population_density/

select * into world_population_Data from Vw_World_population_data;

select * from world_population_Data;

Alter Table world_population_data Add population_density float;

update world_population_Data set population_density = Population/Area;

---6. Which country is the most dense country in the world?

select Country Highest_dense_country ,Population_density  from World_population_data
where Population_density = (select max(Population_density) from World_population_data);

---World GDP Analysis---

create view Vw_World_GDP_Data
as
select a.number,a.country,a.GDP_per_capita,B.GDP_growth_rate from gdp_per_capita A
inner join gdp_real_growth_rate B
on a.country = b.country;

select * from Vw_World_GDP_Data;

---1. Which country has the highest GDP_per Capita ?

select country,GDP_per_capita,GDP_growth_rate from Vw_World_GDP_Data 
where gdp_per_capita = (select max(GDP_per_capita) from Vw_World_GDP_Data);

---2. Which country has the highest GDP growth rate ? in %

select country,GDP_per_capita,GDP_growth_rate from Vw_World_GDP_Data 
where GDP_growth_rate = (select max(GDP_growth_rate) from Vw_World_GDP_Data);

---stored procedures for Population by country name--

create procedure Sp_GetPopulation (@Country nvarchar(100))
as
select Country,Population,population_density,Population_growth_rate from world_population_Data 
where Country = @Country;
go

execute Sp_GetPopulation 'India'

--Q. Highest infant mortality rate with birthRate and death rate life expectancy at birth?

create view vw_InfantMortalityWorld as
select A.country,A.Infant_Mortality_rate,B.Life_expectancy_at_birth,c.Birth_Rate,d.Death_Rate
from country_comparison_infant_mortality_rate A
inner join country_comparison_life_expectancy_at_birth B
on A.country = B.country
inner join Country_comparison_birth_rate C
on B.country = C.country
inner join Country_comparison_death_rate D
on c.country = d.country;

select * from vw_InfantMortalityWorld where
Infant_Mortality_rate = (select max(Infant_Mortality_rate) from vw_InfantMortalityWorld);

-- infant mortality rate , life expectancy at birth and birth rate by country name Procedure

create procedure Sp_Infant_Mortality_rate (@country nvarchar(100))
as
select Country,Infant_Mortality_rate,Life_expectancy_at_birth,Birth_Rate from vw_InfantMortalityWorld
where country = @country;
go

exec Sp_Infant_Mortality_rate 'Pakistan'

--- World Crude oil production import export analysis--

create view Vw_World_Crude_oil_Data
as 
select a.country,a.Crude_oil_production,b.Crude_oil_exports,c.Crude_oil_imports from crude_oil_production A
inner join crude_oil_exports B
on A.country = B.country 
inner join crude_oil_imports C
on b.country = c.country;

---1. Highest crude oil producing country?

select A.country,A.Crude_oil_production from Vw_World_Crude_oil_Data A
where Crude_oil_production = (Select max(Crude_oil_production) from Vw_World_Crude_oil_Data)