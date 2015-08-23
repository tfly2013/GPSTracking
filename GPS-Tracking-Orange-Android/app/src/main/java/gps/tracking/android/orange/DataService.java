package gps.tracking.android.orange;

import android.app.Service;
import android.content.Intent;
import android.location.Location;
import android.os.Bundle;
import android.os.IBinder;
import android.support.annotation.Nullable;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonObjectRequest;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.LocationListener;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;

import org.json.JSONException;
import org.json.JSONObject;

public class DataService extends Service implements GoogleApiClient.OnConnectionFailedListener, GoogleApiClient.ConnectionCallbacks, LocationListener {

    private GoogleApiClient apiClient;

    public DataService() {

    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        buildGoogleApiClient();
        apiClient.connect();
        return START_STICKY;
    }

    protected synchronized void buildGoogleApiClient() {
        apiClient = new GoogleApiClient.Builder(this)
                .addConnectionCallbacks(this)
                .addOnConnectionFailedListener(this)
                .addApi(LocationServices.API)
                .build();
    }

    @Override
    public void onConnected(Bundle bundle) {
        LocationRequest locationRequest = new LocationRequest();
        locationRequest.setInterval(10000);
        locationRequest.setFastestInterval(5000);
        locationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);
        LocationServices.FusedLocationApi.requestLocationUpdates(
                apiClient, locationRequest, this);
    }

    @Override
    public void onConnectionSuspended(int i) {
        Toast.makeText(DataService.this, "Connection Suspended", Toast.LENGTH_LONG).show();
    }

    @Override
    public void onConnectionFailed(ConnectionResult connectionResult) {
        Toast.makeText(DataService.this, "Connection Failed " + connectionResult.getErrorCode(), Toast.LENGTH_LONG).show();
    }


    @Override
    public void onLocationChanged(Location location) {
        Toast.makeText(DataService.this, location.getLatitude() + ", " + location.getLongitude(), Toast.LENGTH_LONG).show();
        JSONObject jsonObj = new JSONObject();
        JSONObject locationObj = new JSONObject();
        try {
            locationObj.put("latitude", location.getLatitude());
            locationObj.put("longitude", location.getLongitude());
            locationObj.put("accuracy", location.getAccuracy());
            locationObj.put("speed", location.getSpeed());8
            locationObj.put("time", location.getTime());
            jsonObj.put("api_location",locationObj);
        } catch (JSONException e) {
            Toast.makeText(DataService.this, e.getMessage(), Toast.LENGTH_LONG).show();
        }
        JsonObjectRequest jsObjRequest = new JsonObjectRequest
                (Request.Method.POST, VolleyHelper.LOCATION_URL, jsonObj, new Response.Listener<JSONObject>() {
                    @Override
                    public void onResponse(JSONObject response) {
                    }
                }, new Response.ErrorListener() {

                    @Override
                    public void onErrorResponse(VolleyError error) {
                        Toast.makeText(DataService.this, error.getLocalizedMessage(), Toast.LENGTH_LONG).show();
                    }
                });
        VolleyHelper.getInstance(DataService.this).addToRequestQueue(jsObjRequest);
    }

    @Override
    public void onDestroy() {
        apiClient.disconnect();
        super.onDestroy();
    }
}
