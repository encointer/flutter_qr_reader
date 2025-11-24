package me.hetian.flutter_qr_reader.views;

import android.content.Context;
import android.view.View;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.platform.PlatformView;
import me.hetian.flutter_qr_reader.readerView.QRCodeReaderView;
import java.util.Map;

public class QrReaderView implements PlatformView {

    private final QRCodeReaderView qrCodeReaderView;

    public QrReaderView(@NonNull Context context,
                        @NonNull BinaryMessenger messenger,
                        int id,
                        Map<String, Object> params) {

        qrCodeReaderView = new QRCodeReaderView(context);

        // Optional params
        if (params != null) {
            Object torch = params.get("torchEnabled");
            if (torch instanceof Boolean) {
                qrCodeReaderView.setTorchEnabled((Boolean) torch);
            }
        }

        qrCodeReaderView.startCamera();
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
