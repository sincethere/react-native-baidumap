//
//  BaiduMapLibrary.m
//  BaiduMapLibrary
//
//  Created by rover on 16/4/15.
//  Copyright © 2016年 rover. All rights reserved.
//

#import "BaiduMapLibrary.h"


#import "UIImage+XG.h"

@implementation BaiduMapLibrary{
    BMKMapView *mapView_mk;
    NSString *imageUrl;
    NSMutableArray *pointDataArray;
    NSMutableArray *pointViewArray;
    float    lat;
    float    log;
    BOOL     circleFlag;  //点击画圆的标识
    BMKPointAnnotation *anno;
    BMKLocationService *_locService;
    RCTResponseSenderBlock callb;
}

@synthesize bridge = _bridge;
@synthesize methodQueue = _methodQueue;
@synthesize geoSearcher;
@synthesize sugestionSearch;
@synthesize touchAddress;
@synthesize search_AddressArray;
@synthesize search_Coordinate2DArray;
@synthesize callback_RCT;
@synthesize isEnableClicked;
@synthesize range;
@synthesize fenceDic;
@synthesize iconStr;
@synthesize operationQueue;
@synthesize iconImage;
@synthesize waveTimer;
@synthesize tempArray;
@synthesize startPointFlag;
@synthesize endPointFlag;

RCT_EXPORT_MODULE()     //必须导入Native的该宏，想当于声明这个类要实现自定义模块的功能


RCT_EXPORT_VIEW_PROPERTY(showMapScaleBar,BOOL)

RCT_CUSTOM_VIEW_PROPERTY(region, MKCoordinateRegion, RCTMap){
    [view setRegion:json ? [RCTConvert MKCoordinateRegion:json] : defaultView.region animated:NO];
}

RCT_CUSTOM_VIEW_PROPERTY(isEnableClicked, BOOL, BaiduMapLibrary){
    self.isEnableClicked = [json boolValue];
    NSLog(@"self.isEnableClicked = %d",self.isEnableClicked);
}

RCT_CUSTOM_VIEW_PROPERTY(range, int, BaiduMapLibrary){
    self.range = [json intValue];
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (UIView *)view{
    BMKMapView *map = [[BMKMapView alloc] init];
    map.delegate = self;
    [map setMapType:BMKMapTypeStandard];
    map.userTrackingMode = BMKUserTrackingModeFollow;
    map.zoomLevel = 17;//5;
    self.geoSearcher = [[BMKGeoCodeSearch alloc]init];
    self.geoSearcher.delegate = self;
    self.sugestionSearch = [[BMKSuggestionSearch alloc]init];
    self.sugestionSearch.delegate = self;
    self.iconImage = nil;
    self.startPointFlag = NO;
    self.endPointFlag = NO;
    UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(drawCrile:)];
    tapgesture.delegate = self;
    [map addGestureRecognizer:tapgesture];
    return map;
}

#pragma mark -------------------------------------------------- 地图上画圆
- (void)drawCrile:(UITapGestureRecognizer *)gesture{
    if(self.isEnableClicked == YES){
        return;
    }
    self.touchAddress = nil;
    self.fenceDic = [[NSMutableDictionary alloc] init];
    
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)gesture;
    BMKMapView *bk = (BMKMapView *)gesture.view;
    CGPoint point = [tap locationInView:bk];
    CLLocationCoordinate2D coord1 = [bk convertPoint:point
                                toCoordinateFromView:mapView_mk];
    CLLocationCoordinate2D  pt = (CLLocationCoordinate2D){coord1.latitude, coord1.longitude};
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];//初始化反编码请求
    reverseGeocodeSearchOption.reverseGeoPoint = pt;//设置反编码的店为pt
    BOOL flag = [self.geoSearcher reverseGeoCode:reverseGeocodeSearchOption];//发送反编码请求.并返回是否成功
    if(flag){
        NSLog(@"反geo检索发送成功 手势点击事件 pt = %f  %f",pt.latitude,pt.longitude);
        NSNumber *number1 = [NSNumber numberWithFloat:pt.latitude];
        NSNumber *number2 = [NSNumber numberWithFloat:pt.longitude];
        [self.fenceDic setObject:number1 forKey:@"baidu_latitude"];
        [self.fenceDic setObject:number2 forKey:@"baidu_longitude"];
        [bk setCenterCoordinate:coord1 animated:YES];
        BMKCircle *cir = [BMKCircle circleWithCenterCoordinate:coord1 radius:self.range];
        [bk removeOverlays:bk.overlays];
        [bk addOverlay:cir];
    }
    else{
        NSLog(@"反geo检索发送失败");
    }
    
}

