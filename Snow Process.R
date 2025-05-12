library(readxl)
library(dplyr)
library(tidyr)

# 设置工作目录
setwd("~/Desktop/000ClimateChange/12124 SNDP")

# 定义要筛选的国家列表
selected_countries <- c("AR", "AU", "BR", "CA", "CH", "FR", "GM", "IN", "ID", 
                  "IT", "JA", "MX", "KR", "RS", "SA", "ZA", "TU", "UK", "US")

# 创建一个空数据框来存储结果
all_snow_counts <- data.frame()

# 循环读取并处理每个文件
for (year in 2012:2023) {
  # 构建文件名
  file_name <- paste0("SNDP_", year, "_daily.xlsx")
  
  # 读取Excel文件
  temp_data <- read_excel(file_name)
  
  # 筛选出G20国家的数据
  temp_data_selected <- filter(temp_data, Country %in% selected_countries)
  
  # 将积雪数据转换成长格式
  data_processed <- temp_data_selected %>%
    mutate(site = NAME) %>%
    pivot_longer(cols = starts_with(as.character(year)),
                 names_to = "Date",
                 values_to = "SnowDepth") %>%
    mutate(Month = format(as.Date(Date), "%Y-%m"))%>%
    select(Country, Date, SnowDepth, Month, site) %>%
    replace(is.na(.), 0)  # 将缺失值替换为0
  
  # 计算每个国家每个站点每月的大雪数量
  snow_site_month_counts <- data_processed %>%
    group_by(Country,site, Month) %>%
    summarise(snow_disaster_count = sum(SnowDepth > 1.9685, na.rm = TRUE), .groups = "drop") %>%
    replace(is.na(.), 0)  # 将缺失值替换为0
  
  # 计算每个国家每个月的所有站点的雪灾数量之和
  snow_country_counts <- snow_site_month_counts %>%
    group_by(Country,Month)%>%
    summarize(snow= sum(snow_disaster_count),.groups = "drop")

  # 将结果添加到总数据框中
  all_snow_counts <- bind_rows(all_snow_counts, snow_country_counts)
}

# 将所有结果保存为一个CSV文件
write.csv(all_snow_counts, "12124 climate_SNDP.csv", row.names = FALSE)
