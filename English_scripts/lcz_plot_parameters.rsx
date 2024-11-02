##LCZ4r General functions=group
##Visualize LCZ parameter map=name 
##dont_load_any_packages
##pass_filenames
##LCZ_map_parameter=raster
##Select_parameter=enum literal SVF1;SVF2;SVF3;AR1;AR2;AR3;BSF1;BSF2;BSF3;ISF1;ISF2;ISF3;PSF1;PSF2;PSF3;TSF1;TSF2;TSF3;HRE1;HRE2;HRE3;TRC1;TRC2;TRC3;SAD1;SAD2;SAD3;SAL1;SAL2;SAL3;AH1;AH2;AH3;z0
##Subtitle=string My City
##Caption=string Source:LCZ4r,  2024.
##Height=number 7
##Width=number 10
##dpi=number 600
##Output=output File png


library(LCZ4r)
library(ggplot2)

plot_lcz=lcz_plot_parameters(LCZ_map_parameter, iselect = Select_parameter, subtitle=Subtitle, caption = Caption)
ggsave(Output, plot_lcz, height = Height, width = Width, dpi=dpi)

#' LCZ_map:The SpatRaster in a stack format from Retrieve LCZ parameter function.
#' Select_parameter: Specify one single parameter name based on raster parameter map. 
#' Output: Specifies file extensions: PNG (*.png), JPG (*.jpg *.jpeg), TIF (*.tif), PDF (*.pdf), SVG (*.svg).</p><p>
#'       :Example: <b>/Users/myPC/Documents/name_lcz_par.jpeg</b>
#' ALG_DESC: This function generates a graphical representation of a Local Climate Zone (LCZ) map provided as a SpatRaster object.</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ general functions</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0
