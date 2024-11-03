##PT-LCZ4r Funções Gerais=group
##Visualizar LCZ parâmetros=name 
##dont_load_any_packages
##pass_filenames
##LCZ_map_parameter=raster
##Select_parameter=optional enum literal multiple SVF1;SVF2;SVF3;AR1;AR2;AR3;BSF1;BSF2;BSF3;ISF1;ISF2;ISF3;PSF1;PSF2;PSF3;TSF1;TSF2;TSF3;HRE1;HRE2;HRE3;TRC1;TRC2;TRC3;SAD1;SAD2;SAD3;SAL1;SAL2;SAL3;AH1;AH2;AH3;z0
##Subtitle=string My City
##Caption=string Source:LCZ4r,  2024.
##Height=number 7
##Width=number 10
##dpi=number 600
##inclusive=boolean FALSE
##Output=output File

library(LCZ4r)
library(ggplot2)

# Generate and plot the LCZ map
plot_lcz <-lcz_plot_parameters(LCZ_map_parameter, iselect = Select_param, subtitle=Subtitle, caption = Caption, inclusive=inclusive)
ggsave(Output, plot_lcz, height = Height, width = Width, dpi=dpi)

#' LCZ_map:The SpatRaster in a stack format from Retrieve LCZ parameter function.
#' Select_parameter: Specify one or more parameter names to retrieve specific parameters. 
#' inclusive: Logical. Set to TRUE to use a colorblind-friendly palette.
#' Output: Specifies file extensions: PNG (*.png), JPG (*.jpg *.jpeg), TIF (*.tif), PDF (*.pdf).
#' ALG_DESC: This function generates a graphical representation of a Local Climate Zone (LCZ) map provided as a SpatRaster object.</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ general functions</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0