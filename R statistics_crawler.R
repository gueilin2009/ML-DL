
#Reopen with Encoding UTF-8

#all_steps    regarding Internet tables, articles, url (images<img src>tag, files...the same way) 

#step1: request目標網頁
#step2: 找出tag爬下捐款進度報告表格（兩種方法）,輸出檔案
#step3: 找出tag爬下報導標題與捐款明細"網址",新增到表格中,輸出檔案
#step4: 找出tag爬下網頁總個數與設定隨機選取
#step5: 找出tag爬下文章全文與已結案的捐款明細表格,輸出檔案

#install packages
#install.packages("xml2")
library(xml2)   


#step1

url <- "https://tw.appledaily.com/charity/projlist/"   #捐款進度報告首頁  
doc <- read_html(url)
doc


#step2 (1)

xpath <- "//table/tr[1]/td"    #定位xpath
headings <- xml_text(xml_find_all(doc, xpath))
headings

xpath1 <- "//table/tr/td[1]"   #定位xpath1
aid <- xml_text(xml_find_all(doc, xpath1))
aid

xpath2 <- "//table/tr/td[2]"   #定位xpath2
title <- xml_text(xml_find_all(doc, xpath2))
title

xpath3 <- "//table/tr/td[3]"    #定位xpath3
date.published <- xml_text(xml_find_all(doc, xpath3))
date.published

xpath4 <- "//table/tr/td[4]"    #定位xpath4
case.closed <- xml_text(xml_find_all(doc, xpath4))           
case.closed

xpath5 <- "//table/tr/td[5]"    #定位xpath5
donation <- xml_text(xml_find_all(doc, xpath5))
donation

xpath6 <- "//table/tr/td[6]"    #定位xpath6
details <- xml_text(xml_find_all(doc, xpath6))
details

#step2 (2)

t1 <- xml_text(xml_find_all(doc, "//table/tr/td"))   #一次抓取所有td的text下來
t1 <- data.frame(matrix(t1, ncol=6, byrow=T), stringsAsFactors = F) #直接設定matrix欄列數,list一次填入matrix並存成dataframe,不用管資料結構
colnames(t1) <- c("aid", "title", "date.published", "case.closed", "donation", "details")
t1  #結果跟step1(1)相同,

#step3

xpath6 <- "//table/tr/td[2]/h2/a"    #href埋在h2 tag下
attr1 <- "href"                                   
url.article <- xml_attr(xml_find_all(doc, xpath6), attr1)   #xml_attr抓取href屬性
url.article      

xpath7 <- "//table/tr/td[6]/a"
attr2 <- "href"
url.detail <- xml_attr(xml_find_all(doc, xpath7), attr2)
url.detail      #可以比較方便抓取

web.url <- "https://tw.appledaily.com/"
t2  <- xml_attr(xml_find_all(doc, "//table//a"), "href")   #也可以將上兩欄的href一次抓下來填入matrix,共40個
t2 <- data.frame(matrix(t2, ncol=2, byrow=T), stringsAsFactors = F)
colnames(t2) <- c("url.article", "url.detail")
t2$url.detail <- paste0(web.url, t2$url.detail) #href是字串,再加上web.url變成網址

t1 <- t1[, -which(colnames(t1)=="details")]  #將dataframe的details明細欄刪除
t1 <- t1[-which(rownames(t1)==1),]   #將dataframe的第一列(標題)刪除
table <- cbind(t1, t2)  #合併兩個dataframe的欄位
#stopifnot(ncol(t2)==5, nrow(t2)==20)


#step4

xpath.bonus <- "//*[@id='charity']/div/div[2]/ul/li[8]/a"
totalpage <- xml_text(xml_find_all(doc, xpath.bonus))
totalpage  #有220頁
n.page <- totalpage[length(totalpage)]
n.page <- as.integer(n.page)   #將總網頁個數text轉為數值
page <- sample(1:n.page, 1)   #隨機選取一頁
page  #例如選到176頁


#step5

#爬取捐款明細

i=2
aid <- table$aid[i]  #爬取其中一筆明細
url.detail <- table$url.detail[i]   #將其url存成doc進行parse
doc <- read_html(url.detail)

xpath <- "//table[2]/tr/td"   #xpath定位是第二個table tag
donate <- trimws(xml_text(xml_find_all(doc, xpath)))
donate

donate <- data.frame(matrix(donate, ncol=4, byrow=T),stringsAsFactors = F)  #把抓到的list填入matrix,dataframe
n <- nrow(donate)  #查看共幾筆捐款資料
donate <- donate[-which(rownames(donate)==1),]  #刪除標題列
donate

colnames(donate) <- c("aid", "donor.name", "donation", "date.donate")
View(donate)  #看完整表格

write.csv(donate, file= "D:/r_my_crawler/donate_txt.csv", row.names=F,fileEncoding = "cp950")  #將表格寫出成檔案 D:/目錄下


#爬取全文

url.article <- table$url.article[i]
doc <- read_html(url.article)
title <- xml_text(xml_find_all(doc, "//article//hgroup/h1"))  #爬取文章主標題
article <- xml_text(xml_find_all(doc, "//*[@class='ndArticle_margin']/p | //*[@class='ndArticle_margin']/h2")) #爬取全文
article <- c(title, article) #將標題與全文合併
class(article)  #全文為字串

write.csv(article, "D:/r_my_crawler/article_raw.csv", row.names=F, fileEncoding = "cp950")  #將原始全文寫出檔案by lines

