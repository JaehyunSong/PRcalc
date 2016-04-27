#========================================================
# PRcalc for R 0.6.0
# Author: Jaehyun SONG (Kobe University)
# Homepage: http://www.JaySong.net
# E-mail: jaehyun.song@stu.kobe-u.ac.jp
# Date: 2014-04-24
# Modified: 2014-04-25 (0.2.x)
#           2014-04-26 (0.3.x)
#           2014-04-27 (0.4.x)
#           2014-04-28 (0.5.x)
#           2014-05-07 (0.6.x)
#========================================================
#' @name PRcalc
#' @title PRcalc
#' @author Jaehyun SONG
#' @description Proportional Representation Calculator for R
#' @docType package
#'
#' @usage PRcalc(nseat, vote, method
#'        threshold = 0, multiple = FALSE, viewer = TRUE)
#'
#' @param nseat Number of seats(scalar or vector)
#' @param vote Votes(vector or data.frame)
#' @param method
#' \itemize {
#'  \item dt: d'Hondt
#'  \item sl: Sainte-Laguë
#'  \item msl: Modified Sainte-Laguë
#'  \item denmark: Danish
#'  \item imperiali: Imperiali
#'  \item hh: Huntington-Hill
#'  \item hare: Hare
#'  \item droop: Droop
#'  \item hh: Huntington-Hill
#' }
#' @param threshold Threshold(numeric, 0~1)
#' @param viewr Showing the result
#'
#' @return List type
#'
#' @examples
#' #Number of seats=50, (PartyA 100 votes, PartyB 80 votes, PartyC 60 votes), Method = Hare
#' PRcalc(nseat = 50,
#'       vote = c(“Party A” = 100,
#'                “Party B” = 80,
#'                “Party C” = 60),
#'       method = “hare”)
#'
#' #Number of seats = 54, ( 700 votes, 80 votes, 100 votes, 70 votes (without party names)), Method = d’Hondt, Threshold = 5%
#' PRcalc(nseat = 54,
#'       vote = c(700, 80, 100, 70),
#'       method = “dt”, threshold = 0.05)
#'
#' # Number of seats = 183, Using Austrian sample dataset, Method = d’Hondt, Threshold = 4%
#' PRcalc(nseat = 183,
#'       vote = austrian.sample,
#'       method = “dt”, threshold = 0.04)
NULL

PRcalc <- function(nseat, # Number of seats
                   vote,  # Voteshare(and Party name)
                   method, # Method
                   threshold = 0, #Threshold
                   multiple = FALSE, # Multiple Districts
                   viewer = TRUE # Result viewer
)
{
  #======================================================================
  # Defining the functions, HA.M and LR.M
  #======================================================================


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

#======================================================================
#
#======================================================================
  
  nparty = length(vote)

  # Identifying whether there are multiple district using the length of nseat
  if(length(nseat) > 1){
    multiple = TRUE
  }else{
    multiple = FALSE
  }

  if(viewer == TRUE){ #Showing Welcome Message
    cat("PRcalc for R 0.6.1 \n")
    cat("Proportional Representation Calculator \n \n")
    cat("Author: Jaehyun Song (Kobe University) \n")
    cat("Homepate: http://www.JaySong.net \n")
    cat("Latest Update: 2016-04-27 \n")
  }

  #Calculating Processing Time
  start.time <- Sys.time()

  if(multiple == TRUE){
    # Showing an error message 1
    if(!is.data.frame(vote)){
      stop("vote must be a data frame if multiple was TRUE")
      }else{
        # Showing an error message 2
      if(ncol(vote) - 1 != length(nseat)){
        stop("the length of nseat must equal to number of districts")
        }else{}
    }
  }else{}

  #=============================================
  # In case of single district
  #=============================================
  if(multiple == FALSE){
    # Indeifying whether vote is a vector
    if(is.data.frame(vote) == 1){ # If vote was a data frame, vote will be changed into a vector
      vote.temp <- vote[, 2]
      names(vote.temp) <- vote[, 1]
      vote <- vote.temp
    }else{} # Or not, go through

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
  }else{}

  #=============================================
  # In case of multiple district
  #=============================================
  if(multiple == TRUE){
    result.df <- data.frame(Party = vote[, 1])

    for(i in 1:(ncol(vote)-1)){
      nparty <- nrow(vote)

      temp.vote <- c()
      for(j in 1:nrow(vote)){ # Changing vote to zero, if vote was lower than threshold.
        if((vote[j, i+1]/sum(vote[, i+1])) < threshold){
          temp.vote[j] <- 0
        }else{
          temp.vote[j] <- vote[j, i+1]
        }
      }

      switch(method,
             dt = {
               result.vec <- HA.M(nparty, nseat[i], temp.vote, method = "dt")
               method.name <- c("d'Hondt")
             },
             sl = {
               result.vec <- HA.M(nparty, nseat[i], temp.vote, method = "sl")
               method.name <- c("Sainte-Laguë")
             },
             msl = {
               result.vec <- HA.M(nparty, nseat[i], temp.vote, method = "msl")
               method.name <- c("Modified Sainte-Laguë")
             },
             denmark = {
               result.vec <- HA.M(nparty, nseat[i], temp.vote, method = "denmark")
               method.name <- c("Denmark")
             },
             imperiali = {
               result.vec <- HA.M(nparty, nseat[i], temp.vote, method = "imperiali")
               method.name <- c("Imperiali")
             },
             hh = {
               result.vec <- HA.M(nparty, nseat[i], temp.vote, method = "hh")
               method.name <- c("Hungtinton-Hill")
             },
             hare = {
               result.vec <- LR.M(nparty, nseat[i], temp.vote, method = "hare")
               method.name <- c("Hare")
             },
             droop = {
               result.vec <- LR.M(nparty, nseat[i], temp.vote, method = "droop")
               method.name <- c("Droop")
             },
             imperialiQ = {
               result.vec <- LR.M(nparty, nseat[i], temp.vote, method = "imperialiQ")
               method.name <- c("Imperiali Quota")
             })
      temp.df <- data.frame(vote = vote[, 1+i],
                            seat = result.vec)
      colnames(temp.df) <- c(paste("Vote", i), paste("Seat", i))
      result.df <- cbind(result.df, temp.df)
    }
    Vote.Sum <- c()
    for(i in 1:nparty){ Vote.Sum[i] <- sum(result.df[i, seq(from = 2, to = ncol(result.df)-1, by = 2)]) }
    Seat.Sum <- c()
    for(i in 1:nparty){ Seat.Sum[i] <- sum(result.df[i, seq(from = 3, to = ncol(result.df), by = 2)]) }

    result.df <- cbind(result.df, Vote.Sum, Seat.Sum)

    #ENP_before <- 1/sum(raw.vote.ratio^2)
    #ENP_after <- 1/sum((result.df$Seats/sum(result.df$Seats))^2)
    #G.index <- sqrt(0.5 * sum((((raw.vote/sum(raw.vote))*100) - ((result.vec/sum(result.vec))*100))^2))
    finish.time <- Sys.time()
    time <- finish.time - start.time

    if(viewer == TRUE){
      cat("======================================================= \n
          Method:", method.name, "\n \n")
      print(result.df)
      #cat(paste("ENP(Before):", round(ENP_before, 2)), "\n")
      #cat(paste("ENP(After):", round(ENP_after, 2)), "\n")
      #cat(paste("Gallagher Index:", round(G.index, 3)), "\n")
      cat(paste("Processing Time:", round(time, 5)), "s. \n")
    }else{
      return(result.df)
    }

  }
}
