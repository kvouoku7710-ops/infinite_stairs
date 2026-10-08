// =======================
//  Stamina.pde  スタミナ
// =======================
// スタミナの量と、その増減のルールをまとめたクラス。
// 「止まっていると減る」「登ると回復する」「間違えると大きく減る」を、ここで管理する。
class Stamina {
  float value;          // 今のスタミナ(0〜STAMINA_MAX)
  boolean started;      // 最初の1段を登ったら true。それまではスタミナが減らない
  int playFrames;       // 登り始めてからの経過フレーム数(リザルトの時間表示に使う)

  // ---- 最初の状態に戻す ----
  void reset() {
    value = STAMINA_MAX;    // 満タンにする
    started = false;        // まだ登り始めていない
    playFrames = 0;
  }

  // スタミナの割合(0〜1)。ゲージの長さや色の判定に使う
  float ratio() {
    return value / STAMINA_MAX;
  }

  // 残りが4分の1未満なら true(アバターが疲れた様子になる)
  boolean isTired() {
    return ratio() < 0.25;
  }

  // ---- 1段登ったとき ----
  void onClimb() {
    started = true;                                 // 登り始めたので、ここからスタミナが減り始める
    value = min(STAMINA_MAX, value + RECOVER);      // 回復する(最大値は超えない)
  }

  // ---- 向きを間違えたとき ----
  // スタミナが尽きたら true を返す
  boolean onMiss() {
    value -= MISS_PENALTY;
    if (value <= 0) {
      value = 0;
      return true;
    }
    return false;
  }

  // ---- 毎フレームの減少(プレイ中、毎フレーム呼ばれる) ----
  // cur = 今の段数。スタミナが尽きたら true を返す
  boolean update(int cur) {
    if (!started) return false;                     // まだ1段も登っていなければ、減らさずに終わる
    playFrames++;                                   // 経過フレーム数を1増やす
    // 1秒あたりの減少量 = 基本の量 + 段数に比例して増える量(高い段ほど速く減る)
    float decayPerSec = DECAY_BASE + DECAY_PER_STEP * cur;
    // 1フレームぶんの減少量は「1秒あたりの量」を FPS で割ったもの(60回に分けて引く)
    value -= decayPerSec / FPS;
    if (value <= 0) {
      value = 0;
      return true;
    }
    return false;
  }

  // ---- 残りに合わせた色(緑 → 黄 → 赤) ----
  // ゲージとアバターの胸のランプが、同じ基準でこの色を使う
  int statusColor() {
    float r = ratio();
    if (r > 0.5) return color(80, 200, 120);        // 半分より多い: 緑
    if (r > 0.25) return color(240, 190, 60);       // 4分の1より多い: 黄
    return color(230, 80, 80);                      // それ以下: 赤
  }
}
