# 加载所需的库
library(plm)
library(urca)
library(readxl)
# 读取面板数据
panel_data <- read_excel("Desktop/000ClimateChange/121 dt.xlsx", 
                         col_types = c("date", "skip", "text", 
                            "numeric", "numeric", "numeric", 
                           "numeric", "numeric", "numeric", 
                          "numeric", "numeric", "numeric"))

# 将数据转换为面板数据格式
panel_data <- pdata.frame(panel_data, index = c("Country", "Date"))
panel_data$Date <- as.Date(panel_data$Date)

# 加载所需的包
library(lubridate)
# 提取月份和年份
panel_data$Month <- month(panel_data$Date)
panel_data$Year <- year(panel_data$Date)

# 提取需要进行检验的变量
variables <- panel_data[, c("GPRC", "GPRHC", "V_WTI", "V_BNG")]
var_climate <- panel_data[,c("lnCRI")]

# 定义进行单位根检验的函数
unit_root_test <- function(var) {
  ur.df(var, type = "none", lags = 2, selectlags = "Fixed")
}

# 对所有变量进行单位根检验
unit_root_tests <- lapply(variables, unit_root_test)
# 输出单位根检验的结果
for (i in seq_along(unit_root_tests)) {
  cat("Variable:", names(variables)[i], "\n")
  print(summary(unit_root_tests[[i]]))
  cat("\n")
}#结果以上几个变量的ADF检验结果的P值均小于0.01 可以很好的拒绝原假设，
#即不存在单位根，数据是平稳的

#对CRI进行季节性单位根检验
library(seasonal)
seasonal_unit_root_test <- ur.df(lnCRI, type = "drift", lags = 12)
summary(seasonal_unit_root_test)#CRI通过了季节性单位根检验

#绘制CRI季节变化图片
# 将日期列转换为日期格式
panel_data$Date <- as.Date(panel_data$Date)
# 将数据转换为时间序列对象
cri_ts <- ts(panel_data$lnCRI, frequency = 12, start = c(2012, 1), end = c(2023, 12))


library(plot3D)
# 创建 3D 散点图
par(mar = c(5, 5, 4, 2) + 0.1)
scatter3D(panel_data$Month, panel_data$Year, panel_data$CRI, colvar = NULL,
          xlab = "Month", ylab = "Year", zlab = "CRI", main = "3D Scatter Plot of CRI")

library(rgl)

# 创建3D散点图
plot3d(panel_data$Month, panel_data$Year, panel_data$CRI, 
       xlab = "Month", ylab = "Year", zlab = "CRI", 
       type = "s", col = "blue", size = 2, main = "3D Scatter Plot of CRI")

# 保存图形为RGL格式
saveRDS("plot.rds", "plot3d")

# 加载图形
loaded_plot <- readRDS("plot.rds")
# 显示图形
plot3d(loaded_plot)



