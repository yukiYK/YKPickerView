//
//  YKPickerView.m
//  YKPickerView
//
//  Created by hg-yk on 2017/12/5.
//

#import "YKPickerView.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
static CGFloat const kTopViewHeight = 30.0;
static CGFloat const kButtonWidth = 60.0;
static CGFloat const kAnimationDuration = 0.3;

@interface YKPickerView () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIPickerView *pickerView;


// 数据数组
@property (nonatomic, strong) NSArray *dataArr;
/** 解析每一层数据的key */
@property (nonatomic, strong) NSArray *resultKeyArr;
/** 获取下一层数据的key */
@property (nonatomic, strong) NSArray *nextKeyArr;
@property (nonatomic, assign) YKPickerViewStyle style;

/** 保存每一列的rowCount */
@property (nonatomic, strong) NSMutableArray *rowArray;
/** 输出结果数组 */
@property (nonatomic, strong) NSMutableArray *resultArr;

@end

@implementation YKPickerView

#pragma mark - <Lazy Load>
- (NSArray *)resultKeyArr {
    if (!_resultKeyArr) {
        _resultKeyArr = [NSArray array];
    }
    return _resultKeyArr;
}

- (NSArray *)nextKeyArr {
    if (!_nextKeyArr) {
        _nextKeyArr = [NSArray array];
    }
    return _nextKeyArr;
}

- (NSMutableArray *)rowArray {
    if (!_rowArray) {
        _rowArray = [NSMutableArray array];
        switch (self.style) {
            case YKPickerViewStyleSingleColumn:
                [_rowArray addObject:@(self.dataArr.count)];
                break;
            case YKPickerViewStyleMultipleColumn:
                for (NSArray *arr in self.dataArr) {
                    [_rowArray addObject:@(arr.count)];
                }
                break;
            case YKPickerViewStyleLinkageColumn: {
                [_rowArray addObject:@(self.dataArr.count)];
                NSMutableArray *itemArr = [NSMutableArray arrayWithArray:self.dataArr];
                for (int i=0;i<self.nextKeyArr.count;i++) {
                    NSString *nextKey = self.nextKeyArr[i];
                    NSArray *nextArr = [NSArray arrayWithArray:itemArr[0][nextKey]];
                    [_rowArray addObject:@(nextArr.count)];
                    [itemArr removeAllObjects];
                    [itemArr addObjectsFromArray:nextArr];
                }
            }
                break;
            default:
                break;
        }
    }
    return _rowArray;
}

- (NSMutableArray *)resultArr {
    if (!_resultArr) {
        _resultArr = [NSMutableArray array];
        switch (self.style) {
            case YKPickerViewStyleSingleColumn:{
                [_resultArr addObject:self.dataArr[0]];
            }
                break;
            case YKPickerViewStyleMultipleColumn: {
                for (NSArray *itemArr in self.dataArr) {
                    [_resultArr addObject:itemArr[0]];
                }
            }
                break;
            case YKPickerViewStyleLinkageColumn: {
                [_resultArr addObject:self.dataArr[0][self.resultKeyArr[0]]];
                NSMutableArray *itemArr = [NSMutableArray arrayWithArray:self.dataArr];
                for (int i=0;i<self.nextKeyArr.count;i++) {
                    NSString *resultKey = self.resultKeyArr[i+1];
                    NSString *nextKey = self.nextKeyArr[i];
                    NSArray *nextArr = [NSArray arrayWithArray:itemArr[0][nextKey]];
                    [_resultArr addObject:nextArr[0][resultKey]];
                    [itemArr removeAllObjects];
                    [itemArr addObjectsFromArray:nextArr];
                }
            }
                break;
                
            default:
                break;
        }
    }
    return  _resultArr;
}

- (UIView *)mainView {
    if (!_mainView) {
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, kTopViewHeight + 200)];
        
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kTopViewHeight)];
        topView.backgroundColor = [UIColor whiteColor];
        [_mainView addSubview:topView];
        
        UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - kButtonWidth - 8, 0, kButtonWidth, kTopViewHeight)];
        [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [confirmButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [confirmButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [confirmButton addTarget:self action:@selector(onConfirmButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:confirmButton];
        
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 0, kButtonWidth, kTopViewHeight)];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [cancelButton addTarget:self action:@selector(onCancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:cancelButton];
        
        UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame), kScreenWidth, 200)];
        pickerView.backgroundColor = [UIColor whiteColor];
        pickerView.dataSource = self;
        pickerView.delegate = self;
        [_mainView addSubview:pickerView];
        self.pickerView = pickerView;
    }
    return _mainView;
}


#pragma mark - <init>
- (instancetype)initWithDataArray:(NSArray *)dataArr pickerViewStyle:(YKPickerViewStyle)style {
    
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        self.dataArr = [NSArray arrayWithArray:dataArr];
        self.style = style;
        if (style != YKPickerViewStyleLinkageColumn) {
            [self addSubview:self.mainView];
        }
    }
    return self;
}

