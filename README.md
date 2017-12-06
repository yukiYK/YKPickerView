# YKPickerView

 - ##安装

使用cocoapods安装
`pod 'YKPickerView'`

##- 使用

####1. 初始化
>>>>>>> 3027e3b0dcced162133cdb1cc98c3f2a6c44b2f2

 ####1. 初始化
 
```
/**
 初始化方法
 
 @param dataArr 数据数组  请根据不同的style传不同格式的array
 [a,b,c]
 [[a,b,c],[d,e,f],[g,h,i]]
 [{}, {}, {}] 比较复杂，就不细写了。。。配合keyArr用的，你应该懂的
 @param style  pickerView的类型
 @return NAPickerView对象
 */
- (instancetype)initWithDataArray:(NSArray *)dataArr pickerViewStyle:(YKPickerViewStyle)style;
```

当然如果是联动类型，你还需要提供解析数据的keyArr，其他两种类型则不需要

```
/**
 设置联动的两个key数组，如果是联动的style请一定要设置，否则无法获取数据。
 其他style的无需设置
 
 @param resultKeyArr 每一层取值的key  例如 [provinceName, cityName, areaName]
 @param nextKeyArr 每一层获取下一层数组的key 例如[cityList, areaList]
 注意：前者数组的count必须为后者count+1才对，否则数据无法解析
 */
- (void)setResultKeyArr:(NSArray *)resultKeyArr nextKeyArr:(NSArray *)nextKeyArr;
```

####2. 设置代理delegate，用于获取数据

####3. 展示

```
- (void)show;
```

####4. 实现delegate获取数据resultArr

```
@protocol YKPickerViewDelegate <NSObject>

- (void)pickerViewComplete:(YKPickerView *)pickerView result:(NSArray *)resultArr;

- (void)pickerViewCancel:(YKPickerView *)pickerView;

@end
```

------------------------

具体的使用可以参考本项目Demo和 [**我的博客**](http://www.jianshu.com/p/30db76f1303c)
