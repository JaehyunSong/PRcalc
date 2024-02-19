# PRcalc for R

Proportional Representation Calculator for R

Current Version: 0.8.0 (2024/02/19)

PRcalc for Web: <https://jaysong.shinyapps.io/prcalc4web/>

---

**CAUTION!!!** {PRcalc} is now on code refactoring. Do NOT use this pacakges for any purpose (acamdemic, commercial, or etc.). Please use for only testing.

---

## Author Information

* Jaehyun SONG, Ph.D.
   * Associate Professor (Kansai University, Japan)
   * <https://www.jaysong.net>
* Yuta Kamahara, Ph.D.
   * Associate Professor (Yokohama National University, Japan)
   * <https://sites.google.com/site/yutakamaharapolisci/>

## History

* 2015/04/24 (0.1.0): 初公開
* 2015/04/25 (0.2.0)
  * `nparty`引数の削除
  * 仮引数`voteshare`の名称を`vote`に変更
  * 非比例性指標 (Gallagher Index) の出力
  * 関数の効率化
  * 例を出力する`PR.calc.ex()`関数の追加
* 2015/04/26 (0.3.0): 阻止条項が指定可能
* 2015/04/27 (0.4.0): `vote`の実引数としてdata.frame型が使用可能
* 2015/04/28 (0.5.0)
  * {PRcalc}のパッケージ化
  * サンプルデータの追加
* 2015/05/07 (0.6.0)
  * 新しいサンプルデータ`japanese.sample2`の追加
  * ブロック制比例代表が計算可能
* 2016/04/27 (0.6.1)
  * バグ修正
* 2022/03/09 (0.7.0)
  * 大幅なアップデート (というか、作り直しました)
* 2024/02/19 (0.8.0)
  * コードリファクトリング
  
---

## インストール

```r
install("remotes") # {remotes}がインストールされていない場合
remotes::install_github("JaehyunSong/PRcalc")
```

---

## 使い方

### データセット

```r
# 2019年参院選
data("jp_upper_2019")
jp_upper_2019
```

```
##       Party     Vote
## 1      自民 17712373
## 2      公明  6536336
## 3      立憲  7917721
## 4      維新  4907844
## 5      共産  4483411
## 6      国民  3481078
## 7    れいわ  2280253
## 8      社民  1046012
## 9       N国   987885
## 10   安楽死   269052
## 11     幸福   202278
## 12 オリーブ   167897
## 13   労働者    80055
```

```r
# 2021年衆院選
data("jp_lower_2021")
jp_lower_2021
```

```
##     Party Hokkaido  Tohoku Kitakanto Minamikanto   Tokyo Hokuriku   Tokai
## 1    自民   863300 1628233   2172065     2590787 2000084  1468380 2515841
## 2    公明   294371  456287    823930      850667  715450   322535  784976
## 3    立憲   682913  991505   1391149     1651562 1293281   773076 1485947
## 4    共産   207189  292830    444115      534493  670340   225551  408606
## 5    維新   215344  258690    617531      863897  858577   361476  694630
## 6    国民    73621  195754    298056      384482  306180   133600  382734
## 7    社民    41248  101442     97963      124447   92995    71185   84220
## 8    れ新   102086  143265    239592      302675  360387   111281  273208
## 9     N党    42916   52664     87702      111298   92353    43529   98238
## 10 支なし    46142       0         0           0       0        0       0
## 11   第一        0       0         0           0   33661        0       0
## 12 やまと        0       0         0           0   16970        0       0
## 13 コロナ        0       0         0           0    6620        0       0
##      Kinki Chugoku Shikoku  Kyushu
## 1  2407699 1352723  664805 2250966
## 2  1155683  436220  233407 1040756
## 3  1090666  573324  291871 1266801
## 4   736156  173117  108021  365658
## 5  3180219  286302  173826  540338
## 6   303480  113899  122082  279509
## 7   100980   52638   30249  221221
## 8   292483   94446   52941  243284
## 9   111539   36758   21285   98506
## 10       0       0       0       0
## 11       0       0       0       0
## 12       0       0       0       0
## 13       0       0       0       0
```

### `prcalc()`：議席配分

#### 計算

```r
obj1 <- prcalc(jp_upper_2019, m = 50, method = "dt")
obj1
```

