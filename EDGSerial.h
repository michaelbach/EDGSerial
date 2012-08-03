//
//  EDGSerial.h
//  EOG2007
//
//  Created by bach on 11.12.06.
//  Copyright 2006 Prof. Michael Bach. All rights reserved.
//
//	History
//	=======
//
//	2011-07-04	changed names to indicated special treatment of Keyspan's USAs
//	2011-07-29	automatically reads pertinent device names and accesses up to 4 Keyspan USA ports (only 1 device allowed)
//	2011-04-21	added flushOutput & flushInAndOutput; not really tested yet
//	2009-11-25	added "getter" for RTS & DTL
//	2009-11-24	cosmetic changes, also changed number type of _modemBits to "unsigned int"
//	2009-03-06	changed number type of baudrate to "unsigned long"
//	2008-03-24	added port name to the error message, changed printf to NSLog
//	2008-02-25	added parityNone
//	2007-01-10	added "flushInput", "bytesAvailable", "readData"
//	2006-12-11	begun


#import <Cocoa/Cocoa.h>
#include <sys/ioctl.h>
#include <termios.h>
//#include <dirent.h>		// necessary when using the device list


@interface EDGSerial: NSObject {
}


- (id) initWithName: (NSString *) theName;
- (id) initKeyspanUSAWithPortNumber: (NSUInteger) portNumber;	// this is specific for the USA (universal serial adaptor) by Keyspan
- (BOOL) openWithName: (NSString *) theName;	// with this command any serial device can be accessed
// USA49Wb1P1.1, USA49Wb2P1.1, USA49Wb2P2.2, USA19QIb2P1.1, USA49W81P2.2, serial, modem;

- (NSUInteger) numberOfSerialPorts;
- (NSString *) deviceListAsString;
- (NSString *) portSelectedAsString;
- (BOOL) openPortNumber: (NSUInteger) portNumber;

- (void) setDTR:(BOOL) state;
- (BOOL) DTR;
- (void) toggleDTR;

- (BOOL) RTS;
- (void) setRTS:(BOOL) state;
- (void) toggleRTS;

- (void) setBaudrate: (unsigned long) theBaudrate;
- (void) setDataBits: (int) n;
- (void) setStopBits: (int) n;
- (void) setParityEven;
- (void) setParityNone;
- (NSInteger) sendString:(NSString *)string;
- (NSInteger) sendData:(NSData *) data;
- (NSInteger) sendByte: (char) aByte;

- (void) flushInput;
- (void) flushOutput;
- (void) flushInAndOutput;

- (unsigned int) bytesAvailable;
- (NSData *) readData;

@end
