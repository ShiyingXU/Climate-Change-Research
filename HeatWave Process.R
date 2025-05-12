library(readxl)
library(dplyr)
library(tidyr)
library(zoo)
# 设置工作目录
setwd("~/Desktop/000ClimateChange/12121Temp")

# 创建一个空的数据框，用于存储所有文件的处理结果
combined_data <- data.frame()

# 循环处理每个文件
for (year in 2012:2023) {
 # 构建文件路径
 file_path <- paste0("D:/桌面/000 Climate change/12121 Temp_Rain/Temp/TEMP_", year, "_daily.xlsx")
 
 # 读取Excel数据到R中
 temp_data <- read_excel(file_path)
 
 # 筛选出G20国家的数据
 selected_countries <- c("AR","AU","BR","CA","CH","FR","GM","IN","ID","IT",
                         "JA","MX","KR","RS","SA","ZA","TU","UK","US")
 temp_data_selected <- subset(temp_data, Country %in% selected_countries)
 
 # 将温度数据转换成长格式
 data_processed <- temp_data_selected %>%
  mutate(site = NAME) %>%
  pivot_longer(cols = starts_with(as.character(year)),
               names_to = "Date",
               values_to = "Temperature") %>%
  select(Country, Date, Temperature, site) %>%
  mutate(Month = format(as.Date(Date), "%Y-%m")) %>%
  na.omit() # 删除包含缺失值的行
 
 # 计算5日滑动平均温度
 hw_dt <- data_processed %>%
  group_by(Country, Month, site) %>%
  mutate(rolling_avgtemp = zoo::rollmean(Temperature, k = 5, fill = NA, align = "right")) %>%
  ungroup() %>%
  mutate(rolling_avgtemp = replace_na(rolling_avgtemp, 0))
 
 # 计算是否为热浪
 hw <- hw_dt %>%
  mutate(heatwave = ifelse(rolling_avgtemp > 35, 1, 0)) 
 
 # 计算每个国家每个站点每月的热浪数量
 hw_counts <- hw %>%
  group_by(Country, site, Month) %>%
  summarise(heatwave_count = sum(heatwave), .groups = "drop")
 
 # 计算每个国家每个月的所有站点的热浪数量之和
 heatwave <- hw_counts %>%
  group_by(Country, Month) %>%
  summarise(total_heatwave_count = sum(heatwave_count), .groups = "drop")
 
 # 将处理结果添加到组合数据框中
 combined_data <- bind_rows(combined_data, heatwave)
}

write.csv(combined_data, "12121 climate_hw.csv", row.names = TRUE)
