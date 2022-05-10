# Bonjour

Bonjour implements discovery of services registered using the mDNS protocol
	There are two concrete implementations:
		1) Using the dns-sd command line utility
		2) Using a FFI interface to the dnssd dynamic library
		
	Currently only 1) works reliably.
	As some dnssd calls can be blocking whilst waiting for results the use 
	of the threaded/non-blocking functionality of FFI is required. 
	
	Unfortunately, for reasons unknown as yet, this doesn't work. Sometimes it crashes, 
	other times it makes the call and the UI stays responsive, but the call never returns, 
	or it simply freezes showing the Spinning Wheel Of Death!
	
	If blocking calls are used (see BonjourLibraryFFI>>runner), it will run, but eventually
	lock up on a blocking call (presumably as bonjour results are not available when the call
	is made.
	
	To run, click on openApp within the _testing category within the interface you want to use.
	"