```
## Raw:
##       Party     Vote
## 1      自民 17712373
## 2      公明  6536336
## 3      立憲  7917721
## 4      維新  4907844
## 5      共産  4483411
## 6      国民  3481078
## 7    れいわ  2280253
## 8      社民  1046012
## 9       N国   987885
## 10   安楽死   269052
## 11     幸福   202278
## 12 オリーブ   167897
## 13   労働者    80055
## 
## Result:
##       Party Vote
## 1      自民   18
## 2      公明    7
## 3      立憲    8
## 4      維新    5
## 5      共産    5
## 6      国民    3
## 7    れいわ    2
## 8      社民    1
## 9       N国    1
## 10   安楽死    0
## 11     幸福    0
## 12 オリーブ    0
## 13   労働者    0
## 
## Parameters:
##   Allocation method: D'Hondt (Jefferson) method 
##   Extra parameter: 
##   Threshold: 0 
## 
## Magnitude: 50
```

```r
obj2 <- prcalc(jp_lower_2021, 
               m = c(8, 13, 19, 22, 17, 11, 21, 28, 11, 6, 20), 
               method = "dt")
obj2
```

```
## Raw:
##     Party Hokkaido  Tohoku Kitakanto Minamikanto   Tokyo Hokuriku   Tokai
## 1    自民   863300 1628233   2172065     2590787 2000084  1468380 2515841
## 2    公明   294371  456287    823930      850667  715450   322535  784976
## 3    立憲   682913  991505   1391149     1651562 1293281   773076 1485947
## 4    共産   207189  292830    444115      534493  670340   225551  408606
## 5    維新   215344  258690    617531      863897  858577   361476  694630
## 6    国民    73621  195754    298056      384482  306180   133600  382734
## 7    社民    41248  101442     97963      124447   92995    71185   84220
## 8    れ新   102086  143265    239592      302675  360387   111281  273208
## 9     N党    42916   52664     87702      111298   92353    43529   98238
## 10 支なし    46142       0         0           0       0        0       0
## 11   第一        0       0         0           0   33661        0       0
## 12 やまと        0       0         0           0   16970        0       0
## 13 コロナ        0       0         0           0    6620        0       0
##      Kinki Chugoku Shikoku  Kyushu    Total
## 1  2407699 1352723  664805 2250966 19914883
## 2  1155683  436220  233407 1040756  7114282
## 3  1090666  573324  291871 1266801 11492095
## 4   736156  173117  108021  365658  4166076
## 5  3180219  286302  173826  540338  8050830
## 6   303480  113899  122082  279509  2593397
## 7   100980   52638   30249  221221  1018588
## 8   292483   94446   52941  243284  2215648
## 9   111539   36758   21285   98506   796788
## 10       0       0       0       0    46142
## 11       0       0       0       0    33661
## 12       0       0       0       0    16970
## 13       0       0       0       0     6620
## 
## Result:
##     Party Hokkaido Tohoku Kitakanto Minamikanto Tokyo Hokuriku Tokai Kinki
## 1    自民        3      6         7           8     6        5     8     8
## 2    公明        1      1         3           3     2        1     3     3
## 3    立憲        3      4         5           5     4        3     5     3
## 4    共産        0      1         1           1     2        1     1     2
## 5    維新        1      1         2           3     2        1     2    10
## 6    国民        0      0         1           1     0        0     1     1
## 7    社民        0      0         0           0     0        0     0     0
## 8    れ新        0      0         0           1     1        0     1     1
## 9     N党        0      0         0           0     0        0     0     0
## 10 支なし        0      0         0           0     0        0     0     0
## 11   第一        0      0         0           0     0        0     0     0
## 12 やまと        0      0         0           0     0        0     0     0
## 13 コロナ        0      0         0           0     0        0     0     0
##    Chugoku Shikoku Kyushu Total
## 1        5       3      8    67
## 2        2       1      4    24
## 3        3       1      4    40
## 4        0       0      1    10
## 5        1       1      2    26
## 6        0       0      1     5
## 7        0       0      0     0
## 8        0       0      0     4
## 9        0       0      0     0
## 10       0       0      0     0
## 11       0       0      0     0
## 12       0       0      0     0
## 13       0       0      0     0
## 
## Parameters:
##   Allocation method: D'Hondt (Jefferson) method 
##   Extra parameter: 
##   Threshold: 0 
## 
## Magnitude: 
##    Hokkaido      Tohoku   Kitakanto Minamikanto       Tokyo    Hokuriku 
##           8          13          19          22          17          11 
##       Tokai       Kinki     Chugoku     Shikoku      Kyushu 
##          21          28          11           6          20
```

#### 出力

```r
obj3 <- prcalc(jp_lower_2021, 
               m = c(8, 13, 19, 22, 17, 11, 21, 28, 11, 6, 20), 
               method = "hare")

print(obj3, show_total = FALSE) # Total列の除外
```

