package me.hetian.flutter_qr_reader.factorys;

import android.content.Context;

import java.util.Map;

import androidx.annotation.NonNull;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import me.hetian.flutter_qr_reader.views.QrReaderView;

public class QrReaderFactory extends PlatformViewFactory {
    private final @NonNull BinaryMessenger messenger;

    public QrReaderFactory(@NonNull BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
    }

    @Override
    public @NonNull PlatformView create(@NonNull Context context, int id, Object args) {
        @SuppressWarnings("unchecked")
        Map<String, Object> params = (args instanceof Map) ? (Map<String, Object>) args : null;
        return new QrReaderView(context, messenger, id, params);
    }
}
