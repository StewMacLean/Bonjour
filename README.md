# Bonjour

Pharo Smalltalk implementation of Bonjour/Zeroconf/mDNS service discovery for MacOS.
(Tested on Pharo 10 and Mac M1/Monterey).

The DNS Service Discovery API helps you to perform three main tasks:
	Registering a service
	Browsing for services
	Resolving service names to host names

There are two concrete implementations:
	1) Using the dns-sd command line utility
	2) Using a FFI interface to the dnssd dynamic library
		
Currently only 1) works reliably.

As some dnssd calls using 2) can be blocking whilst waiting for results the use 
of the threaded/non-blocking functionality of FFI is required. 
	
Unfortunately, for reasons unknown as yet, this doesn't work. Sometimes it crashes, 
other times it makes the call and the UI stays responsive, but the call never returns, 
or it simply freezes showing the Spinning Wheel Of Death!
	
If blocking calls are used (see BonjourLibraryFFI>>runner), it will run, but eventually
lock up on a blocking call (presumably as Bonjour results are not available when the call
is made.
	
To run, click on openApp within the testing category of the interface you want to use:

![Click on openApp](https://github.com/StewMacLean/Bonjour/blob/master/screenshots/classeswithopenAppmethod.png)

<img src="https://github.com/StewMacLean/Bonjour/blob/master/screenshots/classeswithopenAppmethod.png" style=" width:100px ; height:100px " />

To download into your image, execute:

	[Metacello new 
		repository: 'github://StewMacLean/Bonjour/source';
		baseline: 'Bonjour';
		load] 
			on: MCMergeOrLoadWarning 
			do: [: warning | warning load].
			
It should bring up a browser with the openApp method for the command line interface selected. 

Just click it to open the app and watch the services roll in - Enjoy! 

Open the Transcript to see a log of what is going on under the hood (and see the log files and the system output).
			
I would very much appreciate any help in getting the library interface working!

Thanks,

Stew MacLean



