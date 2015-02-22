package org.floridapoly.icebreakerandroid;

import com.loopj.android.http.*;

import org.apache.http.Header;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.util.Log;

public class Server {
    AsyncHttpClient client = new AsyncHttpClient();
    String serverUrl = "http://icebreaker.duckdns.org";
    public void register(String regid) {
        // to register with the server, we need to send it a json post
        // of a HashMap containing our major and minor beacon ids
        // our registration id with GCM
        // and our device type (android)
        RequestParams paramMap = new RequestParams();
        paramMap.put("userId", "(major:(31782), minor:(36689))");
        paramMap.put("deviceToken", regid);
        paramMap.put("deviceType", "android");
        client.post(serverUrl + "/subscribe",
                paramMap,
                new JsonHttpResponseHandler());
    }

    public void getMessage(String userId, String targetId) {
        RequestParams paramMap = new RequestParams();
        paramMap.put("userId", userId);
        paramMap.put("targetId", targetId);
        client.post(serverUrl + "/message",
                paramMap,
                new JsonHttpResponseHandler() {
                    @Override
                    public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                        super.onSuccess(statusCode, headers, response);
                        Server.parseResponse(response);
                    }

                    @Override
                    public void onFailure(int statusCode, Header[] headers, String responseString, Throwable throwable) {
                        super.onFailure(statusCode, headers, responseString, throwable);
                        Log.i(Constants.TAG, "getMessage failed for environmental reasons.");
                    }
                }
        );
    }

    public static void parseResponse(JSONObject response) {
        String message = "";
        try {
            if (!response.getBoolean("success")) {
                Log.i(Constants.TAG, "getMessage was not successful.");
                JSONArray errors = response.getJSONArray("errors");
                for (int index = 0; index < errors.length(); index++) {
                   Log.i(Constants.TAG, errors.getString(index));
                }
                message = "Failed.";
            } else {
                JSONObject object = response.getJSONObject("object");
                message += object.getString("author");
                message += "\n";
                message += object.getString("category");
                message += "\n";
                message += object.getString("quote");
                message += "\n";
            }
            Log.i(Constants.TAG, message);
            ObservableMessage.getInstance().setMessage(message);
        } catch (JSONException ex) {
            Log.i(Constants.TAG, "JSONException: " + ex.getMessage());
        }
    }
}
