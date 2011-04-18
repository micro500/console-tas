#ifndef MMC_H
#define MMC_H 

#include "WProgram.h"
#include "SPI.h"

class MMC
{
  public:
    MMC();
    
    byte init();
    byte CMD(byte num, long arg);

    byte read_data(byte* buf, long addr);

    byte write_data(byte* data, long addr);

    //void print_sector();
  private:
    SPI spi_port;
    
};
#endif // MMC_H
