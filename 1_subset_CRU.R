###############################################################################
# Crops CRU pentad or monthly precipitation data to cover the spatial extent 
# of the ZOI/CSA/PA boundary of each team site.
###############################################################################

source('0_settings.R')

library(rgdal)
library(raster)
library(stringr)
library(rgeos)
library(teamlucc)

library(foreach)
library(doParallel)

cl <- makeCluster(8)
registerDoParallel(cl)

foreach (dataset=datasets, .inorder=FALSE,
         .packages=c("teamlucc", "rgeos", "raster", "rgdal")) %dopar% {
    timestamp()
    message('Processing ', dataset, '...')

    ncdf <- file.path(in_folder, dataset,
                      pattern=paste(product, datestring, dataset, 'dat.nc', 
                                    sep='.'))
    this_dataset <- stack(ncdf)
    proj4string(this_dataset) <- s_srs

    for (sitecode in sitecodes) {
        load(file.path(zoi_folder, paste0(sitecode, '_ZOI_CSA_PA.RData')))
        aoi <- gConvexHull(aois)
        aoi <- spTransform(aoi, CRS(utm_zone(aoi, proj4string=TRUE)))
        aoi <- gBuffer(aoi, width=10000)
        aoi <- spTransform(aoi, CRS(s_srs))

        dstfile <- file.path(out_folder,
                              paste0(product, '_', dataset, '_', sitecode, '_', 
                                     datestring,  '.tif'))
        cropped_data <- crop(this_dataset, aoi, overwrite=TRUE, 
                             filename=dstfile)
    }
}

stopCluster(cl)
