void updateScoreAndTime() {
  // ゲーム時間を更新(GPT)
  gameTime--;

  // スコア、時間、およびエネルギー収集状況を表示(GPT)
  textFont(myFont); // 设置字体
  fill(0);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("Score: " + score, width / 2, 30);
  text("Time: " + nf(gameTime / 60, 2) + ":" + nf(gameTime % 60, 2), width / 2, 70);

  // エネルギー収集状況を表示(GPT)
  textAlign(LEFT, CENTER);
  fill(#a80008);
  text("Red: " + redBlocksCollected, 10, 30);
  fill(#a86300);
  text("Orange: " + orangeBlocksCollected, 10, 60);
  fill(#0031a8);
  text("Blue: " + blueBlocksCollected, 200, 30);
  fill(#00a80a);
  text("Green: " + greenBlocksCollected, 200, 60);

  // ゲーム終了をチェック
  if (gameTime <= 0) {
    gameOverFlag = true;
  }
}

void displayGameOverScreen() {
  background(0, 0, 0, 150); 
  textFont(myFont); 
  fill(255, 0, 0);
  textSize(64);
  textAlign(CENTER, CENTER);
  text("Game Over", width / 2, height / 2 - 40);
  fill(255);
  textSize(48);
  text("Final Score: " + score, width / 2, height / 2 + 40);
  
  // Retryボタン
  fill(#6cff6b);
  rect(width / 2 - 250, height / 2 + 100, 200, 100);
  fill(0);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("Retry", width / 2 - 150, height / 2 + 150);
  
  // Quitボタン
  fill(#ff6b7b);
  rect(width / 2 + 50, height / 2 + 100, 200, 100);
  fill(0);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("Quit", width / 2 + 150, height / 2 + 150);
}

void retryGame() {
  // ゲームを再初期化
  balls.clear();
  score = 0;
  gameTime = 120 * 60; // 1分
  gameOverFlag = false;
  initBall();
  loop();
}
