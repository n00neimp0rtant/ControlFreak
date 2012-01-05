typedef enum {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	X,
	A,
	B,
	Y,
	L,
	R,
	START,
	SELECT
} iCPButton;

@interface iCPEvent : NSObject {
	iCPButton button;
	BOOL isPressDownEvent;
}
@property(nonatomic, readonly) iCPButton button;
@property(nonatomic, readonly) BOOL isPressDownEvent;
-(id)initWithButton:(iCPButton)btn isBeingPressed:(BOOL)pressed;
@end