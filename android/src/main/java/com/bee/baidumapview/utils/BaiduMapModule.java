package com.bee.baidumapview.utils;

/**
 * Created by kete on 16/3/10.
 */
public class BaiduMapModule {
    public BaiduMapModule(){};
    public BaiduMapModule(Double baidu_latitude,Double baidu_longitude,String address,int range){
        this.baidu_latitude = baidu_latitude;
        this.baidu_longitude = baidu_longitude;
        this.address = address;
        this.range = range;
    };
    public Double baidu_latitude;
    public Double baidu_longitude;
    public String address;
    public int range;
}
