package org.floridapoly.icebreaker;

/**
 * Created by Britt on 2/21/2015.
 */
public class BeaconHandler {
    private static BeaconHandler ourInstance = new BeaconHandler();

    public static BeaconHandler getInstance() {
        return ourInstance;
    }

    private BeaconHandler() {
    }
}
