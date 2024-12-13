final int MAX_BLOCKS = 77;
float[] blockX = new float[MAX_BLOCKS];
float[] blockY = new float[MAX_BLOCKS];
float[] blockWidth = new float[MAX_BLOCKS];
float[] blockHeight = new float[MAX_BLOCKS];
boolean[] blockHitFlag = new boolean[MAX_BLOCKS];
color[] blockColors = new color[MAX_BLOCKS];
PImage[] blockImages = new PImage[MAX_BLOCKS]; 

PGraphics[] maskedImages = new PGraphics[MAX_BLOCKS]; // キャッシュされたマスク画像

final int BLOCK_ROWS = 11; // ブロックの横一列の個数
final int BLOCK_GAP = 2; // ブロックとブロックの間隔

int lastEnergyUpdateTime = 0;//energy time

void arrangeBlocks() {
  // maskedImagesを再生成するためにnullで初期化（GPT）
  for (int i = 0; i < MAX_BLOCKS; i++) {
    maskedImages[i] = null;
    blockImages[i] = null;
  }

  int i = 0;
  while (i < MAX_BLOCKS) {
    blockWidth[i] = 120.0f;
    blockHeight[i] = 30.0f;
    blockHitFlag[i] = false;
    blockX[i] = BLOCK_GAP + i % BLOCK_ROWS * (blockWidth[i] + BLOCK_GAP);
    blockY[i] = BLOCK_GAP + i / BLOCK_ROWS * (blockHeight[i] + BLOCK_GAP);

    // 画像をランダムに割り当て
    int randImage = int(random(28)); // 
    if (randImage <= 5) {
      blockImages[i] = availableImages[0]; // 赤色の画像
      blockColors[i] = color(255, 0, 0); // 赤色
    } else if (randImage <= 10) {
      blockImages[i] = availableImages[1]; // 橙色の画像
      blockColors[i] = color(255, 165, 0); // 橙色
    } else if (randImage <= 16) {
      blockImages[i] = availableImages[2]; // 青色の画像
      blockColors[i] = color(0, 0, 255); // 青色
    } else if (randImage <= 19) {
      blockImages[i] = availableImages[3]; // 緑色の画像
      blockColors[i] = color(0, 255, 0); // 緑色
    } else {
      blockImages[i] = availableImages[4]; // 灰色の画像
      blockColors[i] = color(128, 128, 128); // 灰色
    }
    i++;
  }
}

// 円角のブロック画像を描画（GPT）
void cacheMaskedImages() {
  float radius = 10; // 円角矩形の半径を定義
  for (int i = 0; i < MAX_BLOCKS; i++) {
    if (!blockHitFlag[i]) { // ヒットされていないブロックのみ処理
      PImage img = blockImages[i]; // ブロックの画像を取得
      if (img != null) {
        // ブロックのサイズを取得
        float w = blockWidth[i];
        float h = blockHeight[i];

        // ブロック画像をブロックのサイズにリサイズ
        PImage resizedImg = img.copy();
        resizedImg.resize((int)w, (int)h);

        // ブロックサイズと同じPGraphicsオブジェクトを作成
        maskedImages[i] = createGraphics((int)w, (int)h);
        maskedImages[i].beginDraw();

        // 円角矩形のマスクを作成
        PGraphics mask = createGraphics((int)w, (int)h);
        mask.beginDraw();
        mask.background(0);
        mask.fill(255);
        mask.noStroke();
        mask.beginShape();
        mask.vertex(radius, 0);
        mask.vertex(w - radius, 0);
        mask.quadraticVertex(w, 0, w, radius);
        mask.vertex(w, h - radius);
        mask.quadraticVertex(w, h, w - radius, h);
        mask.vertex(radius, h);
        mask.quadraticVertex(0, h, 0, h - radius);
        mask.vertex(0, radius);
        mask.quadraticVertex(0, 0, radius, 0);
        mask.endShape(CLOSE);
        mask.endDraw();

        // マスクをブロック画像に適用
        resizedImg.mask(mask);

        // 円角のブロック画像を描画
        maskedImages[i].image(resizedImg, 0, 0);
        maskedImages[i].endDraw();
      } 
    }
  }
}

void drawBlocks() {
  int i = 0;
  while (i < MAX_BLOCKS) {
    if (!blockHitFlag[i]) { // ブロックがヒットされていない場合
      if (maskedImages[i] != null) { // キャッシュされたマスク画像がnullではないことを確認
        // ブロック画像を描画
        image(maskedImages[i], blockX[i], blockY[i], blockWidth[i], blockHeight[i]);
      } 
    }
    i++;
  }
}

void blockHit() {
  for (GameBall ball : balls) { // 各ボールについて
    int i = 0;
    while (i < MAX_BLOCKS) {
      if (!blockHitFlag[i]) { // ブロックがヒットされていない場合
        if (ball.checkCollisionWithBlock(blockX[i], blockY[i], blockWidth[i], blockHeight[i])) { // 衝突をチェック
          ball.vy = -ball.vy; // ボールの垂直速度を反転
          blockHitFlag[i] = true; // ブロックをヒット状態に設定
          score += 100; // 各ブロック100点
          
          // energyを増やす条件(0.1s一回のみ）
          if (millis() - lastEnergyUpdateTime >= 100) {
            energy++;
            lastEnergyUpdateTime = millis(); // 更新時間を記録
            // Arduino
             serial.write('H');
          }
          

          println(energy);
         
          // 色に基づいてエネルギーを収集
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
      i++;
    }
  }
  
  // 全てのブロックが消されたかチェック
  if (allBlocksCleared()) {
    score += 10000; // 全てのブロック消去のボーナス10000点
    arrangeBlocks(); // ブロックを再生成
    cacheMaskedImages(); // キャッシュされたマスク画像も再生成
  }
}

boolean allBlocksCleared() {
  for (int i = 0; i < MAX_BLOCKS; i++) {
    if (!blockHitFlag[i]) {
      return false;
    }
  }
  return true;
}
