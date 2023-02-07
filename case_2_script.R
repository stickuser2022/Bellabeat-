---
  title: "case_study_2"
author: "qinggeli"
date: "2022-11-11"
output: html_document
---
  # 加载必要的function
  ```{r function}
rm(combine_data1)
library(ggplot2)
library(tibble)
library(tidyr)
library(readr)
library(purrr)
library(dplyr)
library(stringr)
library(forcats)
library(lubridate)
library(here)
library(skimr)
library(janitor)
```


# 再加载原始数据
```{r 原始数据}
DAM <- read_csv("dailyActivity_merged.csv")
DCM <- read_csv("dailyCalories_merged.csv")
DIM <- read_csv("dailyIntensities_merged.csv")
DSM <- read_csv("dailySteps_merged.csv")
HCM <- read_csv("hourlyCalories_merged.CSV")
HIM <- read_csv("hourlyIntensities_merged.csv")
HSM <- read_csv("hourlySteps_merged.csv")
MCNM<- read_csv("minuteCaloriesNarrow_merged.csv")
MCWM <- read_csv("minuteCaloriesWide_merged.csv")
MINM <- read_csv("minuteIntensitiesNarrow_merged.CSV")
MIWM <- read_csv("minuteIntensitiesWide_merged.csv")
MMNM <- read_csv("minuteMETsNarrow_merged.csv")
MSLM <- read_csv("minuteSleep_merged.csv")
MSLNM <- read_csv("minuteStepsNarrow_merged.csv")
MSWM <- read_csv("minuteStepsWide_merged.csv")
DSLM <- read_csv("sleepDay_merged.csv")
Weight <- read_csv("weightLogInfo_merged.csv")
HeartRate<-read.csv("heartrate_seconds_merged.csv")
```


# 查看数据结构（1）
```{r 数据结构}
str(DAM)
str(DSLM)
str(Weight)
str(HeartRate)
colnames(DAM)
colnames(DSLM)
colnames(Weight)
colnames(HeartRate)
```

# 联合DAM,DCM,DIM,DSM表格用于后续分析

combine_data1<-bind_cols(DAM,DCM,DIM,DSM)
colnames(combine_data1)
row.names(combine_data1)
distinct(combine_data1)




# 联合每日活动数据和每日睡眠数据data2
```{r 联合}
str(DSLM)
#DSLM<-rename(DSLM,ActivityDate=SleepDay)#改成与DAM表格中要匹配的列同名
DSLM<-separate(DSLM,ActivityDate,into = c("ActivityDate","hour"),sep=" ")#将原有的列分离成可匹配的型态
DSLM<-mutate(DSLM,Id=as.character(DSLM$Id))#将Id列转化为字串，这样才能匹配
DAM<-mutate(DAM,Id=as.character(DAM$Id))#将Id列转化为字串，这样才能匹配
combine_data2<-merge(DAM,DSLM,by=c("Id","ActivityDate"))#根据两个匹配条件合并表格

```

```{r 数据结构2}
str(combine_data1)
str(combine_data2)
```

```{r 去除na}
combine_data1<- drop_na(combine_data1)
combine_data2<- drop_na(combine_data2)
```



# 转换数据类型，使其可manipulate，将原日期转换为星期天数
```{r 数据类型}
combine_data1$ActivityDate<-as.Date(combine_data1$ActivityDate,format="%m/%d/%Y")
combine_data1<-mutate(combine_data1,weekday = wday(ActivityDate, label = TRUE))
```


# combine_data1 ,combine2描述性统计分析
```{r}

combine_data1 %>%  
  select(TotalSteps,
         TotalDistance,
         SedentaryMinutes...14,LightlyActiveMinutes...13,FairlyActiveMinutes...12,Calories...18) %>%
  summary()
combine_data2 %>%  
  select(TotalTimeInBed,TotalMinutesAsleep) %>%
  summary()

```

## 智能运动设备使用者坐着的时间和活跃时间的比较分析
```{r}
ggplot(data=combine_data1)+geom_jitter(mapping=aes(x=TotalSteps,y=SedentaryMinutes...14,size=TotalSteps,color=SedentaryMinutes...14))+facet_wrap(combine_data1$weekday)
```


## 智能运动设备使用者每日卡路里消耗和总步数的比较分析
```{r}
ggplot(data=combine_data1)+geom_smooth(mapping=aes(x=TotalSteps, y=Calories...18,size=TotalSteps,color=Calories...18))

```

## 智能设备用户总步数与睡眠时间的比较分析

### 首先计算用户在床时间和睡眠时间的差值,并于总步数表格合并
```{r}

combine_data2<-mutate(combine_data2,TimetofullAsllep=DSLM$TotalTimeInBed-DSLM$TotalMinutesAsleep)
combine_data2$ActivityDate<-as.Date(combine_data2$ActivityDate,format="%m/%d/%Y")
combine_data2<-mutate(combine_data2,weekday = wday(ActivityDate, label = TRUE))
```

## 睡眠时间和极度活跃时间的关系分析

ggplot(data=combine_data2)+geom_smooth(mapping=aes(x=VeryActiveMinutes, y=TotalMinutesAsleep,size=VeryActiveMinutes,color=TotalMinutesAsleep))


## 睡眠时间和总步数的关系分析

ggplot(data=combine_data2)+geom_smooth(mapping=aes(x=TotalSteps, y=TotalMinutesAsleep,size=TotalSteps,color=TotalMinutesAsleep))

