#define SMD
#include "NESBot.h"

#include <MsTimer2.h>
#include <SdFat.h>

SdFat sd;
SdFile movie;

void latch_pulse()
{
    MsTimer2::start();
    
    // If the movie is over, disable the bot   
    if (movie.curPosition() >= movie.fileSize())
    {
        writeButtons();
        detachInterrupt(0);
        movie.close();
    }
        
    // Flash the status led every 5 latches (~6 times a second)
    if (movie.curPosition() % 10 == 0)
    {
        digitalWrite(STATUS, HIGH);
    }
    
    if (movie.curPosition() % 10 == 5)
    {
        digitalWrite(STATUS, LOW);
    }
    
    if (movie.curPosition() % 50 == 0)
    {
        digitalWrite(READY, HIGH);
    }
    
    if (movie.curPosition() % 50 == 25)
    {
        digitalWrite(READY, LOW);
    }
}

// Write the next button sequence to the shift register
void writeButtons()
{
    // Shift out the button information from the data byte
    // and make each pin HIGH or LOW accordingly
    MsTimer2::stop();   
    char buttons = movie.read();
    buttons = ~buttons;
    digitalWrite(A,      buttons & 1);
    buttons = buttons >> 1;
    digitalWrite(B,      buttons & 1);
    buttons = buttons >> 1;
    digitalWrite(SELECT,      buttons & 1);
    buttons = buttons >> 1;
    digitalWrite(START,      buttons & 1);
    buttons = buttons >> 1;
    digitalWrite(UP,      buttons & 1);
    buttons = buttons >> 1;
    digitalWrite(DOWN,      buttons & 1);
    buttons = buttons >> 1;
    digitalWrite(LEFT,      buttons & 1);
    buttons = buttons >> 1;
    digitalWrite(RIGHT,      buttons & 1);
}

// General setup
void setup()
{ 
    // Enable the go button pin with a pullup
    pinMode(GOBTN, INPUT);
    digitalWrite(GOBTN, HIGH);
    
    // Enable status LED pin and turn it off
    pinMode(STATUS, OUTPUT);
    digitalWrite(STATUS, LOW);
    
    // Enable ready LED pin and turn it off
    pinMode(READY, OUTPUT);
    digitalWrite(READY, LOW);
    
    // Make sure the SD card is ready for communication
//    if (SD.begin(SDPIN) == false)
    if (!sd.init(SPI_HALF_SPEED, SDPIN))
    {
      digitalWrite(READY, HIGH);
      while (1)
      {
        digitalWrite(STATUS, HIGH);
        delay(1000);
        digitalWrite(STATUS, LOW);
        delay(1000);
      }
    }
    
    // Initialize the NES playing mode if not done already
    // All of our simulated buttons need to be outputs
    pinMode(RIGHT, OUTPUT);
    pinMode(LEFT, OUTPUT);
    pinMode(DOWN, OUTPUT);
    pinMode(UP, OUTPUT);
    pinMode(START, OUTPUT);
    pinMode(SELECT, OUTPUT);
    pinMode(B, OUTPUT);
    pinMode(A, OUTPUT);
    
    MsTimer2::set(13, writeButtons); 
    MsTimer2::start();
    MsTimer2::stop(); 
    Serial.begin(9600);
}

void loop()
{     
    movie.open("tas.txt", O_READ);
    
    // Make sure we opened the movie file ok
    if (movie.fileSize() > 0)
    {
      Serial.println(movie.fileSize());
      Serial.println(movie.curPosition());
      // Turn on the ready light
      digitalWrite(READY, HIGH);
      while (digitalRead(GOBTN) == HIGH);

      // Write the first set of buttons
      writeButtons();
      movie.seekSet(0);
      Serial.println(movie.curPosition());
      
      // We are now ready to talk to the console, so turn on interrupts
      attachInterrupt(0,latch_pulse, FALLING);
      
      // Wait for the user to release the go button
      while (digitalRead(GOBTN) == LOW);
      
      // We are now running, turn off the ready light
      digitalWrite(READY, LOW);
     
      // Turn on the status LED to announce our readiness
      digitalWrite(STATUS, HIGH);
      
      // Now would be a good time to turn on the console and watch it go!
      
      // Waste time until the movie is over!
      while (movie.curPosition() < movie.fileSize()) {}  
      
      // Movie is over, clean up stuff
      // Note: This MIGHT be unreachable as of right now
      detachInterrupt(0);
      MsTimer2::stop();
      movie.close();
      while (1)
      {
        digitalWrite(READY, HIGH);
        digitalWrite(STATUS, HIGH);
        delay(1000);
        digitalWrite(READY, LOW);
        digitalWrite(STATUS, LOW);
        delay(1000);
      }
    }
    else
    {
      digitalWrite(STATUS, HIGH);
      digitalWrite(READY, HIGH);
      delay(250);
      digitalWrite(STATUS, LOW);
      digitalWrite(READY, LOW);
      delay(250);
      digitalWrite(STATUS, HIGH);
      digitalWrite(READY, HIGH);
      delay(250);
      digitalWrite(STATUS, LOW);
      digitalWrite(READY, LOW);
      delay(1000);
      // FAILED TO OPEN MOVIE
    }
}

