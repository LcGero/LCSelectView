//
//  LCSelectView.m
//  XZD
//
//  Created by LcGero on 16/5/19.
//  Copyright © 2016年 sysweal. All rights reserved.
//

#import "LCSelectView.h"

#define Btn_Select_Color   [[self class] getRGBWithHexColor:@"bca177"]
#define Btn_Normal_Color   [[self class] getRGBWithHexColor:@"808080"]
#define Margin               10
#define Button_Title_Marhin  13

@interface LCSelectView ()
{
    CGFloat     pointX;
    CGFloat     pointY;
}

@end

@implementation LCSelectView

+(UIColor *) getRGBWithHexColor:(NSString *)hexColor
{
    unsigned int red,green,blue;
    @try {
        NSRange range;
        range.length = 2;
        
        range.location = 0;
        [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&red];
        
        range.location = 2;
        [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&green];
        
        range.location = 4;
        [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&blue];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    return [UIColor colorWithRed:(float)(red/255.0f)green:(float)(green / 255.0f) blue:(float)(blue / 255.0f)alpha:1.0f];
}

-(instancetype)init
{
    self = [super init];
    if ( self ) {
        [self infoInit];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self ) {
        [self infoInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        [self infoInit];
    }
    return self;
}

- (void) infoInit
{
    _hightOfItem = 35.0f;
    _selectedItems = [NSMutableArray array];
    _buttonArray = [NSMutableArray array];
    _bMulity = YES;
    _type = EditType_Edit;
    _bNecessarySelect = YES;
    pointX = 0;
    pointY = 0;

    _scrollView = [[UIScrollView alloc]init];
    [self addSubview:_scrollView];
}

#pragma mark - 设置Item及选中的Item，初始化
- (CGSize) showItem:(NSArray *)allItems selectedItems:(NSArray *)selectedItems
{
    for (UIView *subView in _scrollView.subviews) {
        pointX = 0;
        pointY = 0;
        [subView removeFromSuperview];
    }
    [_buttonArray removeAllObjects];
    
    _scrollView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    _scrollView.contentSize = self.bounds.size;
    
    _allItemsArray = [NSArray arrayWithArray:allItems];
    [_scrollView.subviews respondsToSelector:@selector(removeFromSuperview)];
    [allItems enumerateObjectsUsingBlock:^(NSString *itemStr, NSUInteger index, BOOL *stop) {
        UIButton *button = [self getCustomerStyleButton];
        button.tag = index;
        [button addTarget:self action:@selector(clickItemButton:) forControlEvents:UIControlEventTouchUpInside];
        NSString *title = allItems[index];
        [button setTitle:title forState:UIControlStateNormal];
        
        if ( [selectedItems containsObject:title] ) {
            [_selectedItems addObject:[NSNumber numberWithInteger:index]];
            button.selected = YES;
            [self changeButtonStatus:button];
        }
        CGRect rect = [self caculateFrame:itemStr font:button.titleLabel.font];
        button.frame = rect;
        [_buttonArray addObject:button];
        [_scrollView addSubview:button];
    }];
    return _scrollView.contentSize;
}

#pragma mark - caculateItemFrame
-(CGRect ) caculateFrame:(NSString *)titleString font:(UIFont *)font
{
    CGSize strSize = [titleString sizeWithAttributes:@{NSFontAttributeName:font}];
    CGFloat btnWidth = strSize.width + 2*Button_Title_Marhin;
    //超出控件宽度时
    if ( btnWidth + 2*Margin >= self.bounds.size.width  ) {
        btnWidth = self.bounds.size.width - 2*Margin;
    }
    CGFloat x = pointX + Margin + btnWidth;
    CGFloat y  = 0;
    BOOL lineChange = NO;
    if ( x > self.bounds.size.width ) { //换行
        pointY += (Margin +_hightOfItem);
        x = Margin;
        y = pointY + Margin;
        pointX = x + btnWidth;
        lineChange = YES;
    } else if ( x == self.bounds.size.width ){  //换行
        x = pointX + Margin + btnWidth;
        y = pointY;
        pointX = 0;
        pointY += Margin +_hightOfItem;
    } else {
        x = pointX + Margin;
        y = pointY + Margin;
        pointX = x+ btnWidth;
    }
    if ( lineChange ) {
        [self updateScrollViewContentSize:CGPointMake(x, y)];
        lineChange = NO;
    }
    return CGRectMake(x, y, btnWidth , _hightOfItem);
}

-(void) updateScrollViewContentSize:(CGPoint)point
{
    if ( point.y >= _scrollView.contentSize.height ) {
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width, point.y + _hightOfItem + Margin);
    }
}

#pragma mark - 按钮事件
- (void) clickItemButton:(UIButton *)sender
{
    //单选
    if ( !_bMulity ) {
        //如果不是必选
        if (!_bNecessarySelect) {
            for (UIButton *btn in _buttonArray) {
                if (btn == sender) {
                    btn.selected = !btn.selected;
                    [_selectedItems removeAllObjects];
                    if(btn.selected) {
                        [_selectedItems addObject:[NSNumber numberWithInteger:sender.tag]];
                    }
                }
                else {
                    btn.selected = NO;
                    [self changeButtonStatus:btn];
                }
            }
            if ( !sender.selected && [_selectedItems containsObject:[NSNumber numberWithInteger:sender.tag]] ) {
                [_selectedItems removeObject:[NSNumber numberWithInteger:sender.tag]];
            } else if ( sender.selected ) {
                [_selectedItems addObject:[NSNumber numberWithInteger:sender.tag]];
            }
        }
        else {
            if ( !sender.selected ) {
                UIButton *oldSelectBtn = _buttonArray[[_selectedItems.firstObject integerValue]];
                oldSelectBtn.selected = NO;
                [self changeButtonStatus:oldSelectBtn];
                [_selectedItems removeAllObjects];
                
                sender.selected = YES;
                [_selectedItems addObject:[NSNumber numberWithInteger:sender.tag]];
            } else {
                return;
            }
        }
    }
    //多选
    else {
        sender.selected = !sender.selected;
        if ( !sender.selected && [_selectedItems containsObject:[NSNumber numberWithInteger:sender.tag]] ) {
            [_selectedItems removeObject:[NSNumber numberWithInteger:sender.tag]];
        } else if ( sender.selected ) {
            [_selectedItems addObject:[NSNumber numberWithInteger:sender.tag]];
        }
        
    }
    [self changeButtonStatus:sender];
    if ( _clickHandle ) {
        _clickHandle(self,sender);
    }
}

-(void) changeButtonStatus:(UIButton *)button
{
    button.layer.masksToBounds = NO;
    button.layer.borderWidth = 1.0f;
    button.layer.cornerRadius = 6.0f;
    UIColor *normalColor = _normalBorderColor?_normalBorderColor:Btn_Normal_Color;
    UIColor *selectColor = _selectedBorderColor ? _selectedBorderColor : Btn_Select_Color;
    button.layer.borderColor = button.selected ? selectColor.CGColor: normalColor.CGColor;
    if ( button.selected ) {
        [button setTitleColor:Btn_Select_Color forState:UIControlStateNormal];
        if ( _selectedImageName ) {
            UIImage *image = [UIImage imageNamed:_selectedImageName];
            image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15) resizingMode:UIImageResizingModeStretch];
            [button setBackgroundImage:image forState:UIControlStateNormal];
        }
    } else {
        
        [button setTitleColor:Btn_Normal_Color forState:UIControlStateNormal];
        [button setBackgroundImage:nil forState:UIControlStateNormal];
    }
    
}