```
## Raw:
##     Party Hokkaido  Tohoku Kitakanto Minamikanto   Tokyo Hokuriku   Tokai
## 1    自民   863300 1628233   2172065     2590787 2000084  1468380 2515841
## 2    公明   294371  456287    823930      850667  715450   322535  784976
## 3    立憲   682913  991505   1391149     1651562 1293281   773076 1485947
## 4    共産   207189  292830    444115      534493  670340   225551  408606
## 5    維新   215344  258690    617531      863897  858577   361476  694630
## 6    国民    73621  195754    298056      384482  306180   133600  382734
## 7    社民    41248  101442     97963      124447   92995    71185   84220
## 8    れ新   102086  143265    239592      302675  360387   111281  273208
## 9     N党    42916   52664     87702      111298   92353    43529   98238
## 10 支なし    46142       0         0           0       0        0       0
## 11   第一        0       0         0           0   33661        0       0
## 12 やまと        0       0         0           0   16970        0       0
## 13 コロナ        0       0         0           0    6620        0       0
##      Kinki Chugoku Shikoku  Kyushu
## 1  2407699 1352723  664805 2250966
## 2  1155683  436220  233407 1040756
## 3  1090666  573324  291871 1266801
## 4   736156  173117  108021  365658
## 5  3180219  286302  173826  540338
## 6   303480  113899  122082  279509
## 7   100980   52638   30249  221221
## 8   292483   94446   52941  243284
## 9   111539   36758   21285   98506
## 10       0       0       0       0
## 11       0       0       0       0
## 12       0       0       0       0
## 13       0       0       0       0
## 
## Result:
##     Party Hokkaido Tohoku Kitakanto Minamikanto Tokyo Hokuriku Tokai Kinki
## 1    自民        3      5         7           8     5        5     8     7
## 2    公明        1      1         3           2     2        1     3     4
## 3    立憲        2      3         4           5     4        3     5     3
## 4    共産        1      1         1           2     2        1     1     2
## 5    維新        1      1         2           3     2        1     2    10
## 6    国民        0      1         1           1     1        0     1     1
## 7    社民        0      0         0           0     0        0     0     0
## 8    れ新        0      1         1           1     1        0     1     1
## 9     N党        0      0         0           0     0        0     0     0
## 10 支なし        0      0         0           0     0        0     0     0
## 11   第一        0      0         0           0     0        0     0     0
## 12 やまと        0      0         0           0     0        0     0     0
## 13 コロナ        0      0         0           0     0        0     0     0
##    Chugoku Shikoku Kyushu
## 1        5       2      7
## 2        2       1      3
## 3        2       1      4
## 4        1       0      1
## 5        1       1      2
## 6        0       1      1
## 7        0       0      1
## 8        0       0      1
## 9        0       0      0
## 10       0       0      0
## 11       0       0      0
## 12       0       0      0
## 13       0       0      0
## 
## Parameters:
##   Allocation method: Hare-Niemeyer quota 
##   Extra parameter: 
##   Threshold: 0 
## 
## Magnitude: 
##    Hokkaido      Tohoku   Kitakanto Minamikanto       Tokyo    Hokuriku 
##           8          13          19          22          17          11 
##       Tokai       Kinki     Chugoku     Shikoku      Kyushu 
##          21          28          11           6          20
```

```r
print(obj3, prop = TRUE) # 割合で出力
```

