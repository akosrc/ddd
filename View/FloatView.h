#import <UIKit/UIKit.h>
#import "../utils/module_tools.h"

NS_ASSUME_NONNULL_BEGIN

@interface FloatView : UIView

@property (nonatomic, assign) ModuleControl *moduleControl;

+ (instancetype)sharedInstance:(ModuleControl*)control;
- (instancetype)initWithFrame:(CGRect)frame :(ModuleControl*)control;

@end

NS_ASSUME_NONNULL_END
