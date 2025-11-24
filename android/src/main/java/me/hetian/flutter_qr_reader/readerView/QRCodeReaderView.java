package me.hetian.flutter_qr_reader.readerView;

import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.Point;
import android.graphics.PointF;
import android.hardware.Camera;
import android.os.AsyncTask;
import android.os.Build;
import android.util.AttributeSet;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.WindowManager;

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
import com.google.zxing.qrcode.QRCodeReader;

import java.io.IOException;
import java.lang.ref.WeakReference;
import java.util.Map;

import static me.hetian.flutter_qr_reader.QRCodeDecoder.HINTS;

public class QRCodeReaderView extends SurfaceView
        implements SurfaceHolder.Callback, Camera.PreviewCallback {

    public interface OnQRCodeReadListener {
        void onQRCodeRead(String text, PointF[] points, byte[] rawBytes);
    }

    private OnQRCodeReadListener mOnQRCodeReadListener;
    private QRCodeReader mQRCodeReader;
    private int mPreviewWidth;
    private int mPreviewHeight;
    private Camera mCamera;
    private boolean mQrDecodingEnabled = true;
    private DecodeFrameTask decodeFrameTask;
    private Map<DecodeHintType, Object> decodeHints;

    public final QRToViewPointTransformer qrToViewPointTransformer = new QRToViewPointTransformer();

    public QRCodeReaderView(Context context) {
        this(context, null);
    }

    public QRCodeReaderView(Context context, AttributeSet attrs) {
        super(context, attrs);

        if (isInEditMode()) return;

        if (!checkCameraHardware()) {
            throw new RuntimeException("Error: Camera not found");
        }

        getHolder().addCallback(this);
    }

    public void setOnQRCodeReadListener(OnQRCodeReadListener listener) {
        mOnQRCodeReadListener = listener;
    }

    public void setQRDecodingEnabled(boolean enabled) {
        this.mQrDecodingEnabled = enabled;
    }

    public void setDecodeHints(Map<DecodeHintType, Object> hints) {
        this.decodeHints = hints;
    }

    public void setTorchEnabled(boolean enabled) {
        if (mCamera != null) {
            Camera.Parameters params = mCamera.getParameters();
            params.setFlashMode(enabled ? Camera.Parameters.FLASH_MODE_TORCH : Camera.Parameters.FLASH_MODE_OFF);
            mCamera.setParameters(params);
        }
    }

    public void startCamera() {
        if (mCamera != null) mCamera.startPreview();
    }

    public void stopCamera() {
        if (mCamera != null) mCamera.stopPreview();
    }

    public void setBackCamera() {
        openCamera(Camera.CameraInfo.CAMERA_FACING_BACK);
    }

    public void setFrontCamera() {
        openCamera(Camera.CameraInfo.CAMERA_FACING_FRONT);
    }

    private void openCamera(int cameraId) {
        if (mCamera != null) {
            mCamera.stopPreview();
            mCamera.release();
            mCamera = null;
        }

        try {
            mCamera = Camera.open(cameraId);
            mCamera.setPreviewDisplay(getHolder());
            mCamera.setPreviewCallback(this);
            mCamera.setDisplayOrientation(getCameraDisplayOrientation(cameraId));
            mCamera.startPreview();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @SuppressWarnings("deprecation")
    private int getCameraDisplayOrientation(int cameraId) {
        Camera.CameraInfo info = new Camera.CameraInfo();
        Camera.getCameraInfo(cameraId, info);

        int rotation = ((WindowManager) getContext().getSystemService(Context.WINDOW_SERVICE))
                .getDefaultDisplay().getRotation();
        int degrees = 0;
        switch (rotation) {
            case Surface.ROTATION_0: degrees = 0; break;
            case Surface.ROTATION_90: degrees = 90; break;
            case Surface.ROTATION_180: degrees = 180; break;
            case Surface.ROTATION_270: degrees = 270; break;
        }

        if (info.facing == Camera.CameraInfo.CAMERA_FACING_FRONT) {
            int result = (info.orientation + degrees) % 360;
            return (360 - result) % 360;
        } else {
            return (info.orientation - degrees + 360) % 360;
        }
    }

    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        setBackCamera();
        mQRCodeReader = new QRCodeReader();
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
        if (mCamera == null) return;

        mPreviewWidth = mCamera.getParameters().getPreviewSize().width;
        mPreviewHeight = mCamera.getParameters().getPreviewSize().height;

        mCamera.stopPreview();
        try {
            mCamera.setPreviewDisplay(holder);
            mCamera.setPreviewCallback(this);
            mCamera.startPreview();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        if (mCamera != null) {
            mCamera.setPreviewCallback(null);
            mCamera.stopPreview();
            mCamera.release();
            mCamera = null;
        }
    }

    @Override
    public void onPreviewFrame(byte[] data, Camera camera) {
        if (!mQrDecodingEnabled || (decodeFrameTask != null &&
                (decodeFrameTask.getStatus() == AsyncTask.Status.RUNNING ||
                        decodeFrameTask.getStatus() == AsyncTask.Status.PENDING))) {
            return;
        }

        decodeFrameTask = new DecodeFrameTask(this, decodeHints);
        decodeFrameTask.execute(data);
    }

    private boolean checkCameraHardware() {
        PackageManager pm = getContext().getPackageManager();
        return pm.hasSystemFeature(PackageManager.FEATURE_CAMERA) ||
                pm.hasSystemFeature(PackageManager.FEATURE_CAMERA_FRONT) ||
                (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1 &&
                        pm.hasSystemFeature(PackageManager.FEATURE_CAMERA_ANY));
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
            if (view == null || view.mCamera == null) return null;

            Camera.Size previewSize = view.mCamera.getParameters().getPreviewSize();
            PlanarYUVLuminanceSource source =
                    new PlanarYUVLuminanceSource(params[0], previewSize.width, previewSize.height, 0, 0,
                            previewSize.width, previewSize.height, false);

            BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(source));

            try {
                return view.mQRCodeReader.decode(bitmap, hintsRef.get());
            } catch (ChecksumException | FormatException | NotFoundException e) {
                return null;
            } finally {
                view.mQRCodeReader.reset();
            }
        }

        @Override
        protected void onPostExecute(Result result) {
            QRCodeReaderView view = viewRef.get();
            if (view != null && result != null && view.mOnQRCodeReadListener != null) {
                Camera.Size previewSize = view.mCamera.getParameters().getPreviewSize();
                PointF[] transformedPoints = view.qrToViewPointTransformer.transform(
                        result.getResultPoints(),
                        false,
                        view.getWidth() > view.getHeight() ? Orientation.LANDSCAPE : Orientation.PORTRAIT,
                        new Point(view.getWidth(), view.getHeight()),
                        new Point(previewSize.width, previewSize.height)
                );

                view.mOnQRCodeReadListener.onQRCodeRead(result.getText(), transformedPoints, result.getRawBytes());
            }
        }
    }
}
