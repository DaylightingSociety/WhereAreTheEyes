package org.daylightingsociety.wherearetheeyes;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.location.Location;
import android.net.Uri;
import android.os.AsyncTask;
import android.util.Log;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.UnsupportedEncodingException;
import java.net.URL;
import java.net.URLEncoder;
import java.util.AbstractMap;
import java.util.ArrayList;
import java.util.List;

import javax.net.ssl.HttpsURLConnection;

/**
 * Created by milo on 3/6/16.
 *
 * This code runs on a background thread, and sends a network request to unmark an existing camera.
 */
public class UnmarkPin extends AsyncTask<MarkData, Void, Void> {

    @Override
    protected Void doInBackground(MarkData... params) {
        Location l = params[0].loc;
        String username = params[0].username;
        Context context = params[0].context;
        Activity activity = params[0].activity;
        if( username.length() == 0 )
            return null;
        if( l == null ) {
            Log.d("Unmarking", "Location was null!");
            return null; // Location data isn't available yet!
        }
        try {
            List<AbstractMap.SimpleEntry> httpParams = new ArrayList<AbstractMap.SimpleEntry>();
            httpParams.add(new AbstractMap.SimpleEntry<>("username", username));
            httpParams.add(new AbstractMap.SimpleEntry<>("latitude", Double.valueOf(l.getLatitude()).toString()));
            httpParams.add(new AbstractMap.SimpleEntry<>("longitude", Double.valueOf(l.getLongitude()).toString()));

            // Vibrate once, let the user know we received the button tap
            Vibrate.pulse(context);

            URL url = new URL("https://" + Constants.DOMAIN + "/unmarkPin");
            HttpsURLConnection conn = (HttpsURLConnection) url.openConnection();
            try {

                conn.setReadTimeout(10000);
                conn.setConnectTimeout(15000);
                conn.setRequestMethod("POST");
                conn.setDoInput(true);
                conn.setDoOutput(true);

                OutputStream os = conn.getOutputStream();
                BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(os, "UTF-8"));

                writer.write(getQuery(httpParams));
                writer.flush();
                writer.close();
                os.close();

                String response = "";
                int responseCode = conn.getResponseCode();
                if( responseCode == HttpsURLConnection.HTTP_OK ) {
                    String line;
                    BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                    while ((line = br.readLine()) != null) {
                        response += line;
                    }
                }

                handleResponse(response, context, activity);

                Log.d("Unmarking", "Unmarked pin, got response: " + response);
            } finally {
                conn.disconnect();
            }
        } catch( Exception e ) {
            Log.e("UnmarkPin", "Error unmarking pin: " + e.getMessage());
            Log.e("UnmarkPin", Log.getStackTraceString(e));
        }

        return null;
    }

    // Creates an HTTP query string automatically
    private String getQuery(List<AbstractMap.SimpleEntry> params) throws UnsupportedEncodingException
    {
        StringBuilder result = new StringBuilder();
        boolean first = true;

        for (AbstractMap.SimpleEntry pair : params)
        {
            if (first)
                first = false;
            else
                result.append("&");

            result.append(URLEncoder.encode((String)pair.getKey(), "UTF-8"));
            result.append("=");
            result.append(URLEncoder.encode((String)pair.getValue(), "UTF-8"));
        }

        return result.toString();
    }

    // Creates the appropriate error message if necessary
    private void handleResponse(String response, final Context context, final Activity activity) {
        if(response.equals("ERROR: Invalid login")) {
            Log.d("UnmarkPin", "Parsed as 'invalid username'");
            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    AlertDialog.Builder builder = new AlertDialog.Builder(context, AlertDialog.THEME_HOLO_DARK);
                    builder.setTitle(R.string.unmarking_failed_title)
                            .setMessage(R.string.username_invalid)
                            .setCancelable(false)
                            .setPositiveButton(R.string.okay, new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog, int id) {
                                    dialog.cancel();
                                }
                            })
                            .setNegativeButton(R.string.register, new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog, int id) {
                                    Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("https://" + Constants.REGISTER_URL));
                                    activity.startActivity(browserIntent);
                                }
                            });
                    AlertDialog errorMarking = builder.create();
                    errorMarking.show();
                }
            });
        } else if(response.equals("ERROR: Geoip out of range")) {
            Log.d("UnmarkPin", "Parsed as 'geoip error'");
            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    AlertDialog.Builder builder = new AlertDialog.Builder(context, AlertDialog.THEME_HOLO_DARK);
                    builder.setTitle(R.string.unmarking_failed_title)
                            .setMessage(R.string.geoip_failed)
                            .setCancelable(false)
                            .setPositiveButton(R.string.okay, new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog, int id) {
                                    dialog.cancel();
                                }
                            });
                    AlertDialog errorMarking = builder.create();
                    errorMarking.show();
                }
            });
        } else if(response.equals("ERROR: Rate limit exceeded")) {
            Log.d("UnmarkPin", "Parsed as 'ratelimit error'");
            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    AlertDialog.Builder builder = new AlertDialog.Builder(context, AlertDialog.THEME_HOLO_DARK);
                    builder.setTitle(R.string.unmarking_failed_title)
                            .setMessage(R.string.ratelimit_failed)
                            .setCancelable(false)
                            .setPositiveButton(R.string.okay, new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog, int id) {
                                    dialog.cancel();
                                }
                            });
                    AlertDialog errorMarking = builder.create();
                    errorMarking.show();
                }
            });
        } else if(response.equals("ERROR: Permission denied")) {
            Log.d("UnmarkPin", "Parsed as 'permission denied'");
            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    AlertDialog.Builder builder = new AlertDialog.Builder(context, AlertDialog.THEME_HOLO_DARK);
                    builder.setTitle(R.string.unmarking_failed_title)
                            .setMessage(R.string.unmarking_permission_denied)
                            .setCancelable(false)
                            .setPositiveButton(R.string.okay, new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog, int id) {
                                    dialog.cancel();
                                }
                            });
                    AlertDialog errorMarking = builder.create();
                    errorMarking.show();
                }
            });
        } else if(response.startsWith("ERROR:")) {
            Log.d("UnmarkPin", "Parsed as 'other error'");
            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    AlertDialog.Builder builder = new AlertDialog.Builder(context, AlertDialog.THEME_HOLO_DARK);
                    builder.setTitle(R.string.unmarking_failed_title)
                            .setMessage(R.string.marking_failed)
                            .setCancelable(false)
                            .setPositiveButton(R.string.okay, new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog, int id) {
                                    dialog.cancel();
                                }
                            });
                    AlertDialog errorMarking = builder.create();
                    errorMarking.show();
                }
            });
        } else {
            Log.d("UnmarkPin", "Parsed as 'unmarking succeeded'");
        }
    }
}