package com.bee.baidumapview.utils;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.drawable.Drawable;
import android.os.CountDownTimer;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Base64;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.baidu.mapapi.map.BaiduMap;
import com.baidu.mapapi.map.BitmapDescriptor;
import com.baidu.mapapi.map.BitmapDescriptorFactory;
import com.baidu.mapapi.map.Marker;
import com.bee.baidumapview.R;
import com.squareup.okhttp.Response;
import com.squareup.picasso.Picasso;
import com.squareup.picasso.Target;

import java.util.ArrayList;

/**
 * Created by kete on 2015/9/16.
 */
public class MapUtils {
    static Context mContext;
    public static CountDownTimer mDownTimer;




    public interface GetViewBitmapCallback{
        void onSuccess(Bitmap bitmap);
    }

    /**
     * View转换为bitmap的方法。
     */
    public static void getViewBitmap(Context context, final String avatar, final GetViewBitmapCallback getViewBitmapCallback) {
        final View view = View.inflate(context, R.layout.custom_foot_marker, null);
        final ImageView img_pic = (ImageView) view.findViewById(R.id.img_pic);

        if(TextUtils.isEmpty(avatar)){
            img_pic.setImageResource(R.mipmap.default_avatar);
        }else{
            Handler uiHandler = new Handler(Looper.getMainLooper());
            uiHandler.post(new Runnable() {
                @Override
                public void run() {
                    ImageUtil.load(avatar,new Target() {
                        @Override
                        public void onBitmapLoaded(Bitmap bitmap, Picasso.LoadedFrom from) {
                            img_pic.setImageBitmap(bitmap);
                            getViewBitmapCallback.onSuccess(getBitmapFromView(view));
                        }

                        @Override
                        public void onBitmapFailed(Drawable errorDrawable) {
                        }

                        @Override
                        public void onPrepareLoad(Drawable placeHolderDrawable) {
                        }
                    });
                }
            });

        }
    }

    /**
     * View转换为bitmap的方法。
     */
    public static Bitmap getViewBitmap(Context context, Bitmap bitmap,String avatar) {

        View view = View.inflate(context, R.layout.custom_foot_marker, null);
        ImageView img_pic = (ImageView) view.findViewById(R.id.img_pic);
        if (bitmap == null) {
            ImageUtil.load(avatar, img_pic, R.mipmap.default_avatar);
        } else {
            img_pic.setImageBitmap(bitmap);
        }
        return getBitmapFromView(view);
    }


    /**
     * 将View转换为Bitmap
     *
     * @param view
     * @return
     */
    public static Bitmap getBitmapFromView(View view) {
        view.destroyDrawingCache();
        view.measure(View.MeasureSpec.makeMeasureSpec(0,
                View.MeasureSpec.UNSPECIFIED), View.MeasureSpec
                .makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED));
        view.layout(0, 0, view.getMeasuredWidth(), view.getMeasuredHeight());
        view.setDrawingCacheEnabled(true);
        Bitmap bitmap = view.getDrawingCache(true);
        return bitmap;
    }

    /**
     * 根据base64字符串获取Bitmap位图 getBitmap
     *
     * @throws
     */
    public static Bitmap getBitmap(String imgBase64Str) {
        try {
            byte[] bitmapArray;
            bitmapArray = Base64.decode(imgBase64Str, Base64.DEFAULT);
            return BitmapFactory.decodeByteArray(bitmapArray, 0,
                    bitmapArray.length);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * 转换图片成圆形
     *
     * @param bitmap 传入Bitmap对象
     * @return
     */
    public static Bitmap toRoundBitmap(Bitmap bitmap) {
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        float roundPx;
        float left, top, right, bottom, dst_left, dst_top, dst_right, dst_bottom;
        if (width <= height) {
            roundPx = width / 2;

            left = 0;
            top = 0;
            right = width;
            bottom = width;

            height = width;

            dst_left = 0;
            dst_top = 0;
            dst_right = width;
            dst_bottom = width;
        } else {
            roundPx = height / 2;

            float clip = (width - height) / 2;

            left = clip;
            right = width - clip;
            top = 0;
            bottom = height;
            width = height;

            dst_left = 0;
            dst_top = 0;
            dst_right = height;
            dst_bottom = height;
        }

        Bitmap output = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(output);

        final Paint paint = new Paint();
        final Rect src = new Rect((int) left, (int) top, (int) right,
                (int) bottom);
        final Rect dst = new Rect((int) dst_left, (int) dst_top,
                (int) dst_right, (int) dst_bottom);
        final RectF rectF = new RectF(dst);

        paint.setAntiAlias(true);// 设置画笔无锯齿

        canvas.drawARGB(0, 0, 0, 0); // 填充整个Canvas
        // 以下有两种方法画圆,drawRounRect和drawCircle
        canvas.drawRoundRect(rectF, roundPx, roundPx, paint);// 画圆角矩形，第一个参数为图形显示区域，第二个参数和第三个参数分别是水平圆角半径和垂直圆角半径。
        // canvas.drawCircle(roundPx, roundPx, roundPx, paint);

        paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_IN));// 设置两张图片相交时的模式
        canvas.drawBitmap(bitmap, src, dst, paint); // 以Mode.SRC_IN模式合并bitmap和已经draw了的Circle

        return output;
    }


   private static ArrayList<BitmapDescriptor>  bitmapDescriptorArrayList;
    public static ArrayList<BitmapDescriptor> getBitmapDes(Context context) {
        mContext = context;
        if(bitmapDescriptorArrayList == null) {
            bitmapDescriptorArrayList = new ArrayList<>();

            for (int i = 0; i < 10; i++) {
                BitmapDescriptor bd = BitmapDescriptorFactory.fromView(getRoundView(i));
                bitmapDescriptorArrayList.add(bd);
            }
        }
        return bitmapDescriptorArrayList;
    }


    private static View getRoundView(int position) {
        View view = new View(mContext);
        view.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        switch (position) {
            case 0:
                view.setBackgroundResource(R.drawable.shape_round);
                break;
            case 1:
                view.setBackgroundResource(R.drawable.shape_round1);
                break;
            case 2:
                view.setBackgroundResource(R.drawable.shape_round2);
                break;
            case 3:
                view.setBackgroundResource(R.drawable.shape_round3);
                break;
            case 4:
                view.setBackgroundResource(R.drawable.shape_round4);
                break;
            case 5:
                view.setBackgroundResource(R.drawable.shape_round5);
                break;
            case 6:
                view.setBackgroundResource(R.drawable.shape_round6);
                break;
            case 7:
                view.setBackgroundResource(R.drawable.shape_round7);
                break;
            case 8:
                view.setBackgroundResource(R.drawable.shape_round8);
                break;
            case 9:
                view.setBackgroundResource(R.drawable.shape_round9);
                break;
        }
        return view;
    }

    /**
     * 定时停止雷达动画
     * @param millisInFuture
     */
    public static void stopRadarAnimation(long millisInFuture, final Marker markerAnimation) {
        if(markerAnimation == null)
            return;
        mDownTimer = new CountDownTimer(millisInFuture, 1 * 1000) {

            public void onTick(long millisUntilFinished) {

            }

            public void onFinish() {
                markerAnimation.remove();
            }
        }.start();
    }

    /**
     * 定时停止雷达动画
     * @param millisInFuture
     */
    public static void stopHidePopup(long millisInFuture, final BaiduMap baiduMap) {
        mDownTimer = new CountDownTimer(millisInFuture, 1 * 1000) {

            public void onTick(long millisUntilFinished) {

            }

            public void onFinish() {
                baiduMap.hideInfoWindow();
            }
        }.start();
    }
}