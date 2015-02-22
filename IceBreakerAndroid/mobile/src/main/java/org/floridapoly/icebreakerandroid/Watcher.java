package org.floridapoly.icebreakerandroid;

import java.util.Observable;

public class Watcher {
    private static Watcher ourInstance = new Watcher();

    public static Watcher getInstance() {
        return ourInstance;
    }

    public Observable observable = new Observable();

    private Watcher() {
    }
}
