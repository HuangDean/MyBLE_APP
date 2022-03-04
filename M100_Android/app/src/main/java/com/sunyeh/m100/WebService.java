package com.sunyeh.m100;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.os.Build;
import android.util.Log;

import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.toolbox.RequestFuture;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;


public class WebService {
    private static final int READ_TIMEOUT = 5 * 1000;
    private static final String WEB_DEBUG_URL = "http://106.104.165.121:1858/debug";
    private static boolean isDebug = true;

    static String performPostCall(Context context, String url, final HashMap<String, String> params) {
        String result = "";

        try {
            RequestQueue queue = Volley.newRequestQueue(context);
            RequestFuture<String> future = RequestFuture.newFuture();
            StringRequest request = new StringRequest(Request.Method.POST, url, future, future) {
                @Override
                protected Map<String, String> getParams() throws AuthFailureError {
                    return params;
                }
            };
            queue.add(request);

            result = future.get(READ_TIMEOUT, TimeUnit.SECONDS); // Blocks for at most 10 seconds.
        } catch (Exception e) {
            e.printStackTrace();
        }

        Log.e("performPostCall: ", result);
        return result;
    }

    public static int debug(Context context, String message) {


        int result = 0;
        String url = WEB_DEBUG_URL;

        try {
            PackageInfo pInfo = context.getPackageManager().getPackageInfo(context.getPackageName(), 0);
            String version = pInfo.versionName;

            HashMap<String, String> params = new HashMap<String, String>();
            params.put("platform", "ANDROID");
            params.put("model", Build.MANUFACTURER + "," + Build.MODEL + "," + Build.VERSION.RELEASE);
            params.put("package", context.getPackageName() + "(" + version + ")");
            params.put("content", message);

            try {
                if (isDebug) {
                    performPostCall(context, url, params);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        } catch (Exception e) {
            result = -1;
            e.printStackTrace();
        }

        return result;
    }
}
