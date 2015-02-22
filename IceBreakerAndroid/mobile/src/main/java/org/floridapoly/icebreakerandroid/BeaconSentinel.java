package org.floridapoly.icebreakerandroid;

import android.content.Context;
import android.os.RemoteException;
import android.util.Log;

import com.estimote.sdk.Beacon;
import com.estimote.sdk.BeaconManager;
import com.estimote.sdk.Region;

import java.util.HashSet;
import java.util.List;
import java.util.Stack;

public class BeaconSentinel {
    private static BeaconSentinel ourInstance;

    public static BeaconSentinel getInstance(Context context) {
        if (ourInstance == null) {
            ourInstance = new BeaconSentinel(context);
        }
        return ourInstance;
    }

    BeaconManager beaconManager;
    Stack<Beacon> beaconStack;
    HashSet<Beacon> beaconSet;

    private static final Region ALL_ESTIMOTE_BEACONS = new Region("region", Constants.UUID, null, null);

    private BeaconSentinel(final Context context) {
        this.beaconStack = new Stack<Beacon>();
        this.beaconSet = new HashSet<Beacon>();
        this.beaconManager = new BeaconManager(context);
        this.beaconManager.setRangingListener(new BeaconManager.RangingListener() {
            @Override
            public void onBeaconsDiscovered(Region region, final List<Beacon> beacons) {
                for (Beacon beacon : beacons) {
                    if (beacon.getMajor() != Constants.major) {
                        // should check minor too?
                        if (!BeaconSentinel.getInstance(context).beaconSet.contains(beacon)) {
                            BeaconSentinel.getInstance(context).beaconSet.add(beacon);
                            BeaconSentinel.getInstance(context).beaconStack.push(beacon);
                            Log.i(Constants.TAG, "Added beacon: " + beacon.toString());
                        }
                    }
                }
            }
        });
    }

    public void startSearch() {
        beaconManager.connect(new BeaconManager.ServiceReadyCallback() {
            @Override public void onServiceReady() {
                try {
                    beaconManager.startRanging(ALL_ESTIMOTE_BEACONS);
                } catch (RemoteException e) {
                    Log.e(Constants.TAG, "Cannot start ranging", e);
                }
            }
        });
    }

    public void shutdown() {
        beaconManager.disconnect();
    }

    public String getTarget() {
        if (this.beaconStack.isEmpty()) {
            Log.i(Constants.TAG, "Set is empty");
            // we were going to fail anyway, may as well fail hard.
            return "";
        } else {
            Beacon maybeTarget = this.beaconStack.pop();
            int major = maybeTarget.getMajor();
            int minor = maybeTarget.getMinor();
            String targetUserId = "(major:";
            targetUserId += major;
            targetUserId += ", minor:";
            targetUserId += minor;
            targetUserId += ")";
            return targetUserId;
        }
    }
}
