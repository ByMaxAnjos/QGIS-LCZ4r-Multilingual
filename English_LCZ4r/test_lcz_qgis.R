library(LCZ4r)
library(terra)
library(sf)
if (!require(zip)) install.packages("zip")
library(zip)

# List all files inside the folder, excluding _MACOSX and .DS_Store
files_to_zip <- list.files("English_LCZ4r", recursive = TRUE, full.names = TRUE)
# Filter out unwanted macOS metadata files
files_to_zip <- files_to_zip[!grepl("_MACOSX|.DS_Store", files_to_zip)]
# Create ZIP file without _MACOSX and .DS_Store
zip::zip("scripts/English_LCZ4r.zip", files = files_to_zip, recurse = TRUE)


# Define language folders
path <- "scripts/"
file.remove(path)
languages <- c("English_LCZ4r", "Portuguese_LCZ4r", "Chinese_LCZ4r", "Spanish_LCZ4r", "Deutsch_LCZ4r", "French_LCZ4r")

# Loop through each language and create a ZIP file
for (lang in languages) {
  # List all files inside the folder, excluding _MACOSX and .DS_Store
  files_to_zip <- list.files(lang, recursive = TRUE, full.names = TRUE)
  
  # Filter out unwanted macOS metadata files
  files_to_zip <- files_to_zip[!grepl("_MACOSX|.DS_Store", files_to_zip)]
  
  # Create ZIP file without _MACOSX and .DS_Store
  zip::zip(paste0("scripts/", lang, ".zip"), files = files_to_zip, recurse = TRUE)
  
  # Print status
  message("Zipped: ", lang)
}

message("All language ZIP files created successfully!")

# Ensure the file is deleted before downloading
if (file.exists(dest_file)) file.remove(dest_file)



my_map <-lcz_get_map_euro(city = "Madrid")
madrid <- lcz_cal_area(my_map)
lcz_plot_map(my_map)
lcz_anomaly()
lcz_ts()
lcz_interp_map()
lcz_plot_interp()
lcz_get_parameters()

openair::timeAverage()

# CALCULATE AREAS ---------------------------------------------------------

LCZ_map <- "/Users/co2map/Downloads/berlin_test.tif"
LCZ_map <- terra::rast(LCZ_map)

ggplot() +
  geom_spatraster_contour_text(data = r) +
  labs(title = "Labelling contours")

# Load necessary libraries
library(DT)
library(htmlwidgets)


# Define the HTML file path
html_file <- file.path(tempdir(), "LCZ4rDataframe.html")

# Assuming df_test is your data frame
# df_test <- data.frame(...)  # Replace with your actual data frame

# Create the datatable
html_table <- DT::datatable(
  df_test,
  options = list(
    autoWidth = TRUE,
    searching = TRUE,
    dom = 'Bfrtip',
    buttons = list(
      'copy', 'csv', 'excel', 
      list(
        extend = 'pdf',
        text = 'PDF',
        orientation = 'landscape',
        pageSize = 'A4'
      ),
      'print'
    ),
    colReorder = TRUE,
    fixedHeader = TRUE
  ),
  class = "cell-border stripe",
  extensions = c('Buttons', 'FixedHeader', 'ColReorder')
)

# Save the widget to an HTML file
htmlwidgets::saveWidget(
  html_table,
  file = html_file,
  selfcontained = TRUE,  # Embed all dependencies
  title = "LCZ4r Visualization"
)

# Add caption to the HTML file
caption <- '<p style="text-align:right; font-size:16px;">
              LCZ4r Project: <a href="https://bymaxanjos.github.io/LCZ4r/index.html" target="_blank">by Max Anjos</a>
            </p>'

# Append the caption to the HTML file
write(caption, file = html_file, append = TRUE)

# Open the HTML file in the default web browser
utils::browseURL(html_file)


# TS ----------------------------------------------------------------------

library(LCZ4r)
library(ggplot2)
library(terra)
library(lubridate)
library(ggiraph)
library(htmlwidgets)

lcz_interp_eval()

data("lcz_data")

sat_data <- getSpatialData::getSentinel_data(
  time_range = c("2020-01-01", "2020-12-31"),
  products = "NDVI"
)

tmap::tmap_mode("view")
int_map <- tm_shape(final_map$prediction) +
  tm_raster(alpha=0.6, palette="viridis") +
  tm_shape(final_map$uncertainty) +
  tm_raster(alpha=0.4, palette="-magma")

terra::predict(krige_mod, ras_grid, what="variance")

lcz_url <- "https://globalland.cgls.dev/webResources/catalogTree/netcdf/snow_cover_extent/sce_500m_v1_daily/2017/20170301/c_gls_SCE500_201703010000_CEURO_MODIS_V1.0.1.nc"
lcz_download <- terra::rast(base::paste0("/vsicurl/", lcz_url))
terra::plot(lcz_download)

tiles <- get_tilexy(bbx,z)

df_test <- lcz_uhi_intensity(LCZ_map, data_frame = lcz_data, 
                             var="airT", station_id = "station",
       year=2019, month=9, day=1, iplot = F
       )
test <- df_test %>%
    dplyr::mutate(
      uhi_category = base::cut(uhi,
                         breaks = c(-Inf, 0, 2, 4, Inf),
                         labels = c("Cool", "Mild", "Moderate", "Severe"))
    )

p <- ggplot2::ggplot(test, aes(x = date)) +
  geom_line(aes(y = uhi, color = uhi_category)) +
  scale_color_viridis_d("UHI Intensity Category") +
  labs(title = "Urban Heat Island Intensity Analysis",
       subtitle = "Temporal Variation with Categorical Classification")

if (!is.null(custom_theme)) p <- p + custom_theme
if (interactive_plot) p <- plotly::ggplotly(p)


      

