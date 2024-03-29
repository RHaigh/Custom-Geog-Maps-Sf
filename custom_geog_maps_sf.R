library(tidyverse)
library(sf)
library(ggmap)
library(leaflet)
library(data.table)
library(RColorBrewer)

### Stage 01 - Collecting Geography Polygons ###

# You must now obtain a shapefile that contains the polygon shapes of your chosen geography / boundaries.
# For the purposes of this tutorial, we will be looking at the government datazone level.

# For this, we require the geodatabase that contains the shapefiles of datazones. This can be found at:
# https://data.gov.uk/dataset/ab9f1f20-3b7f-4efa-9bd2-239acf63b540/data-zone-boundaries-2011
# Download this to your machine.
path <- "http://sedsh127.sedsh.gov.uk/Atom_data/ScotGov/ZippedShapefiles/SG_DataZoneBdry_2011.zip"
# If this were a project, you would save this file to a project folder. For simplicity, we will just grab it directly and place it in our temporary downloads. 

# Load into temp file directory
temp_shapefile <- tempfile()
download.file(path, temp_shapefile)
temp_dir <- tempdir()
unzip(temp_shapefile, exdir = temp_dir) 

# Using the sf package, we can read in this shapefile with read_sf()
DataZone_sf <- sf::read_sf(file.path(temp_dir,'SG_DataZone_Bdry_2011.shp'))
# Note that you must direct it to the layer within the geodatabase ending in .shp

### Stage 02 - Mapping Polygons ###

# Sf has several advantages over the rgdal approach shown in another repository
# Most importantly, it can be plotted easily at this stage using the plot() function

# We will demonstrate this by filtering our dataframe of datazones for those that are within a certain council area
Datazone_culter <- dplyr::filter(DataZone_sf, Name %like% 'Culter')

# We then call plot and tell it to shade these polygons by a given column
plot(Datazone_culter['ResPop2011'])
# Unlike with rgdal, sf has automatically created bins and map output

# You may choose which column to shade by changing the bracketed string input
plot(Datazone_culter['TotPop2011'])

# And edit the appearance by feeding additional arguments
# pal allows you to specify your chosen color palette and border can specify your outlines
plot(Datazone_culter['TotPop2011'], pal = viridis::viridis, border = 'white')
# Here are selection from the viridis and RcolorBrewer packages you may use to get started
plot(Datazone_culter['TotPop2011'], pal = viridis::magma)
plot(Datazone_culter['TotPop2011'], pal=brewer.pal(7, "OrRd"))
plot(Datazone_culter['TotPop2011'], pal=brewer.pal(7, name = "Dark2"))
plot(Datazone_culter['TotPop2011'], pal=brewer.pal(7, "PuBu"))
# A good guide to utilising the full power of color brewer can be found here: https://www.datanovia.com/en/blog/the-a-z-of-rcolorbrewer-palette/

# We can pass sf objects straight to ggplot and this opens up even more flexibility

### Stage 03 - Collecting Basemaps ###

# If you wish to use leaflet for visualising your maps and polygons then you may skip this stage as leaflet has access to a library of basemaps already (skip to stage 4 - 02)

# If you wish to use ggmap for display then you will need a google maps Geocoding API and Static Maps API key and import your basemaps from there
# Guidance to obtaining this can be found at: https://cloud.google.com/docs/authentication/api-keys#securing_an_api_key
# Once you have a key, add it to your r environ with register_google(key = 'your key')

# You now have two choices for finding your chosen map area

# 1. We collect the bounding box coordinates of our chosen map in format c(top, bottom, left, right)
myMap <- get_map(location =  c(-130, 30, -105, 50), 
               maptype="terrain", crop=FALSE, source = 'stamen')
# A useful tool for drawing the lat and long geo box is available at: https://boundingbox.klokantech.com

# 2. We find by lat and long of chosen centroid
myMap <- get_map(location =  c(lon = -2.3, lat = 57.1), zoom = 13,
                 maptype="terrain", crop=FALSE, source = 'stamen')
# You can easily find the lat and long of a location with geocode('location')

ggmap(myMap)

# We can also choose our background map style with the maptype and source arguments
#There are 4 map “sources” to obtain a map raster, and each of these osm* sources has multiple “map types” (displayed on right).
# - stamen: maptype = c(“terrain”, “toner”, “watercolor”)
# - google: maptype = c(“roadmap”, “terrain”, “satellite”, “hybrid”)

# So more artistic options could be:
myMap <- get_map(location =  c(lon = -2.27, lat = 57.1), zoom = 11,
                 maptype="toner", crop=FALSE, source = 'stamen')

myMap <- get_map(location =  c(lon = -2.27, lat = 57.1), zoom = 11,
                 maptype="watercolor", crop=FALSE, source = 'stamen')
# A comprehensive styling guide to ggmap is available at: https://www.nceas.ucsb.edu/sites/default/files/2020-04/ggmapCheatsheet.pdf

### Stage 04 - Mapping Polygons Over Basemap ###

# There are two options for mapping over basemaps
# Option 1 - ggmap 

# Now we overlay these polygons onto the chosen basemap using the geom_sf() function
ggmap(myMap) +
  geom_sf(data = Datazone_culter, aes(fill=as.factor(TotPop2011)), inherit.aes = FALSE) +
  scale_fill_brewer(palette = "OrRd") +
  coord_sf(crs = st_crs(4326)) + # This is essential to convert CRS to WGS84
  labs(x = 'Longitude', y = 'Latitude', fill = 'Tot Pop 2011') + 
  ggtitle('TotPop2011') 
# geom_sf has a wide range of style arguments to customise your output

# Option 2 - leaflet
# Once again, we must convert CRS to WGS84 but this time using st_transform() from the sf package
Datazone_culter <- st_transform(Datazone_culter, '+proj=longlat +datum=WGS84')

# From here on, it is much the same as using leaflet with our rgdal example
bins <- c(0, 500, 550, 600, 650, 700, 750, 800, Inf) # leaflet does not auto calculate bins so we will need to manually enter them

leaflet(Datazone_culter) %>%
  setView(lng = -2.27, lat = 57.1, zoom = 11) %>%
  addProviderTiles("CartoDB.Positron", layerId = "basetile",options = providerTileOptions(minZoom = 6)) %>% # Here you choose your provider basemap
  addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
              opacity = 1.0, fillOpacity = 0.5,
              fillColor = ~colorQuantile("PuBu", TotPop2011)(TotPop2011), # Choose colour using rcolorbrewer or viridis
              highlightOptions = highlightOptions(color = "white", weight = 2,
                                                  bringToFront = TRUE),
              label=~paste(Datazone_culter$Name),
              labelOptions = labelOptions(textsize = "15px",
                                          direction = "auto")) %>%
  addLegend(pal = colorBin("PuBu", domain = Datazone_culter$TotPop2011, bins = bins),
            values = ~n,
            opacity = 0.7,
            title = 'Total Population 2011',
            position = "bottomright") 
  
  
