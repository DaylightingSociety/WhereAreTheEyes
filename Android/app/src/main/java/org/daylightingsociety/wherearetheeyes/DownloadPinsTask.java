package org.daylightingsociety.wherearetheeyes;

import android.os.AsyncTask;
import android.util.Log;

import com.mapbox.mapboxsdk.annotations.MarkerOptions;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.maps.MapboxMap;
import com.mapbox.mapboxsdk.maps.OnMapReadyCallback;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;


/**
 * Created by milo on 3/6/16.
 */
public class DownloadPinsTask extends AsyncTask<PinData, Void, Void> {

    // We need to parse a CSV of "latitude, longitude, verifications"
    private void parsePins(PinData p, String pinstream) {
        final ArrayList<MarkerOptions> markers = new ArrayList<MarkerOptions>();
        for( String pin : pinstream.split("\n") ) {
            try {
                ArrayList<String> data = new ArrayList<String>();
                for( String sec : pin.split(", ") )
                    data.add(sec);
                if( data.size() < 3 )
                    continue;
                double lat = Double.parseDouble(data.get(0));
                double lon = Double.parseDouble(data.get(1));
                int verifies = Integer.parseInt(data.get(2));
                LatLng pos = new LatLng(lat, lon);

                if( !p.pins.containsKey(pos) ) {
                    p.pins.put(pos, verifies);
                    MarkerOptions marker = new MarkerOptions().position(pos);
                    marker.title("Confirmations: " + Integer.valueOf(verifies).toString());
                    marker.icon(Images.getCameraIcon());
                    markers.add(marker);
                    Log.d("GPS", "Added pin at: " + pin);
                }
            } catch(Exception e) {
                Log.d("GPS", "Error parsing a pin: " + e.getMessage());
                Log.d("GPS", "Stack trace: " + e.getStackTrace());
            }
        }

        if( markers.size() != 0 ) // Apparently mapbox crashes if we try to add zero new pins
        {
            p.map.getMapAsync(new OnMapReadyCallback() {
                @Override
                public void onMapReady(MapboxMap mapboxMap) {
                    mapboxMap.addMarkers(markers);
                }
            });
        }
    }

    // We need to make a request to /getPins/:latitude/:longitude/:zoomlevel
    // The result will be pure CSV data, no HTML to parse
    protected Void doInBackground(PinData[] params) {
        PinData p = params[0];
        String pinstream;
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
                InputStream in = new BufferedInputStream(urlConnection.getInputStream());
                java.util.Scanner s = new java.util.Scanner(in).useDelimiter("\\A");
                pinstream = s.hasNext() ? s.next() : "";
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
        Log.d("GPS", "Downloaded pins: " + pinstream);
        parsePins(p, pinstream);
        return null;
    }
}