#pragma mark -------------------------------------------------- 画圆 画线
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay{
    if ([overlay isKindOfClass:[BMKCircle class]]){
        BMKCircleView* polygonView = [[BMKCircleView alloc] initWithOverlay:overlay];
        polygonView.strokeColor = [[UIColor yellowColor] colorWithAlphaComponent:0.1];
        polygonView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        polygonView.lineWidth = 2.0;
        return polygonView;
    }
    else if ([overlay isKindOfClass:[BMKPolyline class]]){
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.strokeColor = [[UIColor colorWithRed:0x2a/255. green:0xaf/255. blue:0xe7/255. alpha:1.0] colorWithAlphaComponent:1];
        polylineView.lineWidth = 2.0;
        return polylineView;
    }
    return nil;
}


#pragma mark -------------------------------------------------- 实现相关delegate 处理位置信息更新
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    //	mapView_mk.showsUserLocation = YES;//显示定位图层
    //	[mapView_mk updateLocationData:userLocation];
}

#pragma mark -------------------------------------------------- 处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    //	if(anno)
    //		[mapView_mk removeAnnotation:anno];
    //	anno = [[BMKPointAnnotation alloc] init];
    //	CLLocationCoordinate2D center = userLocation.location.coordinate;
    //	anno.coordinate = center;
    //	anno.title = @"宝贝当前位置";
    //	[mapView_mk setCenterCoordinate:center animated:NO];
    //	[mapView_mk addAnnotation:anno];
}


#pragma mark -------------------------------------------------- 接收反向地理编码结果
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    if (error == 0) {
        NSMutableArray *data=[NSMutableArray arrayWithCapacity:result.poiList.count];
        for (BMKPoiInfo *info in result.poiList) {
            NSDictionary *dict=@{@"name":info.name,
                                 @"city":info.city,
                                 @"address":info.address};
            [data addObject:dict];
            self.touchAddress = info.address;
            NSLog(@"点击的地址为 ---> %@",self.touchAddress);
            [self.fenceDic setObject:self.touchAddress forKey:@"address"];
            NSNumber *ra = [NSNumber numberWithInt:self.range];
            [self.fenceDic setObject:ra forKey:@"radius"];
//            [[PetGlobal shareInstance].rootView.bridge.eventDispatcher sendDeviceEventWithName:@"FenceInfo" body:@{@"result":self.fenceDic}];
            [_bridge.eventDispatcher sendDeviceEventWithName:@"FenceInfo" body:@{@"result":self.fenceDic}];
            break;
        }
    }
    else {
        NSLog(@"抱歉，未找到结果");
    }
}


#pragma mark -------------------------------------------------- 联想关键词搜索代理
- (void)onGetSuggestionResult:(BMKSuggestionSearch*)searcher result:(BMKSuggestionResult*)result errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for(int i=0;i<result.ptList.count;i++){
            NSValue *v = result.ptList[i];
            CLLocationCoordinate2D coord1;
            [v getValue:&coord1];
            float f1 = coord1.latitude;
            float f2 = coord1.longitude;
            NSNumber *number1 = [NSNumber numberWithFloat:f1];
            NSNumber *number2 = [NSNumber numberWithFloat:f2];
            NSArray *arr = [[NSArray alloc] initWithObjects:number1,number2, nil];
            [tempArr addObject:arr];
        }
        
        [_bridge.eventDispatcher sendDeviceEventWithName:@"SearchResult" body:@{@"result_pt":tempArr,@"result_key":result.keyList}];
    }
    else {
        NSLog(@"抱歉，未找到结果");
    }
}


#pragma mark -------------------------------------------------- 搜索地址
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView{
    [_bridge.eventDispatcher sendDeviceEventWithName:@"MapLoaded" body:@{@"result":@"OK"}];
}

