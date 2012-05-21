@implementation TapMapper

static int currentMapStep = -1;
static NSMutableDictionary* tapMap;
static NSArray* buttonNames;
static UIWindow* toastWindow;
static UIView* toastView;

+(void)start
{
	if(!isMapping)
	{
		UIAlertView* alert = [[UIAlertView alloc] 	initWithTitle:@"ControlFreak"
													message:@"Start the TapMapper?"
													delegate:self
													cancelButtonTitle:@"No"
													otherButtonTitles:@"Yes", nil];
		[alert show];
	}
}

-(void)assignTapCoordinates:(CGPoint)point
{
	NSArray* newPoint = [NSArray arrayWithObjects:[NSNumber numberWithFloat:point.x], [NSNumber numberWithFloat.point.y], nil]
	[tapMap setObject:newPoint forKey:[buttonNames objectAtIndex:currentMapStep]];
	[self advanceStep];
}

+(void)advanceStep
{
	currentMapStep++;
	if(currentMapStep >= buttonNames)
	{
		UIAlertView* alert = [[UIAlertView alloc] 	initWithTitle:@"ControlFreak"
													message:@"Mapping complete. Have fun!"
													delegate:self
													cancelButtonTitle:@"Game On"
													otherButtonTitles:nil];
		[alert show];
	}
	else
	{
		[ALToastView toastInView:toastView withText:[NSString stringWithFormat:@"Tap for \"%@\"", [buttonNames objectAtIndex:currentMapStep]]];
	}
}

+(BOOL)isMapping
{
	if(currentMapStep < 0)
		return false;
	else return true;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if([[alertView message] isEqualToString:@"Start the TapMapper?"] && buttonIndex == 1)
	{
		// time to set up everything!!!
		
		// first, button names
		buttonNames = [[NSArray alloc] initWithObjects:@"UP", @"DOWN", @"LEFT", @"RIGHT", @"X", @"A", @"B", @"Y", @"L", @"R", @"START", @"SELECT", nil];
		
		// then, toast overlay
		toastWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		toastWindow.windowLevel = UIWindowLevelAlert;
		toastView = [[UIView alloc] initWithFrame:toastWindow.frame];
		[toastWindow addSubview:toastView];
		
		// finally, the dictionary we will be saving
		tapMap = [[NSMutableDictionary alloc] dictionaryWithCapacity:[buttonNames count]];
		
		// go go go
		[self advanceStep];
	}
}
@end