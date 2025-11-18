package com.ruby.app_integrity_attestation;

import android.content.Context;

import com.google.android.gms.tasks.Task;
import com.google.android.play.core.integrity.IntegrityManagerFactory;
import com.google.android.play.core.integrity.StandardIntegrityManager;

import io.flutter.plugin.common.MethodChannel;

public class AppIntegrityAttestation {

    private final Context context;
    private final String requestHash;
    private final Long cloudProjectNumber;

    public AppIntegrityAttestation(Context context, String requestHash, String cloudProjectNumber) {
        this.context = context;
        this.requestHash = requestHash;
        this.cloudProjectNumber = Long.parseLong(cloudProjectNumber);
    }

    public void getIntegrityToken(MethodChannel.Result result) {

        StandardIntegrityManager manager =
                IntegrityManagerFactory.createStandard(context);

        manager.prepareIntegrityToken(
                StandardIntegrityManager.PrepareIntegrityTokenRequest.builder()
                        .setCloudProjectNumber(cloudProjectNumber)
                        .build()
        ).addOnSuccessListener(tokenProvider -> {

            tokenProvider.request(
                    StandardIntegrityManager.StandardIntegrityTokenRequest.builder()
                            .setRequestHash(requestHash)
                            .build()
            ).addOnSuccessListener(standardIntegrityToken -> {

                String token = standardIntegrityToken.token();
                result.success(token);

            }).addOnFailureListener(e -> result.error("REQUEST_FAILED", e.getMessage(), null));

        }).addOnFailureListener(e -> result.error("PREPARE_FAILED", e.getMessage(), null));
    }
}