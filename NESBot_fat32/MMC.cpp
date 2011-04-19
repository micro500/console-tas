#include "SPI.H"
#include "MMC.H"

MMC::MMC()
{

}

byte MMC::init()
{
  byte i;

  // make absolute sure that the SPI clock is under 400MHz
  spi_port.slow_clock();
  
  digitalWrite(CSP, HIGH); // Deactivate card for warmup
  
  for(i=0;i<10;i++) spi_port.send_data(0xFF); // send 80 pulses (10 bytes) for a warmup
  digitalWrite(CSP, LOW);  // reactivate card

  // CMD0 sets card to idle mode, also selects SPI interface
  while (CMD(0,0)!=1)
  {
    if (spi_port.spi_err != 0)
    {
      // a timeout occured, possibly because of no card in the socket
      spi_port.spi_err = 0;
      digitalWrite(CSP, LOW);
      return 1;
    }
  }  

  // ACMD41 (55->41) is the preferred startup sequence for SD cards
  for (i=0; i<255; i++)
  {
    CMD(55,0);
    if (CMD(41,0)==0) break;
  } 

  // sets the SPI clock up to a higher speed.
  // check the datasheet p170 for complete table
  spi_port.fast_clock();

  return 0;
}

// Send a MMC/SD command, num is the actual index, not
// ORed with 0x40. arg is all four bytes of the argument
byte MMC::CMD(byte num, long arg)
{
  digitalWrite(CSP, LOW); // assert chip select for the card

  spi_port.send_data(0xFF); // dummy byte
  spi_port.send_data(0x40|num);  // command token

  // send argument in little endian form (MSB first)
  spi_port.send_data(arg>>24);
  spi_port.send_data(arg>>16);
  spi_port.send_data(arg>>8);
  spi_port.send_data(arg);

  spi_port.send_data(0x95);  // checksum valid for CMD0, not needed
              // thereafter, so we can hardcode this value

  spi_port.send_data(0xFF); // dummy to give card time to process

  return spi_port.send_data(0xFF); // query return value from card
}

byte MMC::read_data(byte* buf, long addr)
{
  byte r1 = CMD(17,addr);
  for (int i=0; i<50; i++)     // wait until the data is found
  {
    if (r1==0) break;
    r1 = spi_port.send_data(0xFF);
  }
  if (r1!=0) return 1;  // timed out
  
  while (spi_port.send_data(0xFF) != 0xFE);  // wait for the "data follows" code
  
  for (int i=0; i<512; i++)
  {
    *(buf++) = spi_port.send_data(0xFF);
  }
  
  spi_port.send_data(0xFF); spi_port.send_data(0xFF);  // dummy bytes to clear any queues
  
  return 0;
}

byte MMC::write_data(byte* data, long addr)
{
  short i;
  
  if (CMD(24,addr) != 0) return 2; // Address is most likely bad
  
  // lead in to actual data
  spi_port.send_data(0xFF); 
  spi_port.send_data(0xFF); 
  spi_port.send_data(0xFE);
  
  for (i=0; i<512; i++) 
  {
    spi_port.send_data(data[i]);
  }
  
  spi_port.send_data(0xFF); spi_port.send_data(0xFF); // dummy before response recieved
  
  char c = spi_port.send_data(0xFF); 
  c &= 0x1F; // bit mask for write error codes
  // see http://elm-chan.org/docs/mmc/mmc_e.html
  
  if (c != 0x05) return 1;
  while (spi_port.send_data(0xFF)!=0xFF);  // block until write finished
  return 0;
}
