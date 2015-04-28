

PRcalc.ex <- function(country){
  switch(country,
         japan = {
           PR.calc(nseat = 48, vote = japanese.sample, method = "dt")
         },
         korea = {
           PR.calc(nseat = 54, vote = korea.sample, method = "hare", threshold = 0.02)
         },
         austria = {
           PR.calc(nseat = 183, vote = austria.sample, method = "dt", threshold = 0.04)
         }
  )
}
