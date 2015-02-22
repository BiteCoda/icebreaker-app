package org.floridapoly.icebreakerandroid;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.support.v4.content.WakefulBroadcastReceiver;

public class GcmBroadcastReceiver extends WakefulBroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        // explicitly specify GcmIntentService handles the intent
        ComponentName comp = new ComponentName(context.getPackageName(),
                GcmIntentService.class.getName());
        // start service - keeps device awake while it launches
        startWakefulService(context, (intent.setComponent(comp)));
        setResultCode(Activity.RESULT_OK);
    }
}
