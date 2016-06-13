//
//  PatientViewCell.h
//  DoctorPlus_ios
//
//  Created by reason on 15-7-17.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PatientAbstract.h"
#import "RecordPatientEvent.h"
#import "RecycleLogic.h"

//@protocol PatientItemEvent  <NSObject>
//
///**子项整个被点击*/
//-(void)onPatientItemClick:(NSIndexPath*)indexPath;
///**子项[结构化]被点击*/
//-(void)onPatientItemStruct:(NSIndexPath*)indexPath;
///**子项[分享]被点击*/
//-(void)onPatientItemShare:(NSIndexPath*)indexPath;
///**子项[删除]被点击*/
//-(void)onPatientItemRemove:(NSIndexPath*)indexPath;
///**子项[删除]被点击*/
//-(void)onPatientItemClear:(NSIndexPath*)indexPath;
///**子项[删除]被点击*/
//-(void)onPatientItemRecover:(NSIndexPath*)indexPath;
//@end

@interface PatientViewCell : UITableViewCell<ComFqHalcyonLogicPracticeRecycleLogic_Remove2RecycleCallBack,
        ComFqHalcyonLogicPracticeRecycleLogic_RecycleCallBack,ComFqHalcyonLogicPracticeRecycleLogic_RecycleCallBack>
{
    ComFqHalcyonEntityPracticePatientAbstract* patientEntity;
    NSIndexPath* indexPath;
    BOOL isRecycle;
    
    UILabel* labelPatientName;
    UILabel* labelRecordCount;
    UIImageView* imgUserHead;
    UILabel* labelDiagnose1;
    UILabel* labelDiagnose2;
    UIButton* imgUserHeadBtn;
//    UILabel* labelSecondName;
}

@property (weak, nonatomic) id<RecordPatientEvent> event;

@property (weak, nonatomic) IBOutlet UIView *contentContainer;

/**
 * 初始化数据，根据数据在初始化UI
 */
-(void)initData:(ComFqHalcyonEntityPracticePatientAbstract*)data IndexPath:(NSIndexPath*)indexPath Event:(id<RecordPatientEvent>)et;

-(void)initData:(ComFqHalcyonEntityPracticePatientAbstract*)data IndexPath:(NSIndexPath*)indexPath Event:(id<RecordPatientEvent>)et isCanSliding:(BOOL)iscanSliding;

/**
 * 初始化数据，根据数据在初始化UI
 */
-(void)initDataForRecycle:(ComFqHalcyonEntityPracticePatientAbstract*)data IndexPath:(NSIndexPath*)indexPath Event:(id<RecordPatientEvent>)et;
//设置是不是可以禁止滑动出菜单，默认可以滑出

-(void)setCanSliding:(BOOL)iscanSliding;

-(void)setFromChart:(BOOL)isFromChart;
@end
