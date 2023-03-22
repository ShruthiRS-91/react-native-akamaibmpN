
package com.akamai.react;

import com.akamai.botman.CYFMonitor;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;
import java.util.HashMap;
import java.util.Map;

import android.app.Activity;
import android.app.Application;

public class RNAkamaibmpModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;

    private boolean isInitialized = false;
    private boolean isChallengeActionInitialized = false;

    public RNAkamaibmpModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "AkamaiBMP";
    }

    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        constants.put("logLevelInfo", CYFMonitor.INFO);
        constants.put("logLevelWarn", CYFMonitor.WARN);
        constants.put("logLevelError", CYFMonitor.ERROR);
        constants.put("logLevelNone", CYFMonitor.NONE);
        constants.put("challengeActionSuccess", 1);
        constants.put("challengeActionFail", -1);
        constants.put("challengeActionCancel", 0);
        return constants;
    }

    @ReactMethod
    public void getSensorData(Callback callback) {
        try {
            String sensordata = CYFMonitor.getSensorData();
            callback.invoke(sensordata);
        } catch (Error e) {
            callback.invoke("default-mobile");
        }
    }

    @ReactMethod
    public void setLogLevel(int logLevel) {
        CYFMonitor.setLogLevel(logLevel);
    }

    @ReactMethod
    public void configure(){
        final Activity activity = getCurrentActivity();
        if(activity==null || isInitialized){
            return;
        }
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {

                Application app = activity.getApplication();
                // we need to start collecting sensor data expelicitly
                // as the activity is already resumed when the plugin is initialized
                com.cyberfend.cyfsecurity.CYFMonitor.startCollectingSensorData(activity);

                // initialize Akamai BMP SDK
                CYFMonitor.initialize(app);
                com.cyberfend.cyfsecurity.CYFMonitor.setActivityVisible(true);
            }
        });
        isInitialized = true;
    }
   
    @ReactMethod
    public void configureWithUrl(final String url){
        final Activity activity = getCurrentActivity();
        if(activity==null || isInitialized){
            return;
        }

        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Application app = activity.getApplication();
                // we need to start collecting sensor data expelicitly
                // as the activity is already resumed when the plugin is initialized
                com.cyberfend.cyfsecurity.CYFMonitor.startCollectingSensorData(activity);

                // initialize Akamai BMP SDK
                CYFMonitor.initialize(app, url);
                com.cyberfend.cyfsecurity.CYFMonitor.setActivityVisible(true);
            }
        });
        isInitialized = true;
    }

    @ReactMethod
    public void didConfigure(Callback callback) {
        callback.invoke(isInitialized);
    }

    @ReactMethod
    public void configureChallengeAction(final String url){
        Activity activity = getCurrentActivity();
        if(activity==null || isChallengeActionInitialized){
            return;
        }
        Application app = activity.getApplication();
        CYFMonitor.configureChallengeAction(app, url);
        isChallengeActionInitialized = true;
    }

    @ReactMethod
    public void didChallengeActionConfigure(Callback callback) {
        callback.invoke(isChallengeActionInitialized);
    }

    @ReactMethod
    public void collectTestData(Callback callback){

        HashMap<Integer, String> testData = CYFMonitor.collectTestData();
        callback.invoke(testData.get(0),
                testData.get(1),
                testData.get(3),
                testData.get(5),
                testData.get(8),
                testData.get(11),
                testData.get(12),
                testData.get(14)
        );
    }


    @ReactMethod
    public void showChallengeAction(final String challengeContext, final String title, final String message, final String cancelButton, 
                    final Promise promise){

        final WritableMap map = Arguments.createMap();

        CYFMonitor.ChallengeActionCallback challengeActionCallback = new CYFMonitor.ChallengeActionCallback() {
            @Override
            public void onChallengeActionCancel() {
                map.putInt("challengeActionStatus", 0);
                promise.resolve(map);
            }
            @Override
            public void onChallengeActionFailure(String failMessage) {
                map.putInt("challengeActionStatus", -1);
                map.putString("challengeActionMessage", failMessage);
                promise.resolve(map);
            }
            @Override
            public void onChallengeActionSuccess() {
                map.putInt("challengeActionStatus", 1);
                promise.resolve(map);
            }
        };

        boolean CCAResponseCode = CYFMonitor.showChallengeAction(getCurrentActivity(), challengeContext,
                            title, message, cancelButton,
                            challengeActionCallback);
    }


}