- (void)chooseItemWithTitles:(NSArray *)titles
{
    if ( titles.count == 0 ) {
        return;
    }
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:titles];
    if (!_bMulity) {
        NSString *firstObj = tempArray.firstObject;
        tempArray = [NSMutableArray arrayWithObject:firstObj];
    }
    for (NSString *subTitle in tempArray) {
        NSInteger index = [_allItemsArray indexOfObject:subTitle];
        UIButton *btn = [_buttonArray objectAtIndex:index];
        if ( [_allItemsArray containsObject:subTitle] ) {
            [self clickItemButton:btn];
        }
    }
}

- (void)clearAllChoosed
{
    if (_selectedItems.count == 0) {
        return;
    }
    NSArray *selectArr = [NSArray arrayWithArray:_selectedItems];
    for (NSNumber *num in selectArr) {
        int index = [num intValue];
        if (index >= _buttonArray.count) {
            return;
        }
        UIButton *btn = [_buttonArray objectAtIndex:index];
        [self clickItemButton:btn];
    }
}

#pragma mark - 获取按钮
- (UIButton *) getCustomerStyleButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self changeButtonStatus:button];
    [button setTitleColor:Btn_Normal_Color forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:_font?_font:15.0];
    button.userInteractionEnabled = _type == EditType_Edit;
    return button;
}

@end
