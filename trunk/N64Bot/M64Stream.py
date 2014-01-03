import serial
def reverse_buttons(str):
    result = ""
    for i in range(0,len(str)/4):
        result = result + str[i*4 + 3] + str[i*4 + 2] + str[i*4 + 1] + str[i*4]
    return result

port = serial.Serial("COM11", 19200)
port.readline();

movie = open("snark,kyman,sonicpacker,mickey_vis,tot-sm64.m64","rb")

signature = movie.read(4)
if signature != "M64\x1A":
    print "M64 file signature not correct! This may not be an M64 movie!"

version = movie.read(4)
uid = movie.read(4)
VI_count = movie.read(4)
rerecords = movie.read(4)
rerecords = (ord(rerecords[3]) << 24) + (ord(rerecords[2]) << 16) + (ord(rerecords[1]) << 8) + ord(rerecords[0])
VIs_per_sec = movie.read(1)
controller_count = movie.read(1)

dummy = movie.read(2)

input_samples = movie.read(4)
movie_start = movie.read(2)

dummy = movie.read(2)

controller_flags = movie.read(4)

dummy = movie.read(160)

rom_name = movie.read(32).rstrip('\0')
rom_crc = movie.read(4)
rom_country_code = movie.read(2)

dummy = movie.read(56)

video_plugin = movie.read(64).rstrip('\0')
sound_plugin = movie.read(64).rstrip('\0')
input_plugin = movie.read(64).rstrip('\0')
rsp_plugin = movie.read(64).rstrip('\0')

author = movie.read(222).rstrip('\0')
movie_description = movie.read(256).rstrip('\0')

print "Rom:\t\t" + rom_name
print "Author:\t\t" + author
print "Description:\t" + movie_description
print "Rerecords:\t" + str(rerecords)
print "\n"

buttons = movie.read(512)
buttons = reverse_buttons(buttons)

port.write(buttons)
port.flush()

cur_frame = -1
new_frame = 0
done = 0
while 1:
    new_string = port.readline()
    new_frame = int(new_string) / 4
    
    if new_frame != cur_frame:
        cur_frame = new_frame
        # Clear the line
        print "\r\t\t\t\t",
        print "\rFrame: " + str(cur_frame),
        
        if done == 0:
            if new_frame % 128 == 1:
                print "\tSending...",
                buttons = movie.read(512)
                if buttons != "":
                    buttons = reverse_buttons(buttons)
                    port.write(buttons)
                else:
                    done = 1
                    print "\tAll data sent!"
                if len(buttons) < 512:
                    done = 1
                    print "\tAll data sent!"

