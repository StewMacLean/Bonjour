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
	
Update 6th August 22
Previously the non-blocking calls would cause spectacular crashes.
Thanks to Estebane Lorenazno, this has now been fixed. 
His key changes made:
1. Indeed, the library needs to run in a worker thread, otherwise this it will freeze inside a callback.
2. Most important: callbacks needs to run too in the worker thread (hence the existence of BonjourCallback, to be implement ffiLibraryName).
3. Value holders (the ones that you pass to a C function to later get its result). You need to pass a ByteArray to later take the stored value.

Upon further testing I discovered that due to using the threaded configuration for all calls, and having multiple callouts/callbacks errors were occuring in the callback processing. 

See TFRunner>>returnCallback: aCallbackInvocation
	"...Otherwise, throw an exception as returning means a bug in your application. [note it doesn't, it just calls recursively].
	The user must guarantee callbacks return in the correct order"
	
To avoid this I created two library interface classes, thus having two workers. One library makes the "synchronous" callouts and handles the corresponding callbacks. The other library makes the asynchronous callouts for the blocking callback "pumps". Note that the 
intrinsically synchronous callouts are still made using the asynchronous threaded mechanisim - they just block/unblock very quickly. I tried to configure this to be true synchronous, but this caused crashes.

However it is still not running as expected. The problem is that calls to the blocking callback pumps, are not returning as expected. What should happen is that after the callout makes the request and registers the callback to receive the results, the corresponding callback pump is called. This blocks until callbacks are ready. Whe the blocked call returns this indicates to the application that there are results to process. This should happen virtually immediately, as results are returned very quickly. Unfortunately, most of these blocked calls are remaining blocked for long periods of time. 

Somewhat randomly, they become unblocked after some time. This is usually caused by a callback being triggered when a new service/service type is discovered. They also become unblocked (along with a sucession of corresponding callbacks) when the socket descriptor references are deallocated. My suspision is that the semaphore that blocks the process until it returns is not being signaled. See

TFExternalAsynchCall>>doExecuteOn: aRunner
	
	| aTaskAddress | 
	
	aTaskAddress := aRunner
		executeFunction: function
		withArguments: parameterArray
		usingSemaphore: self semaphoreIndex.
	
	"I check if the semaphore is already signaled, because doing it in this way 
	is thousands of times faster than just executing the wait. 
	I think is a bug in the VM"
	
	self semaphore isSignaled 
		ifFalse: [ self semaphore wait ].
	
	^ aRunner readReturnValueFromTask: aTaskAddress
	
With reference to the comment in this method, I can't help but experience "code smell". Unfortunately, I don't have the chops to dig into the VM to prove this hypothesis! 

Another factor at play is the priority of the processes making these calls. I have experimented with various settings, above and below the priority of the Callback queue process. It seems more responsive, and less crashes occur on shut down with priority greater than the callback process (69).

There is another issue that occurs fairly frequently - Segmentation faults related to the worker thread - Not in VM thread. I'm not sure what is causing this.

In spite of these problems, by letting it run by shutting down to fire the callbacks I have been able to fully test the full functionality of calls:

1. Browse for service types
2. Browse for services of one or more types
3. Resolve a service to obtain its host name, port and text records
4. Obtain the addresses of each service
5. Registration of a service

Please refer to the sample trace for further details.
Log interpretation:

**> Callout (synchronous intrinsically)

**> | Callout - threaded asynchronous blocking

|<** Return from blocked callout

<** Callback block execution on callback queue thread

@@@@ Application thread callback processing

### State change of domain model



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
			
It will bring up a browser with the openApp method for the library interface selected.

Configure the service types to browse in the openApp method. For testing, it is best to browse for only one service type as there is quite alot of tracing output generated.

Then click the script icon to open the app.

Alternatively, you can download the preloaded image and Pharo 10 engine for a quick start.

### Troubleshooting

Execution is logged to:
1. The Transcript
2. Files within ./logs bonjour/
3. To the terminal 

To see terminal output start Pharo with logLevel=4 using:

<...>/Pharo.app/Contents/MacOS/Pharo  --logLevel=4  <...>/Pharo.image

Results can be validated by running similar a app, Discovery - DNS-SD Browser,  available from the Apple App store:
	https://apps.apple.com/us/app/discovery-dns-sd-browser/id1381004916?mt=12


### Get Involved
			
I would very much appreciate any further help in getting the library interface working!

Thanks to Estebane for his help with getting past the "crashing" phase!

Merci beaucoup,

Stew MacLean




