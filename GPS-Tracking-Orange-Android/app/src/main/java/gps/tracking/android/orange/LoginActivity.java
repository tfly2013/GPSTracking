package gps.tracking.android.orange;

import android.app.Activity;
import android.app.LoaderManager.LoaderCallbacks;
import android.app.ProgressDialog;
import android.content.CursorLoader;
import android.content.Intent;
import android.content.Loader;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.ContactsContract;
import android.text.TextUtils;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.EditorInfo;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonObjectRequest;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * A login screen that offers login via email/password.
 */
public class LoginActivity extends Activity implements LoaderCallbacks<Cursor> {

    private SharedPreferences userPreferences;

    // UI references.
    private AutoCompleteTextView mEmailView;
    private EditText mPasswordView;
    private ProgressDialog progressDialog;
    private View mLoginView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        userPreferences = getSharedPreferences("CurrentUser", MODE_PRIVATE);
        progressDialog = new ProgressDialog(LoginActivity.this,
                R.style.Theme_AppCompat_Dialog);
        progressDialog.setIndeterminate(true);

        mLoginView = findViewById(R.id.login_form);
        mLoginView.setVisibility(View.GONE);

        // Try to Login with token
        String email = userPreferences.getString("Email", null);
        String token = userPreferences.getString("AuthToken", null);
        if (email != null && token != null)
            loginWithToken(email, token);
        else
            mLoginView.setVisibility(View.VISIBLE);

        // Set up the login form.
        mEmailView = (AutoCompleteTextView) findViewById(R.id.email);
        populateAutoComplete();

