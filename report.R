# All plots and data outputs are produced here 

library(icesTAF)
taf.library(icesFO)
library(sf)
library(ggplot2)
library(tidyr)

mkdir("report")

##########
#Load data
##########


ices_areas <- 
  sf::st_read("bootstrap/data/ICES_areas/areas.csv", 
              options = "GEOM_POSSIBLE_NAMES=WKT", crs = 4326)
ices_areas <- dplyr::select(ices_areas, -WKT)

ecoregion <- 
  sf::st_read("bootstrap/data/ICES_ecoregions/ecoregion.csv", 
              options = "GEOM_POSSIBLE_NAMES=WKT", crs = 4326)
ecoregion <- dplyr::select(ecoregion, -WKT)

# read vms fishing effort
effort <-
  sf::st_read("bootstrap/data/ICES_vms_effort_map/vms_effort.csv",
               options = "GEOM_POSSIBLE_NAMES=wkt", crs = 4326)
effort <- dplyr::select(effort, -WKT)

# read vms swept area ratio
sar <-
  sf::st_read("bootstrap/data/ICES_vms_sar_map/vms_sar.csv",
               options = "GEOM_POSSIBLE_NAMES=wkt", crs = 4326)
sar <- dplyr::select(sar, -WKT)

###############
##Ecoregion map
###############

plot_ecoregion_map(ecoregion, ices_areas)
ggplot2::ggsave("2019_IS_FO_Figure1.png", path = "report", width = 170, height = 200, units = "mm", dpi = 300)





###########
## 3: VMS #
###########

#~~~~~~~~~~~~~~~#
# A. Effort map
#~~~~~~~~~~~~~~~#

gears <- c("Static", "Midwater", "Otter", "Dredge")

effort <-
    effort %>%
      dplyr::filter(fishing_category_FO %in% gears) %>%
      dplyr::mutate(
        fishing_category_FO = 
          dplyr::recode(fishing_category_FO,
            Static = "Static gears",
            Midwater = "Pelagic trawls and seines",
            Otter = "Bottom otter trawls",
            Dredge = "Dredges")
        ) %>%
      dplyr::filter(!is.na(mw_fishinghours))

# write layer
write_layer <- function(dat, fname) {
  sf::write_sf(dat, paste0("report/", fname, ".shp"))
  files <- dir("report", pattern = fname, full = TRUE)
  files <- files[tools::file_ext(files) != "png"]
  zip(paste0("report/", fname, ".zip"), files, extras = "-j")
  file.remove(files)
}
write_layer(effort, "2019_IS_FO_Figure9")


plot_effort_map(effort, ecoregion) + 
  ggplot2::ggtitle("Average MW Fishing hours 2015-2018")

ggplot2::ggsave("2019_IS_FO_Figure9.png", path = "report", width = 170, height = 200, units = "mm", dpi = 300)

#~~~~~~~~~~~~~~~#
# A. Swept area map
#~~~~~~~~~~~~~~~#

# write layer
write_layer(sar, "2019_IS_FO_Figure17")

plot_sar_map(sar, ecoregion, what = "surface") + 
  ggtitle("Average surface swept area ratio 2015-2018")

ggplot2::ggsave("2019_IS_FO_Figure17a.png", path = "report", width = 170, height = 200, units = "mm", dpi = 300)

plot_sar_map(sar, ecoregion, what = "subsurface")+ 
  ggtitle("Average subsurface swept area ratio 2015-2018")

ggplot2::ggsave("2019_IS_FO_Figure17b.png", path = "report", width = 170, height = 200, units = "mm", dpi = 300)
