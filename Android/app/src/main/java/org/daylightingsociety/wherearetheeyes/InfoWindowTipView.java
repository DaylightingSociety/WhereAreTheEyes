package org.daylightingsociety.wherearetheeyes;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.util.AttributeSet;
import android.view.View;

/**
 * Ported by milo on 5/15/17.
 *
 * This code is pulled directly from Mapbox's old InfoWindowTipView.
 * I think they removed the code in preparation for making a fancier triangle
 * that will position itself correctly when the annotation is near the edge
 * of the screen. That's great, but we still need the original functionality right now.
 *
 * The code in this file is therefore developed by Mapbox.
 * As such, it is under their license:
 * https://github.com/Innovisite/mapbox-gl-native/blob/master/LICENSE.md
 *
 * To comply with the license we have reproduced it below:


mapbox-gl-native copyright (c) 2014, Mapbox.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

* Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in
  the documentation and/or other materials provided with the
  distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

final class InfoWindowTipView extends View {
    private Paint mPaint;
    private Path mPath;

    public InfoWindowTipView(Context context, AttributeSet attrs) {
        super(context, attrs);

        mPath = new Path();

        this.mPaint = new Paint();
        this.mPaint.setColor(Color.WHITE);
        this.mPaint.setAntiAlias(true);
        this.mPaint.setStrokeWidth(0.0f);
        this.mPaint.setStyle(Paint.Style.FILL);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        int height = getMeasuredHeight();
        int width = getMeasuredWidth();

        mPath.rewind();
        mPath.moveTo((width / 2) - height, 0);
        mPath.lineTo((width / 2) + height, 0);
        mPath.lineTo((width / 2), height);
        mPath.lineTo((width / 2) - height, 0);
        canvas.drawPath(mPath, this.mPaint);
    }
}
