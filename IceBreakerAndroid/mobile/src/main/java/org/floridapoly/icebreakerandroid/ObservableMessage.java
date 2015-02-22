package org.floridapoly.icebreakerandroid;

import java.util.Observable;

public class ObservableMessage extends Observable {

    private static ObservableMessage ourInstance = new ObservableMessage();

    public static ObservableMessage getInstance() { return ourInstance; }

    private String message;

    private ObservableMessage() {
    }

    public void setMessage(String message) {
        this.message = message;
        setChanged();
        notifyObservers();
    }

    public String getMessage() {
        return this.message;
    }
}
