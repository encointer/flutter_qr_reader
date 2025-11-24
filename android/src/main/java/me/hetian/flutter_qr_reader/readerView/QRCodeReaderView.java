package me.hetian.flutter_qr_reader.views;

import android.content.Context;
import android.view.View;
import java.util.Map;

import androidx.annotation.NonNull;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;
import me.hetian.flutter_qr_reader.readerView.QRCodeReaderView;

public class QrReaderView implements PlatformView {
    private final QRCodeReaderView qrCodeReaderView;
    private final MethodChannel channel;

    public QrReaderView(@NonNull Context context,
                        @NonNull BinaryMessenger messenger,
                        int id,
                        Map<String, Object> params) {

        qrCodeReaderView = new QRCodeReaderView(context);

        // Optional: set QR code read listener to send result to Dart
        qrCodeReaderView.setOnQRCodeReadListener((text, points, rawBytes) -> {
            if (text != null) {
                messenger
                        .send("me.hetian.flutter_qr_reader/reader_view_" + id,
                                new MethodChannel.Result() {
                                    @Override
                                    public void success(Object result) {}
                                    @Override
                                    public void error(String errorCode, String errorMessage, Object errorDetails) {}
                                    @Override
                                    public void notImplemented() {}
                                });
            }
        });

        // You can configure params from Dart if needed
        if (params != null) {
            Object torchEnabled = params.get("torchEnabled");
            if (torchEnabled instanceof Boolean && (Boolean) torchEnabled) {
                qrCodeReaderView.setTorchEnabled(true);
            }
        }

        channel = new MethodChannel(messenger, "me.hetian.flutter_qr_reader/reader_view_" + id);
        // Optional: set channel method call handler here if needed
    }

    @NonNull
    @Override
    public View getView() {
        return qrCodeReaderView;
    }

    @Override
    public void dispose() {
        qrCodeReaderView.stopCamera();
    }
}
