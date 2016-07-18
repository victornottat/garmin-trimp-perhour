using Toybox.WatchUi as Ui;

class TrimpPerHourView extends Ui.SimpleDataField {

    //conf
    const movingThreshold = 1.0;

    var userRestingHR = 0;
    var genderMultiplier = 1.92;
    var userMaxHR = 0;
    var staticSport = true;

    var latestTime = 0;
    var latestHR = 0;
    var latestDistance = 0;

    var movingTime = 0.0;

    var trimp = 0.0;

    //! Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        label = "TRIMP/Hr";
        trimp = 0.0;

        genderMultiplier = UserProfile.getProfile().gender == UserProfile.GENDER_MALE ? 1.92 : 1.67;
        userRestingHR = calcNullable(UserProfile.getProfile().restingHeartRate, 0);

        var zones = UserProfile.getHeartRateZones(UserProfile.getCurrentSport());
        userMaxHR = calcNullable(zones[zones.size() - 1], 0);

        if (UserProfile.getCurrentSport() == UserProfile.HR_ZONE_SPORT_BIKING || UserProfile.getCurrentSport() == UserProfile.HR_ZONE_SPORT_RUNNING) {
            staticSport = false;
        }
    }

    //! The given info object contains all the current workout
    //! information. Calculate a value and return it in this method.
    function compute(info) {
        var time = calcNullable(info.elapsedTime, 0);
        var heartRate = calcNullable(info.currentHeartRate, 0);
        var timeVariation = (time - latestTime) / 60000.0; //Minutes
        var distance = calcNullable(info.elapsedDistance, 0);

        //convert ms to minutes at display to reduce roundings influence
        //use average speed since last measure in m/s
        if (staticSport || timeVariation > 0 && (distance - latestDistance) / (timeVariation / 1000.0) > movingThreshold) {
            trimp += timeVariation * getHeartRateReserve(heartRate) * 0.64 * Math.pow(Math.E, getExp(heartRate));
            movingTime += timeVariation;
        }

        //update latest data
        latestTime = time;
        latestHR = heartRate;
        latestDistance = distance;

        if (movingTime != 0) {
            var movingTimeHr = movingTime / 60.0;

            return (trimp / movingTimeHr).format("%3.1f");
        } else {
            return 0;
        }

    }

    function getHeartRateReserve(heartRate) {
        if (userMaxHR != userRestingHR) {
            var latestHRAverage = (heartRate + latestHR) / 2.0;
            return 1.0 * (latestHRAverage - userRestingHR) / (userMaxHR - userRestingHR);
        }
        return 0;
    }

    function getExp(heartRate) {
        return genderMultiplier * getHeartRateReserve(heartRate);
    }

    function calcNullable(nullableValue, defaultValue) {
        if (nullableValue != null) {
            return nullableValue;
        } else {
            return defaultValue;
        }
    }

}
