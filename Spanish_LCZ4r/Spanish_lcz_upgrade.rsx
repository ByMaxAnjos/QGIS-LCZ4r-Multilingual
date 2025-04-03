##LCZ4r Funciones de Configuración=group
##Actualizar LCZ4r=display_name
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterBoolean|Upgrade|Actualizando el paquete R LCZ4r|False
##QgsProcessingParameterFile|in_folder|Seleccionar carpeta para almacenar el script|1
##QgsProcessingParameterEnum|Select_Language|Seleccione su idioma|Inglés;Portugués;Chino;Español;Alemán;Francés|-1|0|False

if(Upgrade){
pak::pak_install("ByMaxAnjos/LCZ4r")
}

Languages <- c("English", "Portuguese", "Chinese", "Spanish", "Deutsch", "French")

if (!is.null(Select_Language) && Select_Language >= 0 && Select_Language < length(Languages)) {
  result_language <- Languages[Select_Language + 1] # Alinhado com indexação baseada em 1 do R
} else {
  stop("Invalid language selection. Please choose the correct language")
}

folder_name <- switch(result_language,
  "English"   = "English_LCZ4r"
)

script_files <- switch(result_language,
  "English" = c("English_lcz_get_map.rsx", "English_lcz_get_map_euro.rsx", "English_lcz_get_map_usa.rsx", "English_lcz_get_map_generator.rsx", 
                "English_lcz_cal_area.rsx", "English_lcz_plot_map.rsx", "English_lcz_get_parameters.rsx", "English_lcz_plot_parameters.rsx", "English_lcz_ts.rsx",  
                "English_lcz_uhi_intensity.rsx", "English_lcz_anomaly.rsx", "English_lcz_interp_map.rsx", "English_lcz_anomaly_map.rsx", "English_lcz_plot_interp.rsx", 
                "English_lcz_interp_eval.rsx", "English_lcz_upgrade.rsx", "English_lcz_install.rsx"),
"Portuguese" = c("Portuguese_lcz_get_map.rsx", "Portuguese_lcz_get_map_euro.rsx", "Portuguese_lcz_get_map_usa.rsx", "Portuguese_lcz_get_map_generator.rsx", 
                "Portuguese_lcz_cal_area.rsx", "Portuguese_lcz_plot_map.rsx", "Portuguese_lcz_get_parameters.rsx", "Portuguese_lcz_plot_parameters.rsx", "Portuguese_lcz_ts.rsx",  
                "Portuguese_lcz_uhi_intensity.rsx", "Portuguese_lcz_anomaly.rsx", "Portuguese_lcz_interp_map.rsx", "Portuguese_lcz_anomaly_map.rsx", "Portuguese_lcz_plot_interp.rsx", 
                "Portuguese_lcz_interp_eval.rsx", "Portuguese_lcz_upgrade.rsx", "Portuguese_lcz_install.rsx"),
  "Chinese" = c("Chinese_lcz_get_map.rsx", "Chinese_lcz_get_map_euro.rsx", "Chinese_lcz_get_map_usa.rsx", "Chinese_lcz_get_map_generator.rsx", 
                "Chinese_lcz_cal_area.rsx", "Chinese_lcz_plot_map.rsx", "Chinese_lcz_get_parameters.rsx", "Chinese_lcz_plot_parameters.rsx", "Chinese_lcz_ts.rsx",  
                "Chinese_lcz_uhi_intensity.rsx", "Chinese_lcz_anomaly.rsx", "Chinese_lcz_interp_map.rsx", "Chinese_lcz_anomaly_map.rsx", "Chinese_lcz_plot_interp.rsx", 
                "Chinese_lcz_interp_eval.rsx", "Chinese_lcz_upgrade.rsx", "Chinese_lcz_install.rsx"),
"Spanish" = c("Spanish_lcz_get_map.rsx", "Spanish_lcz_get_map_euro.rsx", "Spanish_lcz_get_map_usa.rsx", "Spanish_lcz_get_map_generator.rsx", 
                "Spanish_lcz_cal_area.rsx", "Spanish_lcz_plot_map.rsx", "Spanish_lcz_get_parameters.rsx", "Spanish_lcz_plot_parameters.rsx", "Spanish_lcz_ts.rsx",  
                "Spanish_lcz_uhi_intensity.rsx", "Spanish_lcz_anomaly.rsx", "Spanish_lcz_interp_map.rsx", "Spanish_lcz_anomaly_map.rsx", "Spanish_lcz_plot_interp.rsx", 
                "Spanish_lcz_interp_eval.rsx", "Spanish_lcz_upgrade.rsx", "Spanish_lcz_install.rsx"),
"Deutsch" = c("Deutsch_lcz_get_map.rsx", "Deutsch_lcz_get_map_euro.rsx", "Deutsch_lcz_get_map_usa.rsx", "Deutsch_lcz_get_map_generator.rsx", 
                "Deutsch_lcz_cal_area.rsx", "Deutsch_lcz_plot_map.rsx", "Deutsch_lcz_get_parameters.rsx", "Deutsch_lcz_plot_parameters.rsx", "Deutsch_lcz_ts.rsx",  
                "Deutsch_lcz_uhi_intensity.rsx", "Deutsch_lcz_anomaly.rsx", "Deutsch_lcz_interp_map.rsx", "Deutsch_lcz_anomaly_map.rsx", "Deutsch_lcz_plot_interp.rsx", 
                "Deutsch_lcz_interp_eval.rsx", "Deutsch_lcz_upgrade.rsx", "Deutsch_lcz_install.rsx"),
"French" = c("French_lcz_get_map.rsx", "French_lcz_get_map_euro.rsx", "French_lcz_get_map_usa.rsx", "French_lcz_get_map_generator.rsx", 
                "French_lcz_cal_area.rsx", "French_lcz_plot_map.rsx", "French_lcz_get_parameters.rsx", "French_lcz_plot_parameters.rsx", "French_lcz_ts.rsx",  
                "French_lcz_uhi_intensity.rsx", "French_lcz_anomaly.rsx", "French_lcz_interp_map.rsx", "French_lcz_anomaly_map.rsx", "French_lcz_plot_interp.rsx", 
                "French_lcz_interp_eval.rsx", "French_lcz_upgrade.rsx", "French_lcz_install.rsx")
                
)

