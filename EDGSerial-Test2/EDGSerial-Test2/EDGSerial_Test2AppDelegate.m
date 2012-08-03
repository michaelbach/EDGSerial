//
//  EDGSerial_Test2AppDelegate.m
//  EDGSerial-Test2
//
//  Created by bach on 2011-08-01.
//  Copyright 2011 Universitäts-Augenklinik. All rights reserved.
//

#import "EDGSerial_Test2AppDelegate.h"

@implementation EDGSerial_Test2AppDelegate


@synthesize window, autoToggling;



- (void) handleToggleTimer: (NSTimer *) timer {
#pragma unused (timer)
	if (!autoToggling) return;
	[self toggleDTR_Action: NULL];
	[self toggleRTS_Action: NULL];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {	//	NSLog(@"EDGSerial_Test2AppDelegate>applicationDidFinishLaunching\n");
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
}



- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
#pragma unused(theApplication)
	return YES;
}





- (IBAction) toggleDTR_Action: (id) sender {	//	NSLog(@"MainController toggleDTR\n");
#pragma unused(sender)
	[_serialPort toggleDTR];
	[checkBoxDTR_Outlet setState: [_serialPort DTR]];
}
- (IBAction) toggleRTS_Action: (id) sender {	//	NSLog(@"MainController toggleRTS\n");
#pragma unused(sender)
	[_serialPort toggleRTS];
	[checkBoxRTS_Outlet setState: [_serialPort RTS]];
}


- (IBAction) checkBoxDTR_Action: (id) sender {	NSLog(@"MainController checkBoxDTR\n");
	[_serialPort setDTR: [sender state]];
}
- (IBAction) checkBoxRTS_Action: (id) sender {	NSLog(@"MainController checkBoxRTS\n");
	[_serialPort setRTS: [sender state]];
}






@end
