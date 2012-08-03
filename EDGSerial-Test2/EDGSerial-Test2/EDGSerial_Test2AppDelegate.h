//
//  EDGSerial_Test2AppDelegate.h
//  EDGSerial-Test2
//
//  Created by bach on 2011-08-01.
//  Copyright 2011 Universitäts-Augenklinik. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDGSerial.h"


@interface EDGSerial_Test2AppDelegate : NSObject <NSApplicationDelegate> {
@private
	NSWindow *window;
	EDGSerial *_serialPort;
	bool	_hardwareOk;
	
	IBOutlet NSButton *checkBoxDTR_Outlet;
	IBOutlet NSButton *checkBoxRTS_Outlet;
	IBOutlet NSTextField *deviceList_Outlet;
	IBOutlet NSTextField *selectedPort_Outlet;
	
	NSTimer* toggleTimer;
}


- (IBAction) toggleDTR_Action: (id) sender;
- (IBAction) toggleRTS_Action: (id) sender;
- (IBAction) checkBoxDTR_Action: (id) sender;
- (IBAction) checkBoxRTS_Action: (id) sender;


@property bool autoToggling;

@property (assign) IBOutlet NSWindow *window;

@end
