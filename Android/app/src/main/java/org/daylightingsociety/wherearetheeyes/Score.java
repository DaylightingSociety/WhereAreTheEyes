package org.daylightingsociety.wherearetheeyes;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Handler;
import android.os.Looper;
import android.preference.PreferenceManager;
import android.util.Log;
import android.widget.TextView;

import java.io.BufferedInputStream;
import java.io.InputStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.net.URL;
import java.util.ArrayList;

import javax.net.ssl.HttpsURLConnection;

/**
 * Created by milo on 7/20/16.
 *
 * This code is responsible for making network requests to load our score,
 * caching the results, and returning scores when asked for.
 *
 * It caches the username so that we can invalidate our cache if the username changes.
 */
public class Score {
    private SharedPreferences preferences;
    private int cameras_marked = 0;
    private int verifications = 0;
    private TextView cameraScore = null;
    private TextView verificationScore = null;
    private boolean previousEnabledState = false;
    private String oldUsername = "";

    public Score(Context c, TextView _cameraScore, TextView _verificationScore)
    {
        preferences = PreferenceManager.getDefaultSharedPreferences(c);
        cameraScore = _cameraScore;
        verificationScore = _verificationScore;
        previousEnabledState = preferences.getBoolean("show_score", true);
    }

    // Returns whether scores are enabled, and forces a score update
    // if scores have been enabled since last check or username has changed.
    public boolean scoresEnabled(String username) {
        boolean state = preferences.getBoolean("show_score", true);
        if( state == true && previousEnabledState == false ) {
            clearScore();
            updateScore(username);
        }
        if( state == true && !username.equals(oldUsername) ) {
            clearScore();
            updateScore(username);
        }
        previousEnabledState = state;
        oldUsername = username;
        return state;
    }

    public void clearScore() {
        cameras_marked = 0;
        verifications = 0;

        // UI Updates must occur on the main thread
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                cameraScore.setText(Integer.toString(cameras_marked));
                verificationScore.setText(Integer.toString(verifications));
            }
        });
    }

    public int getCamerasMarked() {
        return cameras_marked;
    }

    public int getVerifications() {
        return verifications;
    }

    // This runs a little task in the background for downloading scores
    public void updateScore(final String username) {
        if( username.length() == 0 ) {
            cameras_marked = 0;
            verifications = 0;
            return;
        }

        AsyncTask.execute(new Runnable() {
            @Override
            public void run() {
                String result = "";
                try {
                    // Wait a second in case we just uploaded a pin
                    // This allows the server time to process the pin, so it will appear in this request
                    Thread.sleep(Constants.PIN_MARK_DELAY);

                    URL url = new URL("https://" + Constants.DOMAIN + "/getScore/" + username);
                    HttpsURLConnection conn = (HttpsURLConnection) url.openConnection();

                    InputStream in = new BufferedInputStream(conn.getInputStream());
                    java.util.Scanner s = new java.util.Scanner(in).useDelimiter("\\A");
                    result = s.hasNext() ? s.next() : "";

                    conn.disconnect();

                    parseDownload(result);
                } catch (Exception e) {
                    Log.d("Score", "Crash while downloading score: " + e.getMessage());
                    StringWriter w = new StringWriter();
                    PrintWriter pw = new PrintWriter(w);
                    e.printStackTrace(pw);
                    pw.flush();
                    Log.d("Score", "Trace: " + w.toString());
                }
            }
        });
    }

    // This is run on a background thread inside the above AsyncTask
    private void parseDownload(String data) {
        Log.d("Score", "Downloaded score data: " + data);

        // This is cleaner than catching an exception when parsing the score data explodes
        if( data == null || data.startsWith("ERROR:") )
            return;

        ArrayList<String> scores = new ArrayList<String>();
        for( String score : data.split(", ") ) {
            scores.add(score.replaceAll("[^\\d]", ""));
        }
        cameras_marked = Integer.parseInt(scores.get(0));
        verifications = Integer.parseInt(scores.get(1));

        // UI Updates must occur on the main thread
        new Handler(Looper.getMainLooper()).post(new Runnable() {
           @Override
           public void run() {
               cameraScore.setText(Integer.toString(cameras_marked));
               verificationScore.setText(Integer.toString(verifications));
           }
        });
    }
}
