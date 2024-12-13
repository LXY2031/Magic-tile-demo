PImage magictileImage; // 必殺技１
PImage spiralImage; // 必殺技２
PImage bigMagictileImage; // 必殺技３
ArrayList<Magictile> magictiles; // 全てのマジックタイル（GPT）

void drawMagictiles() {
  for (int i = magictiles.size() - 1; i >= 0; i--) {
    Magictile mt = magictiles.get(i);
    if (mt.active) {
      mt.update();
      mt.display();
      mt.checkCollision(blockX, blockY, blockWidth, blockHeight, blockHitFlag);
    } else {
      magictiles.remove(i);
    }
  }
}

// 単一のマジックタイルを発射する
void launchSingleMagicTile() {
   float size = 60; 
   PVector startPosition = new PVector(barX + barWidth / 2 - size / 2, barY - size);
   PVector startSpeed = new PVector(0, -8); 
   magictiles.add(new Magictile(startPosition, startSpeed, size, 3, magictileImage));
   energy = 0; 
}

// 螺旋状のマジックタイルを発射する(GPT)
void launchSpiralMagicTiles() {
    float size = 60; 
    float upwardSpeed = -8; 
    float spiralRadius = 10; 
    float angleIncrement = 0.1; 

    PVector startPosition1 = new PVector(barX + barWidth / 2 - size / 2, barY - size);
    PVector startPosition2 = new PVector(barX + barWidth / 2 - size / 2, barY - size);

    magictiles.add(new Magictile(startPosition1, new PVector(), size, 3, spiralImage) {
      float angle = 0;
      void update() {
        angle += angleIncrement;
        speed.x = spiralRadius * cos(angle);
        speed.y = upwardSpeed;
        super.update();
      }
    });

    magictiles.add(new Magictile(startPosition2, new PVector(), size, 3, spiralImage) {
      float angle = 0;
      void update() {
        angle += angleIncrement;
        speed.x = -spiralRadius * cos(angle); // 反方向螺旋
        speed.y = upwardSpeed;
        super.update();
      }
    });

    energy = 0; // エネルギーをリセット
}

// 大きなマジックタイルを発射する(GPT)
void launchBigMagicTile() {
  float size = 60; // 小さなマジックタイルのサイズを設定
  float explosionSpeed = -8; // 発射速度
  int numFragments = 12; // 分裂する小さなマジックタイルの数、調整可能

  for (int i = 0; i < numFragments; i++) {
    float angle = radians(15 + (150.0 / (numFragments - 1)) * i); // 170度を均等に分割し、X軸を中心に対称にする
    PVector startPosition = new PVector(barX + barWidth / 2 - size / 2, barY - size);
    PVector newSpeed = new PVector(explosionSpeed * cos(angle), explosionSpeed * sin(angle));
    magictiles.add(new Magictile(startPosition, newSpeed, size, 3, bigMagictileImage) {
      void update() {
        position.add(speed);
        // 画面の左右の端にぶつかったかどうかをチェック
        if (position.x <= 0 || position.x + size / 2 >= width) {
          speed.x *= -1; // 反射
        }
        // 画面の上端にぶつかったかどうかをチェック
        if (position.y <= 0) {
          active = false; // 画面の上端に触れたら消える
        }
        rotationAngle += rotationSpeed;
        updateTrail();
      }
    });
  }
  energy = 0; // エネルギーをリセット
}

//// シリアル入力をチェックする(arudino)
void checkSerial() {
  if (serial.available() > 0) {
    char inChar = serial.readChar();
    if (inChar == 'B') {
      println("Button was pressed.");
      handleButtonPress();
    }
  }
}

// ボタンが押された時の処理を行う
void handleButtonPress() {
  if (energy >= 50) {
    launchBigMagicTile();
  } else if (energy >= 20 && energy < 50) {
    launchSpiralMagicTiles();
  } else if (energy >= 10) {
    launchSingleMagicTile(); 
  }
}

// キーが押された時の処理を行う
void keyPressed() {
  if (key == ' ') {
    handleButtonPress();
    
    //arudino
    serial.write('P');
  }
}
