# 创建一个空的数据框来存储合并后的数据
combined_data <- data.frame()

# 循环读取每个CSV文件并合并到combined_data中
for (year in 2012:2023) {
 file_path <- paste0("D:/桌面/000 Climate change/12121 Temp_Rain/Temp/hw", year, ".csv")
 if (file.exists(file_path)) {
  data <- read.csv(file_path)
  combined_data <- rbind(combined_data, data)
 }
}

# 查看合并后的数据框
print(combined_data)

#存储到文件夹
write.csv(combined_data, "12121 climate_hw.csv", row.names = TRUE)