#pragma mark -------------------------------------------------- 销毁地图
RCT_EXPORT_METHOD(onDestroyBDMap:(nonnull NSNumber *)reactTag){
    dispatch_async(_bridge.uiManager.methodQueue,^{
        [_bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
            for(int i=0;i<self.tempArray.count;i++){
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(waveFun:) object:[self.tempArray objectAtIndex:i]];
            }
            id view = viewRegistry[reactTag];
            self.geoSearcher.delegate = nil;
            self.sugestionSearch.delegate = self;
            BMKMapView *bk = (BMKMapView *)view;
            [bk removeOverlays:bk.overlays];
            [bk removeAnnotations:bk.annotations];
            bk.delegate = nil;
            bk = nil;
        }];
    });
}

#pragma mark -------------------------------------------------- 搜索地址
RCT_EXPORT_METHOD(seekAddress:(NSString *)address){
    self.search_AddressArray = [[NSMutableArray alloc] init];
    self.search_Coordinate2DArray = [[NSMutableArray alloc] init];
    BMKSuggestionSearchOption* option = [[BMKSuggestionSearchOption alloc] init];
    option.keyword = address;
    BOOL _flag = [self.sugestionSearch suggestionSearch:option];
    if(_flag){
        NSLog(@"建议检索发送成功");
    }
    else{
        NSLog(@"建议检索发送失败");
    }
}

#pragma mark -------------------------------------------------- 放大 ／ 缩小地图
RCT_EXPORT_METHOD(setRuler:(nonnull NSNumber *)reactTag int:(int)level){
    dispatch_async(_bridge.uiManager.methodQueue,^{
        [_bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
            id view = viewRegistry[reactTag];
            BMKMapView *bk = (BMKMapView *)view;
            bk.zoomLevel = level;
        }];
    });
}

#pragma mark - 定位定波纹闪动
- (void)waveFun:(NSArray *)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        BMKMapView *mview = (BMKMapView *)[data objectAtIndex:0];
        float f1 = [[data objectAtIndex:1] floatValue];
        float f2 = [[data objectAtIndex:2] floatValue];
        float r  = [[data objectAtIndex:3] intValue];
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake(f1, f2);
        BMKCircle *cir = [BMKCircle circleWithCenterCoordinate:center radius:r];
        [mview removeOverlays:mview.overlays];
        [mview addOverlay:cir];
    });
}

- (void)showWave:(NSArray *)data{
    int r = 0;
    int count =0;
    if(self.tempArray.count > 0){
        [self.tempArray removeAllObjects];
    }
    else{
        self.tempArray = [[NSMutableArray alloc] init];
    }
    for(int i=1;i<4;i++){
        for(int j=1;j<8;j++){
            if(j==1)
                r = 20;
            else if (j==2)
                r = 25;
            else if (j==3)
                r = 30;
            else if (j==4)
                r = 35;
            else if (j==5)
                r = 40;
            else if (j==6)
                r = 45;
            else if (j==7)
                r = 50;
            count++;
            NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:data];
            [self.tempArray addObject:temp];;
            [temp addObject:[NSNumber numberWithInt:r]];
            [self performSelector:@selector(waveFun:) withObject:temp afterDelay:count*0.3];
        }
    }
    [self performSelector:@selector(removeWave:) withObject:[data objectAtIndex:0] afterDelay:count*0.3+1];
}

- (void)removeWave:(id)map{
    BMKMapView *mv = (BMKMapView *)map;
    [mv removeOverlays:mv.overlays];
}


#pragma mark - 设置坐标点动画
RCT_EXPORT_METHOD(setLocationAnimation:(nonnull NSNumber *)reactTag data:(id)data){
    dispatch_async(_bridge.uiManager.methodQueue,^{
        [_bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
            NSObject *obj = data;
            if([obj isKindOfClass:[NSDictionary class]]){
                NSDictionary *dic = (NSDictionary *)obj;
                id view = viewRegistry[reactTag];
                BMKMapView *bk = (BMKMapView *)view;
                float f1_1 = [dic[@"baidu_latitude"] floatValue];
                float f1_2 = [dic[@"baidu_longitude"] floatValue];
                NSArray *arr = [[NSArray alloc] initWithObjects:bk,
                                [NSNumber numberWithFloat:f1_1],
                                [NSNumber numberWithFloat:f1_2],nil];
                for(int i=0;i<self.tempArray.count;i++){
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(waveFun:) object:[self.tempArray objectAtIndex:i]];
                }
                [self performSelector:@selector(showWave:) withObject:arr afterDelay:.1];
                
                
                
                BMKPointAnnotation *anno1 = [[BMKPointAnnotation alloc] init];
                anno1.title = @"1";
                CLLocationCoordinate2D center = CLLocationCoordinate2DMake(22.1234, 113.4321);
                anno1.coordinate = center;
                [bk setCenterCoordinate:center animated:NO];
                [bk addAnnotation:anno1];
                
            }
            
            
        }];
        
        
        
        
    });
}