base_url <- "https://raw.githubusercontent.com/ByMaxAnjos/QGIS-LCZ4r-Multilingual/master/"

if (!dir.exists(in_folder)) dir.create(in_folder, recursive = TRUE)

for (script in script_files) {
  script_url <- paste0(base_url, folder_name, "/", script)
  dest_file <- file.path(in_folder, script)

  # Ensure the file is deleted before downloading
  if (file.exists(dest_file)) file.remove(dest_file)

  # Download the script
  tryCatch({
    download.file(script_url, destfile = dest_file, mode = "wb", quiet = TRUE)
    source(dest_file)
  }, error = function(e) {
    warning(paste("Failed to download or source:", script))
  })
}

#' Upgrade: Si es TRUE, se reinstalarán las Funciones Generales y Locales del paquete LCZ4r. Esto garantiza que esté utilizando las versiones más recientes de estas funciones, que pueden incluir actualizaciones y mejoras importantes.</p><p>
#' in_folder: Especifique el directorio donde se descargarán los scripts desde el repositorio oficial.</p><p>
#'          : Tenga en cuenta que este directorio específico debe ser el mismo que la <b>carpeta de scripts R</b> (Configuración > Opciones... > Procesamiento > Proveedores > R).
#' ALG_DESC: Esta función le permite actualizar el paquete LCZ4r a la versión más reciente y el Plugin de Idioma. Las actualizaciones regulares le permiten beneficiarse de las últimas funciones, correcciones de errores y mejoras de rendimiento.</p<p>
#'         : Para la instalación inicial, siga esta guía: <a href='https://bymaxanjos.github.io/LCZ4r/articles/instalation_lcz4r_qgis.html'>Instalación de LCZ4r en QGIS</a></p<p>
#'         : Para seleccionar un idioma, consulte: <a href='https://bymaxanjos.github.io/LCZ4r/articles/examples.html#multilingual-plugins'>Plugin Multilingüe</a></p<p>
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a>
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Proyecto LCZ4r</a>
#' ALG_VERSION: 0.1.1


