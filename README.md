# react-native-baidumap


![android](https://github.com/sincethere/react-native-baidumap/raw/master/android_map.png) 
![ios](https://github.com/sincethere/react-native-baidumap/raw/master/ios_map.png) 

![android](https://github.com/sincethere/react-native-baidumap/raw/master/android_map2.png)
![ios](https://github.com/sincethere/react-native-baidumap/raw/master/ios_map2.png)


## Installation

First you need to install react-native-baidumapkit:

```javascript
$ npm install react-native-baidumapkit --save
```

**Add Configuration**
link
```javascript 
($ npm install rnpm --global)
$ rnpm link react-native-baidumapkit
```

If the link fails, manually add

settings.gradle
```java
include ':react-native-baidumapkit'
project(':react-native-baidumapkit').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-baidumapkit/android')
```
build.gradle
```java
 dependencies {
    ...
    compile project(':react-native-baidumapkit')
}
```
MainActivity
```java
import com.bee.baidumapview.BaiduMapModuleReactPackage;
 @Override
    protected List<ReactPackage> getPackages() {
        return Arrays.<ReactPackage>asList(
                ...
                new BaiduMapModuleReactPackage(),
                new BaiduMapReactPackage(this),
               );

    }
```

## Release Notes

 * 1.0.0

## Example

```js
import BDMapModule from ('react-native-baidumapkit/BDMapModule');
import BDMapView from ('react-native-baidumapkit');

<BDMapView style={styles.mapViewStyle}
                       ref={'locationMap'}
                       isEnableClicked={true}
                       range={this.state.range}
                />
 let value = {
                "baidu_latitude"    :this.props["baidu_latitude"],
                "baidu_longitude"   :this.props["baidu_longitude"],
                "avatar"            :this.props.avatar
            }
BDMapModule.setLocation(React.findNodeHandle(this.refs.locationMap),value);
BDMapModule.setLocationAnimation(React.findNodeHandle(this.refs.locationMap),value);
BDMapModule.setRuler(React.findNodeHandle(this.refs.locationMap),20);         

other....
```

