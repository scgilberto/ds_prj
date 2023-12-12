##=======================Previsão de demanda Last Mile#=======================
library(tidyverse)
library(forecast)
library(writexl)
library(ggplot2)


#=======================conexao com o banco de dados#=======================

conn <- dbConnect(
  Postgres(),
  user = "postgres",
  password = "8ZFT84dx#9FGc%em",
  dbname = "finance",
  host = "localhost"
)


##=======================Consulta SQL#=======================
query <- ("select periodo, sum(qtde_pacotes) as pacotes from view_model_prev where periodo >= '2023-01-01' group by periodo")
#periodo inicial = 2023-03-01
#periodo Final   = D-1
##=======================Carregar os dados do banco#=======================
dados <- dbGetQuery(conn, query)
class(dados)

##=======================Verificando os dados#=======================
head(dados)
tail(dados)
View(dados)


##=======================Convertendo a coluna data e renomeando#==============

dados$periodo <- as.Date(dados$periodo)
str(dados)
#colnames (dados) <-c("ds","local","y")
View(dados)

##======================= Criar uma série temporal#==============

serie_temporal <- ts(dados$pacotes, frequency = 365)

# Ajustar um modelo de previsão (por exemplo, usando auto.arima do pacote forecast)
modelo <- auto.arima(serie_temporal)

# Gerar previsões para 2024
previsoes <- forecast(modelo, h = 366)

# Criar um dataframe com as datas e as previsões
previsoes_df <- data.frame(Data = seq(as.Date("2024-01-01"), as.Date("2024-12-31"), by = "days"),
                           pacotes = previsoes$mean)

# Criar um plot para visualizar os dados
ggplot(previsoes_df, aes(x = Data, y = pacotes)) +
  geom_line() +
  labs(title = "Previsão de Demanda de Pacotes para 2024",
       x = "Data",
       y = "Quantidade de Pacotes") +
  theme_minimal()

# Salvar o gráfico em um arquivo
ggsave("previsao_demanda_2024.png", width = 8, height = 4)


# Filtrar dados para janeiro de 2023
dados_jan_2023 <- dados %>% filter(format(periodo, "%Y-%m") == "2023-01")
view(dados_jan_2023)

# Criar uma série temporal para janeiro de 2023
serie_temporal_jan_2023 <- ts(dados_jan_2023$pacotes, frequency = 31)

# Ajustar um modelo de previsão para janeiro de 2023
modelo_jan_2023 <- auto.arima(serie_temporal_jan_2023)

# Gerar previsões para janeiro de 2024
previsoes_jan_2024 <- forecast(modelo, h = 31)

# Criar um dataframe com as datas e as previsões para janeiro de 2024
previsoes_jan_2024_df <- data.frame(periodo = seq(as.Date("2024-01-01"), as.Date("2024-01-31"), by = "days"),
                                    pacotes = previsoes_jan_2024$mean)

# Criar um dataframe para janeiro de 2023
dados_jan_2023_df <- data.frame(periodo = dados_jan_2023$periodo,
                                pacotes = dados_jan_2023$pacotes)

# Juntar os dataframes para comparar janeiro de 2023 e janeiro de 2024
comparacao_janeiro <- rbind(dados_jan_2023_df, previsoes_jan_2024_df)
View(comparacao_janeiro)

# Gráfico de série temporal para janeiro de 2023 e 2024
ggplot(comparacao_janeiro, aes(x = periodo, y = pacotes, color = factor(ifelse(periodo < "2024-01-01", "Real (2023)", "Previsão (2024)")))) +
  geom_line() +
  labs(title = "Comparação de Demanda de Pacotes - Janeiro de 2023 e 2024",
       x = "Data",
       y = "Quantidade de Pacotes",
       color = "Legenda") +
  theme_minimal()

# Salvar o gráfico em um arquivo
ggsave("comparacao_janeiro_2023_2024.png", width = 8, height = 4)

# Salvar o arquivo excel sem comparativos
write_xlsx(previsoes_df, "previsoes_2024.xlsx")

# Salvar o arquivo excel com comparativos
write_xlsx(comparacao_janeiro,"Comparacoes_Janeiro_2023_2024.xlsx")
















