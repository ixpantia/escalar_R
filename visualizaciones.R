library(sf)
library(tidyverse)
library(leaflet)

playas <- st_read("datos/playas2014crtm05.shp",
                  options = "ENCODING=latin1") %>%
  # pon el mismo sistema de coordenadas (WGS84)
  st_transform(crs = "+init=epsg:4326") %>%
  select(-X_COORD, -Y_COORD)

segmentos <- st_read("datos/Segmento Censal_CR.shp",
                     options = "ENCODING=latin1") %>%
  # pon el mismo sistema de coordenadas (WGS84)
  st_transform(crs = "+init=epsg:4326")

# Mapa general -----------------------------------------------------------------

leaflet() %>%
  addTiles() %>%
  setView(lat = 10, lng = -84, zoom = 7) %>%
  addCircleMarkers(data = playas,
                   popup = paste0("<strong> Playa: </strong>",
                                  playas$NOMBRE_DE_),
                   opacity = 1,
                   radius = 0.5,
                   color = "#B306B6") %>%
  addPolygons(data = segmentos,
              fillColor = "chartreuse",
              popup = paste0("<strong> Provincia: </strong>",
                             segmentos$PROVINCIA,
                             "<br><strong> Cantón: </strong>",
                             segmentos$NCANTON,
                             "<br><strong> Distrito: </strong>",
                             segmentos$NDISTRITO,
                             "<br><strong> ID Segmento: </strong>",
                             segmentos$IDSEG),
              color = "black",
              fillOpacity = 0.35,
              weight = 1,
              highlight = highlightOptions(weight = 2,
                                           color = "blue"))

# Procedimiento 1 --------------------------------------------------------------

acosta <- readRDS("datos/shapes_segmentos/segmentos_acosta.rds")

alfaro_ruiz <- readRDS("datos/shapes_segmentos/segmentos_alfaro_ruiz.rds")

leaflet() %>%
  addTiles() %>%
  setView(lat = 10, lng = -84, zoom = 7) %>%
  addPolygons(data = acosta,
              fillColor = "chartreuse",
              popup = paste0("<strong> Provincia: </strong>",
                             acosta$PROVINCIA,
                             "<br><strong> Cantón: </strong>",
                             acosta$NCANTON,
                             "<br><strong> Distrito: </strong>",
                             acosta$NDISTRITO,
                             "<br><strong> ID Segmento: </strong>",
                             acosta$IDSEG),
              color = "black",
              fillOpacity = 0.35,
              weight = 1,
              highlight = highlightOptions(weight = 2,
                                           color = "blue")) %>%
  addPolygons(data = alfaro_ruiz,
              fillColor = "chartreuse",
              popup = paste0("<strong> Provincia: </strong>",
                             alfaro_ruiz$PROVINCIA,
                             "<br><strong> Cantón: </strong>",
                             alfaro_ruiz$NCANTON,
                             "<br><strong> Distrito: </strong>",
                             alfaro_ruiz$NDISTRITO,
                             "<br><strong> ID Segmento: </strong>",
                             alfaro_ruiz$IDSEG),
              color = "black",
              fillOpacity = 0.35,
              weight = 1,
              highlight = highlightOptions(weight = 2,
                                           color = "blue"))

# Procedimiento 2---------------------------------------------------------------

leaflet() %>%
  addTiles() %>%
  setView(lat = 10, lng = -84, zoom = 7) %>%
  addPolygons(data = acosta,
              fillColor = "chartreuse",
              popup = paste0("<strong> Provincia: </strong>",
                             acosta$PROVINCIA,
                             "<br><strong> Cantón: </strong>",
                             acosta$NCANTON,
                             "<br><strong> Distrito: </strong>",
                             acosta$NDISTRITO,
                             "<br><strong> ID Segmento: </strong>",
                             acosta$IDSEG),
              color = "black",
              fillOpacity = 0.35,
              weight = 1,
              highlight = highlightOptions(weight = 2,
                                           color = "blue")) %>%
  addCircleMarkers(data = playas,
                   popup = paste0("<strong> Playa: </strong>",
                                  playas$NOMBRE_DE_),
                   opacity = 1,
                   radius = 0.5,
                   color = "#B306B6")

# Procedimiento 3 --------------------------------------------------------------

segmentos <- segmentos %>%
  mutate(NCANTON = as.factor(NCANTON))

factpal <- colorFactor(rainbow(82), unique(segmentos$NCANTON), alpha = FALSE)

leaflet() %>%
  addTiles() %>%
  setView(lat = 10, lng = -84, zoom = 7) %>%
  addPolygons(data = segmentos,
              fillColor = ~factpal(NCANTON),
              popup = paste0("<strong> Provincia: </strong>",
                             segmentos$PROVINCIA,
                             "<br><strong> Cantón: </strong>",
                             segmentos$NCANTON,
                             "<br><strong> Distrito: </strong>",
                             segmentos$NDISTRITO,
                             "<br><strong> ID Segmento: </strong>",
                             segmentos$IDSEG),
              color = "black",
              fillOpacity = 1,
              weight = 1,
              highlight = highlightOptions(weight = 2,
                                           color = "blue"))

## Resultado -------------------------------------------------------------------

resultado <- readRDS("datos/segmentos_playas.rds")

# Hay un poligono vacío
poligonos_vacios <- which(st_is_empty(resultado$geometry.x) == TRUE)

# Removemos el poligono
resultado <- resultado[-poligonos_vacios,]

# Convertimos a multipolygon
resultado <- st_cast(resultado, to = "MULTIPOLYGON")

# Definimos paleta de color
paleta <- colorNumeric(
  palette = colorRampPalette(c('#70FB01', '#760506'))(length(resultado$distancia_m)),
  domain = resultado$distancia_m)

# Graficamos resultado
leaflet() %>%
  addTiles() %>%
  setView(lat = 10, lng = -84, zoom = 7) %>%
  addPolygons(data = resultado,
              color = ~paleta(resultado$distancia_m),
              popup = paste0("<strong> Provincia: </strong>",
                             resultado$PROVINCIA,
                             "<br><strong> Cantón: </strong>",
                             resultado$NCANTON,
                             "<br><strong> Distrito: </strong>",
                             resultado$NDISTRITO,
                             "<br><strong> ID Segmento: </strong>",
                             resultado$IDSEG),
              fillOpacity = 1,
              weight = 1,
              highlight = highlightOptions(weight = 2,
                                           color = "blue")) %>%
  addLegend("bottomright", pal = paleta, values = resultado$distancia_m,
            title = "Cercanía a playa",
            labFormat = labelFormat(suffix = "m"),
            opacity = 1)
