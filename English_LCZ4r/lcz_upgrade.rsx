##LCZ4r Setup Functions=group
##Upgrade LCZ4r=display_name
##dont_load_any_packages
##pass_filenames
# Set the environment variable for standalone mode
Sys.setenv(R_REMOTES_STANDALONE="true")
options(remotes.upgrade = "never")
##ByMaxAnjos/LCZ4r=github_install
##QgsProcessingParameterFile|in_folder|Select the folder where the script be stored|1
##QgsProcessingParameterEnum|Select_Language|Select your Language|English|-1|0|False

# Definição de idiomas disponíveis
Languages <- c("English")

# Verifica e ajusta a seleção do idioma
if (!is.null(Select_Language) && Select_Language >= 0 && Select_Language < length(Languages)) {
  result_language <- Languages[Select_Language + 1] # Alinhado com indexação baseada em 1 do R
} else {
  stop("Invalid language selection. Please choose from English")
}

# Mapeia o idioma selecionado para a pasta correspondente
folder_name <- switch(result_language,
  "English"   = "English_LCZ4r"
)

# Define os scripts a serem baixados conforme o idioma escolhido
script_files <- switch(result_language,
  "English" = c("lcz_get_map.rsx", "lcz_get_map_euro.rsx", "lcz_get_map_usa.rsx", "lcz_get_map_generator.rsx", 
                "lcz_cal_area.rsx", "lcz_plot_map.rsx", "lcz_get_parameters.rsx", "lcz_plot_parameters.rsx", "lcz_ts.rsx",  
                "lcz_uhi_intensity.rsx", "lcz_anomaly.rsx", "lcz_interp_map.rsx", "lcz_anomaly_map.rsx", "lcz_plot_interp.rsx", 
                "lcz_interp_eval.rsx", "lcz_upgrade.rsx", "lcz_install.rsx")
)

# URL base do repositório
base_url <- "https://raw.githubusercontent.com/ByMaxAnjos/QGIS-LCZ4r-Multilingual/master/"

# Define diretório temporário para os scripts
if (!dir.exists(in_folder)) dir.create(in_folder, recursive = TRUE)

# Loop para baixar e carregar os scripts
for (script in script_files) {
  script_url <- paste0(base_url, folder_name, "/", script)
  dest_file <- file.path(in_folder, script)

  # Download do script
  tryCatch({
    download.file(script_url, destfile = dest_file, mode = "wb", quiet = TRUE)
    source(dest_file)
  }, error = function(e) {
    warning(paste("Failed to download or source:", script))
  })
}

#' in_folder: Specify the directory where the scripts will be downloaded from the official repository.</p><p> 
#'          : Note that this specifc directory must be the same directory in <b>R scripts folder</b> (Settings > Options… > Processing > Providers > R).
#' ALG_DESC: This function allows you to upgrade the LCZ4r package to the latest version and the Language Plugin. Regular upgrades ensure you benefit from the latest features, bug fixes, and performance improvements.</p><p>
#'         :If this is your first installation, follow the guide here: <a href='https://bymaxanjos.github.io/LCZ4r/articles/instalation_lcz4r_qgis.html'>Installing LCZ4r in QGIS</a></p><p> 
#'         :To select a language, refer to: <a href='https://bymaxanjos.github.io/LCZ4r/articles/examples.html#multilingual-plugins'>Multilingual Plugin</a></p><p> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.1



