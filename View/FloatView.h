#import <UIKit/UIKit.h>

// C++ strukturunu Objective-C üçün əvvəlcədən tanıdırıq
#ifdef __cplusplus
struct ModuleControl;
#else
typedef struct ModuleControl ModuleControl;
#endif

NS_ASSUME_NONNULL_BEGIN

@interface FloatView : UIView

@property (nonatomic, assign) ModuleControl *moduleControl;

+ (instancetype)sharedInstance:(ModuleControl*)control;
- (instancetype)initWithFrame:(CGRect)frame :(ModuleControl*)control;

@end

NS_ASSUME_NONNULL_END
