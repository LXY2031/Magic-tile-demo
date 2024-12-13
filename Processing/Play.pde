import ddf.minim.*;
//字体
PFont myFont;

Minim minim;
AudioPlayer bgm;
AudioSample testSE;
boolean prevMousePressed;

//Arduino
import processing.serial.*;
Serial serial;

// エネルギー計算(GPT)
int redBlocksCollected = 0;
int orangeBlocksCollected = 0;
int blueBlocksCollected = 0;
int greenBlocksCollected = 0;

int energy = 0;

int score = 0;
int gameTime = 120 * 60; // 1分
boolean gameOverFlag = false;
PImage gridPattern;

PImage[] availableImages = new PImage[5]; //ブロックの画像


void setup() {
  size(1440, 900, P3D); 
  
  //arudino
  serial = new Serial(this, Serial.list()[0], 9600);
  
  //字体
  myFont = createFont("./data/word/pixel.TTF", 32);
  textFont(myFont);
  
  //マスク画像をキャッシュするための配列を初期化(GPT)
  maskedImages = new PGraphics[MAX_BLOCKS];
  
  //ブロックの画像
  availableImages[0] = loadImage("./data/image/red.png");
  availableImages[1] = loadImage("./data/image/Orange.png");
  availableImages[2] = loadImage("./data/image/blue.png");
  availableImages[3] = loadImage("./data/image/Green.png");
  availableImages[4] = loadImage("./data/image/gray.png");
  
  arrangeBlocks();
  cacheMaskedImages();
  
  //bgmとマウスの音
  minim = new Minim(this);

  bgm = minim.loadFile("./data/sound/lightbgm.wav"); 
  bgm.play();

  testSE = minim.loadSample("./data/sound/se6.wav");
  
  // バーの画像をロード
  barImage = loadImage("./data/image/Bar.png");
  extendedBarImage = loadImage("./data/image/LongBar.png");

  // PGraphicsオブジェクトを作成
  barImageRounded = createGraphics((int)barWidth, (int)barHeight);
  extendedBarImageRounded = createGraphics(600, (int)barHeight); // 延長バーの長さは600.0f

  // 円角のバーの画像を作成
  createRoundedBarImage(barImage, barImageRounded, barWidth, barHeight, 10);
  createRoundedBarImage(extendedBarImage, extendedBarImageRounded, 600.0f, barHeight, 10); 
  
  //ball
  smallBallImage = loadImage("./data/image/ball.png");
  largeBallImage = loadImage("./data/image/bigball.png");

  // 初始化其他设置
  initBall();
  
  //magictileの画像
  magictileImage = loadImage("./data/image/greentile.png"); 
  spiralImage = loadImage("./data/image/bluetile.jpg"); 
  bigMagictileImage = loadImage("./data/image/redtile.jpg");
  magictiles = new ArrayList<Magictile>(); 
  
  // ピクセル風の背景格子パターンを生成（GPT）
  gridPattern = createImage(1440, 900, RGB);
  gridPattern.loadPixels();
  for (int x = 0; x < gridPattern.width; x++) {
    for (int y = 0; y < gridPattern.height; y++) {
      if ((x / 60 % 2 == 0 && y / 60 % 2 == 0) || (x / 60 % 2 == 1 && y / 60 % 2 == 1)) {
        gridPattern.pixels[y * gridPattern.width + x] = color(#000000); 
      } else {
        gridPattern.pixels[y * gridPattern.width + x] = color(#212121); 
      }
    }
  }
  gridPattern.updatePixels();
}

void draw() {
  if (!gameOverFlag) {
    // ピクセル風背景を描画
    background(gridPattern); 
    
    // 上部の長方形を描画
    fill(#e6e6e6);
    rect(0, 0, width, 100);

    // スコア、時間、およびエネルギー収集状況を表示
    updateScoreAndTime();

    // ゲーム画面を移動させ、上部の長方形と重ならないようにする
    pushMatrix();
    translate(0, 100);

    // バーを処理して描画
    moveBar();
    drawBar();

    // ボールの位置と衝突を処理
    moveBalls();
    drawBalls();
    checkBallCollisions();

    // ブロックを描画し、衝突を検出
    drawBlocks();
    blockHit();
    
    //superball
    drawMagictiles();
    
    //arudino
    checkSerial();
    
    popMatrix();  

    // マウスが押された時に効果音を再生
    if (mousePressed && !prevMousePressed) {
      testSE.trigger();
    }
    prevMousePressed = mousePressed;

    // 特殊スキルの発動をチェック
    checkSpecialSkills();
  } else {
    displayGameOverScreen();
  }
}

void mousePressed() {
  if (gameOverFlag) {
    if (mouseY > height / 2 + 50 && mouseY < height / 2 + 150) {
      if (mouseX > width / 2 - 250 && mouseX < width / 2 - 50) {
        retryGame();
      } else if (mouseX > width / 2 + 50 && mouseX < width / 2 + 250) {
        exit();
      }
    }
  }
}