```
## Raw:
##     Party Hokkaido Tohoku Kitakanto Minamikanto   Tokyo Hokuriku  Tokai  Kinki
## 1    自民   0.3360 0.3951    0.3519      0.3494 0.31024   0.4183 0.3739 0.2567
## 2    公明   0.1146 0.1107    0.1335      0.1147 0.11098   0.0919 0.1167 0.1232
## 3    立憲   0.2658 0.2406    0.2254      0.2228 0.20061   0.2202 0.2208 0.1163
## 4    共産   0.0806 0.0711    0.0720      0.0721 0.10398   0.0642 0.0607 0.0785
## 5    維新   0.0838 0.0628    0.1001      0.1165 0.13318   0.1030 0.1032 0.3391
## 6    国民   0.0287 0.0475    0.0483      0.0519 0.04749   0.0381 0.0569 0.0324
## 7    社民   0.0161 0.0246    0.0159      0.0168 0.01442   0.0203 0.0125 0.0108
## 8    れ新   0.0397 0.0348    0.0388      0.0408 0.05590   0.0317 0.0406 0.0312
## 9     N党   0.0167 0.0128    0.0142      0.0150 0.01433   0.0124 0.0146 0.0119
## 10 支なし   0.0180 0.0000    0.0000      0.0000 0.00000   0.0000 0.0000 0.0000
## 11   第一   0.0000 0.0000    0.0000      0.0000 0.00522   0.0000 0.0000 0.0000
## 12 やまと   0.0000 0.0000    0.0000      0.0000 0.00263   0.0000 0.0000 0.0000
## 13 コロナ   0.0000 0.0000    0.0000      0.0000 0.00103   0.0000 0.0000 0.0000
##    Chugoku Shikoku Kyushu    Total
## 1   0.4336  0.3914 0.3569 0.346551
## 2   0.1398  0.1374 0.1650 0.123800
## 3   0.1838  0.1718 0.2009 0.199981
## 4   0.0555  0.0636 0.0580 0.072496
## 5   0.0918  0.1023 0.0857 0.140097
## 6   0.0365  0.0719 0.0443 0.045129
## 7   0.0169  0.0178 0.0351 0.017725
## 8   0.0303  0.0312 0.0386 0.038556
## 9   0.0118  0.0125 0.0156 0.013865
## 10  0.0000  0.0000 0.0000 0.000803
## 11  0.0000  0.0000 0.0000 0.000586
## 12  0.0000  0.0000 0.0000 0.000295
## 13  0.0000  0.0000 0.0000 0.000115
## 
## Result:
##     Party Hokkaido Tohoku Kitakanto Minamikanto  Tokyo Hokuriku  Tokai  Kinki
## 1    自民    0.375 0.3846    0.3684      0.3636 0.2941   0.4545 0.3810 0.2500
## 2    公明    0.125 0.0769    0.1579      0.0909 0.1176   0.0909 0.1429 0.1429
## 3    立憲    0.250 0.2308    0.2105      0.2273 0.2353   0.2727 0.2381 0.1071
## 4    共産    0.125 0.0769    0.0526      0.0909 0.1176   0.0909 0.0476 0.0714
## 5    維新    0.125 0.0769    0.1053      0.1364 0.1176   0.0909 0.0952 0.3571
## 6    国民    0.000 0.0769    0.0526      0.0455 0.0588   0.0000 0.0476 0.0357
## 7    社民    0.000 0.0000    0.0000      0.0000 0.0000   0.0000 0.0000 0.0000
## 8    れ新    0.000 0.0769    0.0526      0.0455 0.0588   0.0000 0.0476 0.0357
## 9     N党    0.000 0.0000    0.0000      0.0000 0.0000   0.0000 0.0000 0.0000
## 10 支なし    0.000 0.0000    0.0000      0.0000 0.0000   0.0000 0.0000 0.0000
## 11   第一    0.000 0.0000    0.0000      0.0000 0.0000   0.0000 0.0000 0.0000
## 12 やまと    0.000 0.0000    0.0000      0.0000 0.0000   0.0000 0.0000 0.0000
## 13 コロナ    0.000 0.0000    0.0000      0.0000 0.0000   0.0000 0.0000 0.0000
##    Chugoku Shikoku Kyushu   Total
## 1   0.4545   0.333   0.35 0.35227
## 2   0.1818   0.167   0.15 0.13068
## 3   0.1818   0.167   0.20 0.20455
## 4   0.0909   0.000   0.05 0.07386
## 5   0.0909   0.167   0.10 0.14773
## 6   0.0000   0.167   0.05 0.04545
## 7   0.0000   0.000   0.05 0.00568
## 8   0.0000   0.000   0.05 0.03977
## 9   0.0000   0.000   0.00 0.00000
## 10  0.0000   0.000   0.00 0.00000
## 11  0.0000   0.000   0.00 0.00000
## 12  0.0000   0.000   0.00 0.00000
## 13  0.0000   0.000   0.00 0.00000
## 
## Parameters:
##   Allocation method: Hare-Niemeyer quota 
##   Extra parameter: 
##   Threshold: 0 
## 
## Magnitude: 
##    Hokkaido      Tohoku   Kitakanto Minamikanto       Tokyo    Hokuriku 
##           8          13          19          22          17          11 
##       Tokai       Kinki     Chugoku     Shikoku      Kyushu 
##          21          28          11           6          20
```

```r
summary(obj3) # 要約
```

```
##     Party      Raw Dist
## 1    自民 19914883   62
## 2    公明  7114282   23
## 3    立憲 11492095   36
## 4    共産  4166076   13
## 5    維新  8050830   26
## 6    国民  2593397    8
## 7    社民  1018588    1
## 8    れ新  2215648    7
## 9     N党   796788    0
## 10 支なし    46142    0
## 11   第一    33661    0
## 12 やまと    16970    0
## 13 コロナ     6620    0
```

```r
summary(obj3, prop = TRUE) # 要約（割合）
```

