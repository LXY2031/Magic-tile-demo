// GPT
class Magictile {
  PVector position; // 位置
  PVector speed; // 速度
  float size; // サイズ
  float rotationAngle; // 回転角度
  float rotationSpeed; // 回転速度
  PImage image; // 画像
  boolean active; // アクティブかどうか

  int trailLength = 20; // 残像の長さ
  PVector[] trailPositions = new PVector[trailLength]; // 残像の位置
  float[] trailAngles = new float[trailLength]; // 残像の角度
  int trailUpdateInterval = 3; // 残像の更新間隔（フレーム数）
  int frameCountForTrail = 0; // 残像更新のためのカウンター

  Magictile(PVector startPosition, PVector startSpeed, float size, float rotationSpeed, PImage image) {
    this.position = startPosition.copy();
    this.speed = startSpeed.copy();
    this.size = size;
    this.rotationAngle = 0;
    this.rotationSpeed = rotationSpeed;
    this.image = image;
    this.active = true;
    initializeTrail(); // 残像を初期化
  }

  void initializeTrail() {
    for (int i = 0; i < trailLength; i++) {
      trailPositions[i] = new PVector(-size, -size); // 残像の位置を初期化
      trailAngles[i] = 0;
    }
  }

  void update() {
    position.add(speed);
    rotationAngle += rotationSpeed;
    if (position.y < 0) {
      active = false; // 画面の上端を超えた場合は無効にする
      initializeTrail(); // 残像を再初期化
    }
    updateTrail(); // 残像を更新
  }

  void updateTrail() {
    frameCountForTrail++;
    if (frameCountForTrail >= trailUpdateInterval) {
      for (int i = trailLength - 1; i > 0; i--) {
        trailPositions[i] = trailPositions[i - 1].copy();
        trailAngles[i] = trailAngles[i - 1];
      }
      trailPositions[0] = position.copy();
      trailAngles[0] = rotationAngle;
      frameCountForTrail = 0; // カウンターをリセット
    }
  }

  void display() {
    // 残像を描画
    for (int i = 0; i < trailLength; i++) {
      pushMatrix();
      translate(trailPositions[i].x + size / 2, trailPositions[i].y + size / 2);
      rotate(radians(trailAngles[i]));
      tint(255, 128 * (trailLength - i) / trailLength); // 透明度を設定し、残像をより透明にする
      image(image, -size / 2, -size / 2, size, size);
      popMatrix();
    }
    
    // 現在のマジックタイルを描画
    pushMatrix();
    translate(position.x + size / 2, position.y + size / 2);
    rotate(radians(rotationAngle));
    noTint(); // カラーフィルターをクリア
    image(image, -size / 2, -size / 2, size, size); // サイズに基づいて画像を描画
    popMatrix();
  }

  void checkCollision(float[] blockX, float[] blockY, float[] blockWidth, float[] blockHeight, boolean[] blockHitFlag) {
    for (int i = 0; i < blockX.length; i++) {
      if (!blockHitFlag[i]) {
        if (position.x + size > blockX[i] && position.x < blockX[i] + blockWidth[i] && 
            position.y + size > blockY[i] && position.y < blockY[i] + blockHeight[i]) {
          blockHitFlag[i] = true;
          // スコアを更新
          score += 100; // 各ブロック100点
          if (blockImages[i] == availableImages[0]) { 
            redBlocksCollected++; 
          } else if (blockImages[i] == availableImages[1]) { 
            orangeBlocksCollected++;
          } else if (blockImages[i] == availableImages[2]) { 
            blueBlocksCollected++;
          } else if (blockImages[i] == availableImages[3]) { 
            greenBlocksCollected++; 
          }
        }
      }
    }
  }
}
