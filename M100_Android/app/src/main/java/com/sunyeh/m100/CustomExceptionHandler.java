package com.sunyeh.m100;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

/**
 * Created by hsu on 2017/4/5.
 */

public class CustomExceptionHandler implements Thread.UncaughtExceptionHandler {
    private final Thread.UncaughtExceptionHandler defaultUEH;
    private boolean isDebug = true;

    public CustomExceptionHandler(Thread.UncaughtExceptionHandler defaultUEH) {
        this.defaultUEH = defaultUEH;
    }

    public static boolean isNetworkAvailable(Context context) {
        ConnectivityManager connectivityManager  = (ConnectivityManager)context.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo activeNetworkInfo = connectivityManager.getActiveNetworkInfo();
        return activeNetworkInfo != null && activeNetworkInfo.isConnected();
    }

    @Override
    public void uncaughtException(Thread t, Throwable e) {
        StackTraceElement[] arr = e.getStackTrace();
        String Raghav = t.toString();
        String report = e.toString()+"\n\n";
        report += "--------- Stack trace ---------\n\n"+Raghav;
        for (int i=0; i<arr.length; i++)
        {
            report += "    "+arr[i].toString()+"\n";
        }
        report += "-------------------------------\n\n";

        // If the exception was thrown in a background thread inside
        // AsyncTask, then the actual exception can be found with getCause
        report += "--------- Cause ---------\n\n";
        Throwable cause = e.getCause();
        if(cause != null) {
            report += cause.toString() + "\n\n";
            arr = cause.getStackTrace();
            for (int i=0; i<arr.length; i++)
            {
                report += "    "+arr[i].toString()+"\n";
            }
        }
        report += "-------------------------------\n\n";

        final String errMsg = report;

        if (MyApplication.context != null) {
            if (!isDebug) return;
            if (isNetworkAvailable(MyApplication.context)) {
                new Thread() {
                    public void run() {
                        WebService.debug(MyApplication.context, errMsg);
                    }
                }.start();
            }
        }

        defaultUEH.uncaughtException(t, e);
    }
}
