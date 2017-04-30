## Exploratory analysis + a data viz assignment

## goal: first, make a chart about whether contracts set aside for small
# business are more likely to get terminated.

# second, do other, more useful things

library(tidyverse)
library(forcats)

contracts <- read_csv("data_for_test.csv")

# subset to closed contracts or contracts that are 
# A. past their ultimate date
# B. more than a year past their current date, or
# C. flagged as closed
# as of fiscal 2015

closed_contracts <- contracts %>%
  filter(
    UnmodifiedCurrentCompletionDate <= as.Date("2015-10-01") |
    LastCurrentCompletionDate <= as.Date("2014-10-01") |
    IsClosed == "closed")

# bucket them by contract value
closed_contracts$contract_value <- cut(
  closed_contracts$UnmodifiedContractBaseAndAllOptionsValue,
  breaks = c(-9e12, 1000, 3500, 10000,
             50000, 150000, 500000, 2e6, 10e6, 100e6, 9e12),
  labels = c("1k", "3.5k", "10k", "50k", "150k", "500k", "2M",
             "10M", "100M", ">100M")
)

# code Term as (0,1)
closed_contracts <- closed_contracts %>%
  mutate(Failed = ifelse(Term == "Terminated", 1, 0))

# get a count of each bucket and terminations in each bucket to derive fail rate
closed_contracts <- closed_contracts %>%
  group_by(contract_value) %>%
  summarize(Total = n(), Failed = sum(Failed))

closed_contracts$fail_rate <- 
  (closed_contracts$Failed / closed_contracts$Total) * 100


# make a chart about it

source("C:\\Users\\loren\\Google Drive\\Documents\\R\\Data viz class\\theme_LCL.R")
library(scales)

closed_contracts$setaside <- factor(ifelse(
  closed_contracts$contract_value %in% c("10k", "50k", "150k"),
  "yes",
  "no"))

p <- ggplot(data = closed_contracts, aes(x = contract_value, y = fail_rate)) +
  geom_bar(aes(fill = setaside), stat = "identity", alpha = 0.7) +
  theme_LCL() +
  scale_fill_manual(
    values = c(
      "yes" = "#D09040",
      "no" = "#900090")) +
  scale_y_continuous(labels = scales::percent) +
  theme(
    legend.position = "top",
    axis.ticks = element_blank()) +
  ylab("Proportion Terminated") +
  xlab("Size of Contract") +
  ggtitle("Set-Asides Don't Fail More") 
  # geom_rect(
  #   mapping = aes(
  #     ymin = -Inf,
  #     ymax = Inf,
  #     xmin = 3,
  #     xmax = 6,
  #   color = NA,
  #   fill = "gray75"))


p

library(svglite)
ggsave(
  file="C:\\Users\\loren\\Google Drive\\Documents\\R\\Data viz class\\setasides.svg",
  plot=p,
  width=10, height=7)
