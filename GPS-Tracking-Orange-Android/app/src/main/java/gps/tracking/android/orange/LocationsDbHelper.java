package gps.tracking.android.orange;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.provider.BaseColumns;

/**
 * Created by Fei on 2015/8/31.
 */
public class LocationsDbHelper extends SQLiteOpenHelper {

    public static abstract class LoctionEntry implements BaseColumns {
        public static final String TABLE_NAME = "locations";
        public static final String COLUMN_NAME_LATITUDE = "latitude";
        public static final String COLUMN_NAME_LONGITUDE = "longitude";
        public static final String COLUMN_NAME_ACCURACY = "accuracy";
        public static final String COLUMN_NAME_TIME = "time";
    }

    public static final String REAL_TYPE = " REAL";
    public static final String INTEGER_TYPE = " INTEGER";
    public static final String COMMA_SEP = ",";
    public static final String SQL_CREATE_TABLE =
            "CREATE TABLE " + LoctionEntry.TABLE_NAME + " (" +
                    LoctionEntry._ID + " INTEGER PRIMARY KEY," +
                    LoctionEntry.COLUMN_NAME_LATITUDE + REAL_TYPE + COMMA_SEP +
                    LoctionEntry.COLUMN_NAME_LONGITUDE + REAL_TYPE + COMMA_SEP +
                    LoctionEntry.COLUMN_NAME_ACCURACY + REAL_TYPE + COMMA_SEP +
                    LoctionEntry.COLUMN_NAME_TIME + INTEGER_TYPE +
                    " )";

    public static final String SQL_DELETE_TABLE =
            "DROP TABLE IF EXISTS " + LoctionEntry.TABLE_NAME;

    // If you change the database schema, you must increment the database version.
    public static final int DATABASE_VERSION = 1;
    public static final String DATABASE_NAME = "Loactions.db";

    public LocationsDbHelper(Context context) {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);
    }

    public void onCreate(SQLiteDatabase db) {
        db.execSQL(SQL_CREATE_TABLE);
    }

    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        // This database is only a cache for online data, so its upgrade policy is
        // to simply to discard the data and start over
        db.execSQL(SQL_DELETE_TABLE);
        onCreate(db);
    }

    public void onDowngrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        onUpgrade(db, oldVersion, newVersion);
    }
}