#pragma mark -------------------------------------------------- 提供给JS使用，在地图上标记锚点
RCT_EXPORT_METHOD(setLocation:(nonnull NSNumber *)reactTag data:(id)data)
{
    dispatch_async(_bridge.uiManager.methodQueue,^{
        [_bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
            id view = viewRegistry[reactTag];
            BMKMapView *bk = (BMKMapView *)view;
            NSObject *obj = data;
            if([obj isKindOfClass:[NSDictionary class]]){
                NSDictionary *dic = (NSDictionary *)obj;
                
                float f1_1 = [dic[@"baidu_latitude"] floatValue];
                float f1_2 = [dic[@"baidu_longitude"] floatValue];
                self.iconStr = dic[@"avatar"];
                NSArray *annoArr = bk.annotations;
                BOOL tempflag = NO;
                BMKPointAnnotation *temp;
                for(int i=0;i<annoArr.count;i++){
                    temp = [annoArr objectAtIndex:i];
                    if([temp.title intValue] == 1){
                        tempflag = YES;
                        break;
                    }
                }
                if(tempflag == YES){
                    [bk removeAnnotation:temp];
                }
                BMKPointAnnotation *anno1 = [[BMKPointAnnotation alloc] init];
                anno1.title = @"1";
                CLLocationCoordinate2D center = CLLocationCoordinate2DMake(f1_1, f1_2);
                if([dic[@"fristTime"] boolValue] == YES){
                    [bk setCenterCoordinate:center animated:NO];
                }
                else{
                    anno1.coordinate = center;
                    [bk setCenterCoordinate:center animated:NO];
                    [bk addAnnotation:anno1];
                }
            }
            
            else if([obj isKindOfClass:[NSArray class]]){
                [bk removeAnnotations:bk.annotations];
                [bk removeOverlays:bk.overlays];
                NSArray *temp = (NSArray *)obj;
                for(int i=0;i<temp.count;i++){
                    NSDictionary *dic = (NSDictionary *)[temp objectAtIndex:i];
                    float f1_1 = [dic[@"baidu_latitude"] floatValue];
                    float f1_2 = [dic[@"baidu_longitude"] floatValue];
                    self.iconStr = @"im_his_route_marker_ios.png";
                    BMKPointAnnotation *anno1 = [[BMKPointAnnotation alloc] init];
                    anno1.title = dic[@"baidu_latitude"];
                    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(f1_1, f1_2);
                    if([dic[@"fristTime"] boolValue] == YES){
                        [bk setCenterCoordinate:center animated:NO];
                    }
                    else{
                        anno1.coordinate = center;
                        [bk setCenterCoordinate:center animated:NO];
                        [bk addAnnotation:anno1];
                    }
                }
            }
        }];
    });
}

#pragma mark -------------------------------------------------- 当拉动滑条改变围栏半径是，调用此方法，需将围栏的经纬度传过来
RCT_EXPORT_METHOD(DrawCircle_ios:(nonnull NSNumber *)reactTag data:(id)data){
    dispatch_async(_bridge.uiManager.methodQueue,^{
        [_bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
            id view = viewRegistry[reactTag];
            BMKMapView *bk = (BMKMapView *)view;
            [bk removeAnnotations:bk.annotations];
            [bk removeOverlays:bk.overlays];
            NSObject *obj = data;
            if([obj isKindOfClass:[NSDictionary class]]){
                NSDictionary *dic = (NSDictionary *)obj;
                if(((NSString *)dic[@"address"]).length < 1)
                    return ;
                float f1_1;
                float f1_2;
                if([dic objectForKey:@"baidu_latitude"]){
                    f1_1 = [dic[@"baidu_latitude"] floatValue];
                    f1_2 = [dic[@"baidu_longitude"] floatValue];
                }
                else{
                    f1_1 = [dic[@"latitude"] floatValue];
                    f1_2 = [dic[@"longitude"] floatValue];
                }
                int ra = [dic[@"range"] floatValue];
                CLLocationCoordinate2D center = CLLocationCoordinate2DMake(f1_1, f1_2);
                [bk setCenterCoordinate:center animated:NO];
                BMKCircle *cir = [BMKCircle circleWithCenterCoordinate:center radius:ra];
                [bk removeOverlays:bk.overlays];
                [bk addOverlay:cir];
            }
        }];
    });
}


