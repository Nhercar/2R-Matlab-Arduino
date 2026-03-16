#include "arduino_secrets.h"

#include <Servo.h>

Servo servo1; // Pin 3
Servo servo2; // Pin 10

const int pin1 = 2; //ConexiÃ³n de q1
const int pin2 = 3; //ConexiÃ³n de q2

//Este script manda la posiciÃ³n media a los servos. Este paso es importante antes de fijar el servo a los brazos del robot.

void setup() {
  servo1.attach(pin1);
  servo2.attach(pin2);
  
  // Start serial communication
  Serial.begin(9600);
  
  // Set default positions
  servo1.write(90);
  servo2.write(90);
}

void loop() {


}