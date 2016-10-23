package org.daylightingsociety.wherearetheeyes;

import java.util.Date;
import java.util.HashMap;

import android.location.Location;
import android.location.LocationListener;
import android.os.Bundle;
import android.util.Log;

import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.maps.MapView;


/**
 * Created by milo on 3/5/16.
 */
public class GPS implements LocationListener {
    private Location position = null;
    private Date lastKnown = null;
    private Boolean enabled = true;
    private MapView map = null;
    private HashMap<LatLng, Integer> pins = null;

    public GPS(MapView m) {
        super();
        pins = new HashMap<LatLng, Integer>();
        map = m;
        Log.d("GPS", "Initialized");
    }

    public void onLocationChanged(Location loc) {
        // If this is our first location update just prime everything
        if( position == null || lastKnown == null ) {
            position = loc;
            lastKnown = new Date();
            new DownloadPinsTask().execute(new PinData(pins, map, position));
            return;
        }

        // How long has it been since last check-in and how far have we moved?
        float distance = loc.distanceTo(position);
        Date current = new Date();
        long diff = (current.getTime() - lastKnown.getTime()) / 1000; // Convert to seconds

        lastKnown = current;
        position = loc;

        // Don't constantly re-download pins if we're standing still
        // If we're walking over 5 meters, or it's been 30 seconds, then okay
        if( distance > Constants.MIN_DISTANCE_FOR_PIN_REDOWNLOAD || diff > Constants.MIN_TIME_FOR_PIN_REDOWNLOAD ) {
            Log.d("GPS", "PING! Triggering pin re-download. "
                    + "Distance: "
                    + Float.toString(distance)
                    + " Time diff: "
                    +  Long.toString(diff));
            new DownloadPinsTask().execute(new PinData(pins, map, position));
        } else {
            Log.d("GPS", "PING! No re-download needed. "
                    + "Distance: "
                    + Float.toString(distance)
                    + " Time diff: "
                    +  Long.toString(diff));
        }
    }

    // Redownload pins even if location hasn't changed.
    public void refreshPins() {
        new DownloadPinsTask().execute(new PinData(pins, map, position));
    }

    @Override
    public void onProviderDisabled(String provider) {enabled = false;}

    @Override
    public void onProviderEnabled(String provider) {enabled = true;}

    @Override
    public void onStatusChanged(String provider, int status, Bundle extras) {}

    public Boolean isEnabled() {
        return new Boolean(enabled);
    }

    public Location getLocation() {
        if( position == null )
            return null;
        return new Location(position);
    }

}
