# TemperGold
Read temperature from TemperGold (TemperX) usb dongle

Delphi console application, that can read temperature from Temper (gold) usb stick http://pcsensor.com/usb-thermometers/gold-temper.html

Application read temperature and print result to console in Celsius. It can be used in monitoring systems (I use it in NetXMS to control temperature in server room and send alerts when it reach critical value)

Application created in Delphi XE2.
To compile application you need install Jedy library from http://delphi-jedi.org, that contains jvSetupAPI.pas and HID.pas. This is header files for setupapi.dll and hid.dll
