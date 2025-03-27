##LCZ4r Allgemeine Funktionen=group
##LCZ-Parameter generieren=display_name
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|LCZ-Karte eingeben|None
##QgsProcessingParameterBoolean|iStack|Alle Parameter als einen einzigen speichern|True
##QgsProcessingParameterEnum|Select_parameter|Parameter auswählen|SVFmittel;SVFmax;SVFmin;z0;ARmittel;ARmax;ARmin;BSFmittel;BSFmax;BSFmin;ISFmittel;ISFmax;ISFmin;PSFmittel;PSFmax;PSFmin;TSFmittel;TSFmax;TSFmin;HREmittel;HREmax;HREmin;TRCmittel;TRCmax;TRCmin;SADmittel;SADmax;SADmin;SALmittel;SALmax;SALmin;AHmittel;AHmax;AHmin|-1|None|True
##QgsProcessingParameterRasterDestination|Output_raster|LCZ-Parameter speichern

library(LCZ4r)
library(terra)


# Define the mapping of indices to parameters
parameters <- c("SVFmean", "SVFmax", "SVFmin", 
                "ARmean", "ARmax", "ARmin", 
                "BSFmean", "BSFmax", "BSFmin", 
                "ISFmean", "ISFmax", "ISFmin", 
                "PSFmean", "PSFmax", "PSFmin", 
                "TSFmean", "TSFmax", "TSFmin", 
                "HREmean", "HREmax", "HREmin", 
                "TRCmean", "TRCmax", "TRCmin", 
                "SADmean", "SADmax", "SADmin", 
                "SALmean", "SALmax", "SALmin", 
                "AHmean", "AHmax", "AHmin", 
                "z0")

# Use the selected parameter index to retrieve the corresponding value
# Adjust for zero-based indexing
if (!is.null(Select_parameter) && Select_parameter >= 0 && Select_parameter < length(parameters)) {
  result_par <- parameters[Select_parameter + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_par <- NULL  # Handle invalid or missing selection
}

# Retrieve the LCZ parameters based on user input
if (iStack==TRUE) {
  Output_raster <- LCZ4r::lcz_get_parameters(LCZ_map, iselect = " ", istack = iStack)
} else {
 Output_raster <- LCZ4r::lcz_get_parameters(LCZ_map, iselect = result_par,istack = FALSE)
} 

#' LCZ_map: Ein SpatRaster-Objekt, das die LCZ-Karte enthält, die aus den Funktionen zum Herunterladen der LCZ-Karte abgeleitet wurde.
#' iStack: Speichern Sie mehrere Rasterparameter (oder Bänder) als einen einzigen.
#' Select_parameter: Optional können Sie einen oder mehrere Parameternamen angeben, um spezifische Mittel-, Maximal- und Minimalparameterwerte abzurufen:</p><p>
#'             : <b>SVF</b>: Sky View Factor [0-1]. </p><p>
#'             : <b>z0</b>: Rauheitslängenklasse [Meter]. </p><p>
#'             : <b>AR</b>: Seitenverhältnis [0-3]. </p><p> 
#'             : <b>BSF</b>: Gebäudeflächenanteil [%]. </p><p> 
#'             : <b>ISF</b>: Versiegelte Flächenanteil [%]. </p><p>  
#'             : <b>PSF</b>: Durchlässige Flächenanteil [%]. </p><p>  
#'             : <b>TSF</b>: Baumflächenanteil [%]. </p><p>  
#'             : <b>HRE</b>: Höhenrauhigkeitselemente [Meter]. </p><p>  
#'             : <b>TRC</b>: Gelände-Rauheitsklasse [Meter]. </p><p>
#'             : <b>SAD</b>: Oberflächenadmittanz [J m-2 s1/2 K-1]. </p><p> 
#'             : <b>SAL</b>: Oberflächenalbedo [0 - 0.5]. </p><p> 
#'             : <b>AH</b>: Anthropogene Wärmeabgabe [W m-2]. </p><p> 
#' Output_raster: 1. Wenn <b>Alle Parameter als einen speichern</b> TRUE ist, gibt es alle Parameter als Rasterstapel zurück (100 m Auflösung). </p><p>
#'              : 2. Wenn <b>Alle Parameter als einen speichern</b> FALSE ist, gibt es den ausgewählten Parameter als einzelnes Raster zurück (100 m Auflösung).
#' ALG_DESC: Diese Funktion extrahiert 12 physikalische städtische Kronenparameter (UCPs) basierend auf dem von Stewart und Oke (2012) entwickelten Klassifizierungsschema. 
#'         :Für weitere Informationen besuchen Sie: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_genera_LCZ4r.html#retrieve-and-visualize-lcz-parameters'>Allgemeine LCZ-Funktionen (LCZ-Parameter abrufen und visualisieren)</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r-Projekt</a>  
#' ALG_VERSION: 0.1.0


#' LCZ_map: A SpatRaster object containing the LCZ map derived from Download LCZ map* functions.
#' iStack: Save multiple raster parameters (or bands) as a single one.
#' Select_parameter: Optionally,  specify one or more parameter names to retrieve specific mean, maximum and minumum parameter values:</p><p>
#'             : <b>SVF</b>: Sky View Factor [0-1]. </p><p>
#'             : <b>z0</b>: Roughness Lenght class [meters]. </p><p>
#'             : <b>AR</b>: Aspect Ratio [0-3]. </p><p> 
#'             : <b>BSF</b>: Building Surface Fraction [%]. </p><p> 
#'             : <b>ISF</b>: Impervious Surface Fraction [%]. </p><p>  
#'             : <b>PSF</b>: Pervious Surface Fraction [%]. </p><p>  
#'             : <b>TSF</b>: Tree Surface Fraction [%]. </p><p>  
#'             : <b>HRE</b>: Height Roughness Elements [meters]. </p><p>  
#'             : <b>TRC</b>: Terrain Roughness class [meters]. </p><p>
#'             : <b>SAD</b>: Surface Admittance [J m-2 s1/2 K-1]. </p><p> 
#'             : <b>SAL</b>: Surface Albedo [0 - 0.5]. </p><p> 
#'             : <b>AH</b>: Anthropogenic Heat Outupt [W m-2]. </p><p> 
#' Output_raster: 1. If <b>Save all parameters as single one</b> is TRUE, returns all parameters as a raster stack (100 m resolution). </p><p>
#'              : 2. If <b>Save all parameters as single one</b> is FALSE, returns the selected parameter as a single raster (100 m resolution).
#' ALG_DESC: This function extracts 12 LCZ physical urban canopy parameters (UCP's) based on the classification scheme developed by Stewart and Oke (2012). 
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_genera_LCZ4r.html#retrieve-and-visualize-lcz-parameters'>LCZ General Functions (Retrieve and visualize LCZ parameters)</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0
