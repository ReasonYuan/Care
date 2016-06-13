//
//  TestViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-4-27.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class TestViewController: BaseViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var mCollection: UICollectionView!
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mCollection.delegate = self
        mCollection.dataSource = self
        
        mCollection.registerNib(UINib(nibName: "HomeViewHeaderCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "headerCell")
        mCollection.registerNib(UINib(nibName: "HomeViewEmptyCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "emptyCell")
        mCollection.registerNib(UINib(nibName: "HomeViewMoreCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "moreCell")
        mCollection.registerNib(UINib(nibName: "HomeViewItemCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "itemCell")
        //        mCollectionView
        
        //       self.setTittle("测试")
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func getXibName() -> String {
        return "TestViewController"
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 7
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var size = collectionView.frame.size;
        var identifier = "headerCell"
        var r = count%4
        if(r == 0){
            identifier = "emptyCell"
        }else if(r == 1){
            identifier = "headerCell"
        }else if(r == 2){
            identifier = "moreCell"
        }else if(r == 3){
            identifier = "itemCell"
        }
        count++
        var cell : UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! UICollectionViewCell
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 700
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        var width = floor(collectionView.frame.size.height/7)
        return CGSizeMake(width,width)
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        return 0
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        return 0
    }
    

    
}
