package me.hetian.flutter_qr_reader;

import android.annotation.SuppressLint;
import android.os.AsyncTask;
import java.io.File;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.BinaryMessenger;

import me.hetian.flutter_qr_reader.factorys.QrReaderFactory;

/** FlutterQrReaderPlugin */
public class FlutterQrReaderPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

  private MethodChannel channel;
  private FlutterPluginBinding flutterPluginBinding;

  private static final String CHANNEL_NAME = "me.hetian.flutter_qr_reader";
  private static final String CHANNEL_VIEW_NAME = "me.hetian.flutter_qr_reader.reader_view";

  public FlutterQrReaderPlugin() {}

  /** No more registerWith(Registrar) needed in v2 embedding */

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    this.flutterPluginBinding = binding;
    setup(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    if (channel != null) {
      channel.setMethodCallHandler(null);
    }
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    // Register platform view factory
    flutterPluginBinding.getPlatformViewRegistry().registerViewFactory(
            CHANNEL_VIEW_NAME,
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

  private void setup(BinaryMessenger messenger) {
    channel = new MethodChannel(messenger, CHANNEL_NAME);
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    if (call.method.equals("imgQrCode")) {
      imgQrCode(call, result);
    } else {
      result.notImplemented();
    }
  }

  @SuppressLint("StaticFieldLeak")
  private void imgQrCode(MethodCall call, final MethodChannel.Result result) {
    final String filePath = call.argument("file");
    if (filePath == null) {
      result.error("Not found data", null, null);
      return;
    }

    File file = new File(filePath);
    if (!file.exists()) {
      result.error("File not found", null, null);
      return;
    }

    new AsyncTask<String, Integer, String>() {
      @Override
      protected String doInBackground(String... params) {
        // 解析二维码/条码
        return QRCodeDecoder.syncDecodeQRCode(filePath);
      }

      @Override
      protected void onPostExecute(String s) {
        super.onPostExecute(s);
        if (s == null) {
          result.error("not data", null, null);
        } else {
          result.success(s);
        }
      }
    }.execute(filePath);
  }
}
