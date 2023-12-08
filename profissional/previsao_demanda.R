##=======================Previsão de demanda Last Mile#=======================


##=======================carregando os pacotes#=======================

library(dplyr)
library(ggplot2)
library(dbplyr)
library(DBI)
library(RPostgres)
library(RPostgreSQL)
library(forecast)
library(readxl)

#=======================conexao com o banco de dados#=======================
conn <- dbConnect(
  Postgres(),
  user = "postgres",
  password = "8ZFT84dx#9FGc%em",
  dbname = "finance",
  host = "localhost"
)


##=======================Consulta SQL#=======================
query <- ("select periodo, sum(qtde_pacotes) as pacotes from view_model_prev where periodo >= '2023-03-01' group by periodo")
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
colnames (dados) <-c("ds","local","y")


##=======================Criando o modelo Forecasting #=======================
?forecast

#criando um objeto
modelo <- prophet()

#ajustando o modelo
modelo <- fit.prophet(modelo, dados)

#Gerar datas futuras
futuro <- make_future_dataframe(modelo, periods = 90)

#aplicando o forecast
previsao <- predict(modelo, futuro)

#visualizando os dados
plot(modelo, previsao)

# Criar um DataFrame para as datas futuras e as previsões correspondentes
datas_previsao <- data.frame(ds = previsao$ds, previsao_caixas = previsao$yhat)


#combinando os dados com previsões
dados_com_previsao <- merge(dados, datas_previsao, by = "ds", all= T)


#exportando para um arquivo csv
write.csv(dados_com_previsao, "modelo_previsao_V2.csv", row.names = F)






# Combinar as previsões com o DataFrame original
dados_com_previsao <- cbind(dados, previsao$yhat[1:dim(dados)[1]])

# Renomear a coluna de previsão
colnames(dados_com_previsao)[ncol(dados_com_previsao)] <- "previsao_caixas"

# Exportar para um arquivo CSV
write.csv(dados_com_previsao, "dados_com_previsao.csv", row.names = FALSE)








# Fechar a conexão
dbDisconnect(conn)