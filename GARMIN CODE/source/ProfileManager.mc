//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.BluetoothLowEnergy;

class ProfileManager 
{

    
    //public const THINGY_ENVIRONMENTAL_SERVICE = BluetoothLowEnergy.longToUuid(0xEF6802009B354933L, 0x9B1052FFA9740042L);
    //nitrox service uuid is f63f71e0-7b8e-4bbb-ab5c-8dd8e4ceb7d3
    //#define NITROX_SERVICE_UUID                "f63f71e0-7b8e-4bbb-ab5c-8dd8e4ceb7d3"
    //#define NITROX_RAWDATA_CHARACTERISTIC_UUID "5f64c5e1-c3bc-4398-b49f-a03028eb20c8"
    //#define NITROX_PO2_CHARACTERISTIC_UUID     "fb07ef0a-228f-456c-9218-17770d6c07bd"

    public const NITROX_SERVICE             = BluetoothLowEnergy.stringToUuid("f63f71e0-7b8e-4bbb-ab5c-8dd8e4ceb7d3");
    public const RAWDATA_CHARACTERISTIC     = BluetoothLowEnergy.stringToUuid("5f64c5e1-c3bc-4398-b49f-a03028eb20c8");
    public const PO2_CHARACTERISTIC         = BluetoothLowEnergy.stringToUuid("fb07ef0a-228f-456c-9218-17770d6c07bd");
    public const CALIBRATE_CHARACTERISTIC   = BluetoothLowEnergy.stringToUuid("d008ec36-1853-48ba-8bd8-68c3e861df14");
    public const VOLTAGE_CHARACTERISTIC     = BluetoothLowEnergy.stringToUuid("cc4b22cb-23fe-4f57-8078-ea24d66685df");

    
    //public const HUMIDITY_CHARACTERISTIC      = BluetoothLowEnergy.longToUuid(0xEF6802039B354933L, 0x9B1052FFA9740042L);
    //public const AIR_QUALITY_CHARACTERISTIC   = BluetoothLowEnergy.longToUuid(0xEF6802049B354933L, 0x9B1052FFA9740042L);

    //public const THINGY_CONFIGURATION_SERVICE = BluetoothLowEnergy.longToUuid(0xEF6801009B354933L, 0x9B1052FFA9740042L);

    private const _nitroxProfileDef = 
    {
        :uuid => NITROX_SERVICE,
        :characteristics => [{
            :uuid => RAWDATA_CHARACTERISTIC,
            :descriptors => [BluetoothLowEnergy.cccdUuid()]
        }, 
        {
            :uuid => PO2_CHARACTERISTIC,
            :descriptors => [BluetoothLowEnergy.cccdUuid()]
        },
        {
            :uuid => CALIBRATE_CHARACTERISTIC,
            :descriptors => [BluetoothLowEnergy.cccdUuid()]
        },
        {
            :uuid => VOLTAGE_CHARACTERISTIC,
            :descriptors => [BluetoothLowEnergy.cccdUuid()]
        } ]
    };

    //! Register the bluetooth profile
    public function registerProfiles() as Void 
    {
        BluetoothLowEnergy.registerProfile(_nitroxProfileDef);
    }
}
