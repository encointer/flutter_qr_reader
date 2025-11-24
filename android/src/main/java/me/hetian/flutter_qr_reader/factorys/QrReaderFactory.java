package me.hetian.flutter_qr_reader.factorys;

import android.content.Context;
import android.view.View;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
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
        QRCodeReaderView qrView = new QRCodeReaderView(context);

        // Attach a MethodChannel for this view
        MethodChannel channel = new MethodChannel(
                messenger,
                "me.hetian.flutter_qr_reader.reader_view_" + viewId
        );

        channel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall call, MethodChannel.Result result) {
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
                        boolean enabled = call.arguments() != null && (Boolean) call.arguments();
                        qrView.setTorchEnabled(enabled);
                        result.success(true);
                        break;
                    default:
                        result.notImplemented();
                        break;
                }
            }
        });

        return new PlatformView() {
            @Override
            public View getView() {
                return qrView;
            }

            @Override
            public void dispose() {}
        };
    }
}
