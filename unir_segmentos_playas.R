library(readr)
library(purrr)
library(dplyr)
library(sf)

in_dir <- "/pfs/distancias"
out_dir <- "/pfs/out"

segmentos <- list.files(path = in_dir,
                       pattern = ".rds", 
                       full.names = TRUE, 
                       recursive = FALSE)

segmentos_playas <- map_dfr(.x = segmentos,
    .f = function(segmento) {
      readRDS(segmento)
    })

write_rds(segmentos_playas, file = paste0(out_dir, "/segmentos_playas.rds"))
