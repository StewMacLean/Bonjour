# Bonjour - *C'est si bon!*

A Pharo Smalltalk implementation of Bonjour/Zeroconf/mDNS service discovery for MacOS.

Note that it has only been tested on Pharo 10 and Mac M1/Monterey. Your luck with other versions may vary.

The DNS Service Discovery API helps you to perform three main tasks:
1. Registering a service
2. Browsing for services
3. Resolving service names to host names

Pharo Smalltalk Bonjour has two concrete implementations:
1. Using the dns-sd command line utility
2. Using a FFI interface to the dnssd dynamic library

### There's A Catch...
		
Currently only 1. works reliably.

As some dnssd calls using 2. can be blocking whilst waiting for results the use 
of the threaded/non-blocking functionality of FFI is required. 
	
Update 29/07/22
Previously the non-blocking calls would cause spectacular crashes.
Thanks to Estebane Lorenazno, this has now been fixed. 
His key changes made:
1. Indeed, the library needs to run in a worker thread, otherwise this it will freeze inside a callback.
2. Most important: callbacks needs to run too in the worker thread (hence the existence of BonjourCallback, to be implement ffiLibraryName).
3. Value holders (the ones that you pass to a C function to later get its result). You need to pass a ByteArray to later take the stored value.

However it is still not running as expected. The problem is that calls to the api that are non blocking, are not returning immediately.
For some reason, the call doesn't return, until a call back is fired, such as when you register a new service, which fires a callback.
This caused the "blocked" call to return, and the system runs until the same problem occurs. If another service is registered, this
caused the next "blocked" call to return, and so on. 

Please refer to the annotated trace for further details.

### Running The App
	
To run, click on openApp within the interface you want to use:

<img src="https://github.com/StewMacLean/Bonjour/blob/master/screenshots/classeswithopenAppmethod.png" style=" width:600px " />

which will open the app to show your serivces (dynamically updating as they come and go):

<img src="https://github.com/StewMacLean/Bonjour/blob/master/screenshots/DiscoveryApp.png" style=" width:600px " />

### Behind The Scenes

Both the API classes implement:

<img src="https://github.com/StewMacLean/Bonjour/blob/master/screenshots/api.png" style=" width:600px " />

The BPI (Binary Programming Interface, where we "hit the silicon!") implements:

<img src="https://github.com/StewMacLean/Bonjour/blob/master/screenshots/bpi.png" style=" width:600px " />

which is part of the FFI library:

<img src="https://github.com/StewMacLean/Bonjour/blob/master/screenshots/BonjourFFI.png" style=" width:600px " />

### Installation

To download into your image, execute:

	[Metacello new 
		repository: 'github://StewMacLean/Bonjour/source';
		baseline: 'Bonjour';
		load] 
			on: MCMergeOrLoadWarning 
			do: [: warning | warning load].
			
It should bring up a browser with the openApp method for the library interface selected (as shown above) - click it to run the app.

### Troubleshooting

Execution is logged to:
1. The Transcript
2. Files within ./logs bonjour/
3. To the terminal 

Start Pharo with logLevel=4 using:
<...>/Pharo.app/Contents/MacOS/Pharo  --logLevel=4  <...>/Pharo.image


### Get Involved
			
I would very much appreciate any further help in getting the library interface working!

Thanks to Estebane for getting past the "crashing" phase!

Merci beaucoup,

Stew MacLean




