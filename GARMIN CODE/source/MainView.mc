//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Storage;


class MainView extends WatchUi.View 
{
    private var _dataModel as DeviceDataModel;
    var ppo2 = 1.4;
    var lastConnected = false;
    
    
    var myTimer;
    var lastCalibrating = false;
    var calibratingMillis = 0;

    //! Constructor
    //! @param dataModel The data to show
    public function initialize(dataModel as DeviceDataModel) {
        View.initialize();
       
        if (Storage.getValue("PPO2") != null) { ppo2 = Storage.getValue("PPO2");}

        _dataModel = dataModel;
        _dataModel._view = self;
    }

    //! Update the view
    //! @param dc Device Context

    function timerCallback() as Void 
    {
        var millis = System.getTimer() - calibratingMillis;
       
        if (millis > 5000)
        {
            
            myTimer.stop();
            calibratingMillis = 0;
           
        }
        WatchUi.requestUpdate();
    }
    public function onUpdate(dc as Dc) as Void {
       
        
        
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
        dc.clear();
        if (!_dataModel.isConnected()) {dc.drawText(dc.getWidth() / 2, 15, Graphics.FONT_SMALL, "Disconnected", Graphics.TEXT_JUSTIFY_CENTER);}

        var profile = _dataModel.getActiveProfile();
        if ((lastConnected == true) && (_dataModel.isConnected() == false))
       
        {
            System.exit();
            //_dataModel.unpair();
            //BluetoothLowEnergy.setScanState(BluetoothLowEnergy.SCAN_STATE_SCANNING);
            //WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
        lastConnected = _dataModel.isConnected();
        if (_dataModel.isConnected() && (profile != null)) 
        {
            var midX = dc.getWidth()/2;
            var midY = dc.getHeight()/2;
            if ((profile.calibrating) && (calibratingMillis > 0))
            {
                dc.clear();
                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
                dc.drawText(midX, midY, Graphics.FONT_SMALL, "CALIBRATING",Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
                var degrees = (System.getTimer() - calibratingMillis) / 5000.0 * 360.0;
                dc.setPenWidth(10);
                dc.drawArc(midX, midY, dc.getWidth()/2 - 15, Graphics.ARC_CLOCKWISE, 90, 90-degrees);

            }
            if ((profile.calibrating == true) && (lastCalibrating == false))
            {
               
                myTimer = new Timer.Timer();
                calibratingMillis = System.getTimer();
                myTimer.start(method(:timerCallback), 50, true);
                
                
            }
            if (profile.calibrating == false)
            {
                //draw the calibration
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(midX * 1.85, midY / 1.85, Graphics.FONT_SYSTEM_XTINY, "CAL",Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
                

                
                var battery = profile.getBattery();
                if (battery != null)
                {
                    dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(midX, 15, Graphics.FONT_SMALL, Lang.format("Batt: $1$V",[battery.format("%.2f")]), Graphics.TEXT_JUSTIFY_CENTER);
                }

                var voltage = profile.getVoltage();
                if (voltage != null)
                {
                    dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(midX, 45, Graphics.FONT_SMALL, Lang.format("$1$ mV",[voltage.format("%.2f")]), Graphics.TEXT_JUSTIFY_CENTER);
                }
                var pO2 = profile.getPO2();
                if ((pO2 != null) && (pO2 > 0))
                {
                    
                    dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(midX, midY - 20, Graphics.FONT_NUMBER_THAI_HOT, Lang.format("$1$",[pO2.format("%.1f")]), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
                    
                    var modFeet = ((ppo2 * 100.0 / pO2) - 1) * 33.0;
                    var modMeters = modFeet * 0.3048;               
                    
                    if (modFeet != null) 
                    {
                        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLUE);
                        dc.drawText(midX,midY + 10,Graphics.FONT_MEDIUM,Lang.format("      MOD ($1$)      ",[ppo2.format("%.1f")]), Graphics.TEXT_JUSTIFY_CENTER);
                        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
                        dc.drawText(midX,midY + 44,Graphics.FONT_MEDIUM,Lang.format("$1$ feet",[modFeet.format("%.1f")]), Graphics.TEXT_JUSTIFY_CENTER);
                        dc.drawText(midX,midY + 74,Graphics.FONT_MEDIUM,Lang.format("$1$ Meters",[modMeters.format("%.1f")]), Graphics.TEXT_JUSTIFY_CENTER);
                    }
                }
            }
            lastCalibrating = profile.calibrating;
        }

    
    }

    
}
