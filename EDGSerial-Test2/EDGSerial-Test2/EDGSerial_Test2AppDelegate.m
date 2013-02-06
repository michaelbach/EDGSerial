//
//  EDGSerial_Test2AppDelegate.m
//  EDGSerial-Test2
//
//  Created by bach on 2011-08-01.
//  Copyright 2011 Universitäts-Augenklinik. All rights reserved.
//

#import "EDGSerial_Test2AppDelegate.h"

@implementation EDGSerial_Test2AppDelegate


dispatch_source_t gdcTimerTimingtest;


@synthesize window, autoToggling;



- (void) handleToggleTimer: (NSTimer *) timer {NSLog(@"%s", __PRETTY_FUNCTION__);
#pragma unused (timer)
	if (!autoToggling) return;
	[self toggleDTR_Action: NULL];
	[self toggleRTS_Action: NULL];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {	NSLog(@"%s", __PRETTY_FUNCTION__);
	_hardwareOk = false;
	//	_serialPort = [[EDGSerial alloc] initWithName: @portName];	// Port for DTR + RTS control (flash & on)
	_serialPort = [[EDGSerial alloc] init];	// Port for DTR + RTS control (flash & on)
	if ((_serialPort) && ([_serialPort numberOfSerialPorts] > 0)) {
		_hardwareOk = [_serialPort openPortNumber: 0];
	} else {
		_hardwareOk = false;
	}
	if (!_hardwareOk) {
		NSInteger result = NSRunCriticalAlertPanel(@"EDGSerial", @"Not initialised, device missing?", @"OK", @"Exit program", @"");
		if (result != NSAlertDefaultReturn) [NSApp terminate:nil];
	} else {
		// serial port found, now init it correctly
		//	baud=9600, databits=8, echo=0, in=0, killio, out=0, parity=0, rts=1, stopbits=1
		[_serialPort setBaudrate: 9600];  [_serialPort setDataBits: 8];  [_serialPort setStopBits: 1];  [_serialPort setParityNone];
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.13, false);	// delay
	}
	
	
	[checkBoxRTS_Outlet setState: [_serialPort RTS]];
	[checkBoxDTR_Outlet setState: [_serialPort DTR]];
	[deviceList_Outlet setStringValue: [_serialPort deviceListAsString]];
	[selectedPort_Outlet setStringValue: [_serialPort portSelectedAsString]];
	
	autoToggling = NO;
	
	[self toggleDTR_Action: NULL];

	toggleTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(handleToggleTimer:) userInfo:NULL repeats:YES];
	
	if (NO) {	// this speed test reveals that toggling every 4 ms is possible
		gdcTimerTimingtest = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
		dispatch_source_set_timer(gdcTimerTimingtest, dispatch_time(DISPATCH_TIME_NOW, 0), /*interv*/ 4000000ull , /*leeway*/ 10ull);
		dispatch_source_set_event_handler(gdcTimerTimingtest, ^{
			[_serialPort toggleDTR];
		});
		dispatch_resume(gdcTimerTimingtest);
	}
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
#pragma unused(theApplication)
	return YES;
}





- (IBAction) toggleDTR_Action: (id) sender {	NSLog(@"%s", __PRETTY_FUNCTION__);
	[_serialPort toggleDTR];
	[checkBoxDTR_Outlet setState: [_serialPort DTR]];
}
- (IBAction) toggleRTS_Action: (id) sender {	NSLog(@"%s", __PRETTY_FUNCTION__);
	[_serialPort toggleRTS];
	[checkBoxRTS_Outlet setState: [_serialPort RTS]];
}


- (IBAction) checkBoxDTR_Action: (id) sender {	NSLog(@"%s", __PRETTY_FUNCTION__);
	[_serialPort setDTR: [sender state]];
}
- (IBAction) checkBoxRTS_Action: (id) sender {	NSLog(@"%s", __PRETTY_FUNCTION__);
	[_serialPort setRTS: [sender state]];
}






@end
