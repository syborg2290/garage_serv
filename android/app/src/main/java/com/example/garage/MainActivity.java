package com.example.garage;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

import android.os.Build;
import android.view.ViewTreeObserver;
import android.view.WindowManager;

import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService;

public class MainActivity extends FlutterActivity implements PluginRegistrantCallback {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FlutterFirebaseMessagingService.setPluginRegistrant(this);

        GeneratedPluginRegistrant.registerWith(this);

    }

    @Override
    public void registerWith(PluginRegistry registry) {
        GeneratedPluginRegistrant.registerWith(registry);
    }
}