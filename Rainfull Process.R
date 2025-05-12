library(readxl)
library(dplyr)
library(tidyr)
library(zoo)
# 设置工作目录
setwd("~/Desktop/000ClimateChange/12122Rain")

# 创建一个空数据框，用于存储所有结果
all_rainfall_counts <- data.frame()

# 循环处理每个文件
for (year in 2012:2023) {
 # 构建文件名
 file_name <- paste0("PRCP_", year, ".xlsx")
 
 # 读取数据
 rain_data <- read_excel(file_name)
 
 # 筛选出G20国家的数据
 selected_countries <- c("AR","AU","BR","CA","CH","FR","GM","IN","ID","IT",
                         "JA","MX","KR","RS","SA","ZA","TU","UK","US")
 rain_data_selected <- subset(rain_data, Country %in% selected_countries)
 
 # 将数据转换为长格式
 data_processed <- rain_data_selected %>%
  mutate(site = NAME) %>%
  pivot_longer(cols = starts_with(as.character(year)),
               names_to = "Date",
               values_to = "rain") %>%
  select(Country, Date, rain, site) %>%
  group_by(Date, Country) %>%
  mutate(Month = format(as.Date(Date), "%Y-%m")) %>% #月度
  na.omit() # 删除包含缺失值的行
 
 # 计算每个站点每个月暴雨(>50mm)、洪水(>100mm)的数量
 rainfall_counts <- data_processed %>%
  group_by(Country, Month,site) %>%
  summarize(heavy_rain_count = sum(rain > 50),
            flood_count = sum(rain > 100),.groups = "drop")
 
 #计算每个国家每个月所有站点暴雨、洪水的数量
 rainfall_country_counts <- rainfall_counts %>%
  group_by(Country, Month) %>%
  summarize(heavyrain = sum(heavy_rain_count),
            flood = sum(flood_count),.groups = "drop")
 
 # 将结果合并到总数据框中
 all_rainfall_counts <- bind_rows(all_rainfall_counts, rainfall_country_counts)
}

# 将所有结果保存为一个CSV文件
write.csv(all_rainfall_counts, "12122 climate_rain.csv", row.names = FALSE)