        mPasswordView = (EditText) findViewById(R.id.password);
        mPasswordView.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView textView, int id, KeyEvent keyEvent) {
                if (id == R.id.login || id == EditorInfo.IME_NULL) {
                    attemptLogin();
                    return true;
                }
                return false;
            }
        });

        //TODO: for testing
        mEmailView.setText("feit@test.com");
        mPasswordView.setText("testtest");

        Button mEmailSignInButton = (Button) findViewById(R.id.email_sign_in_button);
        mEmailSignInButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                attemptLogin();
            }
        });
    }

    private void populateAutoComplete() {
        getLoaderManager().initLoader(0, null, this);
    }


    /**
     * Attempts to sign in or register the account specified by the login form.
     * If there are form errors (invalid email, missing fields, etc.), the
     * errors are presented and no actual login attempt is made.
     */
    public void attemptLogin() {
        // Reset errors.
        mEmailView.setError(null);
        mPasswordView.setError(null);

        // Store values at the time of the login attempt.
        String email = mEmailView.getText().toString();
        String password = mPasswordView.getText().toString();

        boolean cancel = false;
        View focusView = null;

        // Check for a valid password, if the user entered one.
        if (!TextUtils.isEmpty(password) && !isPasswordValid(password)) {
            mPasswordView.setError(getString(R.string.error_invalid_password));
            focusView = mPasswordView;
            cancel = true;
        }

        // Check for a valid email address.
        if (TextUtils.isEmpty(email)) {
            mEmailView.setError(getString(R.string.error_field_required));
            focusView = mEmailView;
            cancel = true;
        } else if (!isEmailValid(email)) {
            mEmailView.setError(getString(R.string.error_invalid_email));
            focusView = mEmailView;
            cancel = true;
        }

        if (cancel) {
            // There was an error; don't attempt login and focus the first
            // form field with an error.
            focusView.requestFocus();
        } else {
            loginWithPassword(mEmailView.getText().toString(), mPasswordView.getText().toString());
        }
    }

    private void loginWithToken(String email, String token) {
        Map<String, String> params = new HashMap<>();
        params.put("user_email", email);
        params.put("user_token", token);
        JSONObject jsonObj = new JSONObject(params);

        JsonObjectRequest jsObjRequest = new JsonObjectRequest
                (Request.Method.POST, NetHelper.LOGIN_URL, jsonObj, new Response.Listener<JSONObject>() {
                    @Override
                    public void onResponse(JSONObject response) {
                        progressDialog.dismiss();
                        try {
                            if (response.getBoolean("success")) {
                                Intent intent = new Intent(getApplicationContext(), MainActivity.class);
                                startActivity(intent);
                                finish();
                            } else
                                mLoginView.setVisibility(View.VISIBLE);
                        } catch (Exception e) {
                            Toast.makeText(getApplicationContext(), e.getMessage(), Toast.LENGTH_LONG).show();
                            mLoginView.setVisibility(View.VISIBLE);
                        }
                    }
                }, new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError error) {
                        int errorCode = -1;
                        if (error.networkResponse != null)
                            errorCode = error.networkResponse.statusCode;
                        Log.e("Login", "Login with token failed, error code " + errorCode);
                        progressDialog.dismiss();
                        mLoginView.setVisibility(View.VISIBLE);
                    }
                });
        // Show a progress spinner, and kick off a background task to
        // perform the user login attempt.
        progressDialog.setMessage("Loading...");
        progressDialog.show();
        // Access the RequestQueue through your singleton class.
        NetHelper.getInstance(this).addToRequestQueue(jsObjRequest);
    }

    private void loginWithPassword(String email, String password) {
        JSONObject userObj = new JSONObject();
        JSONObject jsonObj = new JSONObject();
        try {
            userObj.put("email", email);
            userObj.put("password", password);
            jsonObj.put("user", userObj);
        } catch (JSONException e) {
            Toast.makeText(getApplicationContext(), e.getMessage(), Toast.LENGTH_LONG).show();
            return;
        }

        JsonObjectRequest jsObjRequest = new JsonObjectRequest
                (Request.Method.POST, NetHelper.LOGIN_URL, jsonObj, new Response.Listener<JSONObject>() {
                    @Override
                    public void onResponse(JSONObject response) {
                        progressDialog.dismiss();
                        try {
                            if (response.getBoolean("success")) {
                                // everything is ok
                                SharedPreferences.Editor editor = userPreferences.edit();
                                // save the returned auth_token into the SharedPreferences
                                editor.putString("Email", response.getJSONObject("data").getString("email"));
                                editor.putString("AuthToken", response.getJSONObject("data").getString("auth_token"));
                                editor.apply();
                                // launch the HomeActivity and close this one
                                Intent intent = new Intent(getApplicationContext(), MainActivity.class);
                                startActivity(intent);
                                finish();
                            }
                            Toast.makeText(getApplicationContext(), "Signed in", Toast.LENGTH_LONG).show();
                        } catch (Exception e) {
                            // something went wrong: show a Toast
                            // with the exception message
                            Toast.makeText(getApplicationContext(), "Internal error, please try again.", Toast.LENGTH_LONG).show();
                        }
                    }
                }, new Response.ErrorListener() {

                    @Override
                    public void onErrorResponse(VolleyError error) {
                        progressDialog.dismiss();
                        int errorCode = -1;
                        if (error.networkResponse != null)
                            errorCode = error.networkResponse.statusCode;
                        switch (errorCode) {
                            case -1:
                                Toast.makeText(getApplicationContext(), "Please check your network connectivity.", Toast.LENGTH_LONG).show();
                            case 401:
                                Toast.makeText(getApplicationContext(), "Invalid email or password.", Toast.LENGTH_LONG).show();
                            default:
                                Toast.makeText(getApplicationContext(), "Error code:" + errorCode + ",please try again .", Toast.LENGTH_LONG).show();
                        }
                    }
                });
        // Show a progress spinner, and kick off a background task to
        // perform the user login attempt.
        progressDialog.setMessage("Signing in...");
        progressDialog.show();
        // Access the RequestQueue through your singleton class.
        NetHelper.getInstance(this).addToRequestQueue(jsObjRequest);
    }

    private boolean isEmailValid(String email) {
        return email.contains("@");
    }

    private boolean isPasswordValid(String password) {
        return password.length() >= 8;
    }

    public void onSignUp(View view) {
        Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(NetHelper.SIGNUP_URL));
        startActivity(browserIntent);
    }

    public void onTitleClick(View view) {
        Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(NetHelper.DOMAIN));
        startActivity(browserIntent);
    }

    @Override
    public Loader<Cursor> onCreateLoader(int i, Bundle bundle) {
        return new CursorLoader(this,
                // Retrieve data rows for the device user's 'profile' contact.
                Uri.withAppendedPath(ContactsContract.Profile.CONTENT_URI,
                        ContactsContract.Contacts.Data.CONTENT_DIRECTORY), ProfileQuery.PROJECTION,

                // Select only email addresses.
                ContactsContract.Contacts.Data.MIMETYPE +
                        " = ?", new String[]{ContactsContract.CommonDataKinds.Email
                .CONTENT_ITEM_TYPE},

                // Show primary email addresses first. Note that there won't be
                // a primary email address if the user hasn't specified one.
                ContactsContract.Contacts.Data.IS_PRIMARY + " DESC");
    }

    @Override
    public void onLoadFinished(Loader<Cursor> cursorLoader, Cursor cursor) {
        List<String> emails = new ArrayList<String>();
        cursor.moveToFirst();
        while (!cursor.isAfterLast()) {
            emails.add(cursor.getString(ProfileQuery.ADDRESS));
            cursor.moveToNext();
        }
        addEmailsToAutoComplete(emails);
    }

    @Override
    public void onLoaderReset(Loader<Cursor> cursorLoader) {

    }

    private interface ProfileQuery {
        String[] PROJECTION = {
                ContactsContract.CommonDataKinds.Email.ADDRESS,
                ContactsContract.CommonDataKinds.Email.IS_PRIMARY,
        };
        int ADDRESS = 0;
    }


    private void addEmailsToAutoComplete(List<String> emailAddressCollection) {
        //Create adapter to tell the AutoCompleteTextView what to show in its dropdown list.
        ArrayAdapter<String> adapter =
                new ArrayAdapter<String>(LoginActivity.this,
                        android.R.layout.simple_dropdown_item_1line, emailAddressCollection);

        mEmailView.setAdapter(adapter);
    }
}

