library(shiny)
options(shiny.sanitize.errors = FALSE)
library(leaflet)
library(RColorBrewer)
library(jsonlite)
library(dplyr)

source("./dataframe.r", local = TRUE)

vars <- c(
  "Distrito Federal" = "DF",
  "Rio Grande do Sul" = "RS"
)


url_template <- "http://localhost/api/[UF]/[ANO]/01?limit=[LIMIT]&source=entorno01,baisco02"
arr_limit <- seq(30, 400, by = 20)  

filteredData <- allcnes

ui <- bootstrapPage(
	navbarPage("CNES", id="nav",
		tabPanel("Mapa",
			div(class="outer",
				tags$head(

					includeCSS("assets/styles.css"),
					includeScript("assets/gomap.js")
				),

				tags$style(type = "text/css", "html, body {width:100%;height:100%}"),

				leafletOutput("map", width = "100%", height = "100%"),

				absolutePanel(top = 10, right = 10,
					numericInput("ano", "Ano", 2016),
					selectInput("uf", "UF", vars),

					sliderInput("range", "Quantidade SUS", 1, 1000,
					  value = range(allcnes$qtd_sus), step = 1.0
					),
					selectInput("limit", "Limite", arr_limit)
				),
				tags$div(id="cite",
					'Compilado ', tags$em('CNES BRASIL: DATA SCIENCE fot Science'), ' Deivison Rayner, Henrique Pires, Luis Santos.'
				)
			)
		), ##tbPanel
			   
		tabPanel("Tabela",
			div(class="outer",
				hr(),
				fluidRow(
				  column(1,
					 downloadButton("downloadData", "Baixar CSV filtrado")
				  )
				),
				br(),
				DT::dataTableOutput('x2'),
				tags$div(id="cite",
					'Compilado ', tags$em('CNES BRASIL: DATA SCIENCE fot Science'), ' Deivison Rayner, Henrique Pires, Luis Santos.'
				)
			)
		) ##tbPanel			   
			   
	)
)

server <- function(input, output, session) {

	
	filteredData <- reactive( {



		url <- url_template


		url <- gsub("\\[LIMIT\\]", input$limit, url)
		url <- gsub("\\[UF\\]", input$uf, url)
		url <- gsub("\\[ANO\\]", input$ano, url)

		alljson <- fromJSON(url)

		alljson <- alljson$docs[,c(1:38)]

		alljson$lat <- as.numeric(alljson$lat)
		alljson$long <- as.numeric(alljson$lon)
		alljson$mag <- 1

		drops <- c("")
		alljson <- alljson[ , !(names(alljson) %in% drops)]

		temp <- alljson %>% 
		group_by(CNES) %>% 
		summarize(qtd_cnes =  n(), mg=2, cod_mun = max(CODUFMUN), num_ano = max(as.numeric(X_ANO)) + 2000, sgl_uf=max(X_UF), qtd_exist = sum(as.numeric(QT_EXIST)), qtd_sus = sum(as.numeric(QT_SUS)), lat = max(lat), long = max(long) )

		temp <- as.data.frame(temp)		 

		temp <- temp[temp$qtd_sus >= input$range[1] & temp$qtd_sus <= input$range[2],]

		temp 
	})
	
	output$downloadData <- downloadHandler(
		filename = function() {
			ctm 	<- as.numeric(Sys.time())*1000
			fnme 	<- "cnae_filtered"
			paste(fnme,ctm ,".csv", sep = "")
		},
		content = function(file) {
			write.csv(filteredData(), file, row.names = FALSE, sep=";")
		}
	)

	output$x2 <- DT::renderDataTable({

		hadley_orgs <- filteredData()
		DT::datatable(hadley_orgs, options = list(lengthMenu = c(5, 30, 50), pageLength = 30))
	})

	
	output$map <- renderLeaflet({

		leaflet(allcnes) %>% addTiles() %>%
		  addProviderTiles(providers$CartoDB.Positron) %>%
			  #setView(-41.280857, -11.409874, zoom = 4) %>% 
		  fitBounds(~min(long), ~min(lat), ~max(long), ~max(lat))
	})

  observe({

    leafletProxy("map", data = filteredData()) %>%
      clearShapes() %>%
	   addCircles(lng = ~long, lat = ~lat, weight = 4, radius = ~sqrt(qtd_sus) * 10) %>%
	 # setView(-41.280857, -11.409874, zoom = 4) %>% 
	  	fitBounds(~min(long), ~min(lat), ~max(long), ~max(lat))
  })
	
}

shinyApp(ui, server)