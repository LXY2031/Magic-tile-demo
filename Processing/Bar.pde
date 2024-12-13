PGraphics barImageRounded;
PGraphics extendedBarImageRounded;

float barX = 550.0f;
float barY = 700.0f;
float barVX = 10.0f;
float barVY = 10.0f;
float barWidth = 300.0f;
float barHeight = 60.0f;
boolean isBarExtended = false;
int barExtendedTime = 0;

PImage barImage;
PImage extendedBarImage;


/* バーの動き */
void moveBar() {
  if (keyPressed) {
    if (keyCode == RIGHT) {
      barX += barVX;
    } else if (keyCode == LEFT) {
      barX -= barVX;
    }
  }

  // バーが画面の端を超えないようにする
  barX = constrain(barX, 0, width - barWidth);

  // バーの拡張効果
  if (isBarExtended) {
    barExtendedTime--;
    if (barExtendedTime <= 0) {
      barWidth = 300.0f; // 元の幅に戻す
      isBarExtended = false;
    }
  }
}

// バーの描画
void drawBar() {
  if (isBarExtended) {
    image(extendedBarImageRounded, barX, barY, 600.0f, barHeight); // 伸長状態の画像を描画
  } else {
    image(barImageRounded, barX, barY, barWidth, barHeight); // 初期状態の画像を描画
  }
}

// 円角のバー画像を作成(ＧＰＴ）
void createRoundedBarImage(PImage img, PGraphics roundedImg, float w, float h, float radius) {
  if (img != null) {
    // バーのサイズを取得
    PImage resizedImg = img.copy();
    resizedImg.resize((int)w, (int)h);

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

    // マスクをバー画像に適用
    resizedImg.mask(mask);

    // 円角のバー画像を描画
    roundedImg.beginDraw();
    roundedImg.image(resizedImg, 0, 0);
    roundedImg.endDraw();
  } else {
    println("Bar image is null.");
  }
}
