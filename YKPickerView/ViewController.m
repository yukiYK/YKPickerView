//
//  ViewController.m
//  YKPickerView
//
//  Created by hg-yk on 2017/12/5.
//

#import "ViewController.h"
#import "YKPickerView.h"

@interface ViewController () <YKPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *singleTextField;
@property (weak, nonatomic) IBOutlet UITextField *multipleTextField;
@property (weak, nonatomic) IBOutlet UITextField *linkageTextField;


@property (nonatomic, strong) YKPickerView *singlePickerView;
@property (nonatomic, strong) YKPickerView *multiplePickerView;
@property (nonatomic, strong) YKPickerView *linkagePickerView;

@end

@implementation ViewController
#pragma mark - <Lazy Load>
- (YKPickerView *)singlePickerView {
    if (!_singlePickerView) {
        _singlePickerView = [[YKPickerView alloc] initWithDataArray:@[@"北京", @"上海", @"深圳", @"广州", @"杭州"] pickerViewStyle:YKPickerViewStyleSingleColumn];
        _singlePickerView.delegate = self;
    }
    return _singlePickerView;
}

- (YKPickerView *)multiplePickerView {
    if (!_multiplePickerView) {
        _multiplePickerView = [[YKPickerView alloc] initWithDataArray:@[@[@"北京", @"上海", @"深圳", @"广州", @"杭州"], @[@"飞机", @"火车", @"汽车", @"自行车"]] pickerViewStyle:YKPickerViewStyleMultipleColumn];
        _multiplePickerView.delegate = self;
    }
    return _multiplePickerView;
}

- (YKPickerView *)linkagePickerView {
    if (!_linkagePickerView) {
        NSString *plistStr = [[NSBundle mainBundle] pathForResource:@"areaArray" ofType:@"plist"];
        NSArray *areaArray = [NSArray arrayWithContentsOfFile:plistStr];
        _linkagePickerView = [[YKPickerView alloc] initWithDataArray:areaArray pickerViewStyle:YKPickerViewStyleLinkageColumn];
        [_linkagePickerView setResultKeyArr:@[@"provinceName", @"cityName", @"areaName"] nextKeyArr:@[@"citylist", @"arealist"]];
        _linkagePickerView.delegate = self;
    }
    return _linkagePickerView;
}

#pragma mark - <Life Cycle>
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.singleTextField.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    self.multipleTextField.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    self.linkageTextField.inputView = [[UIView alloc] initWithFrame:CGRectZero];
}


#pragma mark - <method>
- (void)hideKeyboard {
    [self.singleTextField resignFirstResponder];
    [self.multipleTextField resignFirstResponder];
    [self.linkageTextField resignFirstResponder];
}

- (IBAction)textFieldDidBeginEditing:(id)sender {
    if (sender == self.singleTextField) {
        [self.singlePickerView show];
    } else if (sender == self.multipleTextField) {
        [self.multiplePickerView show];
    } else if (sender == self.linkageTextField) {
        [self.linkagePickerView show];
    }
}

#pragma mark - <YKPickerViewDelegate>
- (void)pickerViewComplete:(YKPickerView *)pickerView result:(NSArray *)resultArr {
    NSLog(@"resultArr = %@", resultArr);
    
    if (pickerView == self.singlePickerView) {
        self.singleTextField.text = resultArr.firstObject;
    } else if (pickerView == self.multiplePickerView) {
        NSMutableString *text = [NSMutableString string];
        for (NSString *str in resultArr) {
            [text appendString:str];
        }
        self.multipleTextField.text = text;
    } else if (pickerView == self.linkagePickerView) {
        NSMutableString *text = [NSMutableString string];
        for (NSString *str in resultArr) {
            [text appendString:str];
        }
        self.linkageTextField.text = text;
    }
    [self hideKeyboard];
}

- (void)pickerViewCancel:(YKPickerView *)pickerView {
    NSLog(@"取消选择");
    [self hideKeyboard];
}

@end
