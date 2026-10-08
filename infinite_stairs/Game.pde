// ==============================
//  Game.pde  ゲーム全体の進行役
// ==============================
// 各部品(空・階段・アバター・スタミナ・カメラ・表示・自己ベスト)を持ち、
// それらをつないでゲームを進めるクラス。
// 「今の状態(タイトル/プレイ中/ポーズ/リザルト)」と「キー入力の処理」もここにある。
class Game {

  // ---- 部品(それぞれ、別のタブで定義したクラスから1つずつ作る) ----
  Sky sky = new Sky();                  // 空
  Stairs stairs = new Stairs();         // 階段
  Avatar avatar = new Avatar();         // アバター
  Camera camera = new Camera();         // カメラ
  Stamina stamina = new Stamina();      // スタミナ
  BestScore best = new BestScore();     // 自己ベスト
  Hud hud = new Hud();                  // 画面に重ねる表示

  // ---- ゲームの状態 ----
  int state;                            // 今の状態(TITLE / PLAY / PAUSE / RESULT のどれか)
  int cur;                              // 今立っている段の番号。そのままスコア(STEP)になる
  boolean isNewRecord;                  // 今回のプレイで自己ベストを更新したか
  boolean[] keys = new boolean[256];    // 各キーが「今押されているか」の記録。keys['a'] が true なら A が押されている

  // ---- コンストラクタ: new Game() と書いたときに1回だけ呼ばれる ----
  Game() {
    best.load();                        // ファイルから自己ベストを読み込む
    showTitle();                        // タイトル画面から始める
  }

  // =====================================================
  //  毎フレームの処理(main の draw() から呼ばれる)
  // =====================================================

  // ---- 更新: ゲームの中身を少し進める ----
  void update() {
    if (state == PLAY) {
      // プレイ中だけ、スタミナを減らす。尽きたらゲームオーバー
      if (stamina.update(cur)) endGame();
    }
    if (state != PAUSE) {
      // ポーズ中以外は、アバターとカメラを動かす
      avatar.moveToward(stairs.get(cur));
      camera.follow(avatar.x, avatar.y);
    }
  }

  // ---- 描画: 今の状態を画面に描く ----
  void draw() {
    drawWorld();                        // 空・階段・アバターは、どの状態でも描く(背景として)
    if (state == TITLE) {
      hud.drawTitle(best.value);        // タイトル画面の文字を重ねる
    } else if (state == RESULT) {
      hud.drawResult(cur, best.value, isNewRecord, stamina.playFrames);   // リザルト画面を重ねる
    } else {
      hud.drawStatus(cur, best.value, stamina);   // プレイ中とポーズ中は、スコアとゲージを重ねる
      if (state == PAUSE) hud.overlay("PAUSED", "P: Resume   R: Restart");   // ポーズ中は暗くして文字を出す
    }
  }

  // ---- 世界全体を描く(空 → 階段 → アバターの順に、奥から手前へ) ----
  void drawWorld() {
    float h = sky.heightOf(avatar.y);             // 今の高さ(段数)
    sky.draw(h, camera.x, camera.y);              // まず背景の空
    int labelCol = sky.labelColor(h);             // 段の番号の文字色(空の明るさに合わせる)

    // ここからは「世界の座標」で描く。
    // カメラを動かす代わりに、世界の方を逆向きにずらして描いている。
    // pushMatrix() で今の座標系を保存し、popMatrix() で元に戻せる。
    pushMatrix();
    translate(-camera.x, -camera.y);
    stairs.draw(cur, labelCol);                   // 階段(0段目は雲の土台)
    avatar.draw(stairs.get(cur), stamina);        // アバター(宇宙服のキャラクター)
    popMatrix();                                  // 座標系を元に戻す(これ以降は画面の座標で描ける)
  }

  // =====================================================
  //  画面の切り替え
  // =====================================================

  // タイトル画面へ(ゲームを初期状態にしてから、状態をTITLEにする)
  void showTitle() {
    reset();
    state = TITLE;
  }

  // ゲーム開始(初期状態にしてから、状態をPLAYにする)
  void startGame() {
    reset();
    state = PLAY;
  }

  // ゲームオーバー
  void endGame() {
    isNewRecord = best.record(cur);     // ベストを超えていたら更新・保存し、更新したかどうかを覚える
    state = RESULT;                     // リザルト画面へ
  }

