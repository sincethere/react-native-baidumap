//
//  BaiduMapLibrary.h
//  BaiduMapLibrary
//
//  Created by rover on 16/4/15.
//  Copyright © 2016年 rover. All rights reserved.
//

#import "RCTViewManager.h"
#import "RCTMapManager.h"
#import "RCTUIManager.h"
#import "RCTBridge.h"
#import <MapKit/MapKit.h>
#import "RCTMap.h"

#import "UIView+React.h"

#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件

#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件

#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件

#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件

@interface BaiduMapLibrary : RCTViewManager<RCTBridgeModule,MKMapViewDelegate,BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,BMKSuggestionSearchDelegate,UIGestureRecognizerDelegate>{
    
    BMKGeoCodeSearch			  *geoSearcher;
    BMKSuggestionSearch     *sugestionSearch;
    NSString							  *touchAddress;   			 //电子围栏时，点击地图搜索到的地址
    NSMutableArray					*search_AddressArray;
    NSMutableArray					*search_Coordinate2DArray;
    BOOL										isEnableClicked;		  //YES：表示普通状态，NO：以触摸点为中心画一个圆
    int	 										range;								//以触摸点为中心画一个圆，会有一个默认值
    NSMutableDictionary			*fenceDic;						//电子围栏信息，上报给JS的
    NSString                *iconStr;
    NSOperationQueue        *operationQueue;      //头像加载异步队列
    UIImage                 *iconImage;
    NSTimer                 *waveTimer;
    NSMutableArray          *tempArray;           //存储wave中间数组
    BOOL                    startPointFlag;       //起点
    BOOL                    endPointFlag;         //终点
}

@property (nonatomic, retain) BMKGeoCodeSearch			*geoSearcher;
@property (nonatomic, retain) BMKSuggestionSearch 	*sugestionSearch;
@property (nonatomic, retain) NSString							*touchAddress;
@property (nonatomic, retain) NSMutableArray				*search_AddressArray;
@property (nonatomic, retain) NSMutableArray				*search_Coordinate2DArray;
@property (assign) RCTResponseSenderBlock  callback_RCT;
@property (assign)						BOOL									isEnableClicked;
@property (assign)						int										range;
@property (nonatomic, retain) NSMutableDictionary		*fenceDic;
@property (nonatomic, retain) NSString              *iconStr;
@property (nonatomic, retain) NSOperationQueue      *operationQueue;
@property (nonatomic, retain) UIImage               *iconImage;
@property (nonatomic, retain) NSTimer               *waveTimer;
@property (nonatomic, retain) NSMutableArray        *tempArray;
@property (assign)            BOOL                  startPointFlag;
@property (assign)            BOOL                  endPointFlag;

@end
