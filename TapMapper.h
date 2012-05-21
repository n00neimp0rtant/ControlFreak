@interface TapMapper : NSObject<LAListener, UIAlertViewDelegate> {}

+(void)start;
+(void)assignTapCoordinates:(CGPoint)point;
+(void)advanceStep;
+(BOOL)isMapping;

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event;
- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event;
- (void)activator:(LAActivator *)activator otherListenerDidHandleEvent:(LAEvent *)event;
- (void)activator:(LAActivator *)activator receiveDeactivateEvent:(LAEvent *)event;
@end