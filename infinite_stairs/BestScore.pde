// =======================================================
//  BestScore.pde  自己ベスト(ファイルへの保存と読み込み)
// =======================================================
// 最高到達段数を覚えておき、data フォルダの best.txt に保存するクラス。
class BestScore {
  int value;      // 自己ベストの段数

  // ---- 起動時に呼ばれる。保存されたファイルがあれば読み込む ----
  void load() {
    value = 0;                                        // 先に0にしておく(ファイルがなかったとき用)
    File f = new File(dataPath(BEST_FILE));           // data フォルダの中の best.txt を指す
    if (!f.exists()) return;                          // ファイルがなければ、ここで終わり(0のまま)
    String[] lines = loadStrings(f);                  // ファイルを1行ずつ読み込む
    if (lines != null && lines.length > 0) {
      value = int(trim(lines[0]));                    // 1行目の文字を、空白を取り除いて整数に変換する
    }
  }

  // ---- ファイルに書き込む ----
  void save() {
    saveStrings(dataPath(BEST_FILE), new String[] { str(value) });   // 数字を文字にして、1行のファイルとして保存
  }

  // ---- 今の段数が自己ベストを超えていたら、更新して保存する ----
  // 更新したら true、しなければ false を返す
  boolean record(int step) {
    if (step > value) {
      value = step;
      save();
      return true;
    }
    return false;
  }
}
