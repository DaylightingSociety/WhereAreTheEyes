package org.daylightingsociety.wherearetheeyes;

import android.content.Context;
import android.os.Vibrator;

/**
 * Created by milo on 11/9/16.
 *
 * This is just a wrapper around Android vibrator calls. Later it might check a preference to decide
 * whether vibrations should be enabled or not.
 *
 */

public class Vibrate {

    private Vibrate() {

    }

    public static final void pulse(Context c) {
        Vibrator v = (Vibrator) c.getSystemService(Context.VIBRATOR_SERVICE);
        // Vibrate for 500 milliseconds
        v.vibrate(500);
    }
}
