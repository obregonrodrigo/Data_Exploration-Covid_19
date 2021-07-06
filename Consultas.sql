-- Data Exploration

-- Total de Casos VS. Total de Mortes
-- Mostra a porcentagem de mortes causadas por dia de covid no Brasil
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Porcentagem_Mortes
FROM CovidPortifolio..CovidDeaths
WHERE location like '%brazil%' AND continent IS NOT NULL
ORDER BY 1,2

-- Total de Casos VS. Popula��o 
-- Mostra a porcentagem da popula��o que teve covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Porcentagem_Populacao_Infectada
FROM CovidPortifolio..CovidDeaths
WHERE location like '%brazil%' AND continent IS NOT NULL
ORDER BY 1,2

-- Paises com maior taxa de infec��o VS. Popula��o
-- Ranking dos paises com maior taxa de infec��o sobre o total da popula��o 
SELECT location, population, MAX(total_cases) AS Total_Infectados, MAX((total_cases/population))*100 AS Porcentagem_Populacao_Infectada
FROM CovidPortifolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Porcentagem_Populacao_Infectada DESC

-- Paises com maior taxa de mortalidade VS. Popula��o
-- Ranking dos paises com maior taxa de mortalidade sobre o total da popula��o
SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_Mortes
FROM CovidPortifolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Mortes DESC

-- CONTINENTES COM MAIOR N�MERO DE MORTES POR POPULA��O
SELECT continent, MAX(CAST(total_deaths AS INT)) AS Total_Mortes
FROM CovidPortifolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Mortes DESC

-- N�MEROS MUNDIAIS DE NOVOS CASOS E MORTES
SELECT date, SUM(new_cases) AS TOTAL_CASOS, SUM(CAST(new_deaths AS INT)) AS TOTAL_MORTES, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS PORCENTAGEM_DE_MORTES
FROM CovidPortifolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Total da Popula��o VS. Vacinados 
-- Mostra o n�mero de pessoas que recebeu ao menos uma vacida da covid
SELECT m.continent, m.location, m.date, m.population, v.new_vaccinations, 
	SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by  m.location ORDER BY m.location) AS total_pessoas_vacinadas
FROM CovidPortifolio..CovidDeaths m
JOIN CovidPortifolio..CovidVaccinations v
ON m.location = v.location AND m.date = v.date
WHERE m.continent IS NOT NULL
ORDER BY 2,3

-- Adi��o da porcentagem na consulta anterior
WITH popvsvac (continent, location, date, population, new_vaccinations, total_pessoas_vacinadas)
AS
(
	SELECT m.continent, m.location, m.date, m.population, v.new_vaccinations, 
		SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by  m.location ORDER BY m.location) AS total_pessoas_vacinadas
	FROM CovidPortifolio..CovidDeaths m
	JOIN CovidPortifolio..CovidVaccinations v
	ON m.location = v.location AND m.date = v.date
	WHERE m.continent IS NOT NULL
)
SELECT *,(total_pessoas_vacinadas/population)*100 
FROM popvsvac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date nvarchar(255),
population numeric,
new_vaccinations numeric,
total_pessoas_vacinadas numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT m.continent, m.location, m.date, m.population, v.new_vaccinations, 
	SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by  m.location ORDER BY m.location) AS total_pessoas_vacinadas
FROM CovidPortifolio..CovidDeaths m
JOIN CovidPortifolio..CovidVaccinations v
ON m.location = v.location AND m.date = v.date

SELECT *, (total_pessoas_vacinadas/population)*100
FROM #PercentPopulationVaccinated