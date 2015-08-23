package gps.tracking.android.orange;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonObjectRequest;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

public class MainActivity extends AppCompatActivity {

    private SharedPreferences userPreferences;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        userPreferences = getSharedPreferences("CurrentUser", MODE_PRIVATE);
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
//            signOut();
        }

        return super.onOptionsItemSelected(item);
    }

    private void signOut() {
        String email = userPreferences.getString("Email", null);
        String token = userPreferences.getString("AuthToken", null);
        Map<String, String> params = new HashMap<>();
        params.put("user_email", email);
        params.put("user_token", token);
        JSONObject jsonObj = new JSONObject(params);

        JsonObjectRequest jsObjRequest = new JsonObjectRequest
                (Request.Method.DELETE, VolleyHelper.LOGOUT_URL, jsonObj, new Response.Listener<JSONObject>() {
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
                });
        VolleyHelper.getInstance(this).addToRequestQueue(jsObjRequest);
    }

    public void OnTripStart(View view) {
        view.setVisibility(View.GONE);
        findViewById(R.id.btn_trip_stop).setVisibility(View.VISIBLE);
        startService(new Intent(this, DataService.class));
    }

    public void OnTripStop(View view) {
        view.setVisibility(View.GONE);
        findViewById(R.id.btn_trip_start).setVisibility(View.VISIBLE);
        stopService(new Intent(this, DataService.class));
    }
}
