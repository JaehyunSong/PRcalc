#' @name PRcalc.ex
#' @title PRcalc.ex
#' @author Jaehyun SONG
#' @description Sample of PRcalc for R
#' @docType package
#'
#' @usage PRcalc.ex(country)
#' @param country
#' \itemize {
#'  \item "korea": 2012 Korean General Election
#'  \item "japan": 2013 Japanese Upper House Election
#'  \item "austria": 2012 Austrian General election
#' }
#'
#' @examples
#' #2012 Korean General Election
#' PR.calc("korea")
NULL

PRcalc.ex <- function(country){
  switch(country,
         japan = {
           PRcalc(nseat = 48, vote = japanese.sample, method = "dt")
         },
         korea = {
           PRcalc(nseat = 54, vote = korean.sample, method = "hare", threshold = 0.02)
         },
         austria = {
           PRcalc(nseat = 183, vote = austrian.sample, method = "dt", threshold = 0.04)
         }
  )
}
