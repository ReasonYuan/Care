//
//  HospitalViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-4.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class HospitalViewController: BaseViewController,BMKGeneralDelegate,BMKGeoCodeSearchDelegate,BMKLocationServiceDelegate,BMKPoiSearchDelegate{
    
    
    let unSelectColor:UIColor = UIColor(red: CGFloat(145.0/255.0), green: CGFloat(145.0/255.0), blue: CGFloat(145.0/255.0), alpha: CGFloat(1))
    let selectColor:UIColor = UIColor(red: CGFloat(140.0/255.0), green: CGFloat(205.0/255.0), blue: CGFloat(197.0/255.0), alpha: CGFloat(1))
    var test = 1
    //    @IBOutlet weak var hospitalTableView: UITableView!
    @IBOutlet weak var selectedHospitalName: UILabel!
    @IBOutlet weak var selectedCityName: UILabel!
    @IBOutlet weak var selectHosBtn: UIButton!
    @IBOutlet weak var selectHosImg: UIImageView!
    @IBOutlet weak var selectHosLabel: UILabel!
    @IBOutlet weak var selectHosNameLabel: UILabel!
    
    var mapManager:BMKMapManager?
    var locationService:BMKLocationService?
    var locationManager:CLLocationManager?
    var geoCode:BMKGeoCodeSearch?
    var poiSearch:BMKPoiSearch?
    var currentPoint:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0,longitude: 0)
    
    //    var hospitalList = [ComFqHalcyonEntityHospital]()
    var user = ComFqLibToolsConstants.getUser()
    
    var selectedCity:ComFqHalcyonEntityCity?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("医院选择")
        hiddenRightImage(true)
        
        //        if currentLocationCity == nil || currentLocationCity == ""  {
        hosBtnEnabled(false)
        selectedCityName.text = "定位中..."
        
        /**初始化百度SDK**/
        intBaiduSdk()
        //        }else{
        //            hosBtnEnabled(true)
        //            selectedCityName.text = currentLocationCity
        //
        //        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func hosBtnEnabled(yes:Bool){
        if yes {
            selectHosBtn.enabled = true
            selectHosImg.image = UIImage(named: "icon_hospital_search.png")
            selectHosLabel.textColor = UIColor.darkGrayColor()
            selectHosNameLabel.textColor = UIColor.darkGrayColor()
        }else{
            selectHosBtn.enabled = false
            selectHosImg.image = UIImage(named: "icon_hospital_unsearch.png")
            selectHosLabel.textColor = UIColor.lightGrayColor()
            selectHosNameLabel.textColor = UIColor.lightGrayColor()
        }
    }
    
    override func getXibName() -> String {
        return "HospitalViewController"
    }
    
    
    
    /**
    搜索医院
    */
    @IBAction func onSearchHospitalClick(sender: AnyObject) {
        var controller = SearchHospitalViewController()
        if selectedCity == nil {
            selectedCity = ComFqHalcyonEntityCity()
            selectedCity?.setNameWithNSString(selectedCityName.text)
        }
        controller.city = selectedCity
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    /**
    选择城市
    */
    @IBAction func onChoseCityClick(sender: AnyObject) {
        var controller = CityViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //    /**
    //    确认按钮点击事件
    //    */
    //    @IBAction func onSureBtnClick() {
    //        var logic = ComFqHalcyonLogic2ResetDoctorInfoLogic()
    //        if newSelectedHospital != nil {
    //            logic.reqModyHospWithInt(selectedCity?.getCityId() ?? 0, withInt: newSelectedHospital!.getHospitalId(), withNSString: newSelectedHospital!.getName())
    //            user.setHospitalWithNSString(newSelectedHospital?.getName())
    //        }
    //        self.navigationController?.popViewControllerAnimated(true)
    //    }
    
    //    /**
    //    获取搜索城市选择结果的回调
    //    */
    //    func selectedCity(contrller: CityViewController, city: ComFqHalcyonEntityCity) {
    //        hosBtnEnabled(true)
    //        selectedCityName.text = city.getName()
    //        selectedCity = city
    //
    //    }
    
    //    /**
    //    获取搜索医院选择结果的回调
    //    */
    //    func selectedHospital(hospital: ComFqHalcyonEntityHospital) {
    //        newSelectedHospital = hospital
    //        selectedHospitalName.text = hospital.getName()
    //    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if selectedCity != nil {
            hosBtnEnabled(true)
            selectedCityName.text = selectedCity?.getName()
        }
        selectHosNameLabel.text = user.getHospital()
    }
    
    
    //KEY--->Inhouse:===MFAtqEzVMiVSlti0vQmbtRkF===----Hitales(hitales)：===c3EROr8NdRNk0rahjG7Nw32W===
    func intBaiduSdk(){
        mapManager = BMKMapManager()
        
        //app store正式版本的key
        var mapKey = "IobpLmuEYsLqm4gVd82etP8c";
    
        if(ComFqLibToolsConstants_isInhouse_){
            mapKey = "qI7Q4z1GaMSbn4ilwy9vRBoR"
        }
        var ret = mapManager?.start(mapKey, generalDelegate: self);
        
        if ret == false {
            println("manager start failed")
        }else {
            println("百度地图成功start")
            baiduLocation()
        }
    }
    
    func onGetNetworkState(iError: Int32) {
        if (0 == iError) {
            println("联网成功")
        }else{
            println("onGetNetworkState \(iError)")
        }
    }
    
    func onGetPermissionState(iError: Int32) {
        if (0 == iError) {
            println("授权成功")
        }else{
            println("onGetPermissionState \(iError)")
        }
    }
    
    func baiduLocation(){
        if IOS_VERSION >= 8 {
            locationManager = CLLocationManager()
            locationManager?.requestWhenInUseAuthorization()
            locationManager?.requestAlwaysAuthorization()
        }
        
        geoCode = BMKGeoCodeSearch()
        geoCode?.delegate = self
        locationService = BMKLocationService()
        locationService?.delegate = self
        locationService?.startUserLocationService()
        
        
    }
    
    func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
        println("didUpdateUserLocation lat \(userLocation.location.coordinate.latitude),long \(userLocation.location.coordinate.longitude)")
        locationService?.stopUserLocationService()
        var pt = CLLocationCoordinate2D(latitude: 0,longitude: 0)
        pt = CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude)
        currentPoint = pt
        var reverseGeocodeSearchOption = BMKReverseGeoCodeOption()
        reverseGeocodeSearchOption.reverseGeoPoint = pt
        var flag = geoCode?.reverseGeoCode(reverseGeocodeSearchOption)
        if flag == true {
            println("反geo检索发送成功")
            //            getNearstLocation(pt)
        }else {
            println("反geo检索发送失败")
        }
    }
    
    func onGetReverseGeoCodeResult(searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        if error.value == 0 {
            var arys = result.poiList
            if arys.count == 0 {
                return
            }
            
            var info:BMKPoiInfo = arys[0] as! BMKPoiInfo
            var address = info.city
            
            if selectedCityName.text == "定位中..." {
                selectedCityName.text = address
            }
            hosBtnEnabled(true)
            
//            currentLocationCity = address
            
            println("定位地址是：\(address)")
        }
        
        
        
    }
    
    func didFailToLocateUserWithError(error: NSError!) {
        locationService?.stopUserLocationService()
        selectedCityName.text = "定位失败"
        hosBtnEnabled(false)
        println("定位失败！\(error)")
    }
    
    func didUpdateUserHeading(userLocation: BMKUserLocation!) {
        println("heading is！\(userLocation.heading)")
    }
    
    //    func getNearstLocation(point:CLLocationCoordinate2D){
    //        poiSearch = BMKPoiSearch()
    //        poiSearch?.delegate = self
    //        var option = BMKNearbySearchOption()
    //        option.pageIndex = 0
    //        option.pageCapacity = 50
    //        option.radius = 3000
    //        option.sortType = BMK_POI_SORT_BY_DISTANCE
    //        option.location = CLLocationCoordinate2DMake(point.latitude,point.longitude)
    //        option.keyword = "医院"
    //        var flag = poiSearch?.poiSearchNearBy(option)
    //        if flag == true {
    //            println("周边检索发送成功")
    //        }else {
    //            println("周边检索发送失败")
    //        }
    //    }
    //
    //    func onGetPoiResult(searcher: BMKPoiSearch!, result poiResult: BMKPoiResult!, errorCode: BMKSearchErrorCode) {
    //        if errorCode.value == 0 {
    //            var arys = poiResult.poiInfoList
    //            if arys.count == 0 {
    //                return
    //            }
    //
    //            //            var tmp = 0.0
    //            //            var currentInfo:BMKPoiInfo?
    //            //
    //            //            for info in arys {
    //            //                var currentDistance = getDistance(info.pt)
    //            //                if tmp == 0 {
    //            //                   tmp  =  currentDistance
    //            //                   currentInfo = info as? BMKPoiInfo
    //            //                }else {
    //            //                    if currentDistance < tmp {
    //            //                         tmp  =  currentDistance
    //            //                         currentInfo = info as? BMKPoiInfo
    //            //                    }
    //            //                }
    //            //
    //            //                println("\(tmp)")
    //            //                println("\(currentInfo?.name)")
    //            //            }
    //            currentLocationHospital = arys[0].name
    //            println("\(arys[0].name)")
    //        }else{
    //            println("未找到结果")
    //        }
    //    }
    //
    //    func getDistance(pt:CLLocationCoordinate2D) -> Double {
    //        var radLat1 = rad(pt.latitude)
    //        var radLat2 = rad(currentPoint.latitude)
    //        var a = radLat1 - radLat2
    //        var b = rad(pt.longitude) - rad(currentPoint.longitude)
    //
    //        var s = 2 * asin(sqrt(pow(sin(a/2), 2) + cos(radLat1) * cos(radLat2) * pow(sin(b/2), 2)))
    //        
    //        s = s * 6378.137
    //        s = round(s * 10000) / 10000
    //        return s
    //    }
    //    
    //    func rad(d:Double) -> Double {
    //        return d * M_PI/180.0
    //    }
    
    
    
}
