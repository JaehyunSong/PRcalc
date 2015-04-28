PRcalc <- function(nseat, # Number of seats
                   vote,  # Voteshare(and Party name)
                   method, # Method
                   threshold = 0, #Threshold
                   viewer = TRUE # Result viewer
)
{
  #========================================================
  # PRcalc for R 0.4.1
  # Author: Jaehyun SONG (Kobe University)
  # Homepage: http://www.JaySong.net
  # Date: 2014-04-24
  # Modified: 2014-04-25 (0.2.0)
  #           2014-04-26 (0.3.0, 0.3.1)
  #           2014-04-27 (0.4.0) (0.4.1)
  #========================================================

  if(viewer == TRUE){ #Showing Welcome Message
    cat("PRcalc for R 0.4.1 \n")
    cat("Proportional Representation Calculator \n \n")
    cat("Author: Jaehyun Song (Kobe University) \n")
    cat("Homepate: http://www.JaySong.net \n")
    cat("Latest Update: 2014-04-27 \n")
  }

  #Calculating Processing Time
  start.time <- Sys.time()

  #vote가 벡터인지 데이터프레임인지 판별
  if(is.data.frame(vote) == 1){
    vote.temp <- vote[, 2]
    names(vote.temp) <- vote[, 1]
    vote <- vote.temp
  }else{}

  #Creating vector combining the names of the parties
  if(is.null(names(vote)) == 1 ){
    party.name = paste("Party", seq(1,nparty,1))
  }else{
    party.name = names(vote)
  }

  #Creating Raw data frame
  raw.vote <- vote
  raw.vote.ratio <- vote/sum(vote)
  raw.df <- data.frame(Party = party.name,
                       voteshare = raw.vote,
                       voterate = raw.vote.ratio)

  for(i in 1:nrow(raw.df)){
    if(raw.df[i, 3] < threshold){
      raw.df[i, 2] <- 0
    }else{
      raw.df[i, 2] <- raw.df[i, 2]
    }
  }

  vote <- raw.df$voteshare

  #Specifying the number of parties
  nparty = length(vote)

  #Error Message
  if(nparty < 2){
    stop("nparty must equal or more than two.")
  }
  if(nparty != length(vote)){
    stop("The length of vote must equal to nparty.")
  }

  #Highest Average Method
  HA.M <- function(nparty, nseat, vote, method){
    result.df <- data.frame(candID = NA, partyID = NA, vote = NA)
    count <- 1

    #Define Quotient
    switch(method,
           dt = { #d'Hondt
             wari.vec <- seq(from = 1, by = 1, length.out = nseat)
           },
           sl = { #Sainte-Laguë
             wari.vec <- seq(from = 1, by = 2, length.out = nseat)
           },
           msl = { #Modified Sainte-Laguë
             wari.vec <- c(1.4, seq(from = 3, by = 2, length.out = nseat-1))
           },
           denmark = { #Danish
             wari.vec <- c(2, seq(from = 3, by = 1, length.out = nseat-1))
           },
           imperiali = { #Imperiali
             wari.vec <- c(2, seq(from = 3, by = 1, length.out = nseat-1))
           },
           hh = { #Huntington-Hill
             wari.vec <- seq(from = 1, by = 1, length.out = nseat)
             wari.vec <- sqrt(wari.vec * (wari.vec - 1))
           }
    )
    for(i in 1:nparty){
      for(j in 1:nseat){
        result.df[count, ] <- c(j, i, as.double(vote[i]/wari.vec[j],3))
        count <- count + 1
      }
    }
    result.df <- result.df[order(as.double(result.df$vote), decreasing = TRUE),]
    rownames(result.df) <- c(1:nrow(result.df))
    result.df <- result.df[1:nseat,]$partyID
    result.vec <- c()
    for(i in 1:nparty) result.vec[i] <- length(result.df[result.df == i])

    return(result.vec)
  }

  #Largest Remainder Method
  LR.M <- function(nparty, nseat, vote, method){

    #Define Quota
    switch(method,
           hare = { #Hare
             quato <- sum(vote)/nseat
           },
           droop = { #Droop
             quato <- 1 + (sum(vote)/(nseat+1))
           },
           imperialiQ = { #Imperiali Quota
             quato <- sum(vote)/(nseat+2)
           }
    )

    base.seat <- vote%/%quato #나머지를 제외한 의석을 배분
    remain <- nseat - sum(base.seat) #잔여 의석 저장
    #정당명과 나머지를 저장하는 데이터프레임(temp.df) 작성 후, 나머지 값이 큰 순서대로 정렬
    temp.df <- data.frame(party = seq(1, nparty, 1), reminder = (vote/quato) - base.seat)
    temp.df <- temp.df[order(as.double(temp.df$reminder), decreasing = TRUE),]
    rownames(temp.df) <- c(1:nrow(temp.df))
    temp.df <- temp.df[1:remain,]
    #나머지를 제외한 확정 의석를 저장하는 데이터 프레임 작성
    result.df <- data.frame(party = seq(1, nparty, 1), seat = base.seat)

    if(as.integer(remain) == 0){ #잔여 의석이 없을 경우 그대로 확정
    }else if(as.integer(remain) == 1){ #잔여좌석이 하나일 경우
      #1순위 정당에게 1석 추가
      result.df[as.integer(temp.df[1,]$party), 2] <- result.df[as.integer(temp.df[1,]$party), 2] + 1
    }else{ #잔여 의석이 둘 이상일 경우
      for(i in 1:remain){
        result.df[as.integer(temp.df[i,]$party), 2] <- result.df[as.integer(temp.df[i,]$party), 2] + 1
      }
    }
    result.vec <- result.df[,2]

    return(result.vec)
  }

  switch(method,
         all = {
           stop("Wait a minute!")
         },
         dt = {
           result.vec <- HA.M(nparty, nseat, vote, method = "dt")
           method.name <- c("d'Hondt")
         },
         sl = {
           result.vec <- HA.M(nparty, nseat, vote, method = "sl")
           method.name <- c("Sainte-Laguë")
         },
         msl = {
           result.vec <- HA.M(nparty, nseat, vote, method = "msl")
           method.name <- c("Modified Sainte-Laguë")
         },
         denmark = {
           result.vec <- HA.M(nparty, nseat, vote, method = "denmark")
           method.name <- c("Denmark")
         },
         imperiali = {
           result.vec <- HA.M(nparty, nseat, vote, method = "imperiali")
           method.name <- c("Imperiali")
         },
         hh = {
           result.vec <- HA.M(nparty, nseat, vote, method = "hh")
           method.name <- c("Hungtinton-Hill")
         },
         hare = {
           result.vec <- LR.M(nparty, nseat, vote, method = "hare")
           method.name <- c("Hare")
         },
         droop = {
           result.vec <- LR.M(nparty, nseat, vote, method = "droop")
           method.name <- c("Droop")
         },
         imperialiQ = {
           result.vec <- LR.M(nparty, nseat, vote, method = "imperialiQ")
           method.name <- c("Imperiali Quota")
         })

  seats.ratio <- result.vec/sum(result.vec)
  vote.seat.ratio <- seats.ratio / raw.vote.ratio

  #Creating the data frame of result
  result.df <- data.frame(Party = party.name,
                          Voteshare = raw.vote,
                          Vote_ratio = paste(round(raw.vote.ratio * 100, 2), "%"),
                          Seats = result.vec,
                          Seats_ratio = paste(round(seats.ratio * 100, 2), "%"),
                          Vote_Seats_Ratio = round(vote.seat.ratio, 2))
  rownames(result.df) <- NULL

  #Calculating Processing Time
  finish.time <- Sys.time()

  method <- method.name
  ENP_before <- 1/sum(raw.vote.ratio^2)
  ENP_after <- 1/sum((result.df$Seats/sum(result.df$Seats))^2)
  G.index <- sqrt(0.5 * sum((((raw.vote/sum(raw.vote))*100) - ((result.vec/sum(result.vec))*100))^2))
  time <- finish.time - start.time

  if(viewer == TRUE){
    cat("======================================================= \n
        Method:", method, "\n \n")
    print(result.df)
    cat(paste("ENP(Before):", round(ENP_before, 2)), "\n")
    cat(paste("ENP(After):", round(ENP_after, 2)), "\n")
    cat(paste("Gallagher Index:", round(G.index, 3)), "\n")
    cat(paste("Processing Time:", round(time, 5)), "s. \n")
  }else{
    result <- list(df = result.df,
                   method = method,
                   ENP_before = ENP_before,
                   ENP_after = ENP_after,
                   index = G.index,
                   time = time)
    return(result)
  }

}
