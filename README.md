# NitroxBLE
Garmin Watch / Arduino code to send oxygen sensor data to a Garmin device over BLE

An Adafruit Itsy Bitsy NRF5280 Express is used as the BLE peripheral.  A Garmin watch is used as the client.

The Arduino code is contained in the ITSY directory.
The Garmin code is contained in the GARMIN directory.

As best as I can tell, there isn't a GATT for oxygen sensor.  So I created the following:


Nitrox Service                     = BLEService("f63f71e0-7b8e-4bbb-ab5c-8dd8e4ceb7d3");
pO2 Characteristic                 = BLECharacteristic("fb07ef0a-228f-456c-9218-17770d6c07bd"); (notify)
calibrationCharacteristic = BLECharacteristic("d008ec36-1853-48ba-8bd8-68c3e861df14");          (write / notify)


the pO2 Characteristic is chock-full of stuff.  
The first 4 bytes are digital PO2 * 10.  E.G.  20.95 would be 2095 
The next 4 bytes are the floating point voltage of the sensor.
The next 4 bytes are battery voltage.  N.B.  This works on the Arduino feather, but will not work on the Itsy Bitsy.


To calibrate, the client sends-up 0x45 to the peripheral using the calibrationCharacteristic (write).  The peripheral, then sends-back ones (using notify) until the calibration is completed.  Here, the process takes 5 seconds.  Upon completion, 0 is sent back along the calibration characteristic (using notify)


The following LED color codes (using the integrated dotstar LED) can help debugging
nothing            power failure
solid red          serial initialization error
flashing orange:    DSP1115 error
flashing blue       searching for client
solid blue.          connected.  sending data
