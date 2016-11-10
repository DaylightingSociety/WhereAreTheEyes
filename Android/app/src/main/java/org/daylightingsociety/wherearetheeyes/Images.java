package org.daylightingsociety.wherearetheeyes;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.support.v4.content.ContextCompat;

import com.mapbox.mapboxsdk.annotations.Icon;
import com.mapbox.mapboxsdk.annotations.IconFactory;

/**
 * Created by milo on 8/31/16.
 *
 * This object caches the image data for each of our camera pins, and making it easy to access
 * the image resources in a format MapBox will understand.
 */
public class Images {
    private static Icon cameraIcon = null;

    private Images() {

    }

    public static void init(Context c) {
        mainContext = c;
    }

    public static final Icon getCameraIcon() {
        if( cameraIcon != null )
            return cameraIcon;
        IconFactory iconFactory = IconFactory.getInstance(mainContext);
        Drawable iconDrawable = ContextCompat.getDrawable(mainContext, R.drawable.map_pin);
        cameraIcon = iconFactory.fromDrawable(iconDrawable);
        return cameraIcon;
    }

    private static Context mainContext;
}
