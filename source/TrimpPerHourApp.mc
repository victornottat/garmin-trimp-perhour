using Toybox.Application as App;


class TrimpPerHourApp extends App.AppBase {

    //const DEFAULT_MAX_HR = 190; // Equals to 220 - 30y = 190bpm
    //const DEFAULT_REST_HR = 60; // Equals to common rest hr at 60bpm

    function initialize() {
        AppBase.initialize();
    }

    //! onStart() is called on application start up
    function onStart(state) {
        System.println("onStart() called");
    }

    //! onStop() is called when your application is exiting
    function onStop(state) {
        System.println("onStop() called");
    }

    function onSettingsChanged() {
        System.println("onSettingsChanged() called");
    }

    //! Return the initial view of your application here
    function getInitialView() {
        System.println("getInitialView() called");
        return [new TrimpPerHourView()];
    }

}