  // 階段とプレイヤーを最初の状態に戻す(新しいゲームを始めるたびに呼ばれる)
  void reset() {
    stairs.reset();                     // 階段を作り直す
    cur = 0;                            // 0段目に立っている
    stamina.reset();                    // スタミナは満タン
    isNewRecord = false;
    avatar.reset(stairs.get(0));        // アバターを0段目に置く
    camera.reset(avatar.x, avatar.y);   // カメラをアバターに合わせる
  }

  // =====================================================
  //  登る処理
  // =====================================================

  // ---- 登ろうとする(A/Dが押されたときに呼ばれる) ----
  // dir: -1 = 左(A), 1 = 右(D)
  void tryMove(int dir) {
    int need = stairs.directionToNext(cur);   // 正解の向き(次の段が右なら 1、左なら -1)
    avatar.turn(dir);                         // 押した向きにアバターを向ける(間違えたときも向く)

    if (dir == need) {
      // ---- 正解: 次の段へ登る ----
      cur++;                                  // 段数を1増やす
      stamina.onClimb();                      // スタミナを回復(ここから減り始める)
      stairs.ensure(cur + 30);                // 30段先まで階段を作っておく
    } else {
      // ---- 不正解: その場に留まり、スタミナが減る ----
      if (stamina.onMiss()) {
        endGame();                            // スタミナが尽きたらゲームオーバー
      }
    }
  }

  // =====================================================
  //  キー入力
  // =====================================================

  // ---- キーが押された瞬間に1回呼ばれる ----
  // 押しっぱなしでは進まないようにしている(押した瞬間だけ反応させる)
  void keyPressed() {
    if (key == CODED) return;                 // 矢印キーなどの特殊キーは使わないので、ここで終わり
    char k = Character.toLowerCase(key);      // 押されたキーを小文字にそろえる(Shiftや CapsLock で大文字でも動くように)
    if (k >= keys.length) return;             // 配列の範囲外の文字(日本語など)は無視する

    // OSは押しっぱなしにすると同じキーを連続して送ってくる。
    // keys[k] がすでに true なら「押しっぱなしの連続入力」なので無視する
    boolean firstPress = !keys[k];            // ! は否定(true と false を逆にする)
    keys[k] = true;                           // このキーを「押されている」と記録する
    if (!firstPress) return;

    // ENTER、RETURN、SPACE のどれかなら「決定」の入力とみなす(|| は「または」)
    boolean confirm = (k == ENTER || k == RETURN || k == ' ');

    // 今の状態によって、キーの意味が変わる
    if (state == TITLE) {
      if (confirm) startGame();               // タイトル: 決定キーでゲーム開始
    } else if (state == PLAY) {
      if (k == 'a') tryMove(-1);              // A: 左へ登ろうとする
      if (k == 'd') tryMove(1);               // D: 右へ登ろうとする
      if (k == 'p') state = PAUSE;            // P: ポーズ
      if (k == 'r') {                         // R: 途中でやり直し(その時点の記録も保存してから)
        best.record(cur);
        startGame();
      }
    } else if (state == PAUSE) {
      if (k == 'p') state = PLAY;             // P: ポーズ解除
      if (k == 'r') {
        best.record(cur);
        startGame();
      }
    } else if (state == RESULT) {
      if (k == 'r') startGame();              // R: もう一度遊ぶ
      if (confirm) showTitle();               // 決定キー: タイトルに戻る
    }
  }

  // ---- キーが離された瞬間に1回呼ばれる ----
  void keyReleased() {
    if (key == CODED) return;
    char k = Character.toLowerCase(key);
    if (k >= keys.length) return;
    keys[k] = false;                          // 「押されていない」状態に戻す
  }

  // =====================================================
  //  ウィンドウの状態
  // =====================================================

  // ---- ウィンドウがアクティブでなくなったとき(別のウィンドウに切り替えたときなど) ----
  //   ・プレイ中なら自動でポーズする(離れている間にスタミナが減らないように)
  //   ・押していたキーの情報をリセットする
  //     (キーを離した情報がゲームに届かず、戻ったあとの1回目の入力が無視されるのを防ぐ)
  void onFocusLost() {
    java.util.Arrays.fill(keys, false);       // 配列 keys の全部の要素を false にする
    if (state == PLAY) {
      state = PAUSE;
    }
  }

  // ---- ウィンドウを閉じたとき・Escキーで終了したとき ----
  // プレイ中(またはポーズ中)なら、その時点の段数を自己ベストとして保存する
  void onExit() {
    if (state == PLAY || state == PAUSE) {
      best.record(cur);
    }
  }
}
