package gps.tracking.android.orange;

import android.app.Service;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.database.sqlite.SQLiteDatabase;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.IBinder;
import android.support.annotation.Nullable;

public class DataService extends Service{

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
        LocationManager locationManager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
        LocationListener locationListener = new LocationListener() {
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
            public void onStatusChanged(String provider, int status, Bundle extras) {

            }

            @Override
            public void onProviderEnabled(String provider) {

            }

            @Override
            public void onProviderDisabled(String provider) {

            }
        };
        locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 5000, 0, locationListener);
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }
}
