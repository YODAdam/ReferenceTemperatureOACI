library(tidyverse)
library(readxl)

data_init <- read_excel(path = "Workbook1_donnees.xls")
unique_months <- data_init %>% pull(var = Month) %>% unique()

data_init <- data_init %>% 
  mutate(
    Month = factor(Month, levels = unique_months)
  )


data_init %>% head()

tcm_data <- data_init %>% select(Station_Name, Year, Month, TCM) %>% 
  pivot_wider(names_from = Month, values_from = TCM) %>% 
  select(!Annuel)

hot_months <- tcm_data %>% 
  select(Janvier:Decembre) %>% 
  apply(MARGIN = 1, FUN = which.max)


tcm_data$hot_months <- hot_months
tcm_data$hot_months_names <- unique_months[hot_months]

tcm_data <- tcm_data %>% select(Station_Name, Year, hot_months, hot_months_names)


tmax_data <- data_init %>% 
  select(Station_Name, Year, Month, TMAX)

ref_temp_data <- tmax_data %>% 
  right_join(y = tcm_data, by = c('Station_Name' = 'Station_Name', 'Year' = 'Year', 'Month' = 'hot_months_names'))


ref_temp_data %>% 
  group_by(Station_Name) %>% 
  summarise(
    ref_temp = mean(TMAX),
    count = n()
  )
