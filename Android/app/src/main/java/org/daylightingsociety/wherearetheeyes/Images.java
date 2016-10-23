package org.daylightingsociety.wherearetheeyes;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.support.v4.content.ContextCompat;

import com.mapbox.mapboxsdk.annotations.Icon;
import com.mapbox.mapboxsdk.annotations.IconFactory;

/**
 * Created by milo on 8/31/16.
 */
public class Images {
    private Images() {

    }

    public static void init(Context c) {
        mainContext = c;
    }

    public static Icon getCameraIcon() {
        IconFactory iconFactory = IconFactory.getInstance(mainContext);
        Drawable iconDrawable = ContextCompat.getDrawable(mainContext, R.drawable.map_pin);
        Icon cameraIcon = iconFactory.fromDrawable(iconDrawable);
        return cameraIcon;
    }

    private static Context mainContext;
}