```
##     Party      Raw    Dist
## 1    自民 0.346551 0.35227
## 2    公明 0.123800 0.13068
## 3    立憲 0.199981 0.20455
## 4    共産 0.072496 0.07386
## 5    維新 0.140097 0.14773
## 6    国民 0.045129 0.04545
## 7    社民 0.017725 0.00568
## 8    れ新 0.038556 0.03977
## 9     N党 0.013865 0.00000
## 10 支なし 0.000803 0.00000
## 11   第一 0.000586 0.00000
## 12 やまと 0.000295 0.00000
## 13 コロナ 0.000115 0.00000
```

#### 可視化

```r
plot(obj1)
```

```r
plot(obj2)
```

```r
# 自民、公明、立憲、維新、共産、国民のみ
plot(obj2, 
     subset_p = c("自民", "公明", "立憲", "維新", "共産", "国民"))
```

```r
# 東京、近畿のみ
plot(obj2, 
     subset_p = c("自民", "公明", "立憲", "維新", "共産", "国民"),
     subset_b = c("Tokyo", "Kinki")) 
```

```r
# 政党でfacet分け
plot(obj2, 
     subset_p  = c("自民", "公明", "立憲", "維新", "共産", "国民"),
     subset_b = c("Tokyo", "Kinki"),
     by        = "party")
```

```r
# 3列構成
plot(obj2, 
     subset_p  = c("自民", "公明", "立憲", "維新", "共産", "国民"),
     subset_b = c("Tokyo", "Kinki"),
     by        = "party",
     facet_col = 3)
```

```r
# facetごとに異なるy軸スケールを使用
plot(obj2, 
     subset_p  = c("自民", "公明", "立憲", "維新", "共産", "国民"),
     subset_b  = c("Tokyo", "Kinki"),
     by        = "party",
     facet_col = 3,
     free_y    = TRUE)
```

### `index()`：各種指標

#### 計算

```r
obj2_index1 <- index(obj2)
obj2_index1
```

```
##             ID                         Index    Value
## 1       dhondt                       D’Hondt  1.13647
## 2       monroe                        Monroe  0.05321
## 3       maxdev    Maximum Absolute Deviation  0.03413
## 4          rae                           Rae  0.16323
## 5           lh             Loosemore & Hanby  0.08162
## 6      grofman                       Grofman  0.03943
## 7     lijphart                      Lijphart  0.03071
## 8    gallagher                     Gallagher  0.04129
## 9  g_gallagher         Generalized Gallagher  0.04129
## 10       gatev                         Gatev  0.08744
## 11    ryabtsev                      Ryabtsev  0.06195
## 12      szalai                        Szalai  2.47839
## 13    w_szalai               Weighted Szalai  0.15384
## 14          ap          Aleskerov & Platonov  1.09773
## 15        gini               Atkinson (Gini)  1.00000
## 16     entropy           Generalized Entropy  0.02912
## 17          sl                  Sainte-Laguë  0.05825
## 18          cs                 Cox & Shugart  1.13266
## 19      farina                        Farina  0.10153
## 20      ortona                        Ortona  0.12490
## 21   fragnelli                     Fragnelli  0.00000
## 22          gb           Gambarelli & Biella  0.00000
## 23          cd          Cosine Dissimilarity  0.00417
## 24          rr Lebeda’s RR (Mixture D’Hondt)  0.12008
## 25         arr                  Lebeda’s ARR  0.87992
## 26         srr                  Lebeda’s SRR  0.04488
## 27        wdrr                 Lebeda’s WDRR  0.09444
## 28          kl     Kullback-Leibler Surprise  0.04684
## 29          lr    Likelihood Ratio Statistic -0.03720
## 30       chisq                   Chi Squared  0.03308
## 31   hellinger            Hellinger Distance  0.14218
## 32          ad              alpha-Divergence  0.04582
```

```r
obj2_index2 <- index(obj2, alpha = 1) # alpha-divergenceのalphaを1に
obj2_index2
```

