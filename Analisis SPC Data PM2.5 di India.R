#input data yang digunakan
data <- read.csv("Downloads/archive/city_day.csv", stringsAsFactors = FALSE)
View(data)

#Kita pisah terlebih dahulu data kota Delhi dan Gurugram

#Membuat tabel data PM2.5 di Delhi
datadelhi <- data %>%
  filter(City %in% c("Delhi")) %>%
  select(Date, PM2.5, City)
View(datadelhi)

#Membuat tabel data PM2.5 di Gurugram
dataguru1 <- data %>%
  filter(City %in% c("Gurugram")) %>%
  select(Date, PM2.5, City)
dataguru <- na.omit(dataguru1) #filter data NA
View(dataguru)

#Nilai W sudah semakin mendekati 1 sehingga kita sudah bisa menganggap data berdistribusi normal.
#Setelah dibuat berdistribusi normal, kita sekarang akan membuat statistika deskriptif terlebih dahulu!

#STATISTIKA DESKRIPTIF# R Chart untuk PM2.5
# R Chart untuk PM2.5
# R Chart untuk PM2.5

#sari numerik
library(psych)
library(pastecs)
stat.desc(datadelhi)
stat.desc(dataguru)
describe(datadelhi)
describe(dataguru)
summary(datadelhi)
summary(dataguru)

#sari grafik
#boxplot
boxplot(datadelhi$'PM2.5', dataguru$'PM2.5', 
        horizontal = TRUE,
        names = c("Delhi", "Gurugram"),
        main = "Perbandingan Konsentrasi PM2.5",
        xlab = "PM2.5")

#histogram
# Histogram untuk data Delhi
hist(datadelhi$'PM2.5',
     breaks = 30,
     main = "Histogram Konsentrasi PM2.5 di Delhi", 
     xlab = "PM2.5",
     col = "blue",             
     border = "black")

# Histogram untuk data Gurugram
hist(dataguru$'PM2.5',
     breaks = 30,
     main = "Histogram Konsentrasi PM2.5 di Gurugram", 
     xlab = "PM2.5",
     col = "green",
     border = "black")

#ANALISIS SPC
#Karena syarat dari analisis SPC adalah data harus berdistribusi normal,
#kita akan menguji kenormalan kedua data

#Periksa kenormalan data
# Uji normalitas untuk Delhi
shapiro.test(datadelhi$`PM2.5`)
# Uji normalitas untuk Gurugram
shapiro.test(dataguru$`PM2.5`)

#Karena belum normal, kita mentransformasi agar mendekati normal
#Terapkan transformasi Tukey untuk data Delhi
library(dplyr)
datadelhi_tukey <- datadelhi %>%
  mutate(
    PM2.5_neg2 = -1 / (PM2.5^2),    # Transformasi kuat: -1/x^2
    PM2.5_neg1 = -1 / PM2.5,        # Transformasi sedang: -1/x
    PM2.5_log = log(PM2.5),         # Transformasi log: log(x)
    PM2.5_sqrt = sqrt(PM2.5)        # Transformasi lemah: sqrt(x)
  )

# Terapkan transformasi Tukey untuk data Gurugram
dataguru_tukey <- dataguru %>%
  mutate(
    PM2.5_neg2 = -1 / (PM2.5^2),
    PM2.5_neg1 = -1 / PM2.5,
    PM2.5_log = log(PM2.5),
    PM2.5_sqrt = sqrt(PM2.5)
  )

# Uji normalitas untuk data Delhi
shapiro.test(datadelhi_tukey$PM2.5_neg2)
shapiro.test(datadelhi_tukey$PM2.5_neg1)
shapiro.test(datadelhi_tukey$PM2.5_log)
shapiro.test(datadelhi_tukey$PM2.5_sqrt)

# Uji normalitas untuk data Gurugram
shapiro.test(dataguru_tukey$PM2.5_neg2)
shapiro.test(dataguru_tukey$PM2.5_neg1)
shapiro.test(dataguru_tukey$PM2.5_log)
shapiro.test(dataguru_tukey$PM2.5_sqrt)

#Hasil transformasi yang digunakan (nilai W terbesar dan p-value paling mendekati 0.05)
datadelhinormal <- datadelhi_tukey$PM2.5_log
datagurunormal <- dataguru_tukey$PM2.5_log

library(qicharts2)
#Bagan Kendali I untuk Delhi
(qi1<-qic(datadelhinormal,chart="i",point.size=2,
          title="Bagan kendali I Kandungan PM2.5 di Delhi",ylab="ln(PM2.5)",xlab="Tanggal"))
#Bagan Kendali MR
(qi2<-qic(datadelhinormal,chart="mr",point.size=2,
          title="Bagan kendali MR Kandungan PM2.5 di Delhi",ylab="ln(PM2.5)",xlab="Tanggal"))

#Informasi dari Badan Kendali
summary(qi1)
summary(qi2)

#Bagan Kendali I untuk Delhi
(qi3<-qic(datagurunormal,chart="i",point.size=2,
          title="Bagan kendali I Kandungan PM2.5 di Gurugram",ylab="ln(PM2.5)",xlab="Tanggal"))
#Bagan Kendali MR
(qi4<-qic(datagurunormal,chart="mr",point.size=2,
          title="Bagan kendali MR Kandungan PM2.5 di Gurugram",ylab="ln(PM2.5)",xlab="Tanggal"))

#Informasi dari Badan Kendali
summary(qi3)
summary(qi4)

