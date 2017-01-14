library(rvest)
library(stringr)
library(curl)

setwd("~/Development/R/R-lava-jato")

baixa_pdf <- function(url, historico) {
  req <- curl_fetch_memory(url)
  if (any(str_detect(parse_headers(req$headers), ".*application/pdf.*"))) {
    tmp <- paste0(getwd(), "/files/", str_replace_all(req$url, "http://lavajato.mpf.mp.br|/", ""), ".pdf")
    curl_download(req$url, tmp)
    return(NULL)
  }
  html <- read_html(req$content)
  html.links <- html %>% html_nodes("a") %>% html_attr("href")
  html.links <- html.links[str_detect(html.links, paste0(url, "(.*)"))]
  if (length(html.links) !=0 && !is.na(html.links)) {
    for (i in 1:length(html.links)) {
      link <- html.links[i]
      if (!(link %in% historico)){
        print(link)
        historico <- c(historico, link)
        if (!is.na(link)) {
          baixa_pdf(link, historico)
        }
      }
    }
  }
  write.table(historico, "files/historico.txt", row.names = FALSE, col.names = FALSE)
}

historico.links <- c()
historico.links <- read.table("files/historico.txt")
historico.links$V1 <- as.character(historico.links$V1)
historico.links <- historico.links[,c('V1')]

baixa_pdf("http://lavajato.mpf.mp.br/", historico.links)
