# react-native-baidumap


![android](https://github.com/honaf/react-native-baidumap/raw/master/android_map.png) 
![ios](https://github.com/honaf/react-native-baidumap/raw/master/ios_map.png) 

![android](https://github.com/honaf/react-native-baidumap/raw/master/android_map1.png) 
![ios](https://github.com/honaf/react-native-baidumap/raw/master/ios_map1.png) 


## Installation

First you need to install react-native-baidumap:

```javascript
$ npm install react-native-baidumap --save
```

**Add Configuration**
link
```javascript 
($ npm install rnpm --global)
$ rnpm link react-native-baidumap
```

If the link fails, manually add

settings.gradle
```java
include ':react-native-baidumap'
project(':react-native-baidumap').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-baidumap/android')
```
build.gradle
```java
 dependencies {
    ...
    compile project(':react-native-baidumap')
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
import BDMapModule from ('react-native-baidumap/BDMapModule');
import BDMapView from ('react-native-baidumap');

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

