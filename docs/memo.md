## Memo

重要度は現時点での重要度

* ドキュメント、ヘルプの整備が重要でないということではなく、現時点では重要でないとのこと。中身が安定し、公開プロセスに移行するならデバッグと共に最重要事項となる。

### 重要度：高

* 引き続き、バグおよび計算間違いの検証
* `read_prcalc()`、`as_prcalc()`の引数名を修正
  * `region` $\rightarrow$ `level1` (or `l1`)
    * Mandatory
  * `district` $\rightarrow$ `levle2` (or `l2`)
    * Optional (全国区などの場合は不要)
  * `population` $\rightarrow$ `p`
  * `magnitude` $\rightarrow$ `q`
  * `district_name` $\rightarrow$ `l2_type = c("party", "district")` 
* 新しいサンプルデータ（政党連合のデータ）

### 重要度：中

* `plot()`メソッドを洗練させる

### 重要度：低

* コードをメンテナンスしやすく
* 各種ドキュメント（ヘルプ、ウェブページ）の整備
   * Referenceも相当あるので明記する。
