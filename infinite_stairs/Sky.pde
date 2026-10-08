// =================================
//  Sky.pde  空(グラデーションと星)
// =================================
// 登った高さに合わせて、背景の空の色を変えるクラス。
// 星の位置もここで持つ。
class Sky {
  // 星それぞれの 位置x・位置y・大きさ・またたきのタイミング
  // (配列は、同じ番号の要素が同じ星のデータになる。例: starX[3] と starY[3] は3番目の星)
  float[] starX, starY, starSize, starPhase;

  // ---- コンストラクタ: new Sky() と書いたときに1回だけ呼ばれ、星の位置をランダムに決める ----
  Sky() {
    // 配列は、使う前に「何個入れるか」を決めて作る必要がある
    starX = new float[STAR_COUNT];
    starY = new float[STAR_COUNT];
    starSize = new float[STAR_COUNT];
    starPhase = new float[STAR_COUNT];
    // i を 0 から STAR_COUNT-1 まで1ずつ増やしながら、星を1つずつ設定する
    for (int i = 0; i < STAR_COUNT; i++) {
      starX[i] = random(width);        // 横の位置: 0〜画面の幅 のランダム
      starY[i] = random(height);       // 縦の位置: 0〜画面の高さ のランダム
      starSize[i] = random(1, 3);      // 大きさ: 1〜3 のランダム
      starPhase[i] = random(TWO_PI);   // またたきのタイミングのずれ: 0〜2π のランダム
    }
  }

  // ---- アバターの足元の高さ y から、「何段目の高さか」を返す(小数あり) ----
  // アバターの表示位置から求めるので、登っている最中も値がなめらかに変わり、空の色も急に変わらない
  // (y は上へ行くほどマイナスなので、符号を逆にして RISE で割ると段数になる)
  float heightOf(float y) {
    return max(0, -y / RISE);
  }

  // ---- 高さ h に合った色を返す ----
  // cols には SKY_TOP / SKY_MID / SKY_BOTTOM のどれかを渡す。
  // 高さ h がどの場面とどの場面の間にあるかを調べて、その間の色を混ぜて返す。
  int colorAt(float h, int[] cols) {
    if (h <= SKY_AT[0]) return cols[0];                  // いちばん低い場面より下なら、その色をそのまま返す
    for (int i = 1; i < SKY_AT.length; i++) {            // 場面を低い方から順に調べる
      if (h <= SKY_AT[i]) {                              // h が i 番目の場面以下なら、「i-1 番目と i 番目の間」にいる
        // t = 2つの場面の間の、どのあたりか(0 = 手前の場面そのもの、1 = 次の場面そのもの)
        float t = (h - SKY_AT[i - 1]) / (float) (SKY_AT[i] - SKY_AT[i - 1]);
        return lerpColor(cols[i - 1], cols[i], t);       // lerpColor は2色を t の割合で混ぜる
      }
    }
    return cols[cols.length - 1];                        // いちばん高い場面を超えたら、最後の色
  }

  // ---- 値 v を 0〜size の範囲に「巻き戻す」 ----
  // 星の位置が画面の外にずれたとき、反対側から出てくるようにするために使う。
  // % は割り算の余り。マイナスの値でも正しく動くように、size を足してもう一度余りを取っている。
  float wrap(float v, float size) {
    return ((v % size) + size) % size;
  }

  // ---- 段の番号の文字色 ----
  // 明るい空では濃い色、暗い空では白に切り替える(高さ75〜150段のあいだに、少しずつ変わる)
  int labelColor(float h) {
    float lt = constrain(map(h, 75, 150, 0, 1), 0, 1);
    return lerpColor(#22304F, #FFFFFF, lt);
  }

  // ---- 空を描く ----
  // h = 今の高さ(段数)、camX / camY = カメラの位置(星の動きに使う)
  void draw(float h, float camX, float camY) {
    int top = colorAt(h, SKY_TOP);              // 今の高さでの、空の上側の色
    int mid = colorAt(h, SKY_MID);              // 同じく、真ん中の色
    int bottom = colorAt(h, SKY_BOTTOM);        // 同じく、下側の色

    // グラデーションは、細い横帯を90本並べて描く(帯ごとに少しずつ色を変える)
    // 上半分は「上の色 → 真ん中の色」、下半分は「真ん中の色 → 下の色」へつなぐ
    int bands = 90;                             // 帯の本数
    float bh = (float) height / bands;          // 帯1本の高さ
    noStroke();                                 // 図形の縁取りを描かない
    for (int i = 0; i < bands; i++) {
      float t = i / (float) (bands - 1);        // 画面の上端が0、下端が1になる位置
      int c;
      if (t < 0.5) {
        c = lerpColor(top, mid, t * 2);         // 上半分: 0〜0.5 を 0〜1 に広げて色を混ぜる
      } else {
        c = lerpColor(mid, bottom, (t - 0.5) * 2);   // 下半分: 0.5〜1 を 0〜1 に広げて色を混ぜる
      }
      fill(c);
      rect(0, i * bh, width, bh + 1);           // 帯を描く。+1 は、帯と帯の間にすき間が出ないようにするため
    }

    drawStars(h, camX, camY);                   // 帯の上に星を重ねる
  }

  // ---- 星を描く ----
  // 高くなるほど見えてくる。カメラの動きよりずっとゆっくり動かして、奥行きを出している(視差)
  void drawStars(float h, float camX, float camY) {
    // 星の明るさ(透明度): 高さが STAR_FADE_START のとき0、STAR_FADE_END のとき255。範囲内に収める
    float a = constrain(map(h, STAR_FADE_START, STAR_FADE_END, 0, 255), 0, 255);
    if (a <= 0) return;                         // まだ見えない高さなら、何も描かずに終わる
    noStroke();
    for (int i = 0; i < STAR_COUNT; i++) {
      // カメラ位置の5%だけ星をずらす(近くの階段より遠くにあるように見える)
      float x = wrap(starX[i] - camX * 0.05, width);
      float y = wrap(starY[i] - camY * 0.05, height);
      // またたき: sin は -1〜1 を行き来する波。0.6〜1.0 の間で明るさが変わる
      float twinkle = 0.6 + 0.4 * sin(frameCount * (3.0 / FPS) + starPhase[i]);
      fill(255, 255, 255, a * twinkle);         // 白色。4つ目の数値が透明度
      ellipse(x, y, starSize[i], starSize[i]);  // 丸を描く(中心x, 中心y, 横幅, 縦幅)
    }
  }
}
