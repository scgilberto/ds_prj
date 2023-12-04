library(shinydashboard)

ui <- dashboardPage(
  dashboardHeader(),
  dashboardSidebar(
    sidebarMenu(
      dateInput("idData", "Informe a data", format ="dd-mm-yyyy", language = "pt", autoclose = TRUE),
      textInput("id_local_base", "Informe a Base", placeholder = "Nome da Base"),
      textInput("id_local_destino", "Informe o Destino", placeholder = "Local de Destino"),
      textInput("id_nome_motorista", "Nome Motorista", placeholder = "Nome do Motorista"),
      radioButtons("dist", "Tipo Motorista:",
                   c("J&T 自有员工" = "CLT",
                     "MEI 司机" = "MEI",
                     "PA 加盟商" = "PA",
                     "TAC 司机" = "AUTONOMO",
                     "Terceirizado 三方代派" = "DISTRIBUIDOR")))
    
  ),
  
  dashboardBody()
)

library(shiny)

server <- function(input, output) {
  
}
shinyApp(ui, server)