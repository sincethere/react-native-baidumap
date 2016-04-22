/**
 * dialog
 * Author:honaf
 */
'use strict';

import {
    Component,
    NativeModules,
    Platform,
    requireNativeComponent
} from 'react-native';

let MyMapModule = undefined;
let plat = Platform.OS;
if (plat === 'ios') {
    MyMapModule = NativeModules.BaiduMapLibrary;
} else {
    MyMapModule = NativeModules.BaiduMapModuleManager;
}

let BDMapModule = {
    /**
     * ref:React.findNodeHandle(this.refs.history)
     */
    onDestroyBDMap(ref){
        MyMapModule.onDestroyBDMap(ref);
    },

    /**
     * ref:React.findNodeHandle(this.refs.history)
     */
    updateMarkInfo(ref,data){
        if(plat === 'ios'){
            MyMapModule.setLocation(ref,data);
        }else{
            MyMapModule.updateMarkInfo(ref,data);
        }
    },

    /**
     *距离
     */
    setRuler(ref,ruler){
        MyMapModule.setRuler(ref,ruler);
    },

    /**
     * 打点
     */
    addPoint(ref,avatar,itemArray){
        if(plat === 'ios'){
            MyMapModule.setLocation(ref,itemArray);
        }else{
            MyMapModule.addPoint(ref,avatar,itemArray);
        }
    },

    /**
     * 连线
     */
    setDrewLine(ref,itemArray){
        if(plat === 'ios'){
            MyMapModule.showHistory_ios(ref,itemArray);
        }else{
            MyMapModule.setDrewLine(ref,itemArray);
        }
    },

    animateMapStatus(ref,value){
        if(plat === 'ios'){
            MyMapModule.setLocation(ref,value);
        }else{
            MyMapModule.animateMapStatus(ref,value);
        }
    },


    setLocation(ref,value){
        MyMapModule.setLocation(ref,value);
    },

    setLocationAnimation(ref,value){
        MyMapModule.setLocationAnimation(ref,value);
    },

    seekAddress(address){
        MyMapModule.seekAddress(address);
    },

    addGeoFenceCircle(ref,msg){
        if(Platform.OS === 'ios'){
            MyMapModule.DrawCircle_ios(ref,msg);
        }else{
            MyMapModule.addGeoFenceCircle(ref,msg)
        }
    },
}

module.exports = BDMapModule;