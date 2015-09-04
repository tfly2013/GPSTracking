package gps.tracking.android.orange;

import android.app.Service;
import android.content.ContentValues;
import android.content.Intent;
import android.database.sqlite.SQLiteDatabase;
import android.location.Location;
import android.os.Bundle;
import android.os.IBinder;
import android.support.annotation.Nullable;
import android.widget.Toast;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.LocationListener;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;

public class DataService extends Service implements GoogleApiClient.OnConnectionFailedListener, GoogleApiClient.ConnectionCallbacks, LocationListener {

    private GoogleApiClient apiClient;
    private SQLiteDatabase db;

    public DataService() {

    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        db = new LocationsDbHelper(this).getWritableDatabase();
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
        locationRequest.setInterval(5000);
        locationRequest.setFastestInterval(1000);
        locationRequest.setMaxWaitTime(60000);
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
        ContentValues values = new ContentValues();
        values.put(LocationsDbHelper.LoctionEntry.COLUMN_NAME_LATITUDE, location.getLatitude());
        values.put(LocationsDbHelper.LoctionEntry.COLUMN_NAME_LONGITUDE, location.getLongitude());
        values.put(LocationsDbHelper.LoctionEntry.COLUMN_NAME_ACCURACY, location.getAccuracy());
        values.put(LocationsDbHelper.LoctionEntry.COLUMN_NAME_TIME, location.getTime());
        db.insert(LocationsDbHelper.LoctionEntry.TABLE_NAME, null, values);
    }

    @Override
    public void onDestroy() {
        apiClient.disconnect();
        super.onDestroy();
    }
}
