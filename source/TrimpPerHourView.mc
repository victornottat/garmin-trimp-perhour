using Toybox.WatchUi as Ui;

class TrimpPerHourView extends Ui.SimpleDataField {

    //conf
    const MOVING_THRESHOLD = 1.0;
    const DEFAULT_MAX_HR = 190; // Equals to 220 - 30y = 190bpm
    const DEFAULT_REST_HR = 60; // Equals to common rest hr at 60bpm

    var genderMultiplier = 1.92; // Default MALE HRR computation multiplier

    var userMaxHR;
    var userRestHR;
    var staticSport = true;

    var latestTime = 0;
    var latestHeartRate = 0;
    var latestDistance = 0;

    var movingTime = 0.0;

    var trimp = 0.0;

    //! Set the label of the data field here.
    function initialize() {

        SimpleDataField.initialize();
        label = "TRIMP/Hr";
        
        // Female athlete? If yes adapt gender mulpiplier
        if (UserProfile.getProfile().gender == UserProfile.GENDER_FEMALE) {
            genderMultiplier = 1.67;
        }

        // Getting MAX hr from end value of last zone
        var hrZones = UserProfile.getHeartRateZones(UserProfile.getCurrentSport());
        userMaxHR = replaceNull(hrZones[hrZones.size() - 1], DEFAULT_MAX_HR);

        // Updating REST hr from device settings
        userRestHR = replaceNull(UserProfile.getProfile().restingHeartRate, DEFAULT_REST_HR);

        if (UserProfile.getCurrentSport() == UserProfile.HR_ZONE_SPORT_BIKING || UserProfile.getCurrentSport() == UserProfile.HR_ZONE_SPORT_RUNNING) {
            staticSport = false;
        }

        System.println("Using MAX HR :" + userMaxHR);
        System.println("Using REST HR :" + userRestHR);
    }

    //! The given info object contains all the current workout
    //! information. Calculate a value and return it in this method.
    function compute(info) {
        var elapsedTime = replaceNull(info.elapsedTime, 0);
        var currentHeartRate = replaceNull(info.currentHeartRate, 0);
        var timeVariation = (elapsedTime - latestTime) / 60000.0; //Minutes
        var distance = replaceNull(info.elapsedDistance, 0);

        // Convert ms to minutes at display to reduce roundings influence
        // Use average speed since last measure in m/s
        if (staticSport || timeVariation > 0 && (distance - latestDistance) / (timeVariation / 1000.0) > MOVING_THRESHOLD) {
            trimp += timeVariation * getHeartRateReserve(currentHeartRate) * 0.64 * Math.pow(Math.E, getExp(currentHeartRate));
            movingTime += timeVariation;
        }

        // Update latest data
        latestTime = elapsedTime;
        latestHeartRate = currentHeartRate;
        latestDistance = distance;

        if (movingTime > 0) {
            var movingTimeHr = movingTime / 60.0;
            return (trimp / movingTimeHr).format("%3.1f");
        } else {
            return 0;
        }

    }

    function getHeartRateReserve(heartRate) {
        if (userMaxHR != userRestHR) {
            var latestHeartRateAvg = (heartRate + latestHeartRate) / 2.0;
            return 1.0 * (latestHeartRateAvg - userRestHR) / (userMaxHR - userRestHR);
        }
        return 0;
    }

    function getExp(heartRate) {
        return genderMultiplier * getHeartRateReserve(heartRate);
    }

    function replaceNull(nullableValue, defaultValue) {
        if (nullableValue != null) {
            return nullableValue;
        } else {
            return defaultValue;
        }
    }

}
