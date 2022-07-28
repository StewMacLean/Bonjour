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
	
Unfortunately, for reasons unknown as yet, this doesn't work. Sometimes it crashes, 
other times it makes the call and the UI stays responsive, but the call never returns, 
or it simply freezes showing the Spinning Wheel Of Death!
	
If blocking calls are used (see BonjourLibraryFFI>>runner), it will run, but eventually
lock up on a blocking call (presumably as Bonjour results are not available when the call
is made.

### Running The App
	
To run, click on openApp within the testing category of the interface you want to use:

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
			
It should bring up a browser with the openApp method for the command line interface selected (as shown above) - click it to run the app.

### Troubleshooting

Execution is logged to:
1. The Transcript
2. Files within ./logs bonjour/
3. To the terminal 

Start Pharo with logLevel=4 using:
<...>/Pharo.app/Contents/MacOS/Pharo  --logLevel=4  <...>/Pharo.image

When you get the Spinning Wheel Of Death, open the Activity Monitor select Pharo, and do a SpinDump to see where it is stuck in the bowels of the VM.

### Get Involved
			
I would very much appreciate any help in getting the library interface working!

Merci beaucoup,

Stew MacLean




