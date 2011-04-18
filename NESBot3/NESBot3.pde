#define RIGHT 10
#define LEFT 9
#define DOWN 8
#define UP 7
#define START 6
#define SELECT 5
#define B 4
#define A 3

#define READY 16    // analog pin 2
#define GOBTN 17    // analog pin 3
#define STATUS 14   // analog pin 0
#define SD_LOAD 18  // analog pin 4

#include <MsTimer2.h>
#include "MMC.h"

volatile unsigned long frame = 0; // This is the frame for which data is currently loaded

unsigned long movie_length = 0;

byte buttons1[512];
byte buttons2[512];

unsigned long data_amount = 0;
unsigned long data_count = 0;
boolean dataRecording = false;
boolean sd_load_init_done = false;
boolean nes_init_done = false;
byte write_me[512];

byte sd_init_return = 255;

boolean data_read = false;
boolean data_written = false;

MMC sd_card;

volatile char next_buttons = 0;

volatile unsigned long time = 0;

void latch_pulse()
{
//    detachInterrupt(0);
//    MsTimer2::stop();
    MsTimer2::start();
    
    // If the movie is over, disable the bot   
    if (frame == movie_length - 1) {
        next_buttons = 0;
        writeButtons();
        detachInterrupt(0);
//        Timer1.stop();
    }
    
    // After 512 frames, copy in the next chunk of frame data
    if (frame != 0 && frame % 512 == 0 && data_written == false)
    {
        for (int i = 0; i < 512; i++)
        {
            buttons1[i] = buttons2[i]; 
        }
        data_written = true;
    }
    else if (frame % 512 != 0)
    {
        data_written = false;
    }
    
    // Flash the status led every 5 latches (~6 times a second)
    if (frame % 10 == 0)
    {
        digitalWrite(STATUS, HIGH);
    }
    
    if (frame % 10 == 5)
    {
        digitalWrite(STATUS, LOW);
    }
    
    if (frame % 50 == 0)
    {
        digitalWrite(READY, HIGH);
    }
    
    if (frame % 50 == 25)
    {
        digitalWrite(READY, LOW);
    }
}

// Write the given button sequence to the shift register
void writeButtons()
{
    // Shift out the button information from the data byte
    // and make each pin HIGH or LOW accordingly
    MsTimer2::stop();   
//    next_buttons = buttons1[frame % 512];
    char buttons = buttons1[frame % 512];
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
    frame++;
//    attachInterrupt(0,latch_pulse, FALLING);
}

// Initialize the system to play the NES
void nes_init()
{
    // Undo the SD loading initialization if previously completed
    if (sd_load_init_done)
    {
        Serial.end();
        sd_load_init_done = false;
    }
    
    // All of our simulated buttons need to be outputs
    pinMode(RIGHT, OUTPUT);
    pinMode(LEFT, OUTPUT);
    pinMode(DOWN, OUTPUT);
    pinMode(UP, OUTPUT);
    pinMode(START, OUTPUT);
    pinMode(SELECT, OUTPUT);
    pinMode(B, OUTPUT);
    pinMode(A, OUTPUT);
    
    // Turn on the ready light
    digitalWrite(READY, HIGH);
    
    frame = 0;
    movie_length = 0;
    data_read = false;
    MsTimer2::set(15, writeButtons); // 500ms period
    MsTimer2::start();
    MsTimer2::stop(); 
    nes_init_done = true;
}

// Initialize the system to load the movie onto the SD card
void sd_load_init()
{
    if (nes_init_done)
    {
        nes_init_done = false;
    }
    
    // Setup the serial port
    Serial.begin(115200);
    Serial.flush();

    // Let the computer know we're ready
    Serial.print(sd_init_return,HEX);
    data_count = 0;
    sd_load_init_done = true;
}

