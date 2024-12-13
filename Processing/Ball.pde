ArrayList<GameBall> balls = new ArrayList<GameBall>();  //<>//

PImage smallBallImage;
PImage largeBallImage;

class GameBall {
  float x, y, vx, vy, diameter;
  float originalDiameter;
  color currentColor;
  PImage smallImage;
  PImage largeImage;
  boolean isBallEnlarged;
  float angle; 
  float rotationSpeed;

  GameBall(float x, float y, float speed, PImage smallImage, PImage largeImage) {
    this.x = x;
    this.y = y;
    this.diameter = 30.0f;
    
    this.smallImage = smallImage;
    this.largeImage = largeImage;
    this.isBallEnlarged = false;
    this.angle = 0;
    this.rotationSpeed = 0.05; 

    float angle;//ランダム方向のボール(GPT)
    if (random(1) < 0.5) {
      angle = radians(random(40, 45)); 
    } else {
      angle = radians(random(135, 140)); 
    }

    this.vx = speed * cos(angle);
    this.vy = -speed * abs(sin(angle)); 
  }

  void move() {
    x += vx;
    y += vy;
    angle += rotationSpeed; 

    // 壁にぶつかったら反射する
    if (x - diameter / 2 < 0) {
      vx = -vx;
      x = diameter / 2; 
    }
    if (x + diameter / 2 > width) {
      vx = -vx;
      x = width - diameter / 2; 
    }
    if (y - diameter / 2 < 0) {
      vy = -vy;
      y = diameter / 2; 
    }
  }

  void draw() {
    noStroke();
    pushMatrix();
    translate(x, y);
    rotate(angle);
    if (isBallEnlarged) {
      image(largeImage, -diameter / 2, -diameter / 2, diameter, diameter);
    } else {
      image(smallImage, -diameter / 2, -diameter / 2, diameter, diameter);
    }
    popMatrix();
  }

  void enlargeBall() {
    isBallEnlarged = true;
    diameter = 70.0f; 
  }

  void shrinkBall() {
    isBallEnlarged = false;
    diameter = 30.0f; 
  }

  boolean isOffScreen() {
    return y - diameter / 2 > height;
  }

  boolean checkCollisionWithBar() {
    return x + diameter / 2 > barX && x - diameter / 2 < barX + barWidth && y + diameter / 2 > barY && y - diameter / 2 < barY + barHeight;
  }

  boolean checkCollisionWithBlock(float blockX, float blockY, float blockWidth, float blockHeight) {
    return x + diameter / 2 > blockX && x - diameter / 2 < blockX + blockWidth && y + diameter / 2 > blockY && y - diameter / 2 < blockY + blockHeight;
  }
}

void initBall() {
  if (balls.size() < 5) {
    balls.add(new GameBall(width / 2, height / 2, 8, smallBallImage, largeBallImage)); // 这里的8是速度大小
  }
}

void moveBalls() {
  for (GameBall ball : balls) {
    ball.move();
  }

  // 画面外に出たボールを削除
  balls.removeIf(ball -> ball.isOffScreen());
  
  // ボールがなくなった場合，新しいボールを生成
  if (balls.isEmpty()) {
    balls.add(new GameBall(width / 2, height / 2, 8, smallBallImage, largeBallImage)); 
  }
}

void drawBalls() {
  for (GameBall ball : balls) {
    ball.draw();
  }
}

void checkBallCollisions() {
  for (GameBall ball : balls) {
    // ボールとバーの衝突検出
    if (ball.checkCollisionWithBar()) {
      ball.vy = -ball.vy;
      ball.y = barY - ball.diameter / 2 - 1; // ボールがバーに引っかからないようにする(GPT)
    }
  }
}
