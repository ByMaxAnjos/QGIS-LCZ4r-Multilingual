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
