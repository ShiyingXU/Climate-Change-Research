library(ncdf4)
library(raster)

# 读取NetCDF文件
nc_file <- nc_open("~/Desktop/000ClimateChange/12126scPDSI.nc")

# 提取经度和纬度数据
lon <- ncvar_get(nc_file, "longitude")
lat <- ncvar_get(nc_file, "latitude")

# 提取干旱指数数据
scpdsi <- ncvar_get(nc_file, "scpdsi")
scpdsi_matrix <- apply(scpdsi, c(1, 2, 3), mean)# 将多维数组转换为矩阵

# 创建RasterLayer对象
raster_data <- raster::raster(scpdsi_matrix, xmn = min(lon), xmx = max(lon), ymn = min(lat), ymx = max(lat), crs = "+proj=longlat")

# 循环将每个月的干旱指数数据写入tif文件
for (i in 1:dim(scpdsi)[3]) {
  # 获取第i个月的干旱指数数据
  layer <- raster::raster(raster_data, layer = i)
  
  # 创建tif文件名
  tif_file <- paste0("scPDSI_", i, ".tif")
  
  # 将数据写入tif文件
  writeRaster(layer, filename = tif_file, format = "GTiff", overwrite = TRUE)
}

# 关闭NetCDF文件
nc_close(nc_file)
