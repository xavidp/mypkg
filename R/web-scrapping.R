# Web Scrapping
# https://stackoverflow.com/questions/43218761/by-row-vs-rowwise-iteration

# library(rvest)
# library(httr)

# GET() %>% read_html() %>%
#   ...

# safe_retry_read_html <-
#   possibly(~ read_html(RETRY("GET", url = .x)),
#            otherwise = read_html("<html></html>"))

# links <- c("https://www.ratebeer.com/beer/8481/",
#            "https://www.ratebeer.com/beer/3228/",
#            "https://www.ratebeer.com/beer/10325/")

# links %>%
#   c("https://www.wrong-url.foobar") %>%
#   purrr::set_names() %>%
#   map(~ {
#     Sys.sleep(1 + runif(1))
#     safe_retry_read_html(.x)
#   }) %>%
#   map(html_node, "#_brand4 span") %>%
#   map_chr(html_text)



#' Get Shanghai house unit price through \link{https://sh.lianjia.com}.
#'
#' @param house_name
#' @param index
#'
#' @return
#' @export
#' @import httr
#' @import rvest
#' @importFrom purrr map
#'
#' @examples
#' get_sh_lj_price("华润外滩九里")
#' get_sh_lj_price("万科城市花园")
get_sh_lj_price <- function(house_name, index =10) {
  if (index > 30) {
    warning("index must be less than 30")
    index <- 30
  }
  house_url <- modify_url("https://sh.lianjia.com",
                          path = paste0("ershoufang/rs",house_name))

  agent <- user_agent("Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.84 Safari/537.36")
  accept <- accept("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
  charset <- add_headers("Accept-Language"= "zh-CN,zh;q=0.9","Accept-Charset"="gb2312,utf-8;q=0.9,*;q=0.3")

  tmp <- content(GET(house_url,agent,accept, charset), type = "text/html",encoding = "utf-8")
  stopifnot(any(class(tmp) == "xml_node"))

  house_ids <-  tmp %>%
    html_nodes(css = "div.unitPrice") %>%
    html_attr("data-rid") %>% .[seq_len(index)]
  house_id <- names(rev(sort(table(house_ids)))[1])

  house_id_url <- modify_url("https://sh.lianjia.com",
                             path = paste0("xiaoqu/",house_id))
  house_id_tmp <- content(GET(house_id_url, agent, accept,charset),type = "text/html",encoding = "utf-8")

  nodes <- c("span.xiaoquUnitPrice","span.xiaoquInfoLabel","span.xiaoquInfoContent")

  nodes_tmp <- map(nodes, function(x) html_text(html_nodes(house_id_tmp, x)))
  if (NROW(nodes_tmp[[1]]) == 0) {
    warning("Failed")
    return(NA)
  } else {
    data.frame(
      info_label = c("id", "挂牌均价(元/m2)", nodes_tmp[[2]]),
      info_content = c(house_id, nodes_tmp[[1]], nodes_tmp[[3]]),
      stringsAsFactors = FALSE
    )
  }
}








# baidu api-----
# geo_info <- GET("http://api.map.baidu.com/geocoder/v2/?callback=renderReverse&location=39.934,116.329&output=json&pois=1&ak=30DBi9lWqva00t5mPZyonlzpQroDtfiC")



# use gaode amap api ----------------------------------------------------------

# home_adrs <- read_csv("data/os_home_adrs_ll.csv", col_types = "-dd")

# # gaode coordinate to baidu
# GCJ2BD <- function(gcj_lon, gcj_lat) {
#   x_pi = pi * 3000.0 / 180.0
#   x = gcj_lon
#   y = gcj_lat
#   z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_pi)
#   theta = atan2(y, x) + 0.000003 * cos(x * x_pi)
#   bd_lon = z * cos(theta) + 0.0065
#   bd_lat = z * sin(theta) + 0.006
#   c(bd_lon, bd_lat)
# }
#
# # baidu coordinate to gaode
# BD2GCJ <- function(bd_lon, bd_lat) {
#   x_pi = pi * 3000.0 / 180.0
#   x = bd_lon - 0.0065
#   y = bd_lat - 0.006
#   z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi)
#   theta = atan2(y, x) - 0.000003 * cos(x * x_pi)
#   gg_lon = z * cos(theta)
#   gg_lat = z * sin(theta)
#   data.frame(gg_lon, gg_lat)
# }
#
# gcj_home_adrs <- pmap_dfr(home_adrs, ~ BD2GCJ(.x, .y))


#' Title
#'
#' @param lng
#' @param lat
#' @param n
#' @param radius
#' @param types
#'
#' @return
#' @export
#'
#' @examples
#' home_adrs <- read_csv("data/os_home_adrs_ll.csv", col_types = "-dd")
#' # gaode coordinate to baidu
#' GCJ2BD <- function(gcj_lon, gcj_lat) {
#'   x_pi = pi * 3000.0 / 180.0
#'   x = gcj_lon
#'   y = gcj_lat
#'   z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_pi)
#'   theta = atan2(y, x) + 0.000003 * cos(x * x_pi)
#'   bd_lon = z * cos(theta) + 0.0065
#'   bd_lat = z * sin(theta) + 0.006
#'   c(bd_lon, bd_lat)
#' }
#'
#' # baidu coordinate to gaode
#' BD2GCJ <- function(bd_lon, bd_lat) {
#'   x_pi = pi * 3000.0 / 180.0
#'   x = bd_lon - 0.0065
#'   y = bd_lat - 0.006
#'   z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi)
#'   theta = atan2(y, x) - 0.000003 * cos(x * x_pi)
#'   gg_lon = z * cos(theta)
#'   gg_lat = z * sin(theta)
#'   data.frame(gg_lon, gg_lat)
#' }
#' gcj_home_adrs <- pmap_dfr(home_adrs, ~ BD2GCJ(.x, .y))
#' result <- pmap(gcj_home_adrs, ~ get_house_price(..1, ..2, n = 5, radius = 500))
#'
#' get_house_price(106.567288,29.655342, n = 5, radius = 500)
#'
#' home_adrs_price <- home_adrs %>%
#'   mutate(avg_house_price = unlist(result))
#'
#' write_csv(home_adrs_price, "result/home_adrs_price.csv")
get_house_price <- function(lng, lat, n = 10, radius = 500, types = 120300){
  query_list <- list(key = "4bd7f1ec6f3fc87ce264375340cf06c3",
                     location = paste(lng, lat, sep = ","),
                     types = types,
                     radius = radius,
                     offset = n,
                     page = 1,
                     extensions = "all")
  agent <- httr::user_agent("Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.97 Safari/537.36 Vivaldi/1.94.1008.40")

  api_url <- httr::modify_url("http://restapi.amap.com",
                              path = "v3/place/around", query = query_list)
  r <- httr::GET(api_url, agent)
  poi <- httr::content(r)$poi
  distance <- purrr::map_dbl(poi, ~ as.numeric(.x$distance))
  cost <- purrr::map_dbl(poi, .f = function(x){
    cost_list <- x$biz_ext$cost
    ifelse(length(cost_list) == 0, NA, as.numeric(cost_list))
  })
  if(all(is.na(cost))) {
    result <- NA
    print("get NA")
  } else {
   # 能否加入按照不同的距离distance，取不同的值

    result <- round(mean(cost, na.rm = TRUE))
    print("done!")
  }
  Sys.sleep(0.5)
  return(result)
}




