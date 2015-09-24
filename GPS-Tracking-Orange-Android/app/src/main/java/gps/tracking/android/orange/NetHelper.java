package gps.tracking.android.orange;

import android.content.Context;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.toolbox.Volley;

public class NetHelper {
    public static final String DOMAIN = "http://stormy-bastion-5570.herokuapp.com";
//    public static final String DOMAIN = "http://b733b06d.ngrok.io";
    public static final String LOGIN_URL = DOMAIN + "/api/sign_in";
    public static final String LOGOUT_URL = DOMAIN + "/api/sign_out";
    public static final String TRIP_URL = DOMAIN + "/trips";
    public static final String SIGNUP_URL = DOMAIN + "/users/sign_up";

    private static NetHelper mInstance;
    private RequestQueue mRequestQueue;
    private static Context mCtx;

    private NetHelper(Context context) {
        mCtx = context;
        mRequestQueue = getRequestQueue();
    }

    public static synchronized NetHelper getInstance(Context context) {
        if (mInstance == null) {
            mInstance = new NetHelper(context);
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