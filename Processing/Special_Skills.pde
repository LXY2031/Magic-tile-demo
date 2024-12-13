boolean isBallEnlarged = false;
int ballEnlargedTime = 0;
float originalBallDiameter = 20.0f;

void checkSpecialSkills() {
  if (redBlocksCollected >= 4) {
    // ボールが大きくなる、5秒間持続
    for (GameBall ball : balls) {
      ball.enlargeBall(); 
    }
    isBallEnlarged = true;
    ballEnlargedTime = 5 * 60; // 5秒に対応するフレーム数（フレームレートが60の場合）
    redBlocksCollected -= 4; // エネルギーを消費
  }

  if (orangeBlocksCollected >= 4) {
    // 新しいボールを生成
    if (balls.size() < 5) {
      balls.add(new GameBall(width / 2, height / 2, 8, smallBallImage, largeBallImage));
    }
    orangeBlocksCollected -= 4; // エネルギーを消費
  }

  if (blueBlocksCollected >= 4) {
    // バーが長くなる
    barWidth = 600.0f;
    isBarExtended = true;
    barExtendedTime = 10 * 60; // 10秒に対応するフレーム数（フレームレートが60の場合）
    blueBlocksCollected -= 4; // エネルギーを消費
  }

  if (greenBlocksCollected >= 4) {
    // すべてのブロックをクリア
    for (int i = 0; i < MAX_BLOCKS; i++) {
      blockHitFlag[i] = true;
    }
    greenBlocksCollected -= 4; // エネルギーを消費
  }

  // ボールが大きくなる効果の持続時間管理
  if (isBallEnlarged) {
    ballEnlargedTime--;
    if (ballEnlargedTime <= 0) {
      for (GameBall ball : balls) {
        ball.diameter = 30.0f; 
      }
      isBallEnlarged = false;
    }
  }
}
