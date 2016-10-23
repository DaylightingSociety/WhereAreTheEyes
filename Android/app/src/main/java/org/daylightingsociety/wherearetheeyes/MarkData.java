package org.daylightingsociety.wherearetheeyes;

import android.app.Activity;
import android.content.Context;
import android.location.Location;

/**
 * Created by milo on 4/2/16.
 */
public class MarkData {
    public String username;
    public Location loc;

    // We need these two so that we can create a pop-up if marking the pin fails
    public Context context;
    public Activity activity;

    public MarkData(String u, Location l, Context c, Activity a) {
        username = u;
        loc = l;
        context = c;
        activity = a;
    }
}