#pragma mark -------------------------------------------------- 画历史轨迹
RCT_EXPORT_METHOD(showHistory_ios:(nonnull NSNumber *)reactTag data:(id)data)
{
    dispatch_async(_bridge.uiManager.methodQueue,^{
        [_bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
            id view = viewRegistry[reactTag];
            BMKMapView *bk = (BMKMapView *)view;
            [bk removeAnnotations:bk.annotations];
            [bk removeOverlays:bk.overlays];
            pointDataArray = [[NSMutableArray alloc] init];
            NSObject *obj = data;
            if([obj isKindOfClass:[NSArray class]]){
                NSArray *arr = (NSArray *)obj;
                for(int i=0;i<arr.count;i++){
                    [pointDataArray addObject:arr[i]];
                }
                [self drawLine:pointDataArray mapView:bk];
            }
        }];
    });
}

#pragma mark -------------------------------------------------- 移除地图上添加的锚点、线条
RCT_EXPORT_METHOD(ReSetMapview_ios){
    dispatch_async(dispatch_get_main_queue(), ^{
        [mapView_mk removeAnnotations:mapView_mk.annotations];
        [mapView_mk removeOverlays:mapView_mk.overlays];
    });
}

#pragma mark -------------------------------------------------- 画线函数
- (void)drawLine:(NSMutableArray *)linedata mapView:(BMKMapView *)mapview{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(linedata.count == 0)
            return;
        if(linedata.count > 1){
            for(int i=0;i<pointDataArray.count-1;i++){
                NSDictionary *dic1 = [pointDataArray objectAtIndex:i];
                NSDictionary *dic2 = [pointDataArray objectAtIndex:i+1];
                
                float f1_1 = [dic1[@"baidu_latitude"] floatValue];
                float f1_2 = [dic1[@"baidu_longitude"] floatValue];
                
                float f2_1 = [dic2[@"baidu_latitude"] floatValue];
                float f2_2 = [dic2[@"baidu_longitude"] floatValue];
                
                CLLocationCoordinate2D coors[2] = {0};
                coors[0].latitude  = f1_1;
                coors[0].longitude = f1_2;
                coors[1].latitude  = f2_1;
                coors[1].longitude = f2_2;
                BMKPolyline* polyline = [BMKPolyline polylineWithCoordinates:coors count:2];
                [mapview addOverlay:polyline];
            }
            //        for(int i=0;i<1;i++)
            {
                NSDictionary *dic1 = [pointDataArray objectAtIndex:0];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.startPointFlag = YES;
                    float f1_1 = [dic1[@"baidu_latitude"] floatValue];
                    float f1_2 = [dic1[@"baidu_longitude"] floatValue];
                    BMKPointAnnotation *anno1 = [[BMKPointAnnotation alloc] init];
                    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(f1_1, f1_2);
                    anno1.coordinate = center;
                    [mapview addAnnotation:anno1];
                });
            }
            {
                NSDictionary *dic1 = [pointDataArray lastObject];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.endPointFlag = YES;
                    float f1_1 = [dic1[@"baidu_latitude"] floatValue];
                    float f1_2 = [dic1[@"baidu_longitude"] floatValue];
                    BMKPointAnnotation *anno1 = [[BMKPointAnnotation alloc] init];
                    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(f1_1, f1_2);
                    anno1.coordinate = center;
                    [mapview addAnnotation:anno1];
                });
            }
        }
        else{
            NSDictionary *dic1 = [pointDataArray objectAtIndex:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.startPointFlag = YES;
                float f1_1 = [dic1[@"baidu_latitude"] floatValue];
                float f1_2 = [dic1[@"baidu_longitude"] floatValue];
                BMKPointAnnotation *anno1 = [[BMKPointAnnotation alloc] init];
                CLLocationCoordinate2D center = CLLocationCoordinate2DMake(f1_1, f1_2);
                anno1.coordinate = center;
                [mapview addAnnotation:anno1];
            });
            NSDictionary *dic2 = [pointDataArray objectAtIndex:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.endPointFlag = YES;
                float f1_1 = [dic2[@"baidu_latitude"] floatValue];
                float f1_2 = [dic2[@"baidu_longitude"] floatValue];
                BMKPointAnnotation *anno1 = [[BMKPointAnnotation alloc] init];
                CLLocationCoordinate2D center = CLLocationCoordinate2DMake(f1_1, f1_2);
                anno1.coordinate = center;
                [mapview addAnnotation:anno1];
            });
        }
        NSDictionary *dic1 = [pointDataArray lastObject];
        float f1_1 = [dic1[@"baidu_latitude"] floatValue];
        float f1_2 = [dic1[@"baidu_longitude"] floatValue];
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake(f1_1, f1_2);
        [mapview setCenterCoordinate:center animated:NO];
    });
}

