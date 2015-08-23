package gps.tracking.android.orange;

import android.app.Service;
import android.content.Intent;
import android.location.Location;
import android.os.Bundle;
import android.os.IBinder;
import android.support.annotation.Nullable;
import android.util.Log;
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

public class DataService extends Service {

    private static final String LOCATION_URL = "http://stormy-bastion-5570.herokuapp.com/api/locations";
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
        Toast.makeText(DataService.this, "Service Started", Toast.LENGTH_LONG).show();
        buildGoogleApiClient();
        return START_STICKY;
    }

    protected synchronized void buildGoogleApiClient() {
        apiClient = new GoogleApiClient.Builder(this)
                .addConnectionCallbacks(new GoogleApiClient.ConnectionCallbacks() {
                    @Override
                    public void onConnected(Bundle bundle) {
                        Log.e("Google Location Service", "Connection Success");
                        LocationRequest locationRequest = new LocationRequest();
                        locationRequest.setInterval(10000);
                        locationRequest.setFastestInterval(5000);
                        locationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);
                        LocationServices.FusedLocationApi.requestLocationUpdates(
                                apiClient, locationRequest, new LocationListener() {
                                    @Override
                                    public void onLocationChanged(Location location) {
                                        Toast.makeText(DataService.this, location.getLatitude() + ", " + location.getLongitude(), Toast.LENGTH_LONG).show();
                                        JSONObject jsonObj = new JSONObject();
                                        try {
                                            jsonObj.put("latitude", location.getLatitude());
                                            jsonObj.put("longitude", location.getLongitude());
                                            jsonObj.put("accuracy", location.getAccuracy());
                                            jsonObj.put("speed", location.getSpeed());
                                            jsonObj.put("time", location.getTime());
                                        } catch (JSONException e) {
                                            return;
                                        }
                                        JsonObjectRequest jsObjRequest = new JsonObjectRequest
                                                (Request.Method.POST, LOCATION_URL, jsonObj, new Response.Listener<JSONObject>() {
                                                    @Override
                                                    public void onResponse(JSONObject response) {

                                                    }
                                                }, new Response.ErrorListener() {

                                                    @Override
                                                    public void onErrorResponse(VolleyError error) {
                                                    }
                                                });

                                        VolleyHelper.getInstance(DataService.this).addToRequestQueue(jsObjRequest);
                                    }
                                });
                    }

                    @Override
                    public void onConnectionSuspended(int i) {
                        Log.e("Google Location Service", "Connection Suspended");
                        Toast.makeText(DataService.this, "Connection Suspended", Toast.LENGTH_LONG).show();
                    }
                })
                .addOnConnectionFailedListener(new GoogleApiClient.OnConnectionFailedListener() {
                    @Override
                    public void onConnectionFailed(ConnectionResult connectionResult) {
                        Log.e("Google Location Service", "Connection Failed " + connectionResult.getErrorCode());
                        Toast.makeText(DataService.this, "Connection Failed " + connectionResult.getErrorCode(), Toast.LENGTH_LONG).show();
                    }
                })
                .addApi(LocationServices.API)
                .build();
    }
}
