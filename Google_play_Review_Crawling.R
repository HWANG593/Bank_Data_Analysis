library(rvest)
library(RSelenium)
library(httr)
library(stringr)


remDr <- remoteDriver(remoteServerAddr = "localhost" , port = 4445, browserName = "chrome")
remDr$open()
remDr$navigate("https://play.google.com/store/apps/details?id=com.kbstar.kbbank&showAllReviews=true") #설정 URL로 이동



webElem <- remDr$findElement("css", "body") #css의 body를 element로 찾아 지정
webElem$sendKeysToElement(list(key = "end")) #해당 element(화면)의 끝(end)으로 이동


flag <- TRUE #while문 종료 플래그
endCnt <- 0 #시간 측정 변수

while (flag) {
  Sys.sleep(10) #10초 대기
  webElemButton <- remDr$findElements(using = 'css selector',value = '.ZFr60d.CeoRYc') #'더보기' 버튼 element 찾아 지정
  
  if(length(webElemButton)==1){ #버튼이 나타난 경우 진입
    endCnt <- 0 #시간 측정 초기화
    webElem$sendKeysToElement(list(key = "home")) #화면의 처음(home)으로 이동
    webElemButton <- remDr$findElements(using = 'css selector',value = '.ZFr60d.CeoRYc')
    Sys.sleep(1)
    remDr$mouseMoveToLocation(webElement = webElemButton[[1]]) #해당 버튼으로 포인터 이동
    Sys.sleep(1)
    remDr$click() #마우스 클릭 액션
    Sys.sleep(1)
    webElem$sendKeysToElement(list(key = "end")) #해당 화면의 끝(end)으로 이동
  }else{
    if(endCnt>3){ #30초 이상 대기한 경우 진입
      flag <- FALSE #while문 종료
    }else{
      endCnt <- endCnt + 1 #대기 시간 증가
    }
  }
}


frontPage <- remDr$getPageSource() #페이지 전체 소스 가져오기
reviewNames <- read_html(frontPage[[1]]) %>% html_nodes('.bAhLNe.kx8XBd') %>% html_nodes('.X43Kjb') %>%  html_text() #페이지 전체 소스에서 리뷰 게시자 부분 추출하기 
reviewDates <- read_html(frontPage[[1]]) %>% html_nodes('.bAhLNe.kx8XBd') %>% html_nodes('.p2TkOb') %>%  html_text() #페이지 전체 소스에서 리뷰 게시 일자 및 시간 부분 추출하기 
reviewComments <- read_html(frontPage[[1]]) %>% html_nodes('.UD7Dzf') %>%  html_text() #페이지 전체 소스에서 리뷰 내용 부분 추출하기 
reviewScore <- read_html(frontPage[[1]]) %>% html_nodes('.nt2C1d ') %>% html_nodes('.pf5lIe') %>% html_nodes('div') %>%  html_attr('aria-label')
reviewScore <- na.omit(reviewScore)
reviewScore <- as.numeric(substr(reviewScore, 11,11))

reviewData <- data.frame(name=reviewNames, date=reviewDates, comment=reviewComments, score=reviewScore) #수집한 데이터 통합





write.csv(reviewData,"C:/Users/HYM/Desktop/kBbank.csv")


