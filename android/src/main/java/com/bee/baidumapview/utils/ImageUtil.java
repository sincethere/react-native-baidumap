package com.bee.baidumapview.utils;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.support.annotation.DrawableRes;
import android.text.TextUtils;
import android.widget.ImageView;


import com.squareup.picasso.Picasso;
import com.squareup.picasso.Target;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;

/**
 * Created by chon_den on 2015/6/30.
 *
 */
public class ImageUtil {
    private static Context context;
    private static int defaultDrawableRes;
    private static RoundedTransformation roundedTransformation;

    public static void init(Context c,int defaultRes) {
        context = c;
        defaultDrawableRes = defaultRes;
    }

    /**
     * 加载图片（无默认图片显示）
     * @param url
     * @param imageView
     */
    public static void load(String url,ImageView imageView){
        if(TextUtils.isEmpty(url)){
            load(defaultDrawableRes,imageView);
            return;
        }
        Picasso.with(context)
                .load(url)
                .into(imageView);
    }

    public static void load(@DrawableRes int drawableRes,ImageView imageView){
        Picasso.with(context)
                .load(drawableRes)
                .into(imageView);
    }

    /**
     * 加载图片回调
     * @param url   图片url
     * @param target    回调
     */
    public static void load(String url,Target target){
        if(TextUtils.isEmpty(url)){
            Picasso.with(context).load(defaultDrawableRes).into(target);
            return;
        }
        Picasso.with(context).load(url).into(target);
    }


/*
    public static void load(String url,ImageView imageView,Transformation transformation){
        if(TextUtils.isEmpty(url)){
            return;
        }
        Picasso.with(context)
                .load(url)
                .transform(transformation)
                .into(imageView);
    }
*/


    /**
     * 加载圆角图形
     * @param url
     * @param imageView
     */
/*    public static void loadCircle(String url,ImageView imageView){
        if(TextUtils.isEmpty(url)){
            return;
        }
        if(roundedTransformation == null){
            roundedTransformation = new RoundedTransformation();
        }

        load(url, imageView, roundedTransformation);
    }*/


    /**
     * 加载图片（）
     * @param url               图片地址
     * @param imageView         图片控件
     * @param placeholderRes    默认展位图片
     */
    public static void load(String url,ImageView imageView,@DrawableRes int placeholderRes){
        if(TextUtils.isEmpty(url)){
            Picasso.with(context).load(placeholderRes).into(imageView);
            return;
        }

        Picasso.with(context)
                .load(url)
                .placeholder(placeholderRes)
                .into(imageView);
    }


    /**
     * 加载图片
     * @param url               图片地址
     * @param imageView         图片控件
     * @param placeholderRes    默认展位图片
     * @param errorRes          加载错误显示图片
     */
    public static void load(String url,ImageView imageView,@DrawableRes int placeholderRes,@DrawableRes int errorRes){
        if(TextUtils.isEmpty(url)){
            load(placeholderRes,imageView);
            return;
        }
        Picasso.with(context)
                .load(url)
                .placeholder(placeholderRes)
                .error(errorRes)
                .into(imageView);
    }

    /**
     * 加载本地文件图片
     * @param filePath 文件图片路径
     * @param imageView 图片控件
     */
    public static void loadFileImage(String filePath, ImageView imageView) {
        Picasso.with(context)
                .load(new File(filePath))
                .into(imageView);
    }

    public static void loadDrawableCircle(@DrawableRes int drawableRes,ImageView imageView){
        if(roundedTransformation == null){
            roundedTransformation = new RoundedTransformation();
        }
        Picasso.with(context)
                .load(drawableRes)
                .transform(roundedTransformation)
                .into(imageView);
    }
    public static void loadFileCircle(File f,ImageView imageView){
        if(roundedTransformation == null){
            roundedTransformation = new RoundedTransformation();
        }
        Picasso.with(context)
                .load(f)
                .transform(roundedTransformation)
                .into(imageView);
    }
    /**
     * 图片压缩方法实现
     * @param srcPath 原图地址
     * @param finishPath 压缩后保存图片地址
     * @param avatorpath 保存的文件夹路径
     * @return
     */
    public static Bitmap getimage(String srcPath,String finishPath,String avatorpath) {
        BitmapFactory.Options newOpts = new BitmapFactory.Options();
//        newOpts.inPreferredConfig = Bitmap.Config.ARGB_8888;
//        newOpts.inPreferredConfig = Bitmap.Config.RGB_565;
        newOpts.inPreferredConfig = Bitmap.Config.ALPHA_8;
        // 开始读入图片，此时把options.inJustDecodeBounds 设回true了
        newOpts.inJustDecodeBounds = true;
//        Bitmap bitmap = BitmapFactory.decodeFile(srcPath, newOpts);
        Bitmap bitmap;
        newOpts.inJustDecodeBounds = false;
        int w = newOpts.outWidth;
        int h = newOpts.outHeight;
        int hh = 800;// 这里设置高度为800f
        int ww = 480;// 这里设置宽度为480f
        // 缩放比。由于是固定比例缩放，只用高或者宽其中一个数据进行计算即可
        int be = 1;// be=1表示不缩放
        if (w > h && w > ww) {// 如果宽度大的话根据宽度固定大小缩放
            be = (int) (newOpts.outWidth / ww);
        } else if (w < h && h > hh) {// 如果高度高的话根据高度固定大小缩放
            be = (int) (newOpts.outHeight / hh);
        }
        if (be <= 0)
            be = 1;
        newOpts.inSampleSize = be;// 设置缩放比例
        // 重新读入图片，注意此时已经把options.inJustDecodeBounds 设回false了
        bitmap = BitmapFactory.decodeFile(srcPath, newOpts);
        return compressImage(bitmap,finishPath,avatorpath);// 压缩好比例大小后再进行质量压缩
    }


