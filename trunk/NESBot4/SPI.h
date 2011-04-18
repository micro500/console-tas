#ifndef SPI_H
#define SPI_H

#define MOSIP 11       // Arduino pin 11
#define MISOP 12       // Arduino pin 12
#define SCLKP 13       // Arduino pin 13
#define CSP 10         // Arduino analog pin 5
#define SSP 10         // Arduino pin 10 


#include "WProgram.h"

class SPI
{
  public:
    SPI();

    byte send_data(volatile char data);
    
    // Sets the SPI clock speed under 400KHz
    void slow_clock();
    
    // Sets the SPI clock speed to be fast
    void fast_clock();
    
    byte spi_err; // SPI timeout flag, must be cleared manually
};

#endif // SPI_H