```
##             ID                         Index    Value
## 1       dhondt                       D’Hondt  1.13647
## 2       monroe                        Monroe  0.05321
## 3       maxdev    Maximum Absolute Deviation  0.03413
## 4          rae                           Rae  0.16323
## 5           lh             Loosemore & Hanby  0.08162
## 6      grofman                       Grofman  0.03943
## 7     lijphart                      Lijphart  0.03071
## 8    gallagher                     Gallagher  0.04129
## 9  g_gallagher         Generalized Gallagher  0.04129
## 10       gatev                         Gatev  0.08744
## 11    ryabtsev                      Ryabtsev  0.06195
## 12      szalai                        Szalai  2.47839
## 13    w_szalai               Weighted Szalai  0.15384
## 14          ap          Aleskerov & Platonov  1.09773
## 15        gini               Atkinson (Gini)  1.00000
## 16     entropy           Generalized Entropy      NaN
## 17          sl                  Sainte-Laguë  0.05825
## 18          cs                 Cox & Shugart  1.13266
## 19      farina                        Farina  0.10153
## 20      ortona                        Ortona  0.12490
## 21   fragnelli                     Fragnelli  0.00000
## 22          gb           Gambarelli & Biella  0.00000
## 23          cd          Cosine Dissimilarity  0.00417
## 24          rr Lebeda’s RR (Mixture D’Hondt)  0.12008
## 25         arr                  Lebeda’s ARR  0.87992
## 26         srr                  Lebeda’s SRR  0.04488
## 27        wdrr                 Lebeda’s WDRR  0.09444
## 28          kl     Kullback-Leibler Surprise  0.04684
## 29          lr    Likelihood Ratio Statistic -0.03720
## 30       chisq                   Chi Squared  0.03308
## 31   hellinger            Hellinger Distance  0.14218
## 32          ad              alpha-Divergence  0.04684
```

#### 出力

```r
# 一部の指標のみ抽出
print(obj2_index1, subset = c("dhondt", "gallagher", "lh", "ad"))
```

```
##          ID             Index  Value
## 1    dhondt           D’Hondt 1.1365
## 2        lh Loosemore & Hanby 0.0816
## 3 gallagher         Gallagher 0.0413
## 4        ad  alpha-Divergence 0.0458
```

```r
# ID列を隠す
print(obj2_index1, 
      subset  = c("dhondt", "gallagher", "lh", "ad"),
      hide_id = TRUE)
```

```
##               Index  Value
## 1           D’Hondt 1.1365
## 2 Loosemore & Hanby 0.0816
## 3         Gallagher 0.0413
## 4  alpha-Divergence 0.0458
```

```r
# 表で出力
print(obj2_index2, 
      subset  = c("dhondt", "gallagher", "lh", "ad"),
      hide_id = TRUE,
      use_gt  = TRUE)
```

| Index | Value |
|:------|------:|
|D’Hondt|1.136|
|Loosemore & Hanby|0.082|
|Gallagher|0.041|
|alpha-Divergence|0.047|

#### 可視化

```r
plot(obj2_index2)
```

```r
plot(obj2_index2, style = "lollipop") # ロリポップ
```

```r
plot(obj2_index2, 
     index = c("dhondt", "gallagher", "lh", "ad"))
```

### `decompose()`：分解

明日から頑張る

### `compare()`：比較

#### 配分結果の比較

```r
obj4 <- prcalc(jp_lower_2021, 
               m = c(8, 13, 19, 22, 17, 11, 21, 28, 11, 6, 20), 
               method = "sl")

compare(list(obj2, obj3))
```

```
##     Party Model1 Model2
## 1    自民     67     62
## 2    公明     24     23
## 3    立憲     40     36
## 4    共産     10     13
## 5    維新     26     26
## 6    国民      5      8
## 7    社民      0      1
## 8    れ新      4      7
## 9     N党      0      0
## 10 支なし      0      0
## 11   第一      0      0
## 12 やまと      0      0
## 13 コロナ      0      0
```

```r
# モデルに名前を付ける
compare(list("ドント式" = obj2, "ヘア式" = obj3, "サン＝ラゲ式" = obj4)) 
```

```
##     Party ドント式 ヘア式 サン＝ラゲ式
## 1    自民       67     62           63
## 2    公明       24     23           24
## 3    立憲       40     36           36
## 4    共産       10     13           13
## 5    維新       26     26           26
## 6    国民        5      8            7
## 7    社民        0      1            1
## 8    れ新        4      7            6
## 9     N党        0      0            0
## 10 支なし        0      0            0
## 11   第一        0      0            0
## 12 やまと        0      0            0
## 13 コロナ        0      0            0
```

```r
# 可視化
compare(list("ドント式" = obj2, "ヘア式" = obj3, "サン＝ラゲ式" = obj4)) |> 
  plot()
```

```r
# 政党ごとにfacet分割
compare(list("ドント式" = obj2, "ヘア式" = obj3, "サン＝ラゲ式" = obj4)) |> 
  plot(facet = TRUE)
```

```r
# 3列構成 + y軸スケール固定
compare(list("ドント式" = obj2, "ヘア式" = obj3, "サン＝ラゲ式" = obj4)) |> 
  plot(facet = TRUE, facet_col = 3, free_y = FALSE)
```

