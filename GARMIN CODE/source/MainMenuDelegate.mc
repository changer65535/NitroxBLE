//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.BluetoothLowEnergy;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Storage;

class MODDelegate extends WatchUi.MenuInputDelegate 
{
    function initialize() 
    {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) 
    {
        if (item == :oneone) 
        {
            Storage.setValue("PPO2", 1.1);
        } 
        if (item == :onetwo) 
        {
            Storage.setValue("PPO2", 1.2);
        }
        if (item == :onethree) 
        {
            Storage.setValue("PPO2", 1.3);
        }
        if (item == :onefour) 
        {
            Storage.setValue("PPO2", 1.4);
        }
    }
}

class MainMenuDelegate extends WatchUi.MenuInputDelegate 
{
    var _dataModel as DeviceDataModel?; 

    //! Constructor
    public function initialize() {
        MenuInputDelegate.initialize();
    }

    //! Handle a menu item being chosen
    //! @param item The identifier of the chosen item
    public function onMenuItem(item as Symbol) as Void 
    {
        if (item == :search) 
        {
            BluetoothLowEnergy.setScanState(BluetoothLowEnergy.SCAN_STATE_SCANNING);
        } 
        else if (item == :stop) 
        {
            BluetoothLowEnergy.setScanState(BluetoothLowEnergy.SCAN_STATE_OFF);
        }
        else if (item == :maxPPO2) 
        {
            //BluetoothLowEnergy.setScanState(BluetoothLowEnergy.SCAN_STATE_OFF);
            var menu = new WatchUi.Menu();
            var delegate;
            menu.setTitle("Max PPO2");
            menu.addItem("1.1", :oneone);
            menu.addItem("1.2", :onetwo);
            menu.addItem("1.3", :onethree);
            menu.addItem("1.4", :onefour);
            delegate = new MODDelegate(); // a WatchUi.MenuInputDelegate
            WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
            
        }
        
        
    }
}
