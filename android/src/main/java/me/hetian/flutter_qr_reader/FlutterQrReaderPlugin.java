package me.hetian.flutter_qr_reader;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.BinaryMessenger;
import me.hetian.flutter_qr_reader.factorys.QrReaderFactory;

public class FlutterQrReaderPlugin implements FlutterPlugin, ActivityAware {

  private static final String CHANNEL_NAME = "me.hetian.flutter_qr_reader";
  private FlutterPluginBinding flutterPluginBinding;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    flutterPluginBinding = binding;
    // You can set up plugin-wide MethodChannel here if needed
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    // Clean up if needed
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    flutterPluginBinding.getPlatformViewRegistry().registerViewFactory(
            "me.hetian.flutter_qr_reader/reader_view",
            new QrReaderFactory(flutterPluginBinding.getBinaryMessenger())
    );
  }

  @Override
  public void onDetachedFromActivity() {}

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {}
}
