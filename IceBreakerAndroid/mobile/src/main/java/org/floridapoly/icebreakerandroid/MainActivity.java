package org.floridapoly.icebreakerandroid;

import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.os.AsyncTask;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ProgressBar;
import android.content.Context;
import com.google.android.gms.common.GooglePlayServicesUtil;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.gcm.GoogleCloudMessaging;

import android.util.Log;
import android.widget.TextView;

import java.io.IOException;
import java.util.Observable;
import java.util.Observer;

public class MainActivity extends ActionBarActivity implements Observer {

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

    // communication with server
    Server server;

    private ProgressBar spinner;
    private TextView message;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // we watch the watcher
        ObservableMessage.getInstance().addObserver(this);
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        // get our application context
        context = getApplicationContext();
        // we need a valid play services apk to get push notifications
        if (checkPlayServices()) {
            gcm = GoogleCloudMessaging.getInstance(this);
            // our server is stateless; create new regid every time
            // this is blocking, so we'll see if it causes problems
            registerInBackground();
        } else {
            Log.i(TAG, "No valid Google Play Services APK found.");
            finish();
        }

        // spinning progress bar animation during search
        spinner = (ProgressBar) findViewById(R.id.progressBar);
        spinner.setVisibility(View.GONE);
        // text box
        message = (TextView) findViewById(R.id.textView);
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
        server.getMessage(Constants.userId);
    }

    @Override
    public void update(Observable observable, Object data) {
        message.setText(ObservableMessage.getInstance().getMessage());
        spinner.setVisibility(View.GONE);
        Log.i(Constants.TAG, "I am updating the textView.");
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

    private void registerInBackground() {
        new AsyncTask<Void, String, String>() {
            @Override
            protected String doInBackground(Void... params) {
                String msg;
                try {
                    if (gcm == null) {
                        gcm = GoogleCloudMessaging.getInstance(context);
                    }
                    regid = gcm.register(SENDER_ID);
                    msg = "Device registered, registration ID=" + regid;

                    // You should send the registration ID to your server over HTTP,
                    // so it can use GCM/HTTP or CCS to send messages to your app.
                    // The request to your server should be authenticated if your app
                    // is using accounts.

                    // For this demo: we don't need to send it because the device
                    // will send upstream messages to a server that echo back the
                    // message using the 'from' address in the message.

                    // Persist the registration ID - no need to register again.
                } catch (IOException ex) {
                    msg = "Error :" + ex.getMessage();
                    // If there is an error, don't just keep trying to register.
                    // Require the user to click a button again, or perform
                    // exponential back-off.
                }
                return msg;
            }

            @Override
            protected void onPostExecute(String msg) {
                Log.i(TAG, "Registered with GCM Server" + msg);
                MainActivity.this.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        server = new Server();
                        server.register(regid);
                    }
                });
            }
        }.execute(null, null, null);
    }
}
