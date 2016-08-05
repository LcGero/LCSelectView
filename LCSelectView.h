//
//  LCSelectView.h
//  XZD
//
//  Created by LcGero on 16/5/19.
//  Copyright © 2016年 sysweal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LCSelectView;

typedef void(^ItemClickHandle)(LCSelectView *,UIButton *);

typedef NS_ENUM(NSInteger ,EditType){
    EditType_Edit,
    EditType_ShowOnly
};

@interface LCSelectView : UIView

@property (nonatomic, strong) UIColor              *normalBorderColor;
@property (nonatomic, strong) UIColor              *selectedBorderColor;
@property (nonatomic, strong) NSString             *selectedImageName;
@property (nonatomic, assign) CGFloat              font;
@property (nonatomic, assign) CGFloat              hightOfItem;
@property (nonatomic, assign) EditType             type;
@property (nonatomic, assign) BOOL                 bMulity;
@property (nonatomic, assign) BOOL                 bNecessarySelect;

@property (nonatomic, strong, readonly) NSMutableArray       *buttonArray;    //所有的btn
@property (nonatomic, strong, readonly) UIScrollView         *scrollView;
@property (nonatomic, strong, readonly) NSMutableArray       *selectedItems;  //选中的items
@property (nonatomic, strong, readonly) NSArray              *allItemsArray;
@property (nonatomic, copy) ItemClickHandle                  clickHandle;


/**
 *  显示Item
 *
 *  @param allItems      显示Items
 *  @param selectedItems 选择的Items
 *
 *  @return ScrollView的ContentSize
 */
- (CGSize ) showItem:(NSArray *)allItems selectedItems:(NSArray *)selectedItems;

/**
 *  选中多个item
 *
 *  @param title 选中的item‘s Title
 */
- (void)chooseItemWithTitles:(NSArray *)titles;

/**
 *  清除所有选择
 */
- (void)clearAllChoosed;
@end


