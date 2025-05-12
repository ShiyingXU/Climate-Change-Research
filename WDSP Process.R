library(readxl)
library(dplyr)
library(tidyr)

# 设置工作目录
setwd("D:/桌面/000 Climate change/12123 WDSP/")

# 创建一个空数据框，用于存储所有结果
all_wind_counts <- data.frame()

# 循环处理每个文件
for (year in 2012:2023) {
 # 构建文件名
 file_name <- paste0("WDSP_", year, "_daily.xlsx")
 
 # 读取数据
 WDSP_data <- read_excel(file_name)
 
 # 筛选出G20国家的数据
 selected_countries <- c("AR","AU","BR","CA","CH","FR","GM","IN","ID","IT","JA","MX","KR","RS","SA","ZA","TU","GB","US")
 WDSP_data_selected <- subset(WDSP_data, Country %in% selected_countries)
 
 # 数据预处理
 data_processed <- WDSP_data_selected %>%
  mutate(site = NAME) %>%
  pivot_longer(cols = starts_with(as.character(year)),
               names_to = "Date",
               values_to = "WDSP") %>%
  mutate(Month = format(as.Date(Date), "%Y-%m")) %>%
  select(Country, Date, WDSP, Month, site) %>%
  replace(is.na(.), 0)  # 将缺失值替换为0
 
 # 计算每个国家每个站点每月的风害数量
 wind_site_counts <- data_processed %>%
  group_by(Country, Month, site) %>%
  summarize(wind_site_count = sum(WDSP > 17.2, na.rm = TRUE), .groups = "drop") %>%
  replace(is.na(.), 0)  # 将缺失值替换为0
 
 # 计算每个国家每个月所有站点的风害数量之和
 wind_country_counts <- wind_site_counts %>%
  group_by(Country, Month) %>%
  summarize(wind = sum(wind_site_count), .groups = "drop")
 
 # 将结果添加到总数据框中
 all_wind_counts <- bind_rows(all_wind_counts, wind_country_counts)
}

# 将所有结果保存为一个CSV文件
write.csv(all_wind_counts, "12123 climate_WDSP.csv", row.names = FALSE)