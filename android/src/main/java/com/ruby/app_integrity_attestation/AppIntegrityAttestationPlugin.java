package com.ruby.app_integrity_attestation;

import android.content.Context;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class AppIntegrityAttestationPlugin implements FlutterPlugin, MethodCallHandler {

  private MethodChannel channel;
  private Context applicationContext;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    channel = new MethodChannel(binding.getBinaryMessenger(), "app_integrity_attestation");
    channel.setMethodCallHandler(this);

    applicationContext = binding.getApplicationContext();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

    if (call.method.equals("getIntegrityToken")) {

      String requestHash = call.argument("requestHash");
      String cloudProjectNumber = call.argument("cloudProjectNumber");

      AppIntegrityAttestation attestation =
              new AppIntegrityAttestation(applicationContext, requestHash, cloudProjectNumber);

      attestation.getIntegrityToken(result);
      return;
    }

    result.notImplemented();
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}