##PT-LCZ4r Funções Gerais=group
##Extrair LCZ parâmetros=display_name
##dont_load_any_packages
##pass_filenames
##LCZ_map=raster
##iStack=boolean TRUE
##Select_parameter=optional enum literal multiple SVF1;SVF2;SVF3;AR1;AR2;AR3;BSF1;BSF2;BSF3;ISF1;ISF2;ISF3;PSF1;PSF2;PSF3;TSF1;TSF2;TSF3;HRE1;HRE2;HRE3;TRC1;TRC2;TRC3;SAD1;SAD2;SAD3;SAL1;SAL2;SAL3;AH1;AH2;AH3;z0
##Output_raster=output raster

# Print R session info
library(LCZ4r)
library(terra)

# Retrieve the LCZ parameters based on user input
if (iStack) {
  Output_raster <- lcz_get_parameters(LCZ_map, iselect = " ", istack = iStack)
} else {
 Output_raster <- lcz_get_parameters(LCZ_map, iselect = Select_param, istack = iStack)
}

#' LCZ_map: A SpatRaster object containing the LCZ map derived from Obtain LCZ map* functions
#' iStack: If TRUE, returns all parameters as a raster stack. If FALSE, returns a list of individual parameter rasters using the Select parameters
#' Select_parameter: Optionally,  specify one or more parameter names to retrieve specific parameters:</p><p>
#'             : SVF1 (Minimum Sky View Factor), SVF2 (Maximum Sky View Factor), SVF3 (Mean Sky View Factor)</p><p> AR1 (Minimum Aspect Ratio), AR2 (Maximum Aspect Ratio), AR3 (Mean Aspect Ratio)</p><p>
#'             : BSF1 (Minimum Building Surface Fraction), BSF2 (Maximum Building Surface Fraction), BSF3 (Mean Building Surface Fraction)</p><p> ISF1 (Minimum Impervious Surface Fraction), ISF2 (Maximum Impervious Surface Fraction), ISF3 (Mean Impervious Surface Fraction)</p><p>
#'             : PSF1 (Minimum Vegetation Surface Fraction), PSF2 (Maximum Vegetation Surface Fraction), PSF3 (Mean Vegetation Surface Fraction)</p><p> TSF1 (Minimum Tree Surface Fraction), TSF2 (Maximum Tree Surface Fraction), TSF3 (Mean Tree Surface Fraction)</p><p>
#'             : HRE1 (Minimum Height Roughness Elements), HRE2 (Maximum Height Roughness Elements), HRE3 (Mean Height Roughness Elements)</p><p> TRC1 (Minimum Terrain Roughness class), TRC2 (Maximum Terrain Roughness class), TRC3 (Mean Terrain Roughness class)</p><p>
#'             : SAD1 (Minimum Surface Admittance), SAD2 (Maximum Surface Admittance), SAD3 (Mean Surface Admittance)</p><p> SAL1 (Minimum Surface Albedo), SAL2 (Maximum Surface Albedo), SAL3 (Mean Surface Albedo)</p><p> 
#'             : AH1 (Minimum Anthropogenic Heat Outupt), AH2 (Maximum Anthropogenic Heat Outupt), AH3 (Mean Anthropogenic Heat Outupt)</p><p> z0 (Roughness Lenght class)</p><p>
#' Output_raster: If TRUE, returns all parameters as a raster stack (100 m resolution)
#' ALG_DESC: This function extracts 34 LCZ physical parameters based on the classification scheme developed by Stewart and Oke (2012). 
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ general functions</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0