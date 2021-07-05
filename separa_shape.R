library(lwgeom)
library(sf)
library(readr)
library(dplyr)
library(tibble)
library(purrr)
library(stringr)
library(stringi)

in_dir <- "/pfs/shapes_sp/shapes"
out_dir <- "/pfs/out"

segmentos <- st_read(paste0(in_dir, "/Segmento Censal_CR.shp"), options = "ENCODING=latin1") %>% 
  st_transform(crs = "+init=epsg:4326") # pone el mismo sistema de coordenadas (WGS84)

# Crea carpeta para guardar los feathers
segmentos_out <- paste0(out_dir, "/shapes_segmentos")

if(!dir.exists(segmentos_out)) {
  dir.create(segmentos_out)
}

# guarda segmentos censales por canton como rds
segmentos %>% 
  group_split(CCANT) %>% 
  map(.f = function(canton_shape) {
    canton <- canton_shape %>% 
      pull(NCANTON) %>% 
      tolower() %>% 
      stringi::stri_trans_general("Latin-ASCII") %>% 
      str_replace_all(" ", "_") %>% 
      unique()
    
    write_rds(canton_shape, file = paste0(segmentos_out,"/segmentos_", canton, ".rds"))
  })

playas_out <- paste0(segmentos_out, "/playas")

if(!dir.exists(playas_out)) {
  dir.create(playas_out)
  
  playas <- st_read(paste0(in_dir, "/playas2014crtm05.shp"), options = "ENCODING=latin1") %>% 
    st_transform(crs = "+init=epsg:4326") %>%  # pone el mismo sistema de coordenadas (WGS84)
    select(-X_COORD, -Y_COORD)
  
  # guarda playas como rds
  write_rds(playas, file = paste0(playas_out, "/playas.rds"))
  
}
