# Imagen base de R 4.0.0
FROM rocker/r-base:4.0.0

# Instala librerias frecuentes
RUN apt-get update -qq && apt-get install -y \
  libssl-dev \
  libcurl4-gnutls-dev \
  libudunits2-dev

# Instala dependencias para analisis espacial
RUN apt-get install -y libgdal-dev gdal-bin libproj-dev proj-data proj-bin libgeos-dev

# Instala paquetes de R
RUN R -e "install.packages('purrr')"
RUN R -e "install.packages('dplyr')"
RUN R -e "install.packages('tibble')"
RUN R -e "install.packages('stringr')"
RUN R -e "install.packages('readr')"
RUN R -e "install.packages('stringi')"
RUN R -e "install.packages('rgdal')"
RUN R -e "install.packages('sf')"
RUN R -e "install.packages('lwgeom')"


# Copia todo al directorio de inicio del contenedor
COPY distancias.R  distancias.R
COPY separa_shape.R  separa_shape.R
COPY unir_segmentos_playas.R unir_segmentos_playas.R

# Abre puerto 80 para traffic
EXPOSE 80