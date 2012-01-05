#import "iCPEvent.h"

@implementation iCPEvent

@synthesize button, isPressDownEvent;

-(id)initWithButton:(iCPButton)btn isBeingPressed:(BOOL)pressed
{
	if ((self = [super init]))
	{
		button = btn;
		isPressDownEvent = pressed;
	}
	return self;
}

@end