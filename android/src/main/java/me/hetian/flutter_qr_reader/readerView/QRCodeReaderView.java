package me.hetian.flutter_qr_reader.readerView;

import android.content.Context;
import android.graphics.PointF;
import android.hardware.Camera;
import android.os.AsyncTask;
import android.util.AttributeSet;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.ChecksumException;
import com.google.zxing.DecodeHintType;
import com.google.zxing.FormatException;
import com.google.zxing.MultiFormatReader;
import com.google.zxing.NotFoundException;
import com.google.zxing.PlanarYUVLuminanceSource;
import com.google.zxing.Result;
import com.google.zxing.ResultPoint;
import com.google.zxing.common.HybridBinarizer;
import com.google.zxing.client.android.camera.CameraManager;
import java.io.IOException;
import java.lang.ref.WeakReference;
import java.util.Map;
import me.hetian.flutter_qr_reader.QRCodeDecoder;
import me.hetian.flutter_qr_reader.readerView.QRToViewPointTransformer;

/** QRCodeReaderView: pure SurfaceView + ZXing camera decoding */
public class QRCodeReaderView extends SurfaceView implements SurfaceHolder.Callback, Camera.PreviewCallback {

    public interface OnQRCodeReadListener {
        void onQRCodeRead(String text, PointF[] points, byte[] rawBytes);
    }

    private OnQRCodeReadListener mOnQRCodeReadListener;
    private CameraManager mCameraManager;
    private boolean mQrDecodingEnabled = true;
    private DecodeFrameTask decodeFrameTask;
    private Map<DecodeHintType, Object> decodeHints;
    private QRToViewPointTransformer qrToViewPointTransformer = new QRToViewPointTransformer();
    private MultiFormatReader mQRCodeReader;

    public QRCodeReaderView(Context context) {
        this(context, null);
    }

    public QRCodeReaderView(Context context, AttributeSet attrs) {
        super(context, attrs);

        if (checkCameraHardware()) {
            mCameraManager = new CameraManager(context);
            mCameraManager.setPreviewCallback(this);
            getHolder().addCallback(this);
            setBackCamera();
        } else {
            throw new RuntimeException("Camera not found");
        }
    }

    public void setOnQRCodeReadListener(OnQRCodeReadListener listener) {
        mOnQRCodeReadListener = listener;
    }

    public void setQRDecodingEnabled(boolean enabled) {
        mQrDecodingEnabled = enabled;
    }

    public void setDecodeHints(Map<DecodeHintType, Object> hints) {
        decodeHints = hints;
    }

    public void startCamera() {
        mCameraManager.startPreview();
    }

    public void stopCamera() {
        mCameraManager.stopPreview();
    }

    public void setTorchEnabled(boolean enabled) {
        mCameraManager.setTorchEnabled(enabled);
    }

    public void setBackCamera() {
        mCameraManager.setPreviewCameraId(Camera.CameraInfo.CAMERA_FACING_BACK);
    }

    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        try {
            mCameraManager.openDriver(holder, getWidth(), getHeight());
            mQRCodeReader = new MultiFormatReader();
            mCameraManager.startPreview();
        } catch (IOException e) {
            mCameraManager.closeDriver();
        }
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
        if (mCameraManager.getPreviewSize() == null) return;
        mCameraManager.stopPreview();
        mCameraManager.setPreviewCallback(this);
        mCameraManager.setDisplayOrientation(getCameraDisplayOrientation());
        mCameraManager.startPreview();
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        mCameraManager.stopPreview();
        mCameraManager.closeDriver();
    }

    @Override
    public void onPreviewFrame(byte[] data, Camera camera) {
        if (!mQrDecodingEnabled || (decodeFrameTask != null &&
                (decodeFrameTask.getStatus() == AsyncTask.Status.RUNNING
                        || decodeFrameTask.getStatus() == AsyncTask.Status.PENDING))) return;

        decodeFrameTask = new DecodeFrameTask(this, decodeHints);
        decodeFrameTask.execute(data);
    }

    private boolean checkCameraHardware() {
        return getContext().getPackageManager().hasSystemFeature(android.content.pm.PackageManager.FEATURE_CAMERA_ANY);
    }

    private int getCameraDisplayOrientation() {
        // default 0, implement proper rotation if needed
        return 0;
    }

    private static class DecodeFrameTask extends AsyncTask<byte[], Void, Result> {
        private final WeakReference<QRCodeReaderView> viewRef;
        private final WeakReference<Map<DecodeHintType, Object>> hintsRef;

        DecodeFrameTask(QRCodeReaderView view, Map<DecodeHintType, Object> hints) {
            viewRef = new WeakReference<>(view);
            hintsRef = new WeakReference<>(hints);
        }

        @Override
        protected Result doInBackground(byte[]... params) {
            QRCodeReaderView view = viewRef.get();
            if (view == null) return null;

            PlanarYUVLuminanceSource source = view.mCameraManager.buildLuminanceSource(
                    params[0], view.mCameraManager.getPreviewSize().x, view.mCameraManager.getPreviewSize().y);
            BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(source));
            try {
                return view.mQRCodeReader.decode(bitmap, hintsRef.get());
            } catch (ChecksumException | NotFoundException | FormatException e) {
                view.mQRCodeReader.reset();
            }
            return null;
        }

        @Override
        protected void onPostExecute(Result result) {
            QRCodeReaderView view = viewRef.get();
            if (view != null && result != null && view.mOnQRCodeReadListener != null) {
                view.mOnQRCodeReadListener.onQRCodeRead(result.getText(), result.getResultPoints(), result.getRawBytes());
            }
        }
    }
}
