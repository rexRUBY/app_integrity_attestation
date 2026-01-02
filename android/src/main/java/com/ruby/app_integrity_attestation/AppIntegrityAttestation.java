package com.ruby.app_integrity_attestation;

import android.content.Context;

import com.google.android.gms.tasks.Task;
import com.google.android.play.core.integrity.IntegrityManagerFactory;
import com.google.android.play.core.integrity.IntegrityServiceException;
import com.google.android.play.core.integrity.StandardIntegrityManager;
import com.google.android.play.core.integrity.model.IntegrityErrorCode;

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
        StandardIntegrityManager manager = IntegrityManagerFactory.createStandard(context);

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
                result.success(standardIntegrityToken.token());
            }).addOnFailureListener(e -> handleError(e, result)); // 에러 처리 함수로 통합

        }).addOnFailureListener(e -> handleError(e, result)); // 여기서도 동일하게 처리
    }

    private void handleError(Exception e, MethodChannel.Result result) {
        if (e instanceof IntegrityServiceException) {
            int errorCode = ((IntegrityServiceException) e).getErrorCode();

            // 에러 코드가 -8 (TOO_MANY_REQUESTS) 인 경우
            if (errorCode == IntegrityErrorCode.TOO_MANY_REQUESTS) {
                // Flutter 쪽으로 'QUOTA_EXCEEDED'라는 에러 코드를 던짐
                result.error("QUOTA_EXCEEDED", "하루 할당량 1만 개를 다 썼거나 요청이 너무 많음", e.getMessage());
                return;
            }
        }

        // 그 외 일반적인 에러들
        result.error("INTEGRITY_ERROR", e.getMessage(), null);
    }
}