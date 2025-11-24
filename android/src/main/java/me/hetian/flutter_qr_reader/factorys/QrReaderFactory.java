package me.hetian.flutter_qr_reader.factorys;

import android.content.Context;
import android.graphics.PointF;
import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.StandardMessageCodec;

import me.hetian.flutter_qr_reader.readerView.QRCodeReaderView;

public class QrReaderFactory extends PlatformViewFactory {

    private final BinaryMessenger messenger;

    public QrReaderFactory(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        return new QrReaderPlatformView(context, messenger, viewId);
    }

    private static class QrReaderPlatformView implements PlatformView, MethodCallHandler {

        private final QRCodeReaderView qrView;
        private final MethodChannel channel;

        QrReaderPlatformView(Context context, BinaryMessenger messenger, int viewId) {
            qrView = new QRCodeReaderView(context);
            channel = new MethodChannel(messenger, "me.hetian.flutter_qr_reader.reader_view_" + viewId);
            channel.setMethodCallHandler(this);

            // Setup listener to send QR code reads to Flutter
            qrView.setOnQRCodeReadListener(new QRCodeReaderView.OnQRCodeReadListener() {
                @Override
                public void onQRCodeRead(String text, PointF[] points, byte[] rawBytes) {
                    List<String> pointStrs = new ArrayList<>();
                    for (PointF p : points) {
                        pointStrs.add(p.x + "," + p.y);
                    }

                    Map<String, Object> args = new HashMap<>();
                    args.put("text", text);
                    args.put("points", pointStrs);
                    args.put("rawData", rawBytes != null ? new String(rawBytes) : "");

                    channel.invokeMethod("onQRCodeRead", args);
                }
            });
        }

        @Override
        public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
            switch (call.method) {
                case "startCamera":
                    qrView.startCamera();
                    result.success(true);
                    break;
                case "stopCamera":
                    qrView.stopCamera();
                    result.success(true);
                    break;
                case "flashlight":
                    Boolean enabled = call.arguments != null && (Boolean) call.arguments;
                    qrView.setTorchEnabled(enabled != null && enabled);
                    result.success(true);
                    break;
                default:
                    result.notImplemented();
            }
        }

        @NonNull
        @Override
        public android.view.View getView() {
            return qrView;
        }

        @Override
        public void dispose() {
            qrView.stopCamera();
        }
    }
}