- (void)setResultKeyArr:(NSArray *)resultKeyArr nextKeyArr:(NSArray *)nextKeyArr {
    self.resultKeyArr = [NSArray arrayWithArray:resultKeyArr];
    self.nextKeyArr = [NSArray arrayWithArray:nextKeyArr];
    if (self.resultKeyArr.count != self.nextKeyArr.count + 1) return;
    
    if (self.style == YKPickerViewStyleLinkageColumn) [self addSubview:self.mainView];
    [self.pickerView reloadAllComponents];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self onCancelButtonClicked:nil];
}

- (void)show {
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    [UIView animateWithDuration:kAnimationDuration animations:^{
        CGRect rect = _mainView.frame;
        rect.origin.y = kScreenHeight - _mainView.frame.size.height;
        _mainView.frame = rect;
    }];
}

#pragma mark - <Private Method>
- (void)dismiss {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        CGRect rect = _mainView.frame;
        rect.origin.y = kScreenHeight;
        _mainView.frame = rect;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


#pragma mark - <Events>
- (void)onConfirmButtonClicked:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(pickerViewComplete:result:)]) {
        [self.delegate pickerViewComplete:self result:self.resultArr];
    }
    [self dismiss];
}

- (void)onCancelButtonClicked:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(pickerViewCancel:)]) {
        [self.delegate pickerViewCancel:self];
    }
    [self dismiss];
}

#pragma mark - <UIPickerViewDelegate, UIPickerViewDataSource>
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    NSInteger components = 0;
    switch (self.style) {
        case YKPickerViewStyleSingleColumn:
            components = 1;
            break;
        case YKPickerViewStyleMultipleColumn:
            components = self.dataArr.count;
            break;
        case YKPickerViewStyleLinkageColumn:
            components = self.resultKeyArr.count;
            break;
        default:
            break;
    }
    return components;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.rowArray[component] integerValue];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title = @"";
    switch (self.style) {
        case YKPickerViewStyleSingleColumn:
            title = self.dataArr[row];
            break;
        case YKPickerViewStyleMultipleColumn:
            title = self.dataArr[component][row];
            break;
        case YKPickerViewStyleLinkageColumn: {
            if (component == 0) {
                title = self.dataArr[row][self.resultKeyArr[0]];
            } else {
                NSMutableArray *itemArr = [NSMutableArray arrayWithArray:self.dataArr];
                for (int i=0; i<component; i++) {
                    NSInteger lastSelected = [pickerView selectedRowInComponent:i];
                    NSString *nextKey = self.nextKeyArr[i];
                    if (lastSelected > itemArr.count-1) lastSelected = itemArr.count-1;
                    NSArray *nextArr = [NSArray arrayWithArray:itemArr[lastSelected][nextKey]];
                    [itemArr removeAllObjects];
                    [itemArr addObjectsFromArray:nextArr];
                }
                NSString *resultKey = self.resultKeyArr[component];
                NSInteger row1 = row > itemArr.count - 1 ? 0 : row;
                title = itemArr[row1][resultKey];
            }
        }
            break;
        default:
            break;
    }
    return title;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    NSInteger components = 1;
    switch (self.style) {
        case YKPickerViewStyleMultipleColumn:
            components = self.dataArr.count;
            break;
        case YKPickerViewStyleLinkageColumn:
            components = self.resultKeyArr.count;
            break;
        default:
            break;
    }
    return self.frame.size.width / components;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *pickerLabel = (UILabel *)view;
    if (!pickerLabel) {
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        pickerLabel.textColor = [UIColor blackColor];
        pickerLabel.backgroundColor = [UIColor clearColor];
        pickerLabel.font = [UIFont systemFontOfSize:14];
    }
    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *selectItem = [self pickerView:pickerView titleForRow:row forComponent:component];
    [self.resultArr replaceObjectAtIndex:component withObject:selectItem];
    
    // 如果选中的是最后一列，无需联动
    if (self.style != YKPickerViewStyleLinkageColumn || component >= self.resultKeyArr.count - 1)
        return;
    
    // 否则联动后面所有的列
    NSMutableArray *itemArr = [NSMutableArray arrayWithArray:self.dataArr];
    for (int i=0; i<self.nextKeyArr.count; i++) {
        NSInteger lastSelected = i <= component ? [pickerView selectedRowInComponent:i] : 0;
        NSString *nextKey = self.nextKeyArr[i];
        if (lastSelected > itemArr.count - 1) lastSelected = itemArr.count - 1;
        NSArray *nextArr = [NSArray arrayWithArray:itemArr[lastSelected][nextKey]];
        if (i >= component) {
            // 更新后面所有列的rowCount
            [self.rowArray replaceObjectAtIndex:i+1 withObject:@(nextArr.count)];
            
            // 同时更新resultArr的后面列
            NSString *resultKey = self.resultKeyArr[i+1];
            NSString *result = nextArr[0][resultKey];
            [self.resultArr replaceObjectAtIndex:i+1 withObject:result];
        }
        [itemArr removeAllObjects];
        [itemArr addObjectsFromArray:nextArr];
    }
    
    // 重置后面所有列选中第一项
    for (int i=(int)component+1;i<self.resultKeyArr.count;i++) {
        [pickerView selectRow:0 inComponent:i animated:NO];
    }
    [pickerView reloadAllComponents];
}

@end
