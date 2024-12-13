#include <Adafruit_NeoPixel.h>

const int LED_PIN = 4;    // LEDのデータ入力ピン
const int buttonPin = 5;  // ボタンのピン

Adafruit_NeoPixel pixels = Adafruit_NeoPixel(2, 4, NEO_RGB + NEO_KHZ800);

int energy = 0;
bool buttonPressed = false;
bool serialButtonPressed = false;

void setup() {
  pinMode(buttonPin, INPUT_PULLUP);  // ボタンピンを入力として設定し、内部プルアップ抵抗を有効にする
  Serial.begin(9600);
  pixels.begin();
  pixels.show();  // すべてのLEDをオフの状態で初期化する
}

void loop() {
  if (digitalRead(buttonPin) == LOW) {
    buttonPressed = true;
  } else {
    buttonPressed = false;
  }

  if (Serial.available() > 0) {
    char ch = Serial.read();
    if (ch == 'H') {
      energy++;
    } else if (ch == 'P') { 
      serialButtonPressed = true;
    }
  }

  if ((buttonPressed || serialButtonPressed) && energy >= 10) {
    energy = 0;
    buttonPressed = false;
    serialButtonPressed = false;
    Serial.println("Energy reset to 0.");
    pixels.setPixelColor(0, pixels.Color(0, 0, 0));  // 最初のLEDをオフにする
    pixels.setPixelColor(1, pixels.Color(0, 0, 0));  
    pixels.show();
    Serial.write('B');  // Processingに文字'B'を送信する
  }

  // エネルギー値に基づいて対応するLEDの色と状態を設定する 
  if (energy >= 50) {
    pixels.setPixelColor(0, pixels.Color(255, 0, 0));  // 赤
    pixels.setPixelColor(1, pixels.Color(255, 0, 0));  
    pixels.show();
    delay(300);
    pixels.setPixelColor(0, pixels.Color(0, 0, 0));  
    pixels.setPixelColor(1, pixels.Color(0, 0, 0));  // 点滅
    pixels.show();
    delay(300);
  } else if (energy >= 20 && energy < 50) {
    pixels.setPixelColor(0, pixels.Color(0, 0, 255));  //青
    pixels.setPixelColor(1, pixels.Color(0, 0, 255));  
    pixels.show();
  } else if (energy >= 10) {
    pixels.setPixelColor(0, pixels.Color(0, 255, 0));  // 緑
    pixels.setPixelColor(1, pixels.Color(0, 0, 0));    // 2番目のLEDをオフにする
    pixels.show();
  } else {
    pixels.setPixelColor(0, pixels.Color(0, 0, 0));  // 最初のLEDをオフにする
    pixels.setPixelColor(1, pixels.Color(0, 0, 0));  // 
    pixels.show();
  }

  delay(100);  // ボタンのチャタリングを防ぐために遅延させる
}
