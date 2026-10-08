// ======================
//  Stairs.pde  階段全体
// ======================
// 段(Step)をたくさん並べて持ち、「作る」「描く」を担当するクラス。
// 0番目がスタート地点(雲の土台)で、番号が大きいほど高い場所の段になる。
class Stairs {
  // すべての段を入れておくリスト。ArrayList は「必要に応じて増やせる配列」。
  //   list.get(3)   … 3番目の段を取り出す(番号は0から)
  //   list.add(...) … 末尾に段を追加する
  //   list.size()   … 今の段の数
  //   list.clear()  … 全部消す
  ArrayList<Step> list = new ArrayList<Step>();

  // ---- 最初の状態に戻す(新しいゲームを始めるたびに呼ばれる) ----
  void reset() {
    list.clear();                               // 前回の階段を全部消す
    list.add(new Step(55, 0, START_W));         // 0段目(スタート地点)を作る。中心x=55、高さy=0、幅=START_W
    ensure(30);                                 // 30段目まで、ランダムな階段を作っておく
  }

  // ---- 階段を作る ----
  // upto 番目の段まで、左右ランダムに伸びる階段を作っておく。
  // すでに作ってあれば何もしない。必要になるたびに足されるので、階段は無限に続く。
  void ensure(int upto) {
    while (list.size() <= upto) {                       // 段の数が足りない間、くり返す
      Step last = list.get(list.size() - 1);            // いちばん上(最後)の段を取り出す
      float dir = random(1) < 0.5 ? -1 : 1;             // 50%の確率で -1(左) か 1(右) を選ぶ
      // 次の段 = 最後の段から、左右(dir)に PITCH だけずらして、RISE だけ上に置く
      // (上に行くほど y は小さくなるので、RISE を引いている)
      list.add(new Step(last.cx + dir * PITCH, last.y - RISE, TREAD));
    }
  }

  // i 番目の段を返す
  Step get(int i) {
    return list.get(i);
  }

  // ---- i 番目の段から見て、次の段が伸びている向き(1 = 右, -1 = 左) ----
  // これが「正解の向き」になる
  int directionToNext(int i) {
    Step now = list.get(i);                     // 今立っている段
    Step next = list.get(i + 1);                // 次の段
    return next.cx > now.cx ? 1 : -1;           // 次の段が右にあれば 1、左にあれば -1
  }

  // ---- 階段を描く ----
  // cur = 今立っている段の番号、labelCol = 段の番号の文字色
  // (カメラの座標変換をかけたあとに呼ばれる前提)
  void draw(int cur, int labelCol) {
    // 画面に入りそうな範囲(今いる段の20段下〜25段上)の段だけを描く。ぜんぶ描くと重くなるため
    int from = max(0, cur - 20);
    int to = min(list.size() - 1, cur + 25);
    noStroke();
    for (int i = from; i <= to; i++) {
      Step s = list.get(i);                     // i 番目の段を取り出す
      if (i == 0) {
        drawCloudBase(s);                       // 0段目は雲の土台として描く
        continue;                               // continue = 以降の処理を飛ばして、次の段へ進む
      }
      fill(90, 110, 170);
      rect(s.left(), s.y, s.w, THICK);          // 段の本体(四角)。rect(左端x, 上端y, 横幅, 縦幅)
      fill(130, 155, 225);
      rect(s.left(), s.y, s.w, 4);              // 段の上面の明るいライン(高さ4px)
      if (i % 5 == 0) {                         // i を5で割った余りが0 = 5の倍数の段だけ、番号を描く
        fill(labelCol, 170);
        textAlign(CENTER, TOP);                 // 文字の基準位置: 横は中央、縦は上端
        textSize(14);
        text(str(i), s.cx, s.y + THICK + 4);    // 数字を文字にして、段の下に描く
      }
    }
  }

  // ---- スタート地点の土台(雲)を描く ----
  // st は0段目の Step。雲の上面が st.y の高さになるように、丸を重ねて描く
  void drawCloudBase(Step st) {
    float cx = st.cx;
    float y = st.y;
    noStroke();

    // 下側の影(少し青みのある灰色)を先に描く
    fill(190, 205, 235);
    ellipse(cx, y + 34, 230, 34);
    ellipse(cx - 55, y + 40, 80, 32);
    ellipse(cx + 60, y + 38, 90, 34);

    // 本体(白)を、影の上に重ねて描く(あとから描いたものが手前に来る)
    fill(246, 249, 255);
    ellipse(cx, y + 22, 250, 44);
    ellipse(cx - 85, y + 22, 96, 46);
    ellipse(cx + 88, y + 20, 104, 48);
    ellipse(cx - 30, y + 14, 80, 40);
    ellipse(cx + 35, y + 12, 90, 38);
  }
}
