#include <MicroView.h>


const int latchPin = 5;
const int clockPin = 3;
const int dataPin = 2;

const int layer1 = A0;
const int layer2 = A1;
const int layer3 = A2;
const int layer4 = A3;

const int nLayers = 4;

int currentLayer = 0;

byte state[8];
int currentPos = 0;


void setup()
{
  pinMode(latchPin, OUTPUT);
  pinMode(clockPin, OUTPUT);
  pinMode(dataPin, OUTPUT);
  pinMode(layer1, OUTPUT);
  pinMode(layer2, OUTPUT);
  pinMode(layer3, OUTPUT);
  pinMode(layer4, OUTPUT);

  Serial.begin(115200);
  while (!Serial) {}
}
 
void loop()
{
  while (Serial.available() > 0)
  {
    int b = Serial.read();
    if ((b & (1 << 7)) != 0)
      currentPos = 0;

    if (currentPos < 64)
    {
      for (int i = 6; i >= 0; i--)
      {
        if ((b & (1 << i)) != 0)
          state[currentPos / 8] |= (1 << (7 - currentPos % 8));
        else
          state[currentPos / 8] &= ~(1 << (7 - currentPos % 8));
        currentPos++;
        if (currentPos > 63) break;
      }
    }
  }

  digitalWrite(layer1, LOW);
  digitalWrite(layer2, LOW);
  digitalWrite(layer3, LOW);
  digitalWrite(layer4, LOW);

  digitalWrite(latchPin, LOW);
  shiftOut(dataPin, clockPin, MSBFIRST, state[2 * currentLayer + 1]);
  shiftOut(dataPin, clockPin, MSBFIRST, state[2 * currentLayer]);
  digitalWrite(latchPin, HIGH);
  
  switch (currentLayer)
  {
    case 0:
      digitalWrite(layer1, HIGH);
      digitalWrite(layer2, LOW);
      digitalWrite(layer3, LOW);
      digitalWrite(layer4, LOW);
      break;
    case 1:
      digitalWrite(layer1, LOW);
      digitalWrite(layer2, HIGH);
      digitalWrite(layer3, LOW);
      digitalWrite(layer4, LOW);
      break;
    case 2:
      digitalWrite(layer1, LOW);
      digitalWrite(layer2, LOW);
      digitalWrite(layer3, HIGH);
      digitalWrite(layer4, LOW);
      break;
    case 3:
      digitalWrite(layer1, LOW);
      digitalWrite(layer2, LOW);
      digitalWrite(layer3, LOW);
      digitalWrite(layer4, HIGH);
      break;
  }

  currentLayer = (currentLayer + 1) % nLayers;
  delay(5);
}