#### 指標の比較

```r
compare(list(index(obj2), index(obj3), index(obj4)))
```

```
##             ID                         Index   Model1    Model2   Model3
## 1       dhondt                       D’Hondt  1.13647  1.055589  1.10148
## 2       monroe                        Monroe  0.05321  0.020396  0.02505
## 3       maxdev    Maximum Absolute Deviation  0.03413  0.013865  0.01387
## 4          rae                           Rae  0.16323  0.055416  0.07506
## 5           lh             Loosemore & Hanby  0.08162  0.027708  0.03753
## 6      grofman                       Grofman  0.03943  0.011857  0.01641
## 7     lijphart                      Lijphart  0.03071  0.005143  0.00798
## 8    gallagher                     Gallagher  0.04129  0.015827  0.01944
## 9  g_gallagher         Generalized Gallagher  0.04129  0.015827  0.01944
## 10       gatev                         Gatev  0.08744  0.034607  0.04227
## 11    ryabtsev                      Ryabtsev  0.06195  0.024478  0.02990
## 12      szalai                        Szalai  2.47839  2.294929  2.29695
## 13    w_szalai               Weighted Szalai  0.15384  0.105784  0.10847
## 14          ap          Aleskerov & Platonov  1.09773  1.029574  1.04611
## 15        gini               Atkinson (Gini)  1.00000  1.000000  1.00000
## 16     entropy           Generalized Entropy  0.02912  0.012455  0.01360
## 17          sl                  Sainte-Laguë  0.05825  0.024911  0.02720
## 18          cs                 Cox & Shugart  1.13266  1.035874  1.05312
## 19      farina                        Farina  0.10153  0.047980  0.05482
## 20      ortona                        Ortona  0.12490  0.042402  0.05743
## 21   fragnelli                     Fragnelli  0.00000  0.000000  0.00000
## 22          gb           Gambarelli & Biella  0.00000  0.000000  0.00000
## 23          cd          Cosine Dissimilarity  0.00417  0.000932  0.00122
## 24          rr Lebeda’s RR (Mixture D’Hondt)  0.12008  0.052662  0.09213
## 25         arr                  Lebeda’s ARR  0.87992  0.947338  0.90787
## 26         srr                  Lebeda’s SRR  0.04488  0.023669  0.03500
## 27        wdrr                 Lebeda’s WDRR  0.09444  0.036026  0.05573
## 28          kl     Kullback-Leibler Surprise  0.04684  0.021767  0.02292
## 29          lr    Likelihood Ratio Statistic -0.03720 -0.014052 -0.01174
## 30       chisq                   Chi Squared  0.03308  0.026543  0.02888
## 31   hellinger            Hellinger Distance  0.14218  0.098133  0.09959
## 32          ad              alpha-Divergence  0.04582  0.020288  0.02143
```

```r
compare(list("ドント式"     = index(obj2), 
             "ヘア式"       = index(obj3), 
             "サン＝ラゲ式"  = index(obj4)))
```

```
##             ID                         Index ドント式    ヘア式 サン＝ラゲ式
## 1       dhondt                       D’Hondt  1.13647  1.055589      1.10148
## 2       monroe                        Monroe  0.05321  0.020396      0.02505
## 3       maxdev    Maximum Absolute Deviation  0.03413  0.013865      0.01387
## 4          rae                           Rae  0.16323  0.055416      0.07506
## 5           lh             Loosemore & Hanby  0.08162  0.027708      0.03753
## 6      grofman                       Grofman  0.03943  0.011857      0.01641
## 7     lijphart                      Lijphart  0.03071  0.005143      0.00798
## 8    gallagher                     Gallagher  0.04129  0.015827      0.01944
## 9  g_gallagher         Generalized Gallagher  0.04129  0.015827      0.01944
## 10       gatev                         Gatev  0.08744  0.034607      0.04227
## 11    ryabtsev                      Ryabtsev  0.06195  0.024478      0.02990
## 12      szalai                        Szalai  2.47839  2.294929      2.29695
## 13    w_szalai               Weighted Szalai  0.15384  0.105784      0.10847
## 14          ap          Aleskerov & Platonov  1.09773  1.029574      1.04611
## 15        gini               Atkinson (Gini)  1.00000  1.000000      1.00000
## 16     entropy           Generalized Entropy  0.02912  0.012455      0.01360
## 17          sl                  Sainte-Laguë  0.05825  0.024911      0.02720
## 18          cs                 Cox & Shugart  1.13266  1.035874      1.05312
## 19      farina                        Farina  0.10153  0.047980      0.05482
## 20      ortona                        Ortona  0.12490  0.042402      0.05743
## 21   fragnelli                     Fragnelli  0.00000  0.000000      0.00000
## 22          gb           Gambarelli & Biella  0.00000  0.000000      0.00000
## 23          cd          Cosine Dissimilarity  0.00417  0.000932      0.00122
## 24          rr Lebeda’s RR (Mixture D’Hondt)  0.12008  0.052662      0.09213
## 25         arr                  Lebeda’s ARR  0.87992  0.947338      0.90787
## 26         srr                  Lebeda’s SRR  0.04488  0.023669      0.03500
## 27        wdrr                 Lebeda’s WDRR  0.09444  0.036026      0.05573
## 28          kl     Kullback-Leibler Surprise  0.04684  0.021767      0.02292
## 29          lr    Likelihood Ratio Statistic -0.03720 -0.014052     -0.01174
## 30       chisq                   Chi Squared  0.03308  0.026543      0.02888
## 31   hellinger            Hellinger Distance  0.14218  0.098133      0.09959
## 32          ad              alpha-Divergence  0.04582  0.020288      0.02143
```

