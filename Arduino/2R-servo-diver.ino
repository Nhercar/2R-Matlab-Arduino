#include "arduino_secrets.h"

#include <Servo.h>

Servo servo1; // Pin 3
Servo servo2; // Pin 10

const int pin1 = 2; //ConexiÃ³n de q1
const int pin2 = 3; //ConexiÃ³n de q2

const int offsetq1 = 0; // Este offset hay que configurarlo antes de programar el robot.
const int offsetq2 = 0; // Al enviar servo1=90, servo2=90. Los brazos deben estar alineados al eje X.

// Handshake settings: Matlab busca por los puertos COM disponibles. Manda un mensaje y espera una respuesta con un A.
const char HANDSHAKE_QUERY = '?';
const char HANDSHAKE_RESPONSE = 'A'; // 'A' for Ack/Arduino

void setup() {
  servo1.attach(pin1);
  servo2.attach(pin2);
  
  // Start serial communication
  Serial.begin(9600);
  
  // Set default positions
  servo1.write(90 + offsetq1);
  servo2.write(90 + offsetq2);
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
      int angle1 = 90 - Serial.parseInt() + offsetq1;
      
      // Parse the second integer (it automatically skips the comma)
      int angle2 = Serial.parseInt() + 90 + offsetq2;

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