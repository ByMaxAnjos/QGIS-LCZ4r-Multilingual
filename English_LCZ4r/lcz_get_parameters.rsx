##LCZ4r General Functions=group
##Retrieve LCZ Parameters=display_name
##dont_load_any_packages
##pass_filenames

# ------------------------------
# **1. Input Data**
# ------------------------------
##QgsProcessingParameterRasterLayer|LCZ_map|Enter LCZ map|None
##QgsProcessingParameterBoolean|iStack|Save all parameters as single one|True

# ------------------------------
# **2. Select Parameters**
# ------------------------------
##QgsProcessingParameterEnum|Select_parameter|Select paramater|SVFmean;SVFmax;SVFmin;z0;ARmean;ARmax;ARmin;BSFmean;BSFmax;BSFmin;ISFmean;ISFmax;ISFmin;PSFmean;PSFmax;PSFmin;TSFmean;TSFmax;TSFmin;HREmean;HREmax;HREmin;TRCmean;TRCmax;TRCmin;SADmean;SADmax;SADmin;SALmean;SALmax;SALmin;AHmean;AHmax;AHmin|-1|None|True

# ------------------------------
# **4. Output**
# ------------------------------
##QgsProcessingParameterRasterDestination|Output_raster|Save LCZ parameter

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

#' LCZ_map: A SpatRaster object containing the LCZ map derived from Download LCZ map* functions
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
#' Output_raster: If TRUE, returns all parameters as a raster stack (100 m resolution)
#' ALG_DESC: This function extracts 12 LCZ physical parameters based on the classification scheme developed by Stewart and Oke (2012). 
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_genera_LCZ4r.html#retrieve-and-visualize-lcz-parameters'>LCZ General Functions (Retrieve and visualize LCZ parameters)</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0
