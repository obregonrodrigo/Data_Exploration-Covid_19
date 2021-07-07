<b># COVID19 DATA EXPLORARION</b>
<br>Exploração de dados COVID-19

<br>Banco de dados utilizado: SQL Server 2019
<br>Fonte de dados: Our World in Data, Coronavirua(COVID-19) Deaths | https://ourworldindata.org/covid-deaths
<br>Skills: Joins, CTE'S, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

<br><b>Data Exploration</b>
<br>USE CovidPortifolio
<br>
<br><b>Total de Casos VS. Total de Mortes</b>
<br><b>Mostra a porcentagem de mortes causadas por dia pela Covid-19 no Brasil</b>
<br>SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Porcentagem_Mortes
<br>FROM CovidPortifolio..CovidDeaths
<br>WHERE location like '%brazil%' AND continent IS NOT NULL
<br>ORDER BY 1,2
<br>
<br><b>Total de Casos VS. Total da População</b>
<br><b>Mostra a porcentagem do total da população que teve Covid-19</b>
<br>SELECT location, date, population, total_cases, (total_cases/population)*100 AS Porcentagem_Populacao_Infectada
<br>FROM CovidPortifolio..CovidDeaths
<br>WHERE location like '%brazil%' AND continent IS NOT NULL
<br>ORDER BY 1,2
<br>
<br><b>Paises com maior taxa de infecção VS. Total da População</b>
<br><b>Ranking dos paises com maior taxa de infecção sobre o total da população</b> 
<br>SELECT location, population, MAX(total_cases) AS Total_Infectados, MAX((total_cases/population))*100 AS Porcentagem_Populacao_Infectada
<br>FROM CovidPortifolio..CovidDeaths
<br>WHERE continent IS NOT NULL
<br>GROUP BY location, population
<br>ORDER BY Porcentagem_Populacao_Infectada DESC

<br><b>Paises com maior taxa de mortalidade VS. Total da População</b>
<br><b>Ranking dos paises com maior taxa de mortalidade causadas pela Covid-19 sobre o total da população</b>
<br>SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_Mortes
<br>FROM CovidPortifolio..CovidDeaths
<br>WHERE continent IS NOT NULL
<br>GROUP BY location
<br>ORDER BY Total_Mortes DESC

<br><b>Continentes com maior taxa de mortalidade VS. Total da População</b>
<br>SELECT continent, MAX(CAST(total_deaths AS INT)) AS Total_Mortes
<br>FROM CovidPortifolio..CovidDeaths
<br>WHERE continent IS NOT NULL
<br>GROUP BY continent
<br>ORDER BY Total_Mortes DESC

<br><b>Números mundiais de novos casos de infecção e mortes causadas pela Covid-19</b>
<br>SELECT date, SUM(new_cases) AS TOTAL_CASOS, SUM(CAST(new_deaths AS INT)) AS TOTAL_MORTES, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS PORCENTAGEM_DE_MORTES
<br>FROM CovidPortifolio..CovidDeaths
<br>WHERE continent IS NOT NULL
<br>GROUP BY date
<br>ORDER BY 1,2

<br><b>Total de Vacinados VS. Total da População</b>
<br><b>Mostra o número de pessoas que recebeu ao menos uma dose da vacina da covid</b>
<br>SELECT m.continent, m.location, m.date, m.population, v.new_vaccinations, 
<br>	SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by  m.location ORDER BY m.location) AS total_pessoas_vacinadas
<br>FROM CovidPortifolio..CovidDeaths m
<br>JOIN CovidPortifolio..CovidVaccinations v
<br>ON m.location = v.location AND m.date = v.date
<br>WHERE m.continent IS NOT NULL
<br>ORDER BY 2,3

<br><b>Adição da porcentagem</b>
<br><b>Adiciona a porcentagem na consulta "Total de Vacinados VS. Total da População"</b>
<br>WITH popvsvac (continent, location, date, population, new_vaccinations, total_pessoas_vacinadas)
<br>AS
<br>(
<br>	SELECT m.continent, m.location, m.date, m.population, v.new_vaccinations, 
<br>		SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by  m.location ORDER BY m.location) AS total_pessoas_vacinadas
<br>	FROM CovidPortifolio..CovidDeaths m
<br>	JOIN CovidPortifolio..CovidVaccinations v
<br>	ON m.location = v.location AND m.date = v.date
<br>	WHERE m.continent IS NOT NULL
<br>)
<br>SELECT *,(total_pessoas_vacinadas/population)*100 
<br>FROM popvsvac

<br><b>Utilização da tabela temporária</b>
<br>DROP TABLE IF EXISTS #PorcentagemVacinados
<br>CREATE TABLE #PorcentagemVacinados
<br>(
<br>continent nvarchar(255),
<br>location nvarchar(255),
<br>date nvarchar(255),
<br>population numeric,
<br>new_vaccinations numeric,
<br>total_pessoas_vacinadas numeric
<br>)
<br>
<br>INSERT INTO #PorcentagemVacinados
<br>SELECT m.continent, m.location, m.date, m.population, v.new_vaccinations, 
<br>	SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by  m.location ORDER BY m.location) AS total_pessoas_vacinadas
<br>FROM CovidPortifolio..CovidDeaths m
<br>JOIN CovidPortifolio..CovidVaccinations v
<br>ON m.location = v.location AND m.date = v.date
<br>WHERE m.continent IS NOT NULL
<br>
<br>SELECT *, (total_pessoas_vacinadas/population)*100
<br>FROM #PorcentagemVacinados
<br>
<br><b>Criação de View para visualização posterior</b>
<br>CREATE VIEW PorcentagemVacinados AS
<br>SELECT m.continent, m.location, m.date, m.population, v.new_vaccinations, 
<br>	SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by  m.location ORDER BY m.location) AS total_pessoas_vacinadas
<br>FROM CovidPortifolio..CovidDeaths m
<br>JOIN CovidPortifolio..CovidVaccinations v
<br>ON m.location = v.location AND m.date = v.date
<br>WHERE m.continent IS NOT NULL
<br>
<br>SELECT *
<br>FROM PorcentagemVacinados
