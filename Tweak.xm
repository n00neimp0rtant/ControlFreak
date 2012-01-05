#include <stdio.h>
#include <math.h>
#include <unistd.h>
#include <hid-support.h>
#include <objc/runtime.h>
#include <mach/mach_port.h>
#include <mach/mach_init.h>
#include <dlfcn.h>
#include <substrate.h>
#import <GraphicsServices/GSEvent.h>
#import "iCPEvent.h"

typedef enum __GSHandInfoType2 {
	kGSHandInfoType2TouchDown    = 1,    // first down
	kGSHandInfoType2TouchDragged = 2,    // drag
	kGSHandInfoType2TouchChange  = 5,    // nr touches change
	kGSHandInfoType2TouchFinal   = 6,    // final up
} GSHandInfoType2;

//static NSString* presses = @"wxadlkoihjuy";
//static NSString* releases = @"ezqcvpgmrnft";
static NSMutableDictionary* depressedButtons = [[NSMutableDictionary alloc] init];
static uint8_t touchEvent[sizeof(GSEventRecord) + sizeof(GSHandInfo) + sizeof(GSPathInfo)];

static void (*original_GSSendEvent)(GSEventRecord* record, mach_port_t port);
extern "C" void replaced_GSSendEvent(GSEventRecord* record, mach_port_t port)
{
	original_GSSendEvent(record, port);
	if(record->type == kGSEventHand)
	{
		struct GSTouchEvent {
    	    GSEventRecord record;
    	    GSHandInfo    handInfo;
    	} * event = (struct GSTouchEvent*) record;
		NSLog(@"**************************TOUCH EVENT**************************");
		float x = event->record.windowLocation.x;
		float y = event->record.windowLocation.y;
		switch(event->handInfo.type)
		{
			case 1:
				NSLog(@"touch down at (%f, %f)", x, y);
				break;
			case 2:
				NSLog(@"touch drag at (%f, %f)", x, y);
				break;
			case 5:
				NSLog(@"touch change at (%f, %f)", x, y);
				break;
			case 6:
				NSLog(@"touch up at (%f, %f)", x, y);
				break;
			default:
				break;
		}
		int size = sizeof(event->handInfo.pathInfos);
		unsigned char index = event->handInfo.pathInfos[0].pathIndex;
		unsigned char identity = event->handInfo.pathInfos[0].pathIdentity;
		unsigned char proximity = event->handInfo.pathInfos[0].pathProximity;
		NSLog(@"size of pathInfos: %d", size);
		NSLog(@"index: %c", index);
		NSLog(@"identity: %c", identity);
		NSLog(@"proximity: %c", proximity);
	}
}

__attribute__((constructor))
static void initialize()
{
	NSLog(@"MyExt: Loaded");
	MSHookFunction((void*)GSSendEvent, (void*)replaced_GSSendEvent, (void**)&original_GSSendEvent);
}

%hook UIKeyboardInputManager
-(BOOL)acceptInputString:(id)string
{
	%log;
	
	if([string isEqualToString:@"l"] || [string isEqualToString:@"L"]) hid_inject_button_down(HWButtonHome);
	else if([string isEqualToString:@"v"] || [string isEqualToString:@"V"]) hid_inject_button_up(HWButtonHome);
	else if([string isEqualToString:@"a"] || [string isEqualToString:@"q"] || [string isEqualToString:@"d"] || [string isEqualToString:@"c"] || [string isEqualToString:@"o"] || [string isEqualToString:@"g"])
	{
		CGPoint location;
		if([string isEqualToString:@"a"] || [string isEqualToString:@"q"]) location = CGPointMake(60.0, 16.0);
		else if([string isEqualToString:@"d"] || [string isEqualToString:@"c"]) location = CGPointMake(60.0, 84.0);
		else if([string isEqualToString:@"o"] || [string isEqualToString:@"g"]) location = CGPointMake(27.0, 427.0);
		
    	// structure of touch GSEvent
    	struct GSTouchEvent {
    	    GSEventRecord record;
    	    GSHandInfo    handInfo;
    	} * event = (struct GSTouchEvent*) &touchEvent;
    	bzero(touchEvent, sizeof(touchEvent));

    	// set up GSEvent
    	event->record.type = kGSEventHand;
    	event->record.windowLocation = location;
    	event->record.timestamp = GSCurrentEventTimestamp();
    	event->record.infoSize = sizeof(GSHandInfo) + sizeof(GSPathInfo);

    	if([string isEqualToString:@"a"] || [string isEqualToString:@"d"] || [string isEqualToString:@"o"])
    	{
    		event->handInfo.type = (GSHandInfoType) kGSHandInfoType2TouchDown;
		}
    	if([string isEqualToString:@"q"] || [string isEqualToString:@"c"] || [string isEqualToString:@"g"])
    	{
    		event->handInfo.type = (GSHandInfoType) kGSHandInfoType2TouchFinal;
    	}
    	event->handInfo.x52 = 1;
    	bzero(&event->handInfo.pathInfos[0], sizeof(GSPathInfo));
    	event->handInfo.pathInfos[0].pathIndex     = 1;
    	event->handInfo.pathInfos[0].pathIdentity  = 2;
    	if([string isEqualToString:@"a"] || [string isEqualToString:@"d"] || [string isEqualToString:@"o"])
    	{
    		event->handInfo.pathInfos[0].pathProximity = 0x03;
		}
    	if([string isEqualToString:@"q"] || [string isEqualToString:@"c"] || [string isEqualToString:@"g"])
    	{
			event->handInfo.pathInfos[0].pathProximity = 0x00;
    	}
    	event->handInfo.pathInfos[0].pathLocation  = location;
		
	    // send GSEvent
	    NSLog(@"About to send fake touch event");
	    //sendGSEvent( (GSEventRecord*) event, location);
	    
	    //GSSendSystemEvent((GSEventRecord*) event);
	    GSSendEvent((GSEventRecord*) event, GSGetPurpleApplicationPort());
	}
	
	return %orig;
}



//-(BOOL)acceptsCharacter:(unsigned short)character { %log; return %orig; }
//-(BOOL)stringEndsWord:(id)word { %log; return %orig; }
//-(id)addInput:(id)input flags:(unsigned)flags point:(CGPoint)point deletePreceding:(unsigned*)preceding deleteFollowing:(unsigned*)following fromVariantKey:(BOOL)variantKey { %log; return %orig; }
//-(id)addInput:(id)input flags:(unsigned)flags point:(CGPoint)point firstDelete:(unsigned*)aDelete fromVariantKey:(BOOL)variantKey { %log; return %orig; }
%end