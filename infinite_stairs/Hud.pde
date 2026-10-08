// ===============================================================
//  Hud.pde  画面に重ねる表示(スコア、ゲージ、タイトル、リザルト)
// ===============================================================
// 文字やゲージなど、「ゲームの世界」ではなく「画面そのもの」に描くものを担当するクラス。
// 表示に必要な数値は、呼び出すときに引数で受け取る。
class Hud {

  // ---- プレイ中の表示(左上の文字と、右下のゲージ) ----
  // cur = 今の段数、best = 自己ベスト、stamina = スタミナ
  void drawStatus(int cur, int best, Stamina stamina) {
    fill(255);
    textAlign(LEFT, TOP);                       // 文字の基準位置: 左上
    textSize(20);
    text("STEP: " + cur, 16, 12);               // 文字列と数字は + でつなげられる。(文字, x, y)
    textSize(14);
    fill(255, 255, 255, 190);
    text("BEST: " + best, 16, 38);
    textSize(13);
    fill(255, 255, 255, 170);
    text("A / D: Go to the next step (match its direction)   R: Restart   P: Pause", 16, 62);

    drawStaminaGauge(stamina, width - 80, height - 80, 100);   // 右下に円形ゲージを描く
  }

  // ---- 円形のスタミナゲージ ----
  // cx, cy = 円の中心、d = 円の直径。真上から時計回りに描き、減るほど短くなる。
  // 残りが少ないほど 緑 → 黄 → 赤 に変わる
  void drawStaminaGauge(Stamina stamina, float cx, float cy, float d) {
    float ratio = stamina.ratio();              // スタミナの割合(0〜1)

    // 明るい空でも見えるように、暗い半透明の下地を敷く
    noStroke();
    fill(0, 0, 0, 90);
    ellipse(cx, cy, d + 34, d + 34);

    // 土台の輪(薄い白い円。中は塗らず、線だけで描く)
    noFill();
    strokeWeight(12);                           // 線の太さ
    stroke(255, 255, 255, 40);
    ellipse(cx, cy, d, d);

    // 残りのスタミナの円弧。線の色は、残りの割合で緑/黄/赤に切り替わる
    stroke(stamina.statusColor());
    if (ratio > 0) {
      // arc(中心x, 中心y, 横幅, 縦幅, 開始角度, 終了角度)。角度はラジアン(一周 = TWO_PI)
      // -HALF_PI は真上(12時の位置)。そこから ratio の割合ぶんだけ時計回りに描く
      arc(cx, cy, d, d, -HALF_PI, -HALF_PI + TWO_PI * ratio);
    }

    // 中央の表示
    strokeWeight(1);                            // 線の太さを元に戻す
    noStroke();
    fill(255);
    textAlign(CENTER, CENTER);                  // 文字の基準位置: 縦横とも中央
    textSize(24);
    text(ceil(stamina.value), cx, cy - 6);      // ceil は小数点以下の切り上げ(スタミナの数字を整数で表示)
    fill(255, 255, 255, 170);
    textSize(11);
    text("STAMINA", cx, cy + 16);
  }

  // ---- 画面全体を暗くする(半透明の黒い四角を重ねる) ----
  void dim() {
    fill(0, 150);                               // 黒、透明度150
    noStroke();
    rect(0, 0, width, height);
  }

  // ---- ポーズ画面など: 画面を暗くして、大きな題名と小さな説明を出す ----
  void overlay(String title, String sub) {
    dim();
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(48);
    text(title, width / 2, height / 2 - 20);
    textSize(20);
    text(sub, width / 2, height / 2 + 30);
  }

  // ---- タイトル画面 ----
  void drawTitle(int best) {
    dim();
    textAlign(CENTER, CENTER);

    fill(255);
    textSize(64);
    text("INFINITE STAIRS", width / 2, height / 2 - 100);

    fill(255, 255, 255, 190);
    textSize(18);
    text("Press A or D to match the direction of the next step.", width / 2, height / 2 - 35);
    text("A wrong key costs stamina. Keep climbing to recover it.", width / 2, height / 2 - 10);

    fill(255, 200, 60);
    textSize(26);
    text("BEST: " + best, width / 2, height / 2 + 50);

    fill(255);
    textSize(20);
    text("Press ENTER or SPACE to start", width / 2, height / 2 + 105);
  }

  // ---- リザルト画面 ----
  // cur = 今回の段数、best = 自己ベスト、isNewRecord = 自己ベストを更新したか、
  // playFrames = 登り始めてからの経過フレーム数
  void drawResult(int cur, int best, boolean isNewRecord, int playFrames) {
    dim();
    textAlign(CENTER, CENTER);

    fill(255);
    textSize(56);
    text("GAME OVER", width / 2, height / 2 - 130);

    if (isNewRecord) {                          // 自己ベストを更新したときだけ表示
      fill(255, 200, 60);
      textSize(26);
      text("NEW RECORD!", width / 2, height / 2 - 80);
    }

    fill(255);
    textSize(40);
    text("STEP  " + cur, width / 2, height / 2 - 30);

    fill(255, 255, 255, 200);
    textSize(22);
    text("BEST  " + best, width / 2, height / 2 + 15);

    float sec = playFrames / (float) FPS;       // 経過フレーム数を FPS で割ると、秒数になる
    float speed = sec > 0 ? cur / sec : 0;      // 平均の速さ(1秒あたりの段数)。0秒のときは0除算を避けて0にする
    textSize(18);
    // nf(数値, 整数部の桁数, 小数部の桁数) は、数値を決まった桁数の文字にする。ここでは小数1桁
    text("TIME  " + nf(sec, 0, 1) + " s     SPEED  " + nf(speed, 0, 1) + " steps/s", width / 2, height / 2 + 55);

    fill(255);
    textSize(20);
    text("R: Retry     ENTER: Title", width / 2, height / 2 + 110);
  }
}
