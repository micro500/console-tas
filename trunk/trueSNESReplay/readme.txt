Known Issues
============

Host Speed
----------
If the playback computer is slow or is otherwise busy, frames may be dropped
and movies may desync. This is especially common on Windows computers.

To solve this, do not run anything except the playback application, or use
a bare Linux system to play back movies.

In testing, an AMD E-350 with Windows could mostly reliably play back movies
but would sometimes drop frames and desync. Slow by comparison, a Raspberry Pi
with a bare Gentoo Linux install almost never dropped frames.


Data Output
-----------
There is latency when setting bits. This cannot be resolved with this hardware.

While compatible with games that use standard SNES Autopoll, custom games with
very tight reading loops may fail to work properly with this hardware. This is
especially true of SNES multitap.


Firmware Updates
----------------
Firmware updating does not work on Mac OS X.



Operating Modes
===============

There are four operating modes for the replay device. Switch the current mode
by pressing and holding the Action button for about one second when idle.

Mode 0: NES/SNES. Symbolized by slow flashing LED when idle.
Mode 1: SNES Multitap in port 2. Medium rate double flashing LED.
Mode 2: SNES Multitap in port 1 and 2. Fast triple flashing LED.
Mode 3: SNES Multitap in port 1. Medium flash pulsing LED.



Dumping Instructions
====================

todo



Linux Instructions
==================

You need Python 2.7 and pySerial to operate the Replay Device.

USB communication should work natively on most Linux systems. There are
some issues with USB mode, but they have mostly been mitigated and should
not pose any problems in practice.

To use the TTL UART on the Raspberry Pi, refer to the header of replay.py.

replay.py was tested on Gentoo Linux with Python 2.7.5 and pySerial 2.6.
Use your distribution's installation method to install Python 2.7 and
pySerial.



Windows Instructions
====================

You need Python 2.7 and pySerial to operate the Replay Device.

USB communication requires a driver which is present in the replay device
software release at truecontrol.org.

TTL UART requires a TTL UART to USB adapter, frequently called a TTL 232 to
USB adapter, which can be found cheaply and of varying quality at online
vendors and eBay.

You can download Python 2.7 here:
  http://www.python.org/download/releases/2.7.6/

You can download pySerial here:
  http://www.lfd.uci.edu/~gohlke/pythonlibs/#pyserial

To use replay.py, open a command prompt, navigate to the location of replay.py,
and use the following command to run (assuming default install location):
  C:\Python27\python replay.py



Updating the Firmware
=====================

Check for a newer release at truecontrol.org. If available, the download will
include the updating utility for Windows.

todo


CHANGES
=======
1.0f:
 * Decreased response time between clocks by about 400ns, at the expense
   of 200ns at the end of the last clock. Latch should also be faster.

1.0e:
 * Fixed NES support :)