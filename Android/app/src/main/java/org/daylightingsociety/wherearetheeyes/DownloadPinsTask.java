package org.daylightingsociety.wherearetheeyes;

import android.os.AsyncTask;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.mapbox.mapboxsdk.annotations.MarkerOptions;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.maps.MapboxMap;
import com.mapbox.mapboxsdk.maps.OnMapReadyCallback;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Map;


/**
 * Created by milo on 3/6/16.
 *
 * This entire task is run on a background thread, starting with "doInBackground()"
 */
public class DownloadPinsTask extends AsyncTask<PinData, Void, Void> {

    // Converts a single line of CSV data to a pin, saves it in PinData
    // The csv should be in form "latitude, longitude, verifications"
    private void parsePin(PinData p, String pinString) {
        try {
            ArrayList<String> data = new ArrayList<String>();
            for( String sec : pinString.split(", ") ) {
                data.add(sec);
                if( data.size() < 3 )
                    continue;
                double lat = Double.parseDouble(data.get(0));
                double lon = Double.parseDouble(data.get(1));
                int verifies = Integer.parseInt(data.get(2));
                LatLng pos = new LatLng(lat, lon);

                if( !p.pins.containsKey(pos) ) {
                    p.pins.put(pos, verifies);
                    Log.d("GPS", "Parsed pin at: " + pinString);
                }
            }
        } catch(Exception e) {
            Log.d("GPS", "Error parsing a pin: " + e.getMessage());
            Log.d("GPS", "Stack trace: " + e.getStackTrace());
        }
    }

    // Renders all the pins in PinData on the MapBox map
    private void renderPins(final PinData p) {
        // Note: Use a LinkedList here so we don't need contiguous memory
        // We were having some interesting memory problems with an ArrayList.
        final LinkedList<MarkerOptions> markers = new LinkedList<MarkerOptions>();

        Iterator it = p.pins.entrySet().iterator();
        while( it.hasNext() ) {
            Map.Entry pair = (Map.Entry)it.next();
            final MarkerOptions marker = new MarkerOptions().position((LatLng)pair.getKey());
            marker.title(p.map.getContext().getString(R.string.confirmations) + ": " + Integer.valueOf((int)pair.getValue()).toString());
            marker.icon(Images.getCameraIcon());
            marker.snippet("This is a camera.");
            markers.add(marker);
        }
        if( markers.size() != 0 ) {
            Log.d("GPS", "Trying to render pins: " + Integer.toString(markers.size()));

            Runnable clearPins = new Runnable() {
                public void run() {
                    p.map.getMapAsync(new OnMapReadyCallback() {
                        @Override
                        public void onMapReady(MapboxMap mapboxMap) {
                            // We don't want to layer cameras on top
                            mapboxMap.removeAnnotations();
                            mapboxMap.addMarkers(markers);
                            Log.d("GPS", "Pins now on map: " + Integer.toString(mapboxMap.getAnnotations().size()));
                        }
                    });
                }
            };

            // Note: Pins *must* be cleared on the main thread.
            // This is because if a UI window (like the pin detail screen) is currently open
            // then only the thread that created it can destroy it. If we delete the pins from
            // the background while a UI window for the pin is open it crashes the app.
            Handler mainThread = new Handler(Looper.getMainLooper());
            mainThread.post(clearPins);
        }
    }

    // We need to make a request to /getPins/:latitude/:longitude/:zoomlevel
    // The result will be pure CSV data, no HTML to parse
    protected Void doInBackground(PinData[] params) {
        PinData p = params[0];
        Log.d("GPS", "Downloading pins...");

        try {
            // Here we round our GPS coordinates to gross approximations for anonymity
            if( p.position == null ) {
                Log.d("GPS", "Position is null!!");
                return null;
            }
            String lat = Integer.toString((int)(p.position.getLatitude() + 0.5));
            String lon = Integer.toString((int)(p.position.getLongitude() + 0.5));
            String zoom = Integer.toString(4); //(int) p.map.getZoom());
            URL url = new URL("https://" + Constants.DOMAIN + "/getPins/" + lat + "/" + lon + "/" + zoom);

            // Wait a second in case we just uploaded a pin
            // This allows the server time to process the pin, so it will appear in this request
            Thread.sleep(Constants.PIN_MARK_DELAY);

            Log.d("GPS", "Download URL: " + url.toString());
            HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();
            try {
                BufferedReader in = new BufferedReader(new InputStreamReader(urlConnection.getInputStream()));
                String pin;
                while( (pin = in.readLine()) != null )
                    parsePin(p, pin);
            } catch (IOException e) {
                Log.d("GPS", "Exception reading pins: " + e.getMessage());
                return null;
            } finally {
                urlConnection.disconnect();
            }
        } catch (Exception e) {
            Log.d("GPS", "Exception downloading pins: " + e.getMessage());
            StringWriter w = new StringWriter();
            PrintWriter pw = new PrintWriter(w);
            e.printStackTrace(pw);
            pw.flush();
            Log.d("GPS", "Trace: " + w.toString());
            return null;
        }
        Log.d("GPS", "Downloaded pins: " + Integer.toString(p.pins.size()) );
        renderPins(p);
        return null;
    }
}