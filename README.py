# World-Facts-Database-Repository
# This repository uses raw data on global problems and world facts (e.g. electricity production, population growth, birth/death rate) to answer common questions and extract information about countries. The data is analyzed for insights on health, environment, and economy. Future plans include using MS SQL Server, Power BI, Talend OS, and Python
# World Data Factbook Database Management Project
#Manage the connection
import pyodbc

conn = pyodbc.connect('DRIVER={ODBC Driver 13 for SQL Server};'
                      'SERVER=KRYPTON\KRYPTON;'
                      'DATABASE=WorldFacts;'
                      'Trusted_Connection=yes;')

# 1. What is the total amount of money countries owe to the world bank.? $

cursor = conn.cursor()
cursor.execute('select sum(External_debt) as Total_Money_owe_By_Countries from debt_external;')

for i in cursor:
    print(i)

# 2. Which country has the highest debt given and how much is that?

cursor = conn.cursor()
cursor.execute('select top 1 country,External_debt as Maximum_Debt from debt_external order by External_debt desc;')

for i in cursor:
    print(i)

# World population analysis with birth_rate and death rate

#1. Which country has the highest population?

cursor = conn.cursor()
cursor.execute('select Country,Population from Vw_World_population_data where population = (select max(population) from Vw_World_population_data)')

for i in cursor:
    print(i)