```r
compare(list("ドント式"     = index(obj2), 
             "ヘア式"       = index(obj3), 
             "サン＝ラゲ式"  = index(obj4))) |> 
  print(hide_id = TRUE)
```

```
##                            Index ドント式    ヘア式 サン＝ラゲ式
## 1                        D’Hondt  1.13647  1.055589      1.10148
## 2                         Monroe  0.05321  0.020396      0.02505
## 3     Maximum Absolute Deviation  0.03413  0.013865      0.01387
## 4                            Rae  0.16323  0.055416      0.07506
## 5              Loosemore & Hanby  0.08162  0.027708      0.03753
## 6                        Grofman  0.03943  0.011857      0.01641
## 7                       Lijphart  0.03071  0.005143      0.00798
## 8                      Gallagher  0.04129  0.015827      0.01944
## 9          Generalized Gallagher  0.04129  0.015827      0.01944
## 10                         Gatev  0.08744  0.034607      0.04227
## 11                      Ryabtsev  0.06195  0.024478      0.02990
## 12                        Szalai  2.47839  2.294929      2.29695
## 13               Weighted Szalai  0.15384  0.105784      0.10847
## 14          Aleskerov & Platonov  1.09773  1.029574      1.04611
## 15               Atkinson (Gini)  1.00000  1.000000      1.00000
## 16           Generalized Entropy  0.02912  0.012455      0.01360
## 17                  Sainte-Laguë  0.05825  0.024911      0.02720
## 18                 Cox & Shugart  1.13266  1.035874      1.05312
## 19                        Farina  0.10153  0.047980      0.05482
## 20                        Ortona  0.12490  0.042402      0.05743
## 21                     Fragnelli  0.00000  0.000000      0.00000
## 22           Gambarelli & Biella  0.00000  0.000000      0.00000
## 23          Cosine Dissimilarity  0.00417  0.000932      0.00122
## 24 Lebeda’s RR (Mixture D’Hondt)  0.12008  0.052662      0.09213
## 25                  Lebeda’s ARR  0.87992  0.947338      0.90787
## 26                  Lebeda’s SRR  0.04488  0.023669      0.03500
## 27                 Lebeda’s WDRR  0.09444  0.036026      0.05573
## 28     Kullback-Leibler Surprise  0.04684  0.021767      0.02292
## 29    Likelihood Ratio Statistic -0.03720 -0.014052     -0.01174
## 30                   Chi Squared  0.03308  0.026543      0.02888
## 31            Hellinger Distance  0.14218  0.098133      0.09959
## 32              alpha-Divergence  0.04582  0.020288      0.02143
```

```r
compare(list("ドント式"     = index(obj2), 
             "ヘア式"       = index(obj3), 
             "サン＝ラゲ式"  = index(obj4))) |> 
  print(subset  = c("dhondt", "gallagher", "lh", "ad"),
        hide_id = TRUE,
        use_gt  = TRUE)
```

```
Index 	ドント式 	ヘア式 	サン＝ラゲ式
D’Hondt 	1.136 	1.056 	1.101
Loosemore & Hanby 	0.082 	0.028 	0.038
Gallagher 	0.041 	0.016 	0.019
alpha-Divergence 	0.046 	0.020 	0.021
```

```r
compare(list("ドント式"     = index(obj2), 
             "ヘア式"       = index(obj3), 
             "サン＝ラゲ式"  = index(obj4))) |> 
  plot() +
  ggplot2::labs(x = "値", y = "指標", fill = "割当方式")
```