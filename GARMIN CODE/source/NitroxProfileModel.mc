//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.BluetoothLowEnergy;
import Toybox.Lang;
import Toybox.WatchUi;

class NitroxProfileModel 
{
    private var _service as Service?;
    private var _profileManager as ProfileManager;
    private var _pendingNotifies as Array<Characteristic>;

    
    private var _rawData as Numeric?;
    private var _pO2 as Numeric?;
    private var _voltage as Numeric?;
    private var _battery as Numeric?;
    var calibrating as Boolean = false;
    
    
    

    
   
    //! Constructor
    //! @param delegate The BLE delegate for the model
    //! @param profileManager The profile manager for this model
    //! @param device The current device
    public function initialize(delegate as NitroxBLEDelegate, profileManager as ProfileManager, device as Device) 
    {
        delegate.notifyDescriptorWrite(self);
        delegate.notifyCharacteristicChanged(self);

        _profileManager = profileManager;
        _service = device.getService(profileManager.NITROX_SERVICE);

        _pendingNotifies = [] as Array<Characteristic>;

        var service = _service;
        if (service != null) 
        {
            

            var characteristic = service.getCharacteristic(profileManager.PO2_CHARACTERISTIC);
            if (null != characteristic) 
            {
                _pendingNotifies = _pendingNotifies.add(characteristic);
            }
            characteristic = service.getCharacteristic(profileManager.CALIBRATE_CHARACTERISTIC);
            if (null != characteristic) 
            {
                _pendingNotifies = _pendingNotifies.add(characteristic);
            }
            
        }
        activateNextNotification();
    }
  
    //! Handle a characteristic being changed
    //! @param char The characteristic that changed
    //! @param value The updated value of the characteristic
    public function onCharacteristicChanged(char as Characteristic, value as ByteArray) as Void 
    {
        switch (char.getUuid()) 
        {
            case _profileManager.RAWDATA_CHARACTERISTIC:
                _rawData = value.decodeNumber(Lang.NUMBER_FORMAT_UINT32, {});
                WatchUi.requestUpdate();
                 break;

            case _profileManager.PO2_CHARACTERISTIC:
                
                _pO2 = value.decodeNumber(Lang.NUMBER_FORMAT_UINT32, {}) / 100.0;
                _voltage = value.decodeNumber(Lang.NUMBER_FORMAT_FLOAT, {:offset=>4});
                _battery = value.decodeNumber(Lang.NUMBER_FORMAT_FLOAT, {:offset=>8});
                
                WatchUi.requestUpdate();
                break;
            case _profileManager.VOLTAGE_CHARACTERISTIC:
                
                 _voltage = value.decodeNumber(Lang.NUMBER_FORMAT_FLOAT, {});
                WatchUi.requestUpdate();
                break;
            case _profileManager.CALIBRATE_CHARACTERISTIC:
                
                var c = value.decodeNumber(Lang.NUMBER_FORMAT_UINT32, {});
                if (c > 0) {calibrating = true;}
                if (c == 0) {calibrating = false;}
                
                WatchUi.requestUpdate();
                break;

            
        }
    }

    //! Handle the completion of a write operation on a descriptor
    //! @param descriptor The descriptor that was written
    //! @param status The BluetoothLowEnergy status indicating the result of the operation
    public function onDescriptorWrite(descriptor as Descriptor, status as Status) as Void 
    {
        if (BluetoothLowEnergy.cccdUuid().equals(descriptor.getUuid())) 
        {
            processCccdWrite();
        }
    }

    
    
    public function getRawData() as Numeric? 
    {
        return _rawData;
    }
    public function getPO2() as Numeric? 
    {
        return _pO2;
    }
    public function getVoltage() as Numeric? 
    {
        return _voltage;
    }
    public function getBattery() as Numeric? 
    {
        return _battery;
    }
    public function calibrate()
    {
        System.println("calibration entered");

    }

    

    //! Write the next notification to the descriptor
    private function activateNextNotification() as Void 
    {
        if (_pendingNotifies.size() == 0) 
        {
            return;
        }

        var char = _pendingNotifies[0];
        var cccd = char.getDescriptor(BluetoothLowEnergy.cccdUuid());
        if (cccd != null) 
        {
            cccd.requestWrite([0x01, 0x00]b);
        }
    }

    //! Process a CCCD write operation
    private function processCccdWrite() as Void 
    {
        if (_pendingNotifies.size() > 1) 
        {
            _pendingNotifies = _pendingNotifies.slice(1, _pendingNotifies.size());
            activateNextNotification();
        } 
        else 
        {
            _pendingNotifies = [] as Array<Characteristic>;
        }

    }
    public function startCalibrating ()
    {
        //System.println("start calibrating");
        var cCalibrate  = _service.getCharacteristic(_profileManager.CALIBRATE_CHARACTERISTIC);
         
        var bArray=[69,69,69,69]b;
        cCalibrate.requestWrite(bArray,{:writeType=>BluetoothLowEnergy.WRITE_TYPE_DEFAULT});
        var cccd = cCalibrate.getDescriptor(BluetoothLowEnergy.cccdUuid());
        if (cccd != null) 
        {
            var u = cccd.getUuid();
            System.println(u.toString());
            //cccd.requestWrite([0x01, 0x00]b);
        }

        
        //calibrating = true;
    }

}
    

    
    
   
