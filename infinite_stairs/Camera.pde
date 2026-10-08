// ====================
//  Camera.pde  カメラ
// ====================
// 「画面にどこを映すか」を決めるクラス。アバターを少しずつ追いかける。
// x, y は「画面の左上にあたる、世界の座標」。
class Camera {
  float x, y;

  // ---- 最初の位置に合わせる(追いかけず、すぐに目標へ置く) ----
  // 目標は「アバターが画面の横の中央・上から65%の高さに来る位置」
  void reset(float targetX, float targetY) {
    x = targetX - width * 0.5;
    y = targetY - height * 0.65;
  }

  // ---- アバターを追いかける(毎フレーム呼ばれる) ----
  void follow(float targetX, float targetY) {
    // カメラの目標位置: アバターが画面の横の中央・上から65%の高さに来る位置
    float tx = targetX - width * 0.5;
    float ty = targetY - height * 0.65;
    // 「残りの距離の CAMERA_FOLLOW(10%)ぶんだけ進む」を毎フレームくり返す。
    // 最初は速く、近づくほどゆっくりになる、なめらかな動きになる。
    x += (tx - x) * CAMERA_FOLLOW;
    y += (ty - y) * CAMERA_FOLLOW;
  }
}
