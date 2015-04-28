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
