# PRcalc for R
Proportional Representation Calculator for R

---

Current Version: 0.6.0 (2015/05/07)

## Author Information
* Jaehyun SONG (Korean)
* Assistant Professor at Doshisha University, Japan
* Ph.D in Political Science (Kobe University)
* Majoring in voting behavior, political methodology.

## History

* 2015/04/24 (0.1.0): Release {PRclac}
* 2015/04/25 (0.2.0)
  * An argument, `nparty`, was removed.
  * A name of an argument was changed, voteshare to vote. Also, you can define party names. (Of course, it is okay to left blank.)
  * Disproportionality Index(Gallagher Index) is indicated.
  * Optimized function. You can call the package more faster (a little)
  * `PR.calc.ex()` is included. This function show a sample result.
* 2015/04/26 (0.3.0): You can specify a threshold.
* 2015/04/27 (0.4.0): data.frame type is available for vote argument! You don’t have to type troublesome vector argument.
* 2015/04/28 (0.5.0)
  * {PRcalc} come be available as an R package!
  * Sample datasets included.
* 2015/05/07 (0.6.0)
  * New sample dataset added, `japanese.sample2` (2014 Japanese Lower House Election)
  * Calculating multiple districts simultaneously is possible.
* 2016/04/27 (0.6.1)
  * Bugs fixed

---

## Installation

```r
install("devtools") # if devtools is not installed
devtools::install_github("JaehyunSong/PRcalc")
```

---

## Usage

### Required Arguments list
* `nseat`: Number of seats (scalar or vector)
  * If you set nseat as a vector, the length of the vector must equals (the columns of the dataset – 1).
* `vote`: votes(vector or data.frame)
  * Example
  * No party names, votes are 100, 500, 300: `vote = c(100, 500, 300)`
  * Defining party names, Party A got 100 votes, Party B 500 votes, Party C 300 votes: `vote = c("Party A" = 100, "Party B" = 500, "Party C" = 300)`
  * If you want to use data.frame, the data frame must have more than two columns. The first column must be party name and the after columns must be votes.
* method: Method
  * Highest Averages Method
    * `dt`: d’Hondt
    * `sl`: Sainte-Laguë
    * `msl`: Modified Sainte-Laguë
    * `denmark`: Danish
    * `imperiali`: Imperiali
    * `hh`: Huntington-Hill
  * Largest Remainder Method
    * `hare`: Hare
    * `droop`: Droop
    * `imperialiQ`: Imperiali Quota
  * I wish it is equipped methods as many as possible. Please let me know what you want this package to be equipped.

### Optional Argument list
* `threshold`: Threshold(default = 0) (ex: threshold = 0.05)
* `viewer`: Showing the result(default = `TRUE`). if this argument is `FALSE`, the result will not be shown, just return the list type object.

### Extra function
* `PRcalc.ex(argument)` : Showing an example.
  * This function has three samples, `"korea"`(2012 Korean General Election), `"japan"`(2013 Japanese Upper House Election) and `"austria"`(2013 Austrian General Election).

---

## Example

Number of seats=50, (PartyA 100 votes, PartyB 80 votes, PartyC 60 votes), Method = Hare
```r
PRcalc(nseat = 50, vote = c("Party A" = 100, "Party B" = 80, "Party C" = 60), method = "hare")
```

Number of seats = 54, ( 700 votes, 80 votes, 100 votes, 70 votes (without party names)), Method = d’Hondt, Threshold = 5%
```r
PRcalc(nseat = 54, vote = c(700, 80, 100, 70), method = "dt", threshold = 0.05)
```

Number of seats=48, using japanese.sample, method = d’Hondt
```r
PRcalc(nseat = 48, vote = japanese.sample, method = "dt")
```

Number of seats=11 blocks 180 seats, using japanese.sample2, method = d’Hondt, therehold = 2%
```r
PRcalc(nseat = c(8, 14, 20, 22, 17, 11, 21, 29, 11, 6, 21), vote = japanese.sample2, method = "dt", threshold = 0.02)
```

---

## Sample Dataset

* `korean.sample`: 2012 Korean General Election
* `japanese.sample`: 2013 Japanese Upper House Election
* `japanese.sample2`: 2014 Japanese Lower House Election
* `austrian.sample`: 2012 Austrian General Election

---

## Result Example Command(2012 Austrian General Election)

**Input**

```r
PRcalc(nseat = 183, 
       vote = c("Social Democratic Party of Austria" = 1258605, 
                "Austrian People`s Party"            = 1125876, 
                "Freedom Party of Austria"           = 962313, 
                "The Greens – The Green Alternative" = 582657, 
                "Team Stronach"                      = 268679, 
                "NEOS – The New Austria"             = 232946, 
                "Alliance for the Future of Austria" = 165746, 
                "Communist Party of Austria"         = 48175, 
                "Pirate Party of Austria"            = 36265, 
                "Christian Party of Austria"         = 6647, 
                "Others" = 4998), 
       method = "dt", threshold = 0.04) 
```

**Output**

```
PRcalc for R 0.6.0 
Proportional Representation Calculator 
Author: Jaehyun Song (Kobe University) 
Homepate: http://www.JaySong.net 
Latest Update: 2014-05-07 
======================================================= 

Method: d’Hondt

   Party                              Voteshare   Vote_ratio   Seats   Seats_ratio   Vote_Seats_Ratio 
1  Social Democratic Party of Austria 1258605     26.82%       52      28.42%        1.06 
2  Austrian People’s Party            1125876     23.99%       47      25.68%        1.07 
3  Freedom Party of Austria            962313     20.51%       40      21.86%        1.07 
4  The Greens – The Green Alternative  582657     12.42%       24      13.11%        1.06 
5  Team Stronach                       268679      5.73%       11      6.01%         1.05 
6  NEOS – The New Austria              232946      4.96%        9      4.92%         0.99 
7  Alliance for the Future of Austria  165746      3.53%        0         0%         0.00 
8  Communist Party of Austria           48175      1.03%        0         0%         0.00 
9  Pirate Party of Austria              36265      0.77%        0         0%         0.00 
10 Christian Party of Austria            6647      0.14%        0         0%         0.00 
11 Others                                4998      0.11%        0         0%         0.00 

ENP(Before): 5.15
ENP(After): 4.59
Gallagher Index: 3.314　
Processing Time: 0.58107 s.　
```

---

## Future Update
* Add all method in method argument for comparing the all method.
* Showing and comparing multiple method.
* Customize the result
* Optimizing the algorithm.
* PRcalc for Web
