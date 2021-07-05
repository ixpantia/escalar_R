library(readr)
library(dplyr)
library(tibble)
library(purrr)
library(stringr)
library(lwgeom)
library(sf)

in_dir <- "/pfs/separa_shape/shapes_segmentos"
playas_dir <- "/pfs/playas/playas.rds"
out_dir <- "/pfs/out"

playas <- readRDS(playas_dir) %>%
  mutate(id = row_number())

segmento <- list.files(path = in_dir,
                         pattern = ".rds",
                         full.names = TRUE,
                         recursive = FALSE) %>%
  readRDS()


segmento_playas <- segmento %>%
  mutate(id = st_nearest_feature(segmento, playas)) %>%
  left_join(as_tibble(playas), by = "id") %>%
  split(sort(as.numeric(rownames(.)))) %>%
  map_dfr(.f = function(.segmento) {
    .segmento %>%
      mutate(distancia_m = st_distance(.segmento$geometry.x, .segmento$geometry.y) %>%
               as.numeric())
  })

segmento_name <- list.files(path = in_dir,
                            pattern = ".rds",
                            full.names = TRUE,
                            recursive = FALSE) %>%
  basename %>%
  str_remove(".rds")

write_rds(segmento_playas, file = paste0(out_dir, "/", segmento_name, "_playas.rds"))

