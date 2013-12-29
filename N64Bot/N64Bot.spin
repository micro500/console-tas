CON
   _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

   DATA = 16
obj
  term : "FullDuplexSerial"
  sdfat: "fsrw"'
var
  long data_out
  byte spin_frame
  byte spin_frame2
  byte spin_frame3
  byte spin_frame4
  byte buffer[1024]
  long stack[100]



pub main
  term.start(31, 30, 0, 115200)

  sdfat.mount_explicit(23,22,21,20)

  sdfat.popen(string("tas.txt"),"r")

  sdfat.pread(@buffer, 1024)

  cognew(new_data, @stack)
  cognew(@entry, @spin_frame)

'  repeat
'    term.bin(long[@spin_frame],32)
'    term.str(string(13))
'    waitcnt(800_000 + cnt)
'  term.str(string("reset",13))        
'  repeat
'    repeat while (spin_frame2 == 0)
'    term.bin(spin_frame,8)
'    term.str(string(13))
'    spin_frame2 := 0

  repeat
    'term.bin(data_out,32)
    term.dec(long[@spin_frame])
    term.str(string(13))
'    term.dec(long[@spin_frame + 4])
'    term.str(string(13))
    waitcnt(800_000 + cnt)



  repeat
  'DIRA[DATA] := 1

  'OUTA[DATA] := 1

  'waitcnt(80_000_000 + CNT)

  'OUTA[DATA] := 0

pub new_data | data_read1, data_read2
  data_read1 := 0
  data_read2 := 0
  repeat
    if ((long[@spin_frame]) // 1024 > 512 AND data_read1 == 0)
      sdfat.pread(@buffer, 512)
      data_read1 := 1
      data_read2 := 0
      term.str(string("filled 1",13))
    elseif ((long[@spin_frame] // 1024) < 512 and long[@spin_frame] > 1024 and data_read2 == 0)
      sdfat.pread(@buffer[512], 512)
      data_read1 := 0
      data_read2 := 1
      term.str(string("filled 2",13))



dat

        org 0
entry
        ' Reset the frame to 0
        mov frame, #0

        mov console_data, #%11111111

        mov sd_data_addr, par
        add sd_data_addr, #4
        ' Read the first byte of controller data
        rdbyte controller_data, sd_data_addr

'        jmp #main_loop2
        ' Wait for the console to turn on
        waitpeq data_pin, data_pin

main_loop
        call #read_bits

        cmp console_data, #%11111111 wz
        if_z jmp #send_reset_response
        cmp console_data, #%00000000 wz
        if_e jmp #send_reset_response
        cmp console_data, #%00000001 wz
        if_z jmp #send_controller_response

        ' Maybe wait a short time? Maybe?

'        jmp #send_reset_response
        jmp #main_loop


send_reset_response
        mov data_to_send, reset_data
        shl data_to_send, #8
        mov bits_to_send, #24
        call #send_bits
        jmp #main_loop

send_status_response
        mov data_to_send, status_data
        shl data_to_send, #7
        mov bits_to_send, #25
        call #send_bits
        jmp #main_loop

send_controller_response
        mov data_to_send, controller_data
        mov bits_to_send, #32
        call #send_bits

        add frame, #1

        mov sd_data_addr, frame

        shl sd_data_addr, #2
        wrlong sd_data_addr, par
        and sd_data_addr, buffer_length
        add sd_data_addr, par
        add sd_data_addr, #4
        'wrlong sd_data_addr, par



        rdlong controller_data, sd_data_addr

        jmp #main_loop





'main_loop2
'        ' Set command to $01
'        mov data_to_send, #%00000001
'        ' Move data to left to get it at the highest bits
'        shl data_to_send, #24
'        ' Set it 8 bits
'        mov bits_to_send, #8
'        call #send_bits
'
'        call #read_bits
'
'        wrlong console_data, par
'
'        mov delay_time, cnt
'        add delay_time, one_second
'        waitcnt delay_time, #0
'
'        jmp #main_loop2

send_bits
        ' Reset bit count
        mov bit_count, #0
        ' Set pin as output
        mov dira, data_pin


sending_loop
        ' Roll the bit to send to the lowest spot
        rol data_to_send, #1

        ' Set pin low
        mov outa, #0

        ' Check the bit
        and data_to_send, #1 nr, wz
        if_z jmp #send_zero
        'jmp #send_one

send_one
        ' Get the counter time
        mov delay_time, cnt
        ' Wait 1us
        add delay_time, one_pulse
        waitcnt delay_time, three_pulse

        ' Set pin high
        mov outa, data_pin
        ' Wait 3us
        waitcnt delay_time, #0

        jmp #finish_bit_send

send_zero
        ' Get the counter time
        mov delay_time, cnt
        ' Wait 3us
        add delay_time, three_pulse
        waitcnt delay_time, one_pulse

        ' Set pin high
        mov outa, data_pin
        ' Wait 1us
        waitcnt delay_time, #0
        'jmp #finish_bit_send

finish_bit_send
        ' Bit was sent
        ' Now add one to the count, are we done?
        add bit_count, #1
        cmp bit_count, bits_to_send wz
        ' If so, send stop bit
        if_z jmp #send_stop_bit

        ' Other wise, repeat
        jmp #sending_loop

send_stop_bit
        ' Set pin low
        mov outa, #0

        ' Get the counter time
        mov delay_time, cnt
        ' Wait 1us
        add delay_time, one_pulse
        waitcnt delay_time, three_pulse

        ' Set pin high
        mov outa, data_pin
        ' Turn off our transmitter
        mov dira, #0

        ' Data sent
send_32_bits_ret
send_8_bits_ret
send_bits_ret
        ret





read_bits

        mov bit_count, #0
        mov console_data, #0
        mov bits_to_read, #8

wait_for_low
        waitpeq low, data_pin
        

        ' Wait 2 pulses. Data will then be ready
        mov delay_time, cnt
        add delay_time, two_pulse
        waitcnt delay_time, two_pulse

read_bit
        ' Move the previous data left to make room for the new bit
        shl console_data, #1

        ' Read from INA
        mov input, ina
        and input, data_pin nr, wz

        ' If the pin is high, add 1
        'cmp input, data_pin wz
        if_nz add console_data, #1

        ' Increment the number of bits read and compare to desired
        ' If it matches, we're done!
        add bit_count, #1
        cmp bit_count, #8 wz
        if_z jmp #exit_read

wait_for_high
        waitpeq data_pin, data_pin

        jmp #wait_for_low

exit_read
        ' Delay to prevent responding too quickly
        mov delay_time, cnt
        add delay_time, four_pulse
        waitcnt delay_time, #0
read_bits_ret
        ret






buffer_length long %1111111111
controller_data long 0
frame long 0

one byte 1

sd_data_addr long 0

data_to_send long 0
bits_to_send byte 32

sample_controller_data long %00010000000000000000000000000000
status_data long %1000001010000000000000010
reset_data long %000001010000000000000010

console_data long 0
bits_to_read long 8

data_pin long %10000000000000000
delay_length long 80
one_second long 8_000_000
one_pulse long 80
three_half_pule long 120
two_pulse long 160
three_pulse long 240
four_pulse long 320

bit_count long 0

low long 0

input res 0
delay_time  res 0

fit