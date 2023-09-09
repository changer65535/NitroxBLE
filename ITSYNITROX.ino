
#define VBATPIN A6                //turns out itsy bitsy doesn't have capability for checking battery-levels (like the feather).  
#include <bluefruit.h>
#include <Adafruit_ADS1X15.h>
#include <Adafruit_DotStar.h>


Adafruit_ADS1115 ads;             //A-D converter ADS1115 using adafruit libraries
BLEDis bledis;                    // DIS (Device Information Service) helper class instance
BLEService        nitroxService             = BLEService("f63f71e0-7b8e-4bbb-ab5c-8dd8e4ceb7d3");
BLECharacteristic pO2Characteristic         = BLECharacteristic("fb07ef0a-228f-456c-9218-17770d6c07bd");
BLECharacteristic calibrationCharacteristic = BLECharacteristic("d008ec36-1853-48ba-8bd8-68c3e861df14");
Adafruit_DotStar strip(1, 8, 6, DOTSTAR_BRG);


uint32_t cal = 1000;    //converts digital reading to O2 directly

bool calibrating = false;
float voltageCal = 0.0;

void setHue(float c)
{
  int cc = c * 65535;
  strip.setPixelColor(0,strip.ColorHSV(cc));
  strip.show();
}

void setup()
{
  /*************************STRIP************************************/
  strip.begin(); // Initialize pins for output
  strip.setBrightness(20);
  strip.show();  // Turn all LEDs off ASAP
  setHue(0);
  /************************************SERIAL****************************/
  Serial.begin(115200);
  //while ( !Serial ) delay(10);   // for nrf52840 with native usb

  setHue(0.25);
  if (Serial) Serial.println("strip and serial setup complete.");
  /********************************ADS******************************************/
  ads.setGain(GAIN_SIXTEEN);    // 16x gain  +/- 0.256V  1 bit = 0.125mV  0.0078125mV
  voltageCal = 0.0078125;  //mv per bit
  if (!ads.begin()) 
  {
    if (Serial) Serial.println("Failed to initialize ADS.");
    while (true)
    {
      setHue(0.25);
      delay (1000);
      strip.clear();
      strip.show();
      delay(1000);
      
    }
   
  }
  if (Serial) Serial.println("ads setup complete.");
  /************************BLUEFRUIT**************************************/
  Bluefruit.begin(1,0);//max 1 server, 0 clients
  Bluefruit.autoConnLed(false);
  Bluefruit.setName("NITROX");
  // Set the connect/disconnect callback handlers
  Bluefruit.Periph.setConnectCallback(connect_callback);
  Bluefruit.Periph.setDisconnectCallback(disconnect_callback);
  bledis.begin();
  setupService();
  startAdvertising();
  setHue(0.75);
  if (Serial) Serial.println("Bluefruit setup complete");
}

void startAdvertising(void)
{
  // Advertising packet
  Bluefruit.Advertising.addFlags(BLE_GAP_ADV_FLAGS_LE_ONLY_GENERAL_DISC_MODE);
  Bluefruit.Advertising.addTxPower();

  // Include HRM Service UUID
  Bluefruit.Advertising.addService(nitroxService);

  // Include Name
  Bluefruit.Advertising.addName();
  
  
  Bluefruit.Advertising.restartOnDisconnect(true);
  Bluefruit.Advertising.setInterval(32, 244);    // in unit of 0.625 ms
  Bluefruit.Advertising.setFastTimeout(30);      // number of seconds in fast mode
  Bluefruit.Advertising.start(0);                // 0 = Don't stop advertising after n seconds  
}

void startCalibrating()
{
  uint32_t one = 1;
  static long calibratingMillis = 0;
  calibrating = true;
  calibratingMillis = millis();
  if (Serial) Serial.println("Calibrating!");
  
  calibrationCharacteristic.notify32(one);
  
}

void writeCallback(uint16_t conn_hdl, BLECharacteristic* chr, uint8_t* buffer, uint16_t len)
{
      if (buffer[0] == 69) startCalibrating();
    
}






void setupService(void)
{
  
  nitroxService.begin();


  
  
  pO2Characteristic.setProperties(CHR_PROPS_NOTIFY);
  pO2Characteristic.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  pO2Characteristic.setFixedLen(12);
  pO2Characteristic.setCccdWriteCallback(cccd_callback);  // Optionally capture CCCD updates
  pO2Characteristic.begin();

  calibrationCharacteristic.setProperties(CHR_PROPS_READ | CHR_PROPS_WRITE | CHR_PROPS_NOTIFY);
  calibrationCharacteristic.setPermission(SECMODE_OPEN, SECMODE_OPEN);
  calibrationCharacteristic.setFixedLen(4);
  calibrationCharacteristic.setCccdWriteCallback(cccd_callback);
  calibrationCharacteristic.setWriteCallback(writeCallback);
  calibrationCharacteristic.begin();
  
  
  
}

