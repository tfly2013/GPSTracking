package gps.tracking.android.orange;

import android.content.Context;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.toolbox.Volley;

public class VolleyHelper {
    public static final String DOMAIN = "http://stormy-bastion-5570.herokuapp.com";
//    public static final String DOMAIN = "http://8a1fa938.ngrok.io";
    public static final String LOCATION_URL = DOMAIN + "/api/locations";
    public static final String LOGIN_URL = DOMAIN + "/api/sign_in";
    public static final String LOGOUT_URL = DOMAIN + "/api/sign_out";

    private static VolleyHelper mInstance;
    private RequestQueue mRequestQueue;
    private static Context mCtx;

    private VolleyHelper(Context context) {
        mCtx = context;
        mRequestQueue = getRequestQueue();
    }

    public static synchronized VolleyHelper getInstance(Context context) {
        if (mInstance == null) {
            mInstance = new VolleyHelper(context);
        }
        return mInstance;
    }

    public RequestQueue getRequestQueue() {
        if (mRequestQueue == null) {
            // getApplicationContext() is key, it keeps you from leaking the
            // Activity or BroadcastReceiver if someone passes one in.
            mRequestQueue = Volley.newRequestQueue(mCtx.getApplicationContext());
        }
        return mRequestQueue;
    }

    public <T> void addToRequestQueue(Request<T> req) {
        getRequestQueue().add(req);
    }
}