    /**
     * 质量压缩
     * @param image
     * @return
     */
    private static Bitmap compressImage(Bitmap image,String finishPath,String avatorpath) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        image.compress(Bitmap.CompressFormat.JPEG, 60, baos);// 质量压缩方法，这里100表示不压缩，把压缩后的数据存放到baos中
        int options = 60;
        while (baos.toByteArray().length / 1024 > 100) { // 循环判断如果压缩后图片是否大于100kb,大于继续压缩
            baos.reset();// 重置baos即清空baos
            options -= 10;// 每次都减少10
            image.compress(Bitmap.CompressFormat.JPEG, options, baos);// 这里压缩options%，把压缩后的数据存放到baos中
            //如果图片太大，就不能无限减少options，范围（0-100]
            if(options == 10){
                break;
            }

        }
        ByteArrayInputStream isBm = new ByteArrayInputStream(baos.toByteArray());// 把压缩后的数据baos存放到ByteArrayInputStream中
        Bitmap bitmap = BitmapFactory.decodeStream(isBm, null, null);// 把ByteArrayInputStream数据生成图片
        try {
            File fileDir = new File(avatorpath);
            if (!fileDir.exists()) {
                fileDir.mkdirs();
            }
            FileOutputStream out = new FileOutputStream(finishPath);
            bitmap.compress(Bitmap.CompressFormat.PNG, 60, out);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return bitmap;
    }
    /**
     * 图片压缩方法实现
     * @param srcPath 原图地址
     * @param finishPath 压缩后保存图片地址
     * @param avatorpath 保存的文件夹路径
     * @return
     */
    public static void getimageInPath(String srcPath,String finishPath,String avatorpath) {
        BitmapFactory.Options newOpts = new BitmapFactory.Options();
        newOpts.inPreferredConfig = Bitmap.Config.ARGB_8888;
        // 开始读入图片，此时把options.inJustDecodeBounds 设回true了
        newOpts.inJustDecodeBounds = true;
//        Bitmap bitmap = BitmapFactory.decodeFile(srcPath, newOpts);
        Bitmap bitmap;
        newOpts.inJustDecodeBounds = false;
        int w = newOpts.outWidth;
        int h = newOpts.outHeight;
        int hh = 800;// 这里设置高度为800f
        int ww = 480;// 这里设置宽度为480f
        // 缩放比。由于是固定比例缩放，只用高或者宽其中一个数据进行计算即可
        int be = 1;// be=1表示不缩放
        if (w > h && w > ww) {// 如果宽度大的话根据宽度固定大小缩放
            be = (int) (newOpts.outWidth / ww);
        } else if (w < h && h > hh) {// 如果高度高的话根据高度固定大小缩放
            be = (int) (newOpts.outHeight / hh);
        }
        if (be <= 0)
            be = 1;
        newOpts.inSampleSize = be;// 设置缩放比例
        // 重新读入图片，注意此时已经把options.inJustDecodeBounds 设回false了
        bitmap = BitmapFactory.decodeFile(srcPath, newOpts);
        compressImageInPath(bitmap, finishPath, avatorpath);// 压缩好比例大小后再进行质量压缩
    }


    /**
     * 质量压缩
     * @param image
     * @return
     */
    private static void compressImageInPath(Bitmap image,String finishPath,String avatorpath) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        image.compress(Bitmap.CompressFormat.JPEG, 60, baos);// 质量压缩方法，这里100表示不压缩，把压缩后的数据存放到baos中
        int options = 60;
        while (baos.toByteArray().length / 1024 > 100) { // 循环判断如果压缩后图片是否大于100kb,大于继续压缩
            baos.reset();// 重置baos即清空baos
            options -= 10;// 每次都减少10
            image.compress(Bitmap.CompressFormat.JPEG, options, baos);// 这里压缩options%，把压缩后的数据存放到baos中
            //如果图片太大，就不能无限减少options，范围（0-100]
            if(options == 10){
                break;
            }

        }
        ByteArrayInputStream isBm = new ByteArrayInputStream(baos.toByteArray());// 把压缩后的数据baos存放到ByteArrayInputStream中
        Bitmap bitmap = BitmapFactory.decodeStream(isBm, null, null);// 把ByteArrayInputStream数据生成图片
        try {
            File fileDir = new File(avatorpath);
            if (!fileDir.exists()) {
                fileDir.mkdirs();
            }
            FileOutputStream out = new FileOutputStream(finishPath);
            bitmap.compress(Bitmap.CompressFormat.PNG, 60, out);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    /**
     * 根据原图和变长绘制圆形图片
     *
     * @param source
     * @param min
     * @return
     */
    public static Bitmap createCircleImage(Bitmap source, int min)
    {
        final Paint paint = new Paint();
        paint.setAntiAlias(true);
        Bitmap target = Bitmap.createBitmap(min, min, Bitmap.Config.ARGB_8888);
        /**
         * 产生一个同样大小的画布
         */
        Canvas canvas = new Canvas(target);
        /**
         * 首先绘制圆形
         */
        canvas.drawCircle(min / 2, min / 2, min / 2, paint);
        /**
         * 使用SRC_IN，参考上面的说明
         */
        paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_IN));
        /**
         * 绘制图片
         */
        canvas.drawBitmap(source, 0, 0, paint);
        return target;
    }
}
