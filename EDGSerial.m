  //
//  EDGSerial.mm
//  EOG2007
//
//  Created by bach on 11.12.2006.
//  Copyright 2006 Prof. Michael Bach. All rights reserved.
//


#import "EDGSerial.h"


@implementation EDGSerial


static int _serialDevice;
static unsigned int _modemBits;
static struct termios _serialOptions;
static BOOL _currentStateDTR, _currentStateRTS, _isHardwareOk;
static NSUInteger _numberOfSerialPorts;
static NSMutableArray *serialChannels;
static NSString *selectedPort;


///// first internal-only functions
- (BOOL) commitChanges {
	int err = tcsetattr(_serialDevice, TCSANOW, &_serialOptions);
	if (err != 0) {
		NSLog(@"EDGSerial>Error: serial port 4, tcsetattr\n");	return NO;
	} else return YES;
}
////////////////////////////////////


- (void) dealloc {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
	if (_isHardwareOk) close(_serialDevice);
	#if !__has_feature(objc_arc)
		[super dealloc];
	#endif
}


- (BOOL) openWithName: (NSString *) theName {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
#if (false)
		DIR *directoryPointer = opendir("/dev/");
		if (directoryPointer != NULL)	{
			NSLog(@"\r\rList of serial devices\r===================");
			struct dirent *directoryEntryPointer;
			while (directoryEntryPointer = readdir(directoryPointer)) {
				NSString *theDevice = [NSString stringWithCString: directoryEntryPointer->d_name encoding: NSASCIIStringEncoding];
				if ([theDevice hasPrefix: @"cu."])	NSLog(@"%@", theDevice);
			}
			closedir(directoryPointer);		NSLog(@"\r\r");
		} else NSLog(@"EDGSerial>initWithName: Error: Couldn't get serial port.\n");
#endif		
	NSString *thePath = [@"/dev/cu." stringByAppendingString:theName];
	//	NSLog(@"path: %@", thePath); fileDescriptor = open(bsdPath, O_RDWR | O_NOCTTY); // | O_NONBLOCK);
	_serialDevice = open([thePath cStringUsingEncoding: NSASCIIStringEncoding], O_RDWR | O_NOCTTY | O_NDELAY);
	if (_serialDevice < 0) {
		NSLog(@"EDGSerial>initWithName Error: serial port “%@”, open returned %d\n", theName, _serialDevice);	return NO;
	}
	OSStatus err = ioctl(_serialDevice, TIOCMGET, &_modemBits);
	if (err != noErr) {
		NSLog(@"EDGSerial>initWithName: Error: serial port 2\n");	return NO;
	}
	err = tcgetattr(_serialDevice, &_serialOptions);
	if (err != noErr) {
		NSLog(@"EDGSerial>initWithName: Error: serial port 3, tcsetattr\n");	return NO;
	}
	cfmakeraw(&_serialOptions);	// initialise the termios structure
	_serialOptions.c_oflag &= ~OPOST; // Raw output, probably not necessary
	[self commitChanges];
	_isHardwareOk = YES;	
	[self flushInAndOutput];
	[self setDTR: YES];	[self setRTS: YES];// DTR & RTS are hi by default, this is to preset the state variables accordingly
	//	NSLog(@"EDGSerial>initWithName DONE\n");
	selectedPort = theName;
	return YES;
}


- (id) init {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
	if ((self = [super init])) {
		NSError *error;
		NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/dev/" error: &error];
		serialChannels = [NSMutableArray arrayWithCapacity: 4];
		for (NSString *s in directoryContents) {
			if ([s hasPrefix: @"cu."]) {
				NSRange range = [s rangeOfString:@"USA"];
				if (range.location != NSNotFound) [serialChannels addObject: [s substringFromIndex:3]];
			}
		}		//		for (NSString *s in serialChannels) NSLog(s);  NSLog(@"length: %d", [serialChannels count]);
		_numberOfSerialPorts = [serialChannels count];
	}
	selectedPort = [NSString string];
	return self;
}


- (id) initKeyspanUSAWithPortNumber: (NSUInteger) portNumber {
	if ([self init])
		if (_numberOfSerialPorts > portNumber)
			[self openPortNumber: portNumber];
	return self;
}


- (id) initWithName: (NSString *) theName {
	if ([self init]) {
		if (_numberOfSerialPorts > 0) {
				BOOL success = [self openWithName: theName];
			if (success) return self;
		}
	}
	return NULL;
}


- (NSUInteger) numberOfSerialPorts {
	return _numberOfSerialPorts;
}


- (NSString *) deviceListAsString { //	NSLog(@"%s", __PRETTY_FUNCTION__);
	NSString *s = @"";	NSUInteger i = _numberOfSerialPorts;
	while (i > 0) {
		s = [s stringByAppendingFormat: @"%@\r", [serialChannels objectAtIndex: i-1]];  --i;
	}
	return s;
}


- (NSString *) portSelectedAsString {
	return selectedPort;
}


- (BOOL) openPortNumber: (NSUInteger) portNumber {
	if (portNumber < _numberOfSerialPorts) {
		[self openWithName: [serialChannels objectAtIndex: portNumber]];  return YES;
	}
	return NO;
}


