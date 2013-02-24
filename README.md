©2013 Michael Bach, michael.bach@uni-freiburg.de, michaelbach.de


EDGSerial
=========

A way to access RS232 serial devices via USB, using the Keyspan devices.

//  Created by bach on 11.12.06.

//  Copyright 2006 Prof. Michael Bach. All rights reserved.

//	History

//	=======

//
//	2012-11-15	checked on speed. It is possible to toggle DTR every 4 ms (10% faster already becomes a problem)
//	2012-08-03	minor code change to avoid warning about unitialised self
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




Some details
------------

Rhere are many tricks which would need more description… One thing: the port name can either be generic "serial" or specific, e.g. "USA49Wb1P1.1" but then the USB port is addressed too