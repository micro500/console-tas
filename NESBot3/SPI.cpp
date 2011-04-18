#include "SPI.h"

SPI::SPI(void)
{
  // As Master, all SPI pins go out except MOSI which comes in
  
  pinMode(MOSIP, OUTPUT);
  pinMode(SCLKP, OUTPUT);
  pinMode(CSP, OUTPUT);
  pinMode(SSP, OUTPUT);
  pinMode(MISOP, INPUT);

  digitalWrite(SSP, HIGH);
  digitalWrite(CSP, LOW); // Activate card
  
  // spi enabled, master mode, clock @ f/128 for init
  SPCR = (1<<SPE)|(1<<MSTR)|(1<<SPR1)|(1<<SPR0);

  // dummy read registers to clear previous results
  byte clr = SPSR;
  clr = SPDR;

  // you might choose to end this function with a delay
  // to ensure that the SPI hardware is ready before
  // attempting any SPI transmissions
}

byte SPI::send_data(volatile char data)
{
  long c = 0;
  SPDR = data;
  // start the transmission by loading the output
  // byte into the SPI data register

  // check status register for transfer finished flag
  while (!(SPSR & (1<<SPIF)))
  {
    if (++c == 16000)
    {
      spi_err = 1;
      break;
    }
  }

  return SPDR;    //return the received byte
}

void SPI::slow_clock()
{
  //SB(SPCR,SPR1);
  SPCR |= (1 << SPR1) | (1 << SPR0);
  //SB(SPCR,SPR0);
}

void SPI::fast_clock()
{
  SPCR &= ~((1 << SPR1) | (1 << SPR0));
  //CB(SPCR,SPR1);
  //CB(SPCR,SPR0);
}
