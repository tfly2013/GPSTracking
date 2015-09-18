package gps.tracking.android.orange;

import android.app.ActivityManager;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.location.LocationManager;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonObjectRequest;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

public class MainActivity extends AppCompatActivity {

    private SharedPreferences userPreferences;
    private Button btnStart;
    private Button btnStop;
    private SQLiteDatabase db;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        userPreferences = getSharedPreferences("CurrentUser", MODE_PRIVATE);
        db = new LocationsDbHelper(this).getReadableDatabase();

        btnStart = (Button) findViewById(R.id.btn_trip_start);
        btnStop = (Button) findViewById(R.id.btn_trip_stop);
        if (isServiceRunning(DataService.class)) {
            btnStart.setVisibility(View.GONE);
            btnStop.setVisibility(View.VISIBLE);
        } else {
            btnStart.setVisibility(View.VISIBLE);
            btnStop.setVisibility(View.GONE);
        }

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_sign_out) {
            signOut();
        }

        return super.onOptionsItemSelected(item);
    }

    private void signOut() {
        JsonObjectRequest jsObjRequest = new JsonObjectRequest
                (Request.Method.DELETE, VolleyHelper.LOGOUT_URL, new JSONObject(), new Response.Listener<JSONObject>() {
                    @Override
                    public void onResponse(JSONObject response) {
                        try {
                            if (response.getBoolean("success")) {
                                userPreferences.edit().clear().apply();
                                Intent intent = new Intent(getApplicationContext(), LoginActivity.class);
                                startActivity(intent);
                                finish();
                            }
                            Toast.makeText(getApplicationContext(), response.getString("info"), Toast.LENGTH_LONG).show();
                        } catch (Exception e) {
                            // something went wrong: show a Toast with the exception message
                            Toast.makeText(getApplicationContext(), e.getMessage(), Toast.LENGTH_LONG).show();
                        }
                    }
                }, new Response.ErrorListener() {

                    @Override
                    public void onErrorResponse(VolleyError error) {
                        Toast.makeText(getApplicationContext(), error.getLocalizedMessage(), Toast.LENGTH_LONG).show();
                    }
                }) {
            @Override
            public Map<String, String> getHeaders() throws AuthFailureError {
                String email = userPreferences.getString("Email", null);
                String token = userPreferences.getString("AuthToken", null);
                HashMap<String, String> params = new HashMap<>();
                params.put("Accept", "application/json");
                params.put("Content-Type", "application/json");
                params.put("X-User-Email", email);
                params.put("X-User-Token", token);
                return params;
            }
        };
        VolleyHelper.getInstance(this).addToRequestQueue(jsObjRequest);
    }

    private boolean isServiceRunning(Class<?> serviceClass) {
        ActivityManager manager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
        for (ActivityManager.RunningServiceInfo service : manager.getRunningServices(Integer.MAX_VALUE))
            if (serviceClass.getName().equals(service.service.getClassName()))
                return true;
        return false;
    }

    public void OnTripStart(View view) {
        final LocationManager manager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
        if (!manager.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
            buildAlertMessageNoGps();
        } else {
            view.setVisibility(View.GONE);
            btnStop.setVisibility(View.VISIBLE);
            startService(new Intent(this, DataService.class));
        }
    }

    public void OnTripStop(View view) {
        JSONObject jsonObj = getLocationsFromDatabase();
        if (jsonObj != null)
            sendData(jsonObj);
        else
            Toast.makeText(this,"No data available", Toast.LENGTH_LONG).show();

        view.setVisibility(View.GONE);
        btnStart.setVisibility(View.VISIBLE);
        stopService(new Intent(this, DataService.class));
    }

    /**
     * WARNING: All DATA would be removed from database after this function call
     *
     * @return Json object to send.
     */
    private JSONObject getLocationsFromDatabase() {
        String[] projection = {
                LocationsDbHelper.LoctionEntry.COLUMN_NAME_LATITUDE,
                LocationsDbHelper.LoctionEntry.COLUMN_NAME_LONGITUDE,
                LocationsDbHelper.LoctionEntry.COLUMN_NAME_SPEED,
                LocationsDbHelper.LoctionEntry.COLUMN_NAME_ACCURACY,
                LocationsDbHelper.LoctionEntry.COLUMN_NAME_TIME
        };
        String sortOrder = LocationsDbHelper.LoctionEntry.COLUMN_NAME_TIME + " ASC";

        Cursor cursor = db.query(LocationsDbHelper.LoctionEntry.TABLE_NAME, projection, null, null, null, null, sortOrder);
        int latitudeIndex = cursor.getColumnIndexOrThrow(LocationsDbHelper.LoctionEntry.COLUMN_NAME_LATITUDE);
        int longitudeIndex = cursor.getColumnIndexOrThrow(LocationsDbHelper.LoctionEntry.COLUMN_NAME_LONGITUDE);
        int speedIndex = cursor.getColumnIndexOrThrow(LocationsDbHelper.LoctionEntry.COLUMN_NAME_SPEED);
        int accuracyIndex = cursor.getColumnIndexOrThrow(LocationsDbHelper.LoctionEntry.COLUMN_NAME_ACCURACY);
        int timeIndex = cursor.getColumnIndexOrThrow(LocationsDbHelper.LoctionEntry.COLUMN_NAME_TIME);

        if (cursor.getCount() == 0)
            return null;
        cursor.moveToFirst();
        JSONObject jsonObj = new JSONObject();
        JSONArray locationArray = new JSONArray();
        try {
            while (!cursor.isAfterLast()) {
                JSONObject locationObj = new JSONObject();
                locationObj.put("latitude", cursor.getFloat(latitudeIndex));
                locationObj.put("longitude", cursor.getFloat(longitudeIndex));
                locationObj.put("speed", cursor.getFloat(speedIndex));
                locationObj.put("accuracy", cursor.getFloat(accuracyIndex));
                locationObj.put("time", cursor.getLong(timeIndex));
                locationArray.put(locationObj);
                cursor.moveToNext();
            }
            jsonObj.put("locations", locationArray);
        } catch (JSONException e) {
            Toast.makeText(this, e.getMessage(), Toast.LENGTH_LONG).show();
        }
        cursor.close();

        db.delete(LocationsDbHelper.LoctionEntry.TABLE_NAME, "1", null);
        return jsonObj;
    }

    private void sendData(final JSONObject jsonObj) {
        JsonObjectRequest jsObjRequest = new JsonObjectRequest
                (Request.Method.POST, VolleyHelper.TRIP_URL, jsonObj, new Response.Listener<JSONObject>() {
                    @Override
                    public void onResponse(JSONObject response) {
                        Toast.makeText(MainActivity.this, "Your trip is sent successfully.", Toast.LENGTH_LONG).show();
                    }
                }, new Response.ErrorListener() {

                    @Override
                    public void onErrorResponse(VolleyError error) {
                        buildAlertMessageNetworkError(error, jsonObj);
                    }
                }) {
            @Override
            public Map<String, String> getHeaders() throws AuthFailureError {
                String email = userPreferences.getString("Email", null);
                String token = userPreferences.getString("AuthToken", null);
                HashMap<String, String> params = new HashMap<>();
                params.put("Accept", "application/json");
                params.put("Content-Type", "application/json");
                params.put("X-User-Email", email);
                params.put("X-User-Token", token);
                return params;
            }
        };
        VolleyHelper.getInstance(MainActivity.this).addToRequestQueue(jsObjRequest);
    }

    private void buildAlertMessageNoGps() {
        final AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setMessage("Your GPS seems to be disabled, do you want to enable it?")
                .setCancelable(false)
                .setPositiveButton("Yes", new DialogInterface.OnClickListener() {
                    public void onClick(@SuppressWarnings("unused") final DialogInterface dialog, @SuppressWarnings("unused") final int id) {
                        startActivity(new Intent(android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS));
                    }
                })
                .setNegativeButton("No", new DialogInterface.OnClickListener() {
                    public void onClick(final DialogInterface dialog, @SuppressWarnings("unused") final int id) {
                        dialog.cancel();
                    }
                });
        final AlertDialog alert = builder.create();
        alert.show();
    }

    private void buildAlertMessageNetworkError(VolleyError error, final JSONObject jsonObj) {
        final AlertDialog.Builder builder = new AlertDialog.Builder(this);
        int errorCode = -1;
        String errorMessage = null;
        if (error.networkResponse != null) {
            errorCode = error.networkResponse.statusCode;
            errorMessage = error.getMessage();
        }
        builder.setMessage(String.format("Network Error: Code: %d, Message: %s.WARNING: You would lose ALL DATA of this trip if you choose to cancel. ",
                errorCode, errorMessage))
                .setCancelable(false)
                .setPositiveButton("Try again", new DialogInterface.OnClickListener() {
                    public void onClick(@SuppressWarnings("unused") final DialogInterface dialog, @SuppressWarnings("unused") final int id) {
                        sendData(jsonObj);
                    }
                })
                .setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
                    public void onClick(final DialogInterface dialog, @SuppressWarnings("unused") final int id) {
                        dialog.cancel();
                    }
                });
        final AlertDialog alert = builder.create();
        alert.show();
    }
}
