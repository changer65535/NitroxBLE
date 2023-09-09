//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Application;
import Toybox.BluetoothLowEnergy;
import Toybox.Lang;
import Toybox.WatchUi;

//! This app uses the Bluetooth Low Energy API to pair with devices.
class Nitrox02App extends Application.AppBase 
{
    private var _bleDelegate as NitroxBLEDelegate?;
    private var _profileManager as ProfileManager?;
    private var _modelFactory as DataModelFactory?;
    private var _viewController as ViewController?;

    //! Constructor
    public function initialize() {
        AppBase.initialize();
    }

    //! Handle app startup 
    //! @param state Startup arguments
    public function onStart(state as Dictionary?) as Void 
    {
        _profileManager = new $.ProfileManager();
        _bleDelegate = new $.NitroxBLEDelegate(_profileManager as ProfileManager);
        _modelFactory = new $.DataModelFactory(_bleDelegate as NitroxBLEDelegate, _profileManager as ProfileManager);
        _viewController = new $.ViewController(_modelFactory as DataModelFactory);

        BluetoothLowEnergy.setDelegate(_bleDelegate as NitroxBLEDelegate);
        if (_profileManager != null) {
            _profileManager.registerProfiles();
        }
    }

    //! Handle app shutdown
    //! @param state Shutdown arguments
    public function onStop(state as Dictionary?) as Void 
    {
        _viewController = null;
        _modelFactory = null;
        _profileManager = null;
        _bleDelegate = null;
    }

    //! Return the initial views for the app
    //! @return Array Pair [View, InputDelegate]
    public function getInitialView() as Array<Views or InputDelegates>? 
    {
        if (_viewController != null) 
        {
            return _viewController.getInitialView();
        }
        return null;
    }

}
