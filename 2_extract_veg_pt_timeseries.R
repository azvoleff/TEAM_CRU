###############################################################################
# Extracts CRU climate variables for TEAM vegetation plots
###############################################################################

source('0_settings.R')

library(rgdal)
library(raster)
library(reshape2)
library(dplyr)
library(foreach)
library(doParallel)

cl <- makeCluster(8)
registerDoParallel(cl)

# CRU Dataset key:
#
# 	Variable:	                  Symbol:
# 	Mean temperature	            tmp
# 	Maximum Temperature	            tmx
# 	Minimum Temperature          	tmn
# 	Diurnal Range                	dtr
# 	Precipitation                	pre
# 	Wet Days	                    wet
# 	Vapour pressure	      	 	 	vap
# 	Cloud              			   	cld
# 	Potential evapotranspiration	pet
# 	Frost frequency                 frs	

load("vg_pts.RData")

cru <- foreach(dataset=datasets,
               .packages=c('raster', 'reshape2'),
               .inorder=FALSE, .combine=rbind) %dopar% {

    ncdf <- file.path(in_folder, dataset,
                      pattern=paste(product, datestring, dataset, 'dat.nc', 
                                    sep='.'))
    stopifnot(file_test('-f', ncdf))
    this_dataset <- stack(ncdf)

    plot_cru <- extract(this_dataset, vg_pts, df=TRUE)

    stopifnot(plot_cru$ID == 1:nrow(plot_cru))
    plot_cru <- plot_cru[names(plot_cru) != 'ID']

    stopifnot(nrow(plot_cru) == nrow(vg_pts))

    plot_cru <- cbind(sitecode=vg_pts$sitecode,
                      plot_ID=vg_pts$Unit_ID, 
                      plot_num=vg_pts$number,
                      dataset=dataset, plot_cru)

    plot_cru <- melt(plot_cru,
                     id.vars=c('sitecode', 'plot_ID', 'plot_num', 
                               'dataset'), variable.name='date')

    plot_cru$date <- as.Date(plot_cru$date, 'X%Y.%m.%d')

    return(plot_cru)
}
cru  <- tbl_df(cru)
save(cru, file='vg_plot_cru.RData')

stopCluster(cl)
