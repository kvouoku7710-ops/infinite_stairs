// ==============================
//  Avatar.pde  宇宙服のアバター
// ==============================
// アバターの「位置」「向き」「動き」「見た目」を持つクラス。
//
// ゲームの内部では、登った瞬間に「次の段に着いた」ことになる(Game の cur が増える)。
// 画面に出ているアバターの位置(x, y)は、その段に向かって少しずつ近づく。
class Avatar {
  float x, y;           // 画面に出ている位置。y は「足元」の高さ
  int facing = 1;       // 向き(-1 = 左, 1 = 右)

  // ---- 最初の状態に戻す(first = 0段目の Step) ----
  void reset(Step first) {
    x = first.cx;       // 0段目の中心に立たせる
    y = first.y;
    facing = 1;         // 右向きから始める
  }

  // ---- 向きを変える(押した向きにアバターを向ける) ----
  void turn(int dir) {
    facing = dir;
  }

  // ---- 目標の段に向かって、少し進む(毎フレーム呼ばれる) ----
  // 「残りの距離の FOLLOW(29%)ぶんだけ進む」をくり返す。
  // 最初は速く、近づくほどゆっくりになる、なめらかな動きになる。
  void moveToward(Step target) {
    x += (target.cx - x) * FOLLOW;
    y += (target.y - y) * FOLLOW;
  }

  // ---- アバターを描く ----
  // 足元が (x, y) の位置にくるようにして、そこから上に向かって描く
  // target = 向かっている目標の段、stamina = スタミナ(疲れた様子と胸のランプに使う)
  void draw(Step target, Stamina stamina) {
    // ---- 登る動きの計算 ----
    // t は「移動の進み具合」: 0 = 出発した直後、1 = 到着した
    float total = dist(0, 0, PITCH, RISE);        // 1段ぶんの移動距離(斜めの長さ)
    float remain = dist(x, y, target.cx, target.y);   // 目標の段までの残りの距離
    float t = constrain(1 - remain / total, 0, 1);
    // sin(PI * t) は、t が 0→1 の間に 0 → 1 → 0 と山なりに変わる。これで「弾む動き」を作る
    float hop = sin(PI * t) * 12;                 // 移動中に弾む高さ(最大12px)
    float stretch = 1 + 0.12 * sin(PI * t);       // 弾んでいる間だけ縦に少し伸びる
    float armUp = sin(PI * t) * 5;                // 弾んでいる間は腕が上がる

    // ---- スタミナが少ないときの様子 ----
    boolean tired = stamina.isTired();            // 残りが4分の1未満なら true
    float shake = tired ? sin(frameCount * 0.6) * 1.2 : 0;   // 疲れていると体が小刻みに揺れる(? : は「条件 ? trueのとき : falseのとき」)
    int f = facing;                               // 向き(-1 か 1)。左右の位置を切り替えるのに使う

    pushStyle();                                  // 色や線の設定を保存する(あとで元に戻すため)
    pushMatrix();                                 // 座標系を保存する
    translate(x + shake, y - hop);                // 原点(0,0)を「アバターの足元」に移す。これ以降の座標は足元が基準
    scale(1 / stretch, stretch);                  // 縦に伸ばし、そのぶん横を縮める(足元を基準に伸び縮みする)
    noStroke();
    // ※ これ以降の座標は「足元が(0,0)」で、上に行くほど y がマイナスになる

    // 背中の生命維持装置(向いている方向と反対側に、少しはみ出して見える)
    fill(#5B6275);
    rect(f > 0 ? -13 : 7, -25, 6, 15, 2);         // 最後の2は、四角の角の丸み

    // 脚とブーツ
    fill(#E5732B);
    rect(-7, -9, 6, 8, 2);                        // 左脚
    rect(1, -9, 6, 8, 2);                         // 右脚
    fill(#3A3F55);
    rect(-8, -4, 8, 4, 2);                        // 左ブーツ
    rect(0, -4, 8, 4, 2);                         // 右ブーツ

    // 胴体(オレンジの宇宙服)
    fill(#FF8A3D);
    rect(-8, -23, 16, 16, 4);
    fill(255);
    rect(-8, -12, 16, 2);                         // 腰の白いライン

    // 胸のパネル: 左のランプの色が、スタミナの色(緑/黄/赤)と連動する
    fill(#2B3045);
    rect(-5, -20, 10, 5, 1);                      // パネルの土台
    fill(stamina.statusColor());
    ellipse(-2, -17.5, 3, 3);                     // スタミナの色のランプ
    fill(150, 200, 255);
    ellipse(2.5, -17.5, 3, 3);                    // 水色のランプ(飾り)

    // 腕と手袋(弾んでいる間は armUp ぶん上がる)
    fill(#E5732B);
    rect(-12, -22 - armUp, 5, 11, 3);             // 左腕
    rect(7, -22 - armUp, 5, 11, 3);               // 右腕
    fill(255);
    ellipse(-9.5, -10 - armUp, 6, 6);             // 左手袋
    ellipse(9.5, -10 - armUp, 6, 6);              // 右手袋

    // ヘルメット(縁取りを付けて描く)
    stroke(#9AA4BC);                              // 縁取りの色
    strokeWeight(1.5);                            // 縁取りの太さ
    fill(#F2F5FA);
    ellipse(0, -29, 25, 25);
    noStroke();                                   // 縁取りをやめる

    // バイザー(顔の部分)。向いている方向 f に少し寄せて描く
    fill(#1B2A52);
    ellipse(f * 2.5, -29, 17, 14);
    fill(255, 255, 255, 120);
    ellipse(f * 2.5 - 3, -32, 6, 3);              // ガラスに映る光の反射

    // バイザー越しに見える目(疲れていると細くなる)
    fill(150, 230, 255);
    float eyeH = tired ? 2 : 4;                   // 目の縦の大きさ
    ellipse(f * 4 - 3, -29, 3, eyeH);             // 左目
    ellipse(f * 4 + 3, -29, 3, eyeH);             // 右目

    // アンテナ(向いている方向と反対側に出ている)
    stroke(#9AA4BC);
    strokeWeight(1.5);
    line(-f * 5, -40, -f * 8, -46);               // 線を引く(始点x, 始点y, 終点x, 終点y)
    noStroke();
    fill(255, 90, 90);
    ellipse(-f * 8, -46.5, 3.5, 3.5);             // 先端の赤い玉

    // 汗(疲れているときだけ)。frameCount % 20 で、汗の高さが20フレームごとにくり返し変わる
    if (tired) {
      fill(120, 190, 255);
      ellipse(f * 11, -34 + (frameCount % 20) * 0.3, 4, 6);
    }

    popMatrix();                                  // 座標系を元に戻す
    popStyle();                                   // 色や線の設定を元に戻す
  }
}
