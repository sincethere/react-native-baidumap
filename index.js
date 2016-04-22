var {
    View,
    PropTypes,
    requireNativeComponent,
    Platform
} = require('react-native');

var iface = {
  name: 'RCTBaiduMap',
  propTypes: {
    ...View.propTypes,
    mode: PropTypes.number,
    trafficEnabled: PropTypes.bool,
    heatMapEnabled: PropTypes.bool,
    marker:PropTypes.array
  }
}
let BaiduMapView = undefined;

if(Platform.OS === 'ios'){
  BaiduMapView = requireNativeComponent('BaiduMapLibrary', null);
}else{
  BaiduMapView = requireNativeComponent('RCTBaiduMap', iface);
}

module.exports = BaiduMapView;
