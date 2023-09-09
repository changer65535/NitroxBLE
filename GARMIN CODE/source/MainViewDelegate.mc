//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Lang;
import Toybox.WatchUi;
import WatchUi;


class MainViewDelegate extends WatchUi.BehaviorDelegate 
{
    private var _deviceDataModel as DeviceDataModel;
    var progressBar;
    var myCount = 0.0;
    

    //! Constructor
    //! @param deviceDataModel The device data model
    public function initialize(deviceDataModel as DeviceDataModel,theView as MainView) 
    {
        BehaviorDelegate.initialize();

        _deviceDataModel = deviceDataModel;
        _deviceDataModel.pair();
    }

    //! Handle the back behavior
    //! @return true if handled, false otherwise
    
    public function onBack() as Boolean 
    {
        
        _deviceDataModel.unpair();
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
         

        
        
        

        return true;
    }
    



    
    
    public function onSelect() as Boolean 
    {

        //System.println ("calibrate!");
        var profile = _deviceDataModel.getActiveProfile();
        if (_deviceDataModel.isConnected() && (profile != null)) 
        {
            profile.startCalibrating();
            
           
        }
        return true;
    }
}