- (BOOL) DTR  {
	return _currentStateDTR;
}
- (void) setDTR: (BOOL) stateOnNotOff {
	if (!_isHardwareOk) return;
//	NSLog(@"EDGSerial>setDTR: %i", stateOnNotOff);
	_currentStateDTR = stateOnNotOff;
	if (stateOnNotOff) _modemBits |= TIOCM_DTR;	else _modemBits &= ~TIOCM_DTR;
	OSStatus err = ioctl(_serialDevice, TIOCMSET, &_modemBits);
	if (err != noErr) NSLog(@"EDGSerial>setDTR Error: serial port q450ControlPort\n");
}
- (void) toggleDTR {
	[self setDTR: !_currentStateDTR];
}


- (BOOL) RTS  {
	return _currentStateRTS;
}
- (void) setRTS: (BOOL) stateOnNotOff {
	if (!_isHardwareOk) return;
	_currentStateRTS = stateOnNotOff;
	if (stateOnNotOff) _modemBits |= TIOCM_RTS;	else _modemBits &= ~TIOCM_RTS;
	OSStatus err = ioctl(_serialDevice, TIOCMSET, &_modemBits);
	if (err != noErr) NSLog(@"EDGSerial>setRTS Error: serial port q450ControlPort\n");
}
- (void) toggleRTS {
	[self setRTS: !_currentStateRTS];
}

- (void) setBaudrate: (unsigned long) theBaudrate {
	if (!_isHardwareOk) return;
	//	NSLog(@"setBaudrate: %d", theBaudrate);
	OSStatus err = cfsetospeed(&_serialOptions, theBaudrate);
	if (err == -1) {
		NSLog(@"EDGSerial>setBaudrate Error: serial port, setBaudrate returned %d\n", (int) err);	return;
	}	
	cfsetispeed(&_serialOptions, 0);	// same as output speed
	[self commitChanges];
}


- (void) setDataBits: (int) n {
	if (!_isHardwareOk) return;
	_serialOptions.c_cflag &= ~CSIZE;
	switch (n) {
		case 5:	_serialOptions.c_cflag |= CS5;	break;	// redundant since CS5 == 0
		case 6:	_serialOptions.c_cflag |= CS6;	break;
		case 7:	_serialOptions.c_cflag |= CS7;	break;
		case 8:	_serialOptions.c_cflag |= CS8;	break;
	}
	[self commitChanges];
}


- (void) setStopBits: (int) n {
	if (!_isHardwareOk) return;
	if ((n != 1) && (n !=2)) {
		NSLog(@"EDGSerial>setStopBits: Error: serial port, setStopBits, should be 1 or 2, it is: %d\n", n);	return;
	}	
	if (n==1) _serialOptions.c_cflag &= ~CSTOPB; else _serialOptions.c_cflag |= CSTOPB;
	[self commitChanges];
}


- (void) setParityEven {
	if (!_isHardwareOk) return;
	_serialOptions.c_cflag |= PARENB;  _serialOptions.c_cflag &= ~PARODD;
	[self commitChanges];
}


- (void) setParityOdd {
	if (!_isHardwareOk) return;
	_serialOptions.c_cflag |= PARENB;	// Parity enable
	_serialOptions.c_cflag |= PARODD;	// Enable odd parity 
	[self commitChanges];
}


- (void) setParityNone {
	if (!_isHardwareOk) return;
	_serialOptions.c_cflag &= ~PARENB;	// Clear parity enable
	[self commitChanges];
}


- (NSInteger) sendString: (NSString *)theString {
	if (!_isHardwareOk) return -1;
//	return write(_port4handshake, [theString cString], [theString cStringLength]);
	return write(_serialDevice, [theString cStringUsingEncoding: NSASCIIStringEncoding], [theString lengthOfBytesUsingEncoding: NSASCIIStringEncoding]);
}


- (NSInteger) sendData: (NSData *) theData {
	if (!_isHardwareOk) return -1;
	return write(_serialDevice, [theData bytes], [theData length]);
}


- (NSInteger) sendByte: (char) aByte {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
	if (!_isHardwareOk) return -1;
	return write(_serialDevice, &aByte, 1);
}


- (void) flushInput {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
	if (!_isHardwareOk) return;
	tcflush(_serialDevice, TCIFLUSH);
}


- (void) flushOutput {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
	if (!_isHardwareOk) return;
	tcflush(_serialDevice, TCOFLUSH);
}


- (void) flushInAndOutput {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
	if (!_isHardwareOk) return;
	tcflush(_serialDevice, TCIOFLUSH);
}


- (unsigned int) bytesAvailable {
	if (!_isHardwareOk) return 0;
	unsigned int bytes;  ioctl(_serialDevice, FIONREAD, &bytes);
	return bytes;
}


- (NSData *) readData {
	if (!_isHardwareOk) return NULL;
	#define readBufferSize 100
	char readBuffer[readBufferSize];
	NSUInteger len = read(_serialDevice, readBuffer, readBufferSize);
	return [NSData dataWithBytes:readBuffer length:len];
}

@end
