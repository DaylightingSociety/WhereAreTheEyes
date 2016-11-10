package org.daylightingsociety.wherearetheeyes;

/**
 * This stores constants needed in several places through the codebase, outside of activities.
 * Resources files like 'strings.xml' are only accessible from within activities.
 * This is a clunky solution, but appears to be the cleanest available.
 *
 * Created by milo on 7/4/16.
 */
public abstract class Constants {
    public static final String DOMAIN = "eyes.daylightingsociety.org";
    public static final String REGISTER_URL = DOMAIN + "/register";
    public static final String APIKEY = "pk.eyJ1IjoibWlsby10cnVqaWxsbyIsImEiOiJjaXZiZTBua2IwMTF1MnRtcWRra2Z3ZGdoIn0.12wTGPPbJeyjaiJagmGC3Q";
    public static final Integer MIN_DISTANCE_FOR_PIN_REDOWNLOAD = 100; // In meters
    public static final Integer MIN_TIME_FOR_PIN_REDOWNLOAD = 60; // In seconds
    public static final Integer PIN_MARK_DELAY = 1000; // How many milliseconds to wait before polling server
}
