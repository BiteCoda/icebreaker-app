package org.floridapoly.icebreakerandroid;

import com.loopj.android.http.*;

public class Server {
    AsyncHttpClient client = new AsyncHttpClient();
    public void register(String regid) {
        // to register with the server, we need to send it a json post
        // of a HashMap containing our major and minor beacon ids
        // our registration id with GCM
        // and our device type (android)
        // (major:31782, minor:36689)
        // http://icebreaker.duckdns.org
        RequestParams paramMap = new RequestParams();
        paramMap.put("userId", "(major:(31782), minor:(36689))");
        paramMap.put("deviceToken", regid);
        paramMap.put("deviceType", "android");
        client.post("http://icebreaker.duckdns.org/subscribe",
                paramMap,
                new JsonHttpResponseHandler());
    }
}