// General setup
void setup()
{ 
    // Enable the go button pin with a pullup
    pinMode(GOBTN, INPUT);
    digitalWrite(GOBTN, HIGH);
    
    // Enable the SD loading switch pin with a pullup
    pinMode(SD_LOAD, INPUT);
    digitalWrite(SD_LOAD, HIGH);
    
    // Enable status LED pin and turn it off
    pinMode(STATUS, OUTPUT);
    digitalWrite(STATUS, LOW);
    
    // Enable ready LED pin and turn it off
    pinMode(READY, OUTPUT);
    digitalWrite(READY, LOW);
    
    // Make sure the SD card is ready for communication
    delay(10);
    sd_init_return = sd_card.init();
}

void loop()
{
    // We must now decide if we are loading data to the SD card or playing the NES
    switch (digitalRead(SD_LOAD))
    {
        // NES playing mode
        case HIGH:
            // Initialize the NES playing mode if not done already
            if (!nes_init_done)
            {
                nes_init();
            }
            
            while (digitalRead(GOBTN) == HIGH); // Waiting for the go button to be pressed
            
            //delay(500);            
                       
            // Pull out the first block of data which contains the movie length information
            sd_card.read_data(buttons1,0);
            
            // Convert the ascii characters into an actual number
            for (int i = 0; buttons1[i] != ' '; i++)
            {
                movie_length = movie_length * 10 + buttons1[i] - 48;
            }
            
            // Pull out the first block of actual button data
            sd_card.read_data(buttons1,512);
            sd_card.read_data(buttons2,1024);
            
            // Write the first set of buttons
            next_buttons = buttons1[0];
            writeButtons();
            
            
            // We are now ready to talk to the console, so turn on interrupts
            attachInterrupt(0,latch_pulse, FALLING);
            
            while (digitalRead(GOBTN) == LOW);
            frame = 0; 
            
           // We are now running, turn off the ready light
            digitalWrite(READY, LOW);
           
            // Turn on the status LED to announce our readiness
            digitalWrite(STATUS, HIGH);
            
            // Now would be a good time to turn on the console and watch it go!
            while (true)
            {
                // Buffer the next 512 bytes
                if (frame > 1 && frame % 512 == 1 && data_read == false) { 
                    sd_card.read_data(buttons2,frame+1023);
                    data_read = true;
                }
                else if (frame % 512 != 1)
                {
                    data_read = false;
                }
            }  
            
            /* Unreachable Code */
            break;
        
      
        // SD loading mode  
        case LOW:
            // Initialize the loading mode if not done already
            if (!sd_load_init_done) {
                sd_load_init();
            }
            
            // Wait for data from the computer
            while (Serial.available()>0)
            {
                digitalWrite(READY, HIGH);
                
                // The computer will first send the length of the video
                if (dataRecording == false)
                {
                    char inByte;
                    switch (inByte = Serial.read())
                    {
                        case '0':
                        case '1':
                        case '2':
                        case '3':
                        case '4':
                        case '5':
                        case '6':
                        case '7':
                        case '8':
                        case '9':
                            data_amount = data_amount * 10 + inByte - 48;
                            write_me[data_count] = inByte;
                            data_count++;
                            break;
                        case ' ':
                            Serial.println(data_amount);
                            write_me[data_count] = ' ';
                            
                            // Write this movie length as the first block on the SD card
                            sd_card.write_data(write_me, 0);
                            
                            // We are now ready to record actual button data
                            dataRecording = true;
                            data_count = 0;
                            break;
                        default:
                            Serial.flush();
                    }
                }
                else 
                {
                    // Loop until we get all the button data expected
                    while (data_count < data_amount)
                    {
                        // Wait for data
                        while (Serial.available() <=0);
                        
                        // Read in the data, and store it
                        int value = Serial.read();
                        write_me[data_count % 512] = value;
                        data_count++;
                        
                        // When we have a full block, write it to the card
                        if (data_count % 512 == 0)
                        {
                            sd_card.write_data(write_me, data_count);
                        }
                    }
                    
                    // Write the rest of the data to the card
                    sd_card.write_data(write_me, data_count - (data_count % 512) + 512);
                }
                
                // If the computer sent us more data than we were expecting, just ignore it
                if (data_count >= data_amount && dataRecording == true) 
                {
                    Serial.flush();
                    Serial.println("DONE");
                }
            }
            digitalWrite(READY, LOW);
    }
}