void connect_callback(uint16_t conn_handle)
{
  // Get the reference to current connection
  BLEConnection* connection = Bluefruit.Connection(conn_handle);

  char central_name[32] = { 0 };
  connection->getPeerName(central_name, sizeof(central_name));

  if (Serial) Serial.print("Connected to ");
  if (Serial) Serial.println(central_name);
  calibrationCharacteristic.notify32(32);
  
}

/**
 * Callback invoked when a connection is dropped
 * @param conn_handle connection where this event happens
 * @param reason is a BLE_HCI_STATUS_CODE which can be found in ble_hci.h
 */
void disconnect_callback(uint16_t conn_handle, uint8_t reason)
{
  (void) conn_handle;
  (void) reason;

  if (Serial) Serial.print("Disconnected, reason = 0x"); 
  if (Serial) Serial.println(reason, HEX);
  if (Serial) Serial.println("Advertising!");
}

void cccd_callback(uint16_t conn_hdl, BLECharacteristic* chr, uint16_t cccd_value)
{
    // Display the raw request packet
    if (Serial) Serial.print("CCCD Updated: ");
    if (Serial) Serial.print(cccd_value);
    if (Serial) Serial.println("");

    // Check the characteristic this CCCD update is associated with in case
    // this handler is used for multiple CCCD records.
    if (chr->uuid == pO2Characteristic.uuid) 
    {
        if (chr->notifyEnabled(conn_hdl)) 
        {
            if (Serial) Serial.println("O2 Rate Measurement 'Notify' enabled");
        } else 
        {
            if (Serial) Serial.println("O2 Rate Measurement 'Notify' disabled");
        }
    }
    if (chr->uuid == calibrationCharacteristic.uuid) 
    {
        if (chr->notifyEnabled(conn_hdl)) 
        {
            if (Serial) Serial.println("Cal 'Notify' enabled");
        } else 
        {
            if (Serial) Serial.println("Cal 'Notify' disabled");
        }
    }
}

uint32_t readADFake (int mSec)          //This simulates A/D reads.  in the code, replace readAD with readADFake if you don't wanna connect the AD
{
  delay(mSec);
  long m = millis() / 1000;
  long mmod = m % 30;
  if (mmod < 15) return random(900,1100);
  else return random (1900,2100);
}

uint32_t readAD (int mSec)              //mSec is how long you wanna sample for
{
  long stopMillis = millis() + mSec;
  long sum = 0;
  long counter = 0;
  while (millis() < stopMillis)
  {
    sum = sum + ads.readADC_Differential_0_1();
    counter ++;
  }
  return sum / counter;
  
}

float measureBattery ()         ///doesn't work in Itsy Bitsy, but works for feather.
{
  
  float measuredvbat = analogRead(VBATPIN);
  measuredvbat *= 2;    // we divided by 2, so multiply back
  measuredvbat *= 3.3;  // Multiply by 3.3V, our reference voltage
  measuredvbat /= 1024.0; // convert to voltage
  return measuredvbat;
}

void stopCalibrating ()
{
  uint32_t zero = 0;
  calibrating = false;
  calibrationCharacteristic.notify32(zero);
  
            
}
void handleCalibrating ()
{
  uint32_t one = 1;
  if (Serial) Serial.println("Calibrating");
  setHue(0.1666666);
        
  long vSum = 0;
  int counter = 0;
  for (int i = 0;i<5;i++)  //do it 5 times for no real reason
  {
    vSum +=readAD(1000);
    counter++;
    calibrationCharacteristic.notify32(one);
    
    
  }
  cal = vSum / counter;
  stopCalibrating();
  strip.clear();
  strip.show();
}
void handleDataReadAllData ()
{
  setHue(0.6666);       //solid blue means we are actively sending dada
  uint32_t v = readAD(250);
  //safePrint("v: ");safePrintln(v);
  if (cal > 0) 
  {
    uint8_t buf[20];
    memset (buf,0,20);
    
    float fPO2 = (v * 20.95 / cal);
    uint32_t po2 = fPO2 * 100;
    //safePrint("pO2: ");safePrintln(po2);

    float fVolts = v * voltageCal;
    //safePrint("mv: ");safePrintln(fVolts);

    float fBatteryVolts = measureBattery();
    //safePrint ("Battery: ");safePrintln(fBatteryVolts);
    memcpy (&buf[0],&po2,4);
    memcpy (&buf[4],&fVolts,4);
    memcpy (&buf[8],&fBatteryVolts,4);
    pO2Characteristic.notify(buf,12);
    uint32_t temp = millis() / 1000;
  }
    
      
  
}

void loop()
{
  
  if ( Bluefruit.connected() ) 
  {
    if (calibrating) handleCalibrating();
    else handleDataReadAllData();  
  }
  else      //blinking means we are searching for a connection
  {
    long m = millis();
    if (m % 1000 < 100) setHue(0.6666);
    else 
    {
      strip.clear();
      strip.show();
    }
    
  }

  
}
