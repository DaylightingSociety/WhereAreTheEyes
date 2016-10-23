package org.daylightingsociety.wherearetheeyes;

import android.location.Location;

import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.maps.MapView;

import java.util.HashMap;

/**
 * PinData is needed to communicate information between the GPS code and other threads.
 * Created by milo on 3/6/16.
 */
public class PinData {
    HashMap<LatLng, Integer> pins;
    MapView map;
    Location position;

    PinData(HashMap<LatLng, Integer> p, MapView m, Location l) {
        pins = p;
        map = m;
        position = l;
    }
}