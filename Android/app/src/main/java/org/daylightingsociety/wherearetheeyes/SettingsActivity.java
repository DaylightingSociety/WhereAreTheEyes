package org.daylightingsociety.wherearetheeyes;

import android.os.Bundle;
import android.preference.CheckBoxPreference;
import android.preference.EditTextPreference;
import android.preference.Preference;
import android.preference.PreferenceActivity;
import android.text.InputFilter;
import android.text.Spanned;
import android.util.Log;

import com.mapbox.mapboxsdk.telemetry.MapboxEventManager;

/**
 * Created by milo on 4/2/16.
 *
 * This file sets up some handlers so we can trigger events when the user changes settings.
 *
 */
public class SettingsActivity extends PreferenceActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        addPreferencesFromResource(R.xml.preferences);

        final EditTextPreference username = (EditTextPreference) getPreferenceManager().findPreference("username_preference");
        final CheckBoxPreference mapboxanalytics = (CheckBoxPreference) getPreferenceManager().findPreference("mapbox_analytics");

        // Set the title to include the username if there is one
        if( username.getText().length() > 0 )
            username.setTitle("Username (" + username.getText() + ")");

        // This big block of code is equivalent to s/[^A-Za-z0-9_]//g
        InputFilter usernameFilter = new InputFilter() {
            public CharSequence filter(CharSequence source, int start, int end,
                                       Spanned dest, int dstart, int dend) {
                for (int i = start; i < end; i++) {
                    if (!Character.isLetterOrDigit(source.charAt(i)) && source.charAt(i) != '_' ) {
                        return "";
                    }
                }
                return null;
            }
        };
        username.getEditText().setFilters(new InputFilter[] { usernameFilter });

        // Set a callback so we can update the username text when user changes it
        username.setOnPreferenceChangeListener(new Preference.OnPreferenceChangeListener() {
            @Override
            public boolean onPreferenceChange(Preference preference, Object newValue) {
                if( newValue.toString().length() > 0 )
                    preference.setTitle("Username (" + newValue.toString() + ")");
                else
                    preference.setTitle("Username");
                Log.d("PREFERENCES", "Updated username to: " + newValue.toString());
                return true; // Returning true commits the change
            }
        });

        mapboxanalytics.setOnPreferenceChangeListener(new Preference.OnPreferenceChangeListener() {
            @Override
            public boolean onPreferenceChange(Preference preference, Object newValue) {
                MapboxEventManager.getMapboxEventManager().setTelemetryEnabled((Boolean)newValue);
                Boolean nowSet = MapboxEventManager.getMapboxEventManager().isTelemetryEnabled();
                Log.d("PREFERENCES", "Updated mapbox analytics to: " + nowSet.toString());
                return true; // Returning true commits the change
            }
        });

        Log.d("Settings", "Starting settings.");
    }
}