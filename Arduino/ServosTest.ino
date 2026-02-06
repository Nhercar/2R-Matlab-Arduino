#include "arduino_secrets.h"

#include <Servo.h>

Servo servo1; // Pin 3
Servo servo2; // Pin 10

const int pin1 = 3;
const int pin2 = 10;

// Handshake settings
const char HANDSHAKE_QUERY = '?';
const char HANDSHAKE_RESPONSE = 'A'; // 'A' for Ack/Arduino

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
  if (Serial.available() > 0) {
    // Peek at the first character without removing it to check message type
    char firstChar = Serial.peek();
    
    // CASE 1: Handshake Request
    if (firstChar == HANDSHAKE_QUERY) {
      Serial.read(); // Consume the '?'
      Serial.println(HANDSHAKE_RESPONSE); // Send 'A' back to MATLAB
      
      // Clear any junk remaining in buffer
      while(Serial.available()) Serial.read(); 
    }
    
    // CASE 2: Servo Command (Expected format: "90,180\n")
    else {
      // Parse the first integer
      int angle1 = Serial.parseInt() + 90;
      
      // Parse the second integer (it automatically skips the comma)
      int angle2 = -(Serial.parseInt() - 90);

      // Read the terminator (newline) to finish the command
      if (Serial.read() == '\n') {
        
        // Constrain and write
        angle1 = constrain(angle1, 0, 180);
        angle2 = constrain(angle2, 0, 180);
        
        servo1.write(angle1);
        servo2.write(angle2); //Invertida porque el servo estÃ¡ de boca abajo.
      }
    }
  }
}