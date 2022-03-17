library(xlsx)
library(stringr)
library(dplyr)
library(magrittr)
library(tidyr)
library(lubridate)
library(plotly)
library(htmlwidgets)
library(zoo)
library(forecast)

##路徑設定
dir = "~"
setwd(dir)

##讀取檔案
file.list_mask <- list.files(pattern="*.csv")
mask_count_view <- lapply(file.list_mask, function(mask_count){
  mask_count <- read.csv(mask_count, fileEncoding = "UTF-8")
})

mask_count_view_re <- do.call(rbind.data.frame, mask_count_view) %>% unique()
mask_count_view_re$invoice_dt <- sub(pattern = ' 00:00:00.000',replacement = '',x = mask_count_view_re$invoice_dt)
colnames(mask_count_view_re) <- c("date", "counties", "count")

mask_count_view_re_sort <- mask_count_view_re[order(mask_count_view_re$date,decreasing = T),]
mask_count_view_re_sort$date <- mask_count_view_re_sort$date %>% as.Date()

weekdate<- read.csv("~/WEEKDATE.csv", colClasses = c("Date","character")) %>%
  filter(between(date,as.Date("2017-01-01"),Sys.Date())) 
colnames(weekdate) <- c("date","WEEKDATE")

##所有資料、全國每週、各縣市每週、全國累計
mask_count_view_re_sort_week <- left_join(mask_count_view_re_sort, weekdate, by="date")
mask_count_taiwan<-mask_count_view_re_sort_week %>% group_by(WEEKDATE) %>% summarise(count = sum(count))%>% as.data.frame()
mask_count_single<-mask_count_view_re_sort_week %>% group_by(WEEKDATE, counties) %>% summarise(count = sum(count)) %>% as.data.frame()
mask_count_country_sum <- mask_count_view_re_sort_week %>% group_by(counties) %>% summarise(count = sum(count))%>% as.data.frame()


path = paste0("~")
write.xlsx(mask_count_view_re_sort, path, row.names = FALSE, sheetName = "全部資料")
write.xlsx(mask_count_taiwan, path, row.names = FALSE, sheetName = "全國每周資料", append=TRUE)
write.xlsx(mask_count_single, path, row.names = FALSE, sheetName = "各縣市每周資料", append=TRUE)
write.xlsx(mask_count_country_sum, path, row.names = FALSE, sheetName = "全國累積數量", append=TRUE)



