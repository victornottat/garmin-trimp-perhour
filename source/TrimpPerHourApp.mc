using Toybox.Application as App;


class TrimpPerHourApp extends App.AppBase {

    const DEFAULT_MAX_HR = 190; // Equals to 220 - 30y = 190bpm
    const DEFAULT_REST_HR = 60; // Equals to common rest hr at 60bpm

    var userMaxHR;
    var userRestHR;

    function initialize() {
        AppBase.initialize();
    }

    //! onStart() is called on application start up
    function onStart() {
        System.println("onStart() called");
        
        // Getting MAX hr from end value of last zone
        var hrZones = UserProfile.getHeartRateZones(UserProfile.getCurrentSport());

        userMaxHR = Utils.replaceNull(hrZones[hrZones.size() - 1], DEFAULT_MAX_HR);

        // Updating REST hr from device settings
        userRestHR = Utils.replaceNull(UserProfile.getProfile().restingHeartRate, DEFAULT_REST_HR);
    }

    //! onStop() is called when your application is exiting
    function onStop() {
        System.println("onStop() called");
    }

    function onSettingsChanged() {
        System.println("onSettingsChanged() called");
    }

    //! Return the initial view of your application here
    function getInitialView() {
        System.println("getInitialView() called");
        return [new TrimpPerHourView(userMaxHR, userRestHR)];
    }

}
