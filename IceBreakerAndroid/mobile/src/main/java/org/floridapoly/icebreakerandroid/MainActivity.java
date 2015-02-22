package org.floridapoly.icebreakerandroid;

import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ProgressBar;
import android.content.Context;
import com.google.android.gms.common.GooglePlayServicesUtil;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.gcm.GoogleCloudMessaging;

import android.util.Log;

import java.io.IOException;

public class MainActivity extends ActionBarActivity {

    // tag used for logging purposes
    static final String TAG = "IceBreaker";

    // request code given when calling startActivityForResult
    private final static int PLAY_SERVICES_RESOLUTION_REQUEST = 9000;
    // project number used as sender_id
    String SENDER_ID = "835233388096";

    GoogleCloudMessaging gcm;
    Context context;

    // our registration id
    String regid;

    private ProgressBar spinner;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        // get our application context
        context = getApplicationContext();
        // we need a valid play services apk to get push notifications
        if (checkPlayServices()) {
            gcm = GoogleCloudMessaging.getInstance(this);
            // our server is stateless; create new regid every time
            // this is blocking, so we'll see if it causes problems
            try {
                regid = gcm.register(SENDER_ID);
            } catch (IOException ex) {
                Log.i(TAG, "IOException when registering: " + ex.getMessage());
            }
        } else {
            Log.i(TAG, "No valid Google Play Services APK found.");
        }
        // spinning progress bar animation during search
        spinner = (ProgressBar) findViewById(R.id.progressBar);
        spinner.setVisibility(View.GONE);
    }

    // we need to check for play services apk here too
    @Override
    protected void onResume() {
       super.onResume();
       checkPlayServices();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    public void onClick(View view) {
        // here's where we'll start searching, etc.
        spinner.setVisibility(View.VISIBLE);

    }

    /**
     * Check the device to make sure it has the Google Play Services APK. If
     * it doesn't, display a dialog that allows users to download the APK from
     * the Google Play Store or enable it in the device's system settings.
     */
    private boolean checkPlayServices() {
        int resultCode = GooglePlayServicesUtil.isGooglePlayServicesAvailable(this);
        if (resultCode != ConnectionResult.SUCCESS) {
            if (GooglePlayServicesUtil.isUserRecoverableError(resultCode)) {
                GooglePlayServicesUtil.getErrorDialog(resultCode, this,
                        PLAY_SERVICES_RESOLUTION_REQUEST).show();
            } else {
                Log.i(TAG, "This device is not supported.");
                finish();
            }
            return false;
        }
        return true;
    }
}