- (void)drawLineInMainThread:(BMKPolyline *)polyline{
    [mapView_mk addOverlay:polyline];
}

- (void)locationPoint:(NSDictionary *)dic{
    float f1_1 = [dic[@"latitude"] floatValue];
    float f1_2 = [dic[@"longitude"] floatValue];
    
    BMKPointAnnotation *anno1 = [[BMKPointAnnotation alloc] init];
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(f1_1, f1_2);
    anno1.coordinate = center;
    [mapView_mk setCenterCoordinate:center animated:NO];
    [mapView_mk addAnnotation:anno1];
    [pointViewArray addObject:anno1];
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

#pragma mark - 合并两个图片
- (UIImage *)mergeToeImage:(UIImage *)img1 image2:(UIImage *)img2{
    UIImage *img2_ = [UIImage imageWithIconName:img2 borderImage:[UIImage imageNamed:@"home_electri.png"] border:1];
    CGSize size = CGSizeMake(130, 130);
    UIGraphicsBeginImageContext(size);
    [img1 drawInRect:CGRectMake(0, 0, 130, 130)];
    [img2_ drawInRect:CGRectMake(25, 8, 80, 80)];
    UIImage *resultingImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

#pragma mark -------------------------------------------------- 打点回调函数，自定义图片
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation{
    BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    newAnnotationView.pinColor = BMKPinAnnotationColorGreen;
    newAnnotationView.annotation = annotation;
    if([[annotation title] intValue] == 1){
        newAnnotationView.userInteractionEnabled = NO;
    }
    NSURL *url = [NSURL URLWithString:self.iconStr];
    if(self.startPointFlag == YES || self.endPointFlag == YES){
        if(self.startPointFlag == YES){
            self.startPointFlag = NO;
            newAnnotationView.image = [UIImage imageNamed:@"nav_route_result_start_point_ios.png"];;
        }
        if(self.endPointFlag == YES){
            self.endPointFlag = NO;
            newAnnotationView.image = [UIImage imageNamed:@"nav_route_result_end_point_ios.png"];
        }
    }
    else{
        //    if(self.iconImage == nil)
        {
            if(![self.iconStr isEqualToString:@"im_his_route_marker_ios.png"]){
                UIImage *icon = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                
                UIImage *img1 = [UIImage imageNamed:@"marker_foot_ios.png"];//[UIImage imageNamed:@"MapLocatebakImg.png"];
                self.iconImage = [self mergeToeImage:img1 image2:icon];
                
                self.iconImage = [self scaleToSize:self.iconImage size:CGSizeMake(80, 80)];
            }
            else{
                self.iconImage = [UIImage imageNamed:self.iconStr];
            }
        }
        
        newAnnotationView.image = self.iconImage;
    }
    return newAnnotationView;
}


- (void)mapView:(BMKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    //	NSLog(@"region change = %f",mapView.region.center.latitude);
    //	float f1_1 = mapView.region.center.latitude;
    //	float f1_2 = mapView.region.center.longitude;
    //	BMKPointAnnotation *anno1 = [[BMKPointAnnotation alloc] init];
    //	CLLocationCoordinate2D center = CLLocationCoordinate2DMake(f1_1, f1_2);
    //	anno1.coordinate = center;
    //	[mapView addAnnotation:anno1];
}


@end