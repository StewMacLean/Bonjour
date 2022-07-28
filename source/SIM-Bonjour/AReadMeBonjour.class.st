Class {
	#name : #AReadMeBonjour,
	#superclass : #Object,
	#category : #'SIM-Bonjour-ReadMe'
}

{ #category : #'api - overview' }
AReadMeBonjour >> Architecture [
	"
	Function calls to the Bonjour api register callbacks that are made when results are available.
	When the api call is made a handle to a socket is returned. This is stored in a connection for 
	reference when the callbacks fire.
	When callbacks fire they are added to the callbackQueue to be processed by the callback process.
	The callback process triggers events depending on the callback.
	
	For OverDrive, after the initial resolve and address functions have been completed there are two connections 
	for browsing and one registration connection.
	
	Instance variables:
		connections - a connection SV with socket description reference (sdRef) returned from callback function (see below) 
		registrations - a Service object with socket description reference (sdRef) returned from the initial registriation callback (see below)
		
	Service Found (1 per interface) -> Service Resolve (1 per interface)-> Service Address (per address) {including 127.0.0.1 loopback}
	
		
	ServiceType
	        |
	        | *
	Service -- * Interface (#)
               |
               | *
	ServiceAddress		
	"
	
	
]

{ #category : #'api - overview' }
AReadMeBonjour >> Overview [
	"The DNS Service Discovery API helps you to perform three main tasks:
Registering a service
Browsing for services
Resolving service names to host names
In support of these main tasks, this API can directly assist you in performing two subsidiary tasks:

Enumerating domains (finding recommended service domains)
Updating registrations (changing your DNS registration data dynamically)
https://developer.apple.com/library/ios/documentation/Networking/Conceptual/dns_discovery_api/Introduction.html"
	"It is important to understand the structure for working with the socket-based DNSServiceDiscovery APIs . First, you call a function that might, for example, initiate browsing for a service or register a service. Along with the other parameters, you pass in the address of an uninitialized DNSServiceRef (which the call initializes) and also pass in the address of the function that should be called back when interesting events happen.
	
You can then either:

A. Wait for results using a run loop or select loop
---------------------------------------------------

Call DNSServiceRefSockFD(), passing in the newly initialized DNSServiceRef , to extract the file descriptor for the Unix Domain Socket connection to the mdnsd daemon running in the background, and add this file descriptor to your select( ) loop. When the mdnsd daemon sends a message over the Unix Domain Socket connection to your process, your select( ) call will wake up, indicating that there is data waiting to be read on the file descriptor. You then call DNSServiceProcessResult( ) ; the DNS-SD code decodes the message and calls the appropriate callback function you previously specified when starting the operation..
http://flylib.com/books/en/2.94.1.53/1/"
	"From https://github.com/stepheneb/mdns-responder
	

B. Wait for result synchronously - used in this binding
--------------------------------
If you want to run the callback function synchronously instead of setting up a run loop or a select loop, you can call <the api call> and immediately call DNSServiceProcessResult. The DNSServiceProcessResult function will block until the mDNSResponder daemon has a response, at which time the callback specified when DNSServiceResolve was called will be invoked. This entire process should probably be run within a loop of its own for each service you wish to resolve

What is mDNSResponder?
----------------------

The mDNSResponder project is a component of Bonjour,
Apple's ease-of-use IP networking initiative:
<http://developer.apple.com/bonjour/>

Apple's Bonjour software derives from the ongoing standardization
work of the IETF Zero Configuration Networking Working Group:
<http://zeroconf.org/>

The Zeroconf Working Group has identified three requirements for Zero
Configuration Networking:
1. An IP address (even when there is no DHCP server to assign one)
2. Name-to-address translation (even when there is no DNS server)
3. Discovery of Services on the network (again, without infrastucture)

Requirement 1 is met by self-assigned link-local addresses, as
described in "
	"Dynamic Configuration of IPv4 Link-Local Addresses"
	"
<http://files.zeroconf.org/draft-ietf-zeroconf-ipv4-linklocal.txt>

Requirement 2 is met by sending DNS-like queries via Multicast (mDNS).

Requirement 3 is met by DNS Service Dicsovery (DNS-SD).

Self-assigned link-local address capability has been available since
1998, when it first appeared in Windows '98 and in Mac OS 8.5.
Implementations for other platforms also exist.

The mDNSResponder project allows us to meet requirements 2 and 3.
It provides the ability for the user to identify hosts using names
instead of dotted-decimal IP addresses, even if the user doesn't have a
conventional DNS server set up. It also provides the ability for the
user to discover what services are being advertised on the network,
without having to know about them in advance, or configure the machines.

The name "
	"mDNS"
	" was chosen because this protocol is designed to be,
as much as possible, similar to conventional DNS. The main difference is
that queries are sent via multicast to all local hosts, instead of via
unicast to a specific known server. Every host on the local link runs an
mDNSResponder which is constantly listening for those multicast queries,
and if the mDNSResponder receives a query for which it knows the answer,
then it responds. The mDNS protocol uses the same packet format as
unicast DNS, and the same name structure, and the same DNS record types.
The main difference is that queries are sent to a different UDP port
(5353 instead of 53) and they are sent via multicast to address
224.0.0.251. Another important difference is that all "
	"mDNS"
	" names
end in "
	".local When a user types"
	" "
	"yourcomputer.local."
	" into their Web
browser, the presence of "
	".local"
	" on the end of the name tells the host
OS that the name should be looked up using local multicast instead of by
sending that name to the worldwide DNS service for resolution. This
helps reduce potential user confusion about whether a particular name
is globally unique (e.g. "
	"www.apple.com."
	") or whether that name has only
local significance (e.g. "
	"yourcomputer.local."
	").


About the mDNSResponder Code
----------------------------

Because Apple benefits more from widespread adoption of Bonjour than
it would benefit from keeping Bonjour proprietary, Apple is making
this code open so that other developers can use it too.

Because Apple recognises that networks are hetrogenous environments
where devices run many different kinds of OS, this code has been made
as portable as possible.

A typical mDNS program contains three components:

    +------------------+
    |   Application    |
    +------------------+
    |    mDNS Core     |
    +------------------+
    | Platform Support |
    +------------------+

The "
	"mDNS Core"
	" layer is absolutely identical for all applications and
all Operating Systems.

The "
	"Platform Support"
	" layer provides the necessary supporting routines
that are specific to each platform -- what routine do you call to send
a UDP packet, what routine do you call to join multicast group, etc.

The "
	"Application"
	" layer does whatever that particular application wants
to do. It calls routines provided by the "
	"mDNS Core"
	" layer to perform
the functions it needs --
 * advertise services,
 * browse for named instances of a particular type of service
 * resolve a named instance to a specific IP address and port number,
 * etc.
The "
	"mDNS Core"
	" layer in turn calls through to the "
	"Platform Support"
	"
layer to send and receive the multicast UDP packets to do the actual work.

Apple currently provides "
	"Platform Support"
	" layers for Mac OS 9, Mac OS X,
Microsoft Windows, VxWorks, and for POSIX platforms like Linux, Solaris,
FreeBSD, etc.

Note: Developers writing applications for OS X do not need to incorporate
this code into their applications, since OS X provides a system service to
handle this for them. If every application developer were to link-in the
mDNSResponder code into their application, then we would end up with a
situation like the picture below:

  +------------------+    +------------------+    +------------------+
  |   Application 1  |    |   Application 2  |    |   Application 3  |
  +------------------+    +------------------+    +------------------+
  |    mDNS Core     |    |    mDNS Core     |    |    mDNS Core     |
  +------------------+    +------------------+    +------------------+
  | Platform Support |    | Platform Support |    | Platform Support |
  +------------------+    +------------------+    +------------------+

This would not be very efficient. Each separate application would be sending
their own separate multicast UDP packets and maintaining their own list of
answers. Because of this, OS X provides a common system service which client
software should access through the "
	"/usr/include/dns_sd.h"
	" APIs.

The situation on OS X looks more like the picture below:

                                   -------------------
                                  /                   \
  +---------+    +------------------+    +---------+   \  +---------+
  |  App 1  |<-->|    daemon.c      |<-->|  App 2  |    ->|  App 3  |
  +---------+    +------------------+    +---------+      +---------+
                 |    mDNS Core     |
                 +------------------+
                 | Platform Support |
                 +------------------+

Applications on OS X make calls to the single mDNSResponder daemon
which implements the mDNS and DNS-SD protocols. 

Vendors of products such as printers, which are closed environments not
expecting to be running third-party application software, can reasonably
implement a single monolithic mDNSResponder to advertise all the
services of that device. Vendors of open systems which run third-party
application software should implement a system service such as the one
provided by the OS X mDNSResponder daemon, and application software on
that platform should, where possible, make use of that system service
instead of embedding their own mDNSResponder.

See ReadMe.txt in the mDNSPosix directory for specific details of
building an mDNSResponder on a POSIX Operating System.


Compiling on Older C Compilers
------------------------------

We go to some lengths to make the code portable, but //-style comments
are one of the modern conveniences we can't live without.

If your C compiler doesn't understand these comments, you can transform
them into classical K&R /* style */ comments with a quick GREP
search-and-replace pattern.

In BBEdit on the Mac:
1. Open the "
	"Find"
	" dialog window and make sure "
	"Use Grep"
	" is selected
2. Search For  : ([^:])//(.*)
3. Replace With: \1/*\2 */
4. Drag your mDNSResponder source code folder to the Multi-File search pane
5. Click "
	"Replace All"
	"

For the more command-line oriented, cd into your mDNSResponder source code
directory and execute the following command (all one line):

find mDNSResponder \( -name \*.c\* -or -name \*.h \) -exec sed -i .orig -e 's,^//\(.*\),/*\1 */,' -e '/\/\*/\!s,\([^:]\)//\(.*\),\1/*\2 */,' {} \;

"
	
	
]

{ #category : #about }
AReadMeBonjour >> about [

	"Bonjour implements discovery of services registered using the mDNS protocol.
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
]

{ #category : #api }
AReadMeBonjour >> browseNotes [
	"Browsing for Network Services

Browsing for services using this API is fairly simple. You can find out what services of a given type are available in a given domain with a single function call.

Using DNSServiceBrowse

To browse for available services, call DNSServiceBrowse. The parameters for making this call consist of the following:

An uninitialized service discovery reference.
The index for the interface you want to browse; pass 0 to browse all available interfaces, pass –1 to browse for services on the local host only, or pass the number that represents the interface you want to browse (use the if_nametoindex family of calls to get the number).
The registration type of the service you want to browse; the registration type is the service type followed by a dot, followed by the protocol (for example, _printer._tcp).
The domain to browse; pass NULL to browse the domain(s) specified by the user as acceptable for browsing or pass a domain name to only browse that domain.
The callback function that is to be called to provide information on the success or failure of the browse and to provide search results, such as a service that has been found or a service that is no longer available.
A user-defined context value that will be passed to the callback function when it is called, or NULL.
If the browse can be started, DNSServiceBrowse initializes the service discovery reference and creates a socket that is used to communicate with the mDNSResponder daemon. Use the service discovery reference to call DNSServiceRefSockFD and get the socket descriptor for the socket.

Use the socket descriptor to set up a run loop or a select loop that will indicate when a response from the mDNSResponder daemon becomes available. The response may indicate that a service instance matching the specified type, domain, and interface has been found or that a service instance that was previously found is no longer available. When the loop indicates that the mDNSResponder daemon has responded, call DNSServiceProcessResult and pass to it the service discovery reference initialized by DNSServiceBrowse. DNSServiceProcessResult will call the callback function associated with the service discovery reference.

Your callback will be called with the following parameters:

The service discovery reference that was initialized by DNSServiceBrowse.
Flags that provide information about a service that has been found or that is no longer available and browsing status. For example, kDNSServiceFlagsAdd indicates that the service parameter contains the name of a service that has been found; you should add it to your list of available services. If kDNSServiceFlagsAdd is not set, the service specified by the service parameter is no longer available and should be removed from your list of available services. Browsing status is indicated by the kDNSServiceFlagsMoreComing flag. When it is set, your callback function will be called again immediately, so you should not update your user interface. When kDNSServiceFlagsMoreComing is not set, your callback function will not be called again immediately, so you have time to update your user interface.
The index of the interface on which the service was discovered.
An error code that indicates whether browsing was successful; if browsing was successful, the remaining parameters contain valid data.
The name of the service that was found, if browsing was successful.
The registration type, if browsing was successful.
The domain in which the service was discovered, if browsing was successful.
The user-defined context information that was passed to DNSServiceBrowse.
Browsing Multiple Domains

To browse in multiple domains, or for multiple service types, call DNSServiceBrowse for each domain and service type of interest. Your application is responsible for keeping track of the responses.

Note: You can obtain a list of recommended domains to search by calling DNSServiceEnumerateDomains. For details, see Enumerating Domains.
If your application needs to leave the browser interface visible the entire time your application is running, as iTunes and iChat do, then you typically will call DNSServiceBrowse once per session. Whenever a new service becomes available or an existing service becomes unavailable, data is sent to your callback function, so you can simply leave the callback active, and your list of services will always be up to date. This information typically changes infrequently, so the callback usually does not use much CPU time.

However, if you application does not need to constantly show the list of available services, in a situation such as the printer dialog, then you should call DNSServiceBrowse and terminate the browsing when you are finished.

When you call DNSServiceBrowse, it initializes a service discovery reference and opens a socket-based connection with the mDNSResponder daemon. For this reason, if you choose to deactivate your callback and repeat the search as needed, be sure to call DNSServiceRefDeallocate to deallocate the reference before calling DNSServiceBrowse again. Otherwise, you will leak memory and sockets for every search.

The actual IP address and port of a given service instance will change more frequently than the service name. Each time you use the service, you should resolve the current address of a service instance just prior to using the service. See the next section, Resolving the Current Address of a Service.

Terminating Browsing

To terminate browsing, remove the socket descriptor from the run loop or the select loop and call DNSServiceRefDeallocate, passing to it the service discovery reference that was initialized when DNSServiceBrowse was called. Browsing is halted, the service discovery reference is invalidated, and memory associated with the reference is deallocated. The socket that underlies the connection with the mDNSResponder daemon is closed, thereby terminating your application’s connection with the daemon.

"
	
	
]

{ #category : #api }
AReadMeBonjour >> browseServiceTypes [

	"
	Note: dns-sd utility headers are misleading and reflect Services."
	
	
]

{ #category : #'api - overview' }
AReadMeBonjour >> callingSequenceOverview [

"Bonjour calling sequence overview

1) Create an uninitialize service definition reference (sdRef)
2) Create a callback function which will be invoked once results are available
3) Call the api function passing in the sdRef and the callback.
	Functions are:
		Browse for service types (long running)
		Browse for services (long running)
		Resolve a found service
		Get the addresses of a found service
		Register a service that can be discovered (long running)
	These calls return an initialised sdRef
4) Either:
	4.1
		a) Obtain a socket reference using the sdRef
		b) Then execute a select loop on the socket waiting for results
		c) Once results are available call 'process results' to trigger one or more invocations of the registered callback
	4.2
		a) Call 'process results' directly, which blocks until results are available
		b) Once the synchronous call returns, one or more invocations of the registered callback occur
5) Extract results from each callback and make further function calls as required
"
		
		  
]

{ #category : #utilities }
AReadMeBonjour >> commandLine [

 	"
	Prefered:
	sudo -S killall –HUP mDNSResponder
	sudo -S killall –HUP mDNSHelper
	
	Old: 
	sudo killall -CONT mDNSResponder
	sudo killall -STOP mDNSResponder
	"
]

{ #category : #mDNSResponder }
AReadMeBonjour >> commands [

	"
	help:
	man mDSNResonder
	Refresh cache:
	LibC runCommand:  'echo sim123 | sudo -S killall –HUP mDNSResponder'.
	LibC runCommand:  'echo sim123 | sudo -S killall –HUP mDNSHelper'.
	
	warning and notice logging
	LibC runCommand: 'echo sim123 | sudo killall -USR1 mDNSResponder'. 
	log levels Emergency to Debug
	LibC runCommand:  'echo sim123 | syslog -c mDNSResponder -d'. 
	current state in console
	LibC runCommand: 'echo sim123  killall -INFO mDNSResponder'
	"
]

{ #category : #utilities }
AReadMeBonjour >> computerNaming [
	"Find your computer’s local hostname
Your computer’s local hostname, or local network name, is displayed on your local network so others on the network can connect to your Mac. 
It also identifies your Mac to Bonjour-compatible services.

On your Mac, choose Apple menu  > System Preferences, then click Sharing.

Your computer’s local hostname is displayed beneath the computer’s name at the top of Sharing preferences.

The local network name is your computer’s name with .local added, and any spaces are replaced with hyphens (-). 
For example, if your computer’s name is My Computer, your local network name is My-Computer.local. 
Local network names aren’t case sensitive, so my-computer.local is the same as My-Computer.local."
	
	
]

{ #category : #api }
AReadMeBonjour >> daemonVersionNotes [
	"
	uint32_t v;
	uint32_t size = sizeof(v);
	err = DNSServiceGetProperty(kDNSServiceProperty_DaemonVersion, &v, &size);
	if (err) fprintf(stderr, "
	"DNSServiceGetProperty failed %ld\n"
	", (long int)err);
	else printf("
	"Currently running daemon (system service) is version %d.%d\n"
	", v / 10000, v / 100 % 100);
	exit(0);
	"
	"
/* DNSServiceGetProperty() Parameters:
 *
 * property:        The requested property.
 *                  Currently the only property defined is kDNSServiceProperty_DaemonVersion.
 *
 * result:          Place to store result.
 *                  For retrieving DaemonVersion, this should be the address of a uint32_t.
 *
 * size:            Pointer to uint32_t containing size of the result location.
 *                  For retrieving DaemonVersion, this should be sizeof(uint32_t).
 *                  On return the uint32_t is updated to the size of the data returned.
 *                  For DaemonVersion, the returned size is always sizeof(uint32_t), but
 *                  future properties could be defined which return variable-sized results.
 *
 * return value:    Returns kDNSServiceErr_NoError on success, or kDNSServiceErr_ServiceNotRunning
 *                  if the daemon (or "
	"system service"
	" on Windows) is not running.
 */

DNSServiceErrorType DNSSD_API DNSServiceGetProperty
    (
    const char *property,  /* Requested property (i.e. kDNSServiceProperty_DaemonVersion) */
    void       *result,    /* Pointer to place to store result */
    uint32_t   *size       /* size of result location */
    );"

"/*
 * When requesting kDNSServiceProperty_DaemonVersion, the result pointer must point
 * to a 32-bit unsigned integer, and the size parameter must be set to sizeof(uint32_t).
 *
 * On return, the 32-bit unsigned integer contains the API version number
 *
 * For example, Mac OS X 10.4.9 has API version 1080400.
 * This allows applications to do simple greater-than and less-than comparisons:
 * e.g. an application that requires at least API version 1080400 can check:
 *   if (version >= 1080400) ...
 *
 * Example usage:
 * uint32_t version;
 * uint32_t size = sizeof(version);
 * DNSServiceErrorType err = DNSServiceGetProperty(kDNSServiceProperty_DaemonVersion, &version, &size);
 * if (!err) printf(""DNS_SD API version is %d.%d\n"", version / 10000, version / 100 % 100);
 */"
	
	
]

{ #category : #api }
AReadMeBonjour >> deallocateSDRefNotes [
	"
	Terminates the associate operation, the applicationsconnection with the daemon and frees memory associated with the DNSServiceRef.
	The connecting socket is closed.
	
	If the reference's underlying socket is used in a run loop or select() call, it should be removed BEFORE DNSServiceRefDeallocate(_:) is called, 
	as this function closes the reference's socket."
	
	
]

{ #category : #dependencies }
AReadMeBonjour >> dependencies [

	Metacello new
 			baseline: 'OSSubprocess';
 			repository: 'github://pharo-contributions/OSSubprocess:master/repository';
			load
]

{ #category : #utilities }
AReadMeBonjour >> discoveryApp [

 	"
	Discovery.app
	https://github.com/lilyball?tab=overview&from=2021-12-01&to=2021-12-31
	"
]

{ #category : #api }
AReadMeBonjour >> dnsServiceProcessResults [

	"From https://developer.apple.com/reference/dnssd/1804698-dnsservicerefsockfd
	...
	 Alternatively, a client can choose to fork a thread and have it loop calling "
	"DNSServiceProcessResult(ref);"
	"
	If DNSServiceProcessResult is called when no data is available for reading on the socket, 
	it will block until data does become available, and then process the data and return to the caller. 
	..."
	"From - https://developer.apple.com/library/mac/documentation/Networking/Conceptual/dns_discovery_api/Articles/resolving.html

To get a response from mDNSResponder asynchronously, set up a run or a select loop using the socket descriptor. The loop will be notified whenever a response from the mDNSResponder daemon becomes available. When the loop indicates that a response is available, call DNSServiceProcessResult and pass to it the service discovery reference initialized by DNSServiceResolve. DNSServiceProcessResult will call the callback function associated with the service discovery reference. The mDNSResponder daemon will provide a response for each service that it resolves on a per-interface basis.

If you want to run the callback function synchronously instead of setting up a run loop or a select loop, you can call DNSServiceResolve and immediately call DNSServiceProcessResult. The DNSServiceProcessResult function will block until the mDNSResponder daemon has a response, at which time the callback specified when DNSServiceResolve was called will be invoked. This entire process should probably be run within a loop of its own for each service you wish to resolve."
]

{ #category : #api }
AReadMeBonjour >> dnsServiceRefSockFD [
	"The DNS Service Discovery implementation uses this socket to communicate between the client and the mDNSResponder daemon. The application MUST NOT directly read from or write to this socket. Access to the socket is provided so that it can be used as a kqueue event source, a CFRunLoop event source, in a select() loop, etc. When the underlying event management subsystem (kqueue/ select/CFRunLoop etc.) indicates to the client that data is available for reading on the socket, the client should call DNSServiceProcessResult(_:), which will extract the daemon's reply from the socket, and pass it to the appropriate application callback. By using a run loop or select(), results from the daemon can be processed asynchronously. Alternatively, a client can choose to fork a thread and have it loop calling DNSServiceProcessResult(ref); If DNSServiceProcessResult(_:) is called when no data is available for reading on the socket, it will block until data does become available, and then process the data and return to the caller. When data arrives on the socket, the client is responsible for calling DNSServiceProcessResult(ref) in a timely fashion -- if the client allows a large backlog of data to build up the daemon may terminate the connection.
	"
	
	
]

{ #category : #'dns-sd' }
AReadMeBonjour >> dnsdsNetBSD [


"https://man.netbsd.org/dns-sd.1


dns-sd(1)               NetBSD General Commands Manual               dns-sd(1)


NAME

     dns-sd -- Multicast DNS (mDNS) & DNS Service Discovery (DNS-SD) Test Tool


SYNOPSIS

     dns-sd -E

     dns-sd -F

     dns-sd -R name type domain port [key=value ...]

     dns-sd -B type domain

     dns-sd -L name type domain

     dns-sd -P name type domain port host IP [key=value ...]

     dns-sd -q name rrtype rrclass

     dns-sd -Z type domain

     dns-sd -G v4/v6/v4v6 name

     dns-sd -V


DESCRIPTION

     The dns-sd command is a network diagnostic tool, much like ping(8) or
     traceroute(8).  However, unlike those tools, most of its functionality is
     not implemented in the dns-sd executable itself, but in library code that
     is available to any application.  The library API that dns-sd uses is
     documented in /usr/include/dns_sd.h.  The dns-sd command replaces the
     older mDNS command.

     The dns-sd command is primarily intended for interactive use.  Because
     its command-line arguments and output format are subject to change,
     invoking it from a shell script will generally be fragile. Additionally,
     the asynchronous nature of DNS Service Discovery does not lend itself
     easily to script-oriented programming. For example, calls like ""browse""
     never complete; the action of performing a ""browse"" sets in motion
     machinery to notify the client whenever instances of that service type
     appear or disappear from the network. These notifications continue to be
     delivered indefinitely, for minutes, hours, or even days, as services
     come and go, until the client explicitly terminates the call. This style
     of asynchronous interaction works best with applications that are either
     multi-threaded, or use a main event-handling loop to receive keystrokes,
     network data, and other asynchronous event notifications as they happen.
     If you wish to perform DNS Service Discovery operations from a scripting
     language, then the best way to do this is not to execute the dns-sd com-
     mand and then attempt to decipher the textual output, but instead to
     directly call the DNS-SD APIs using a binding for your chosen language.
     For example, if you are programming in Ruby, then you can directly call
     DNS-SD APIs using the dnssd package documented at
     <http://rubyforge.org/projects/dnssd/>.
     Similar bindings for other languages are also in development.

     dns-sd -E
        return a list of domains recommended for registering(advertising) ser-
        vices.

     dns-sd -F
        return a list of domains recommended for browsing services.

        Normally, on your home network, the only domain you are likely to see
        is ""local"".  However if your network administrator has created Domain
        Enumeration records, then you may also see other recommended domains
        for registering and browsing.

     dns-sd -R name type domain port [key=value ...]
        register (advertise) a service in the specified domain with the given
        name and type as listening (on the current machine) on port.

        name can be arbitrary unicode text, containing any legal unicode char-
        acters (including dots, spaces, slashes, colons, etc. without restric-
        tion), up to 63 UTF-8 bytes long.  type must be of the form ""_app-
        proto._tcp"" or ""_app-proto._udp"", where ""app-proto"" is an application
        protocol name registered at
        http://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xml.

        domain is the domain in which to register the service.  In current
        implementations, only the local multicast domain ""local"" is supported.
        In the future, registering will be supported in any arbitrary domain
        that has a working DNS Update server [RFC 2136]. The domain "." is a
        synonym for ""pick a sensible default"" which today means ""local"".

        port is a number from 0 to 65535, and is the TCP or UDP port number
        upon which the service is listening.

        Additional attributes of the service may optionally be described by
        key/value pairs, which are stored in the advertised service's DNS TXT
        record. Allowable keys and values are listed with the service regis-
        tration at
        http://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xml.

     dns-sd -B type domain
        browse for instances of service type in domain.

        For valid types see
        http://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xml.
        as described above. Omitting the domain or using "." means ""pick a
        sensible default.""

     dns-sd -L name type domain
        look up and display the information necessary to contact and use the
        named service: the hostname of the machine where that service is
        available, the port number on which the service is listening, and (if
        present) TXT record attributes describing properties of the service.

        Note that in a typical application, browsing may only happen rarely,
        while lookup (or ""resolving"") happens every time the service is used.
        For example, a user browses the network to pick a default printer
        fairly rarely, but once a default printer has been picked, that named
        service is resolved to its current IP address and port number every
        time the user presses Cmd-P to print.

     dns-sd -P name type domain port host IP [key=value ...]
        create a proxy advertisement for a service running on(offered by) some
        other machine.  The two new options are Host, a name for the device
        and IP, the address of it.

        The service for which you create a proxy advertisement does not neces-
        sarily have to be on your local network.  You can set up a local proxy
        for a website on the Internet.

     dns-sd -q name rrtype rrclass
        look up any DNS name, resource record type, and resource record class,
        not necessarily DNS-SD names and record types.  If rrtype is not spec-
        ified, it queries for the IPv4 address of the name, if rrclass is not
        specified, IN class is assumed. If the name is not a fully qualified
        domain name, then search domains may be appended.

     dns-sd -Z type domain
        browse for service instances and display output in zone file format.

     dns-sd -G v4/v6/v4v6 name
        look up the IP address information of the name.  If v4 is specified,
        the IPv4 address of the name is looked up, if v6 is specified the IPv6
        address is looked up. If v4v6 is specified both the IPv4 and IPv6
        address is looked up. If the name is not a fully qualified domain
        name, then search domains may be appended.

     dns-sd -V
        return the version of the currently running daemon/system service.


EXAMPLES

     To advertise the existence of LPR printing service on port 515 on this
     machine, such that it will be discovered by the Mac OS X printing soft-
     ware and other DNS-SD compatible printing clients, use:

           dns-sd -R ""My Test"" _printer._tcp. . 515 pdl=application/postscript

     For this registration to be useful, you need to actually have LPR service
     available on port 515. Advertising a service that does not exist is not
     very useful, and will be confusing and annoying to other people on the
     network.

     Similarly, to advertise a web page being served by an HTTP server on port
     80 on this machine, such that it will show up in the Bonjour list in
     Safari and other DNS-SD compatible Web clients, use:

           dns-sd -R ""My Test"" _http._tcp . 80 path=/path-to-page.html

     To find the advertised web pages on the local network (the same list that
     Safari shows), use:

           dns-sd -B _http._tcp

     While that command is running, in another window, try the dns-sd -R exam-
     ple given above to advertise a web page, and you should see the ""Add""
     event reported to the dns-sd -B window. Now press Ctrl-C in the dns-sd -R
     window and you should see the ""Remove"" event reported to the dns-sd -B
     window.

     In the example below, the www.apple.com web page is advertised as a ser-
     vice called ""apple"", running on a target host called apple.local, which
     resolves to 17.149.160.49.

           dns-sd -P apple _http._tcp "" 80 apple.local 17.149.160.49

     The Bonjour menu in the Safari web browser will now show ""apple"".  The
     same IP address can be reached by entering apple.local in the web
     browser.  In either case, the request will be resolved to the IP address
     and browser will show contents associated with www.apple.com.

     If a client wants to be notified of changes in server state, it can ini-
     tiate a query for the service's particular record and leave it running.
     For example, to monitor the status of an iChat user you can use:

           dns-sd -q someone@ex1._presence._tcp.local txt

     Everytime status of that user(someone) changes, you will see a new TXT
     record result reported.

     You can also query for a unicast name like www.apple.com and monitor its
     status.

           dns-sd -q www.apple.com"
]

{ #category : #'dns-sd' }
AReadMeBonjour >> dnssdCommandList [

"
dns-sd -H

dns-sd -E                          (Enumerate recommended registration domains)
dns-sd -F                          (Enumerate recommended browsing     domains)
dns-sd -R <Name> <Type> <Domain> <Port> [<TXT>...]         (Register a service)
dns-sd -P <Name> <Type> <Domain> <Port> <Host> <IP> [<TXT>...] (Register Proxy)
dns-sd -B        <Type> <Domain>                 (Browse for service instances)
dns-sd -Z        <Type> <Domain>           (Output results in Zone File format)
dns-sd -L <Name> <Type> <Domain>        (Resolve (‘lookup’) a service instance)
dns-sd -Q <name> <rrtype> <rrclass>         (Generic query for any record type)
dns-sd -q <name> <rrtype> <rrclass>     (Generic query, using SuppressUnusable)
dns-sd -G v4/v6/v4v6 <hostname>          (Get address information for hostname)
dns-sd -X udp/tcp/udptcp <IntPort> <ExtPort> <TTL>           (NAT Port Mapping)
dns-sd -H                               (Print usage for complete command list)
dns-sd -V            (Get version of currently running daemon / system service)
dns-sd -O [-compress|-stdout](Dump the state of mDNSResponder to file / STDOUT)

dns-sd -A                              (Test Adding/Updating/Deleting a record)
dns-sd -C <name> <rrtype> <rrclass>           (Query; reconfirming each result)
dns-sd -I           (Test registering and then immediately updating TXT record)
dns-sd -N                                     (Test adding a large NULL record)
dns-sd -M              (Test creating a registration with multiple TXT records)
dns-sd -S                         (Test multiple operations on a shared socket)
dns-sd -T                                    (Test creating a large TXT record)
dns-sd -U                                          (Test updating a TXT record)
dns-sd -ble                                  (Use kDNSServiceInterfaceIndexBLE)
dns-sd -fmc                      (Force multicast--use mDNS even if not .local)
dns-sd -i <Interface>         (Run dns-sd cmd on a specific interface (en0/en1)
dns-sd -includep2p                        (Set kDNSServiceFlagsIncludeP2P flag)
dns-sd -includeAWDL                      (Set kDNSServiceFlagsIncludeAWDL flag)
dns-sd -intermediates            (Set kDNSServiceFlagsReturnIntermediates flag)
dns-sd -ku                               (Set kDNSServiceFlagsKnownUnique flag)
dns-sd -lo                          (Run dns-sd cmd using local only interface)
dns-sd -m                    (Exit when no more results are coming immediately)
dns-sd -p2p                                  (Use kDNSServiceInterfaceIndexP2P)
dns-sd -r <Name> <Type> <Domain> (Release peer connection for service instance)
dns-sd -sh                                    (Set kDNSServiceFlagsShared flag)
dns-sd -t <seconds>                                      (Exit after <seconds>)
dns-sd -tc                    (Set kDNSServiceFlagsBackgroundTrafficClass flag)
dns-sd -test                                  (Run basic API input range tests)
dns-sd -t1                              (Set kDNSServiceFlagsThresholdOne flag)
dns-sd -tFinder                      (Set kDNSServiceFlagsThresholdFinder flag)
dns-sd -timeout                              (Set kDNSServiceFlagsTimeout flag)
dns-sd -unicastResponse              (Set kDNSServiceFlagsUnicastResponse flag)
dns-sd -autoTrigger                      (Set kDNSServiceFlagsAutoTrigger flag)
dns-sd -enableDNSSEC              (Enable DNSSEC validation for the '-Q' query)
"


]

{ #category : #'dns-sd' }
AReadMeBonjour >> dnssdCommands [

"
Browse service types:
------------------------

dns-sd -B  <Type> <Domain> (optional)

dns-sd -B _services._dns-sd._udp

Timestamp     A/R    Flags  if Domain               Service Type         Instance Name
13:00:29.931  Add        3  14 .                    _tcp.local.          _smb
13:00:29.931  Add        3  11 .                    _tcp.local.          _smb

Browse for service type instances:
---------------------------------

dns-sd -B  <Type> <Domain> (optional)               

dns-sd -B _smb._tcp

Timestamp     A/R    Flags  if Domain               Service Type         Instance Name
12:59:57.983  Add        3  11 local.               _smb._tcp.           Stewart’s MacBook Air
12:59:57.983  Add        3  14 local.               _smb._tcp.           Korimako


Resolve a service: (lookup it’s host name):
-------------------------------------------

dns-sd -L <Name> <Type> <Domain>

dns-sd -L Korimako _smb._tcp   local.

Korimako._smb._tcp.local. can be reached at Korimako-5.local.:445 (interface 14)

Get address of a service:
-------------------------

dns-sd -G v4/v6/v4v6 <hostname> 

dns-sd -G v4v6 Korimako-5.local.

Timestamp     A/R    Flags if Hostname                               Address                                      TTL
13:03:41.958  Add 40000003 14 Korimako-5.local.                      FE80:0000:0000:0000:1C71:71B5:74F5:37DC%en0  120
13:03:41.958  Add 40000003 11 Korimako-5.local.                      FE80:0000:0000:0000:1C71:71B5:74F5:37DC%en1  120
13:03:41.958  Add 40000003 14 Korimako-5.local.                      192.168.1.2                                  120
13:03:41.958  Add 40000002 11 Korimako-5.local.                      192.168.1.2                                 120


Register a service:
--------------------
dns-sd -R <Name> <Type> <Domain> <Port> [<TXT>...] 

dns-sd -R OverDrive _osc._udp. local. 1111


"


]

{ #category : #'dns-sd' }
AReadMeBonjour >> dnssdNotes [
	"
Running dns-sd -B _services._dns-sd._udp will return a list of all available service types that currently being advertised. 
(The list is per interface, so there will be some redundancy.) 
If this is done on a Mac with no active network connection, the list will of course only contain services running on that machine.

Using that list, you can request information about the individual services types by running things like dns-sd -B _home-sharing._tcp (which lists iTunes Home Sharing instances), and then, given an instance name, you can run dns-sd -L lookup information for a particular instance.
"

"From http://agnat.github.io/node_mdns/user_guide.html
As you can see the browser object is an EventEmitter. For each HTTP server a 'serviceUp' event is emitted. Likewise, if a server disappears 'serviceDown' is sent. The service object of a 'serviceUp' event might look like this:

{ interfaceIndex: 4
, name: 'somehost'
, networkInterface: 'en0'
, type: {name: 'http', protocol: 'tcp', subtypes: []}
, replyDomain: 'local.'
, fullname: 'somehost._http._tcp.local.'
, host: 'somehost.local.'
, port: 4321
, addresses: [ '10.1.1.50', 'fe80::21f:5bff:fecd:ce64' ]
}
In fact you might receive more than one event per service instance. That is because dns_sd reports each available network path to a service. Also, note that you might get more (or less) addresses. This depends on the network topology. While testing you will often run both peers on the same machine. Now, if you have both a wired and a wireless connection to the same network you will see both addresses on both interfaces (not including IPv6 addresses). The number of IP addresses also depends on the platform and the resolver being used. More on this later.

On service types
Service type identifiers are strings used to match service instances to service queries. A service type always contains the service name and the protocol. Additionally it may contain one or more subtype identifiers. Here are some examples:

_http._tcp
_osc._udp
_osc._udp,_api-v1,_api-v2
That’s an awful lot of underscores and punctuation. To make things easier mdns has a helper class, called ServiceType and some utility functions like mdns.tcp(...) in the example above. Here are some ways to create a ServiceType object:

var r0 = mdns.tcp('http')                     // string form: _http._tcp
  , r1 = mdns.udp('osc', 'api-v1')            // string form: _osc._udp,_api-v1
  , r2 = new mdns.ServiceType('http', 'tcp')  // string form: _http._tcp
  , r3 = mdns.makeServiceType('https', 'tcp') // string form: _https._tcp
  ;

TXT Records
Each service has an associated DNS TXT record. The application can use it to publish a small amount of metadata. The record contains key-value pairs. The keys must be all printable ascii characters excluding ‘=’. The value may contain any data.

The TXT record is passed to the Advertisement as an object:

var txt_record = {
    name: 'bacon'
  , chunky: true
  , strips: 5
};
var ad = mdns.createAdvertisement(mdns.tcp('http'), 4321, {txtRecord: txt_record});
Non-string values are automatically converted. Buffer objects as values work too.

The size of the TXT record is very limited. That is because everything has to fit into a single DNS message (512 bytes)1. The documentation mentions a “typical size” of 100-200 bytes, whatever that means. There also is a hard limit of 255 bytes for each key-value pair. That’s why they also recommend short keys (9 bytes max). The bottom line is: Keep it brief.

DNS distinguishes between keys with no value and keys with an empty value:

var record = {
    empty: ''
  , just_a_flag: null // or undefined
};
When browsing for services, the incoming TXT record is automatically decoded and attached to the txtRecord property of the service object.

Now, what to put into a TXT record? Let’s start with what not to put in there. You should not put anything in the TXT record that is required to successfully establish a connection to your service. Things like the protocol version should be negotiated in-band whenever possible. Multicast DNS is pretty much a local thing. If your application relies to much on mDNS it will not work in a wide area network. So, just think twice before depending on the TXT record. That said, the TXT record may be used to help with legacy or proprietary protocols. Another application is to convey additional information to the user. Think about a printer dialog. It is very helpful to display the printers location, information about color support &c. before the user makes a choice.

1 This is not entirely accurate. It is possible to use larger TXT records. But you should read the relevant sections of the internet draft before doing so.

"
	
	
]

{ #category : #api }
AReadMeBonjour >> getAddressesNotes [
	"From https://justanapplication.wordpress.com/tag/dnsservicebrowsereply/#start_method

5.2 DNSServiceGetAddrInfo

We can obtain the address of a host using the function DNSServiceGetAddrInfo which is declared like this

    DNSServiceErrorType DNSServiceGetAddrInfo(
                            DNSServiceRef*             sdRef,
                            DNSServiceFlags            flags,
                            uint32_t                   interfaceIndex,
                            DNSServiceProtocol         protocol,
                            const char*                hostname,
                            DNSServiceGetAddrInfoReply callBack,
                            void*                      context);
If the

    kDNSServiceFlagsTimeout
is set in the flags argument then the operation may timeout after a system defined amount of time.

The protocol argument specifies the type of the address requested.

The value should be one of


0

kDNSServiceProtocol_IPv4

kDNSServiceProtocol_IPv6

kDNSServiceProtocol_IPv4|kDNSServiceProtocol_IPv6


A value of 0 (zero) is usually equivalent to requesting both the IPv4 and IPv6 addresses.

The hostname argument should be the absolute name of the host.

5.2.1 The DNSServiceGetAddrInfo Callback Function

The function passed as the callBack argument to DNSServiceGetAddrInfo will be called once for each address type that was requested and is found

It will also be called if the address of the host becomes invalid, e.g., because the host has been turned off.

5.2.2 The DNSServiceGetAddrInfoReply Function Type

The function type DNSServiceGetAddrInfoReply is declared like this

    typedef void (*DNSServiceGetAddrInfoReply)(
                       DNSServiceRef          sdRef,
                       DNSServiceFlags        flags,
                       uint32_t               interfaceIndex,
                       DNSServiceErrorType    errorCode,
                       const char*            hostname,
                       const struct sockaddr* address,
                       uint32_t               ttl,
                       void*                  context);
When a function of this type is invoked, then, if the errorCode argument is kDNSServiceErr_NoError

hostname is the name of the host whose address this is

address is a pointer to its address, and

ttl is the time in seconds for which the given address is valid

The kDNSServiceFlagsAdd flag will be set in the flags argument if the address has been ‘found’, and clear if the address is no longer valid.

The kDNSServiceFlagsMoreComing will be set in the flags argument if there are more addresses, and will be clear if this is the last address.

The type of the address will of course depend upon what what specified as the protocol argument in the call to DNSServiceGetAddrInfo.

If both IPv4 and IPv6 addresses were requested then it will be necessary to examine the sa_family field of the sockaddr struct to find out which one it is.

/* DNSServiceGetAddrInfo() Parameters:
 *
 * sdRef:           A pointer to an uninitialized DNSServiceRef. If the call succeeds then it
 *                  initializes the DNSServiceRef, returns kDNSServiceErr_NoError, and the query
 *                  begins and will last indefinitely until the client terminates the query
 *                  by passing this DNSServiceRef to DNSServiceRefDeallocate().
 *
 * flags:           kDNSServiceFlagsForceMulticast or kDNSServiceFlagsLongLivedQuery.
 *                  Pass kDNSServiceFlagsLongLivedQuery to create a "
	"long-lived"
	" unicast
 *                  query in a non-local domain. Without setting this flag, unicast queries
 *                  will be one-shot - that is, only answers available at the time of the call
 *                  will be returned. By setting this flag, answers (including Add and Remove
 *                  events) that become available after the initial call is made will generate
 *                  callbacks. This flag has no effect on link-local multicast queries.
 *
 * interfaceIndex:  The interface on which to issue the query.  Passing 0 causes the query to be
 *                  sent on all active interfaces via Multicast or the primary interface via Unicast.
 *
 * protocol:        Pass in kDNSServiceProtocol_IPv4 to look up IPv4 addresses, or kDNSServiceProtocol_IPv6
 *                  to look up IPv6 addresses, or both to look up both kinds. If neither flag is
 *                  set, the system will apply an intelligent heuristic, which is (currently)
 *                  that it will attempt to look up both, except:
 *
 *                   * If "
	"hostname"
	" is a wide-area unicast DNS hostname (i.e. not a "
	".local."
	" name)
 *                     but this host has no routable IPv6 address, then the call will not try to
 *                     look up IPv6 addresses for "
	"hostname"
	", since any addresses it found would be
 *                     unlikely to be of any use anyway. Similarly, if this host has no routable
 *                     IPv4 address, the call will not try to look up IPv4 addresses for "
	"hostname"
	".
 *
 *                   * If "
	"hostname"
	" is a link-local multicast DNS hostname (i.e. a "
	".local."
	" name)
 *                     but this host has no IPv6 address of any kind, then it will not try to look
 *                     up IPv6 addresses for "
	"hostname"
	". Similarly, if this host has no IPv4 address
 *                     of any kind, the call will not try to look up IPv4 addresses for "
	"hostname"
	".
 *
 * hostname:        The fully qualified domain name of the host to be queried for.
 *
 * callBack:        The function to be called when the query succeeds or fails asynchronously.
 *
 * context:         An application context pointer which is passed to the callback function
 *                  (may be NULL).
 *
 * return value:    Returns kDNSServiceErr_NoError on success (any subsequent, asynchronous
 *                  errors are delivered to the callback), otherwise returns an error code indicating
 *                  the error that occurred.
 */
"
	
	
]

{ #category : #mDNSResponder }
AReadMeBonjour >> mDNSNetBSD [


"https://man.netbsd.org/mdnsd.8
	
MDNSD(8)                NetBSD System Manager's Manual                MDNSD(8)


NAME

     mdnsd -- Multicast and Unicast DNS daemon


SYNOPSIS

     mdnsd


DESCRIPTION

     mdnsd (also known as mDNSResponder on some systems) is a daemon invoked
     at boot time to implement Multicast DNS and DNS Service Discovery.  On
     Mac OS X 10.6 (Snow Leopard), mdnsd is also the system-wide Unicast DNS
     Resolver.

     mdnsd listens on UDP port 5353 for Multicast DNS Query packets.  When it
     receives a query for which it knows an answer, mdnsd issues the appropri-
     ate Multicast DNS Reply packet.

     mdnsd also performs Unicast and Multicast DNS Queries on behalf of client
     processes, and maintains a cache of the replies.

     mdnsd has no user-specifiable command-line argument, and users should not
     run mdnsd manually.

   LOGGING
     There are several methods with which to examine mdnsd's internal state
     for debugging and diagnostic purposes.  The syslogd(8) logging levels map
     as follows:

           Error - Error messages
           Warning - Client-initiated operations
           Notice - Sleep proxy operations
           Info - Informational messages

     By default, only log level Error is logged.

     A SIGUSR1 signal toggles additional logging, with Warning and Notice
     enabled by default:

           # pkill -USR1 mdnsd

     A SIGUSR2 signal toggles packet logging:

           # pkill -USR2 mdnsd

     A SIGINFO signal will dump a snapshot summary of the internal state to
     /var/log/system.log:

           # pkill -INFO mdnsd


FILES

     /usr/sbin/mdnsd


SEE ALSO

     dns-sd(1), pkill(1), syslogd(8)

     For information on Multicast DNS, see http://www.multicastdns.org/

     For information on DNS Service Discovery, see http://www.dns-sd.org/

     For information on how to use the Multicast DNS and the DNS Service Dis-
     covery APIs on Mac OS X and other platforms, see
     http://developer.apple.com/bonjour/

     For the source code to mdnsd, see
     http://developer.apple.com/darwin/projects/bonjour/


HISTORY

     The mdnsd daemon first appeared in Mac OS X 10.2 (Jaguar).

     Also available from the Darwin open source repository (though not offi-
     cially supported by Apple) are mdnsd daemons for other platforms, includ-
     ing Mac OS 9, Microsoft Windows, Linux, FreeBSD, NetBSD, Solaris, and
     other POSIX systems.
"


]

{ #category : #api }
AReadMeBonjour >> registerNotes [
	"DNSServiceErrorType DNSSD_API DNSServiceRegister
    (
    DNSServiceRef                       *sdRef,
    DNSServiceFlags                     flags,
    uint32_t                            interfaceIndex,
    const char                          *name,         /* may be NULL */
    const char                          *regtype,
    const char                          *domain,       /* may be NULL */
    const char                          *host,         /* may be NULL */
    uint16_t                            port,
    uint16_t                            txtLen,
    const void                          *txtRecord,    /* may be NULL */
    DNSServiceRegisterReply             callBack,      /* may be NULL */
    void                                *context       /* may be NULL */
    );

    /* DNSServiceRegister() Parameters:
 *
 * sdRef:           A pointer to an uninitialized DNSServiceRef. If the call succeeds
 *                  then it initializes the DNSServiceRef, returns kDNSServiceErr_NoError,
 *                  and the registration will remain active indefinitely until the client
 *                  terminates it by passing this DNSServiceRef to DNSServiceRefDeallocate().
 *
 * interfaceIndex:  If non-zero, specifies the interface on which to register the service
 *                  (the index for a given interface is determined via the if_nametoindex()
 *                  family of calls.) Most applications will pass 0 to register on all
 *                  available interfaces. See "
	"Constants for specifying an interface index"
	" for more details.
 *
 * flags:           Indicates the renaming behavior on name conflict (most applications
 *                  will pass 0). See flag definitions above for details.
 *
 * name:            If non-NULL, specifies the service name to be registered.
 *                  Most applications will not specify a name, in which case the computer
 *                  name is used (this name is communicated to the client via the callback).
 *                  If a name is specified, it must be 1-63 bytes of UTF-8 text.
 *                  If the name is longer than 63 bytes it will be automatically truncated
 *                  to a legal length, unless the NoAutoRename flag is set,
 *                  in which case kDNSServiceErr_BadParam will be returned.
 *
 * regtype:         The service type followed by the protocol, separated by a dot
 *                  (e.g. "
	"_ftp._tcp"
	"). The service type must be an underscore, followed
 *                  by 1-14 characters, which may be letters, digits, or hyphens.
 *                  The transport protocol must be "
	"_tcp"
	" or "
	"_udp"
	". New service types
 *                  should be registered at <http://www.dns-sd.org/ServiceTypes.html>.
 *
 *                  Additional subtypes of the primary service type (where a service
 *                  type has defined subtypes) follow the primary service type in a
 *                  comma-separated list, with no additional spaces, e.g.
 *                      "
	"_primarytype._tcp,_subtype1,_subtype2,_subtype3"
	"
 *                  Subtypes provide a mechanism for filtered browsing: A client browsing
 *                  for "
	"_primarytype._tcp"
	" will discover all instances of this type;
 *                  a client browsing for "
	"_primarytype._tcp,_subtype2"
	" will discover only
 *                  those instances that were registered with "
	"_subtype2"
	" in their list of
 *                  registered subtypes.
 *
 *                  The subtype mechanism can be illustrated with some examples using the
 *                  dns-sd command-line tool:
 *
 *                  % dns-sd -R Simple _test._tcp "
	" 1001 &
 *                  % dns-sd -R Better _test._tcp,HasFeatureA "
	" 1002 &
 *                  % dns-sd -R Best   _test._tcp,HasFeatureA,HasFeatureB "
	" 1003 &
 *
 *                  Now:
 *                  % dns-sd -B _test._tcp             # will find all three services
 *                  % dns-sd -B _test._tcp,HasFeatureA # finds "
	"Better"
	" and "
	"Best"
	"
 *                  % dns-sd -B _test._tcp,HasFeatureB # finds only "
	"Best"
	"
 *
 * domain:          If non-NULL, specifies the domain on which to advertise the service.
 *                  Most applications will not specify a domain, instead automatically
 *                  registering in the default domain(s).
 *
 * host:            If non-NULL, specifies the SRV target host name. Most applications
 *                  will not specify a host, instead automatically using the machine's
 *                  default host name(s). Note that specifying a non-NULL host does NOT
 *                  create an address record for that host - the application is responsible
 *                  for ensuring that the appropriate address record exists, or creating it
 *                  via DNSServiceRegisterRecord().
 *
 * port:            The port, in network byte order, on which the service accepts connections.
 *                  Pass 0 for a "
	"placeholder"
	" service (i.e. a service that will not be discovered
 *                  by browsing, but will cause a name conflict if another client tries to
 *                  register that same name). Most clients will not use placeholder services.
 *
 * txtLen:          The length of the txtRecord, in bytes. Must be zero if the txtRecord is NULL.
 *
 * txtRecord:       The TXT record rdata. A non-NULL txtRecord MUST be a properly formatted DNS
 *                  TXT record, i.e. <length byte> <data> <length byte> <data> ...
 *                  Passing NULL for the txtRecord is allowed as a synonym for txtLen=1, txtRecord="
	",
 *                  i.e. it creates a TXT record of length one containing a single empty string.
 *                  RFC 1035 doesn't allow a TXT record to contain *zero* strings, so a single empty
 *                  string is the smallest legal DNS TXT record.
 *                  As with the other parameters, the DNSServiceRegister call copies the txtRecord
 *                  data; e.g. if you allocated the storage for the txtRecord parameter with malloc()
 *                  then you can safely free that memory right after the DNSServiceRegister call returns.
 *
 * callBack:        The function to be called when the registration completes or asynchronously
 *                  fails. The client MAY pass NULL for the callback -  The client will NOT be notified
 *                  of the default values picked on its behalf, and the client will NOT be notified of any
 *                  asynchronous errors (e.g. out of memory errors, etc.) that may prevent the registration
 *                  of the service. The client may NOT pass the NoAutoRename flag if the callback is NULL.
 *                  The client may still deregister the service at any time via DNSServiceRefDeallocate().
 *
 * context:         An application context pointer which is passed to the callback function
 *                  (may be NULL).
 *
 * return value:    Returns kDNSServiceErr_NoError on success (any subsequent, asynchronous
 *                  errors are delivered to the callback), otherwise returns an error code indicating
 *                  the error that occurred (the callback is never invoked and the DNSServiceRef
 *                  is not initialized).
 */

"
	" ctypes.POINTER(DNSServiceRef),	# sdRef
                _DNSServiceFlags,		# flags
                ctypes.c_uint32,		# interfaceIndex
                _utf8_char_p,			# name
                _utf8_char_p_non_null,		# regtype
                _utf8_char_p,			# domain
                _utf8_char_p,			# host
                ctypes.c_uint16,		# port
                ctypes.c_uint16,		# txtLen
                ctypes.c_void_p,		# txtRecord
                _DNSServiceRegisterReply,	# callBack
                ctypes.c_void_p,"
	"DNSServiceErrorType err = DNSServiceRegister(&dnssref,
          0, 0, record.serviceName.toUtf8().constData(),
          record.registeredType.toUtf8().constData(),
          record.replyDomain.isEmpty() ? 0
                    : record.replyDomain.toUtf8().constData(),
          0, bigEndianPort, 0, 0, bonjourRegisterService,
          this);
      if (err != kDNSServiceErr_NoError) {
        emit error(err);
      } else {
        int sockfd = DNSServiceRefSockFD(dnssref);
        if (sockfd == -1) {
          emit error(kDNSServiceErr_Invalid);
        } else {
          bonjourSocket = new QSocketNotifier(sockfd,
                                 QSocketNotifier::Read, this);
          connect(bonjourSocket, SIGNAL(activated(int)),   

DNSServiceRegisterReply
	<C: typedef void (* DNSServiceRegisterReply)(DNSServiceRef sdRef, DNSServiceFlags flags, DNSServiceErrorType errorCode, const char * name, const char * regtype, const char * domain, void * context)>"
	
	
]

{ #category : #api }
AReadMeBonjour >> resolveNotes [
	"https://developer.apple.com/library/mac/documentation/Networking/Conceptual/dns_discovery_api/Articles/resolving.html#//apple_ref/doc/uid/TP40002487-SW1

Using DNSServiceResolve

Once you have the name, registration type, and domain of a service, you can get information about the service, such as the interface(s) on which the service is registered, the full domain name of the service, name of the host that provides the service, and the content of the service’s primary TXT record, by calling DNSServiceResolve.

Warning: DNSServiceResolve is appropriate for getting information about a service that has a single SRV record and a single TXT record (which may be empty). To resolve services that have multiple SRV or TXT records, you should use DNSServiceQueryRecord You should also use DNSServiceQueryRecord to monitor TXT record content instead of DNSServiceResolve.

Mac Developer LibraryDeveloperSearch
DNS Service Discovery Programming Guide
 Table of Contents
Introduction
Registering and Terminating a Service
Browsing for Network Services
Resolving the Current Address of a Service
Enumerating Domains
Using DNS Service Discovery in Windows
Revision History
OTHER REFERENCE
DNS Service Discovery C Reference
RELATED DOCUMENT
Bonjour Overview
NextPrevious
Resolving the Current Address of a Service

This article describes how to use DNSServiceResolve to get information about a service based on its name, type, and domain.

Using DNSServiceResolve

Once you have the name, registration type, and domain of a service, you can get information about the service, such as the interface(s) on which the service is registered, the full domain name of the service, name of the host that provides the service, and the content of the service’s primary TXT record, by calling DNSServiceResolve.

Warning: DNSServiceResolve is appropriate for getting information about a service that has a single SRV record and a single TXT record (which may be empty). To resolve services that have multiple SRV or TXT records, you should use DNSServiceQueryRecord You should also use DNSServiceQueryRecord to monitor TXT record content instead of DNSServiceResolve.
To resolve a service name to its hostname and port, call DNSServiceResolve. The parameters for making this call consist of the following:

An uninitialized service discovery reference
The index of the interface on which you want to resolve the service; pass the value that was passed to your callback function for DNSServiceBrowse, or 0 to resolve on all available interfaces
The service name to be resolved; pass a value that was passed to your callback function for DNSServiceBrowse
The registration type of the service to be resolved; pass the value that was passed to your callback function for DNSServiceBrowse
The domain in which the service is registered; pass the value that was passed to your callback function for DNSServiceBrowse
The callback function that is to be called to provide information on the success or failure of the resolution
A user-defined context value that will be passed to the callback function when it is called, or NULL
If the resolution can be started, DNSServiceResolve initializes the service discovery reference and creates a socket that is used to communicate with the mDNSResponder daemon. Use the service discovery reference to call DNSServiceRefSockFD and get the socket descriptor for the socket.

Setting Up a Callback Function

If DNSServiceResolve returns error-free, you need to have mDNSResponder resolve the service discovery reference and run a callback function when it has received a response. There are two techniques to set up the callback function: asynchronously and synchronously.

To get a response from mDNSResponder asynchronously, set up a run or a select loop using the socket descriptor. The loop will be notified whenever a response from the mDNSResponder daemon becomes available. When the loop indicates that a response is available, call DNSServiceProcessResult and pass to it the service discovery reference initialized by DNSServiceResolve. DNSServiceProcessResult will call the callback function associated with the service discovery reference. The mDNSResponder daemon will provide a response for each service that it resolves on a per-interface basis.

If you want to run the callback function synchronously instead of setting up a run loop or a select loop, you can call DNSServiceResolve and immediately call DNSServiceProcessResult. The DNSServiceProcessResult function will block until the mDNSResponder daemon has a response, at which time the callback specified when DNSServiceResolve was called will be invoked. This entire process should probably be run within a loop of its own for each service you wish to resolve.

In addition to the service discovery reference and flags that are not currently used, your callback will be called with the following parameters:

The interface index on which the service was resolved; use the if_nametoindex family of calls to relate the index to an interface name
An error code that indicates whether the resolution was successful; if the resolution was successful, the remaining parameters contain valid data
The full domain name of the service, suitable for passing to special purpose functions that take a full domain name as a parameter
The hostname of the machine that provides the service, suitable for passing to gethostbyname or DNSServiceQueryRecord to get the host’s IP address
The port number in network byte order on which the service accepts connections
The length of the TXT record for the service
The primary TXT record for the service in standard TXT record format (that is, a length byte followed by data, followed by a length byte, followed by data, and so on)
The user-defined context information that was passed to DNSServiceResolve
Important: The service's IP addresses and port numbers can change dynamically, so you should get the current address each time you use a service, just prior to using it.
Your run loop or select loop will be notified for each interface on which the service is resolved and for each TXT record associated with the service.

When the desired results have been obtained, you must terminate the resolution. Remove the socket descriptor from the run loop or the select loop and call DNSServiceRefDeallocate, passing to it the service discovery reference that was initialized when DNSServiceResolve was called. The service discovery reference is invalidated, and memory associated with the reference is deallocated. The socket that underlies the connection with the mDNSResponder daemon is closed, thereby terminating your application’s connection with the daemon.
"
	
	
]

{ #category : #api }
AReadMeBonjour >> sdRefNotes [
	"When a function call is made to the mdns api you pass in the address of your callback function and the address of an unitialized DNSServiceRef. 
	After the function call has started the operation and initialize the DNSServceRef, you can extract the underlying file descriptor to add it to your select() loop. 
	Each time the mdnsd daemon responds, your select() loop will wake up, you call DNSServiceProcessResult(), and that calls your callback function for you.
	
	sdRef is initially supposed to be a pointer to an uninitialised DNSServiceRef that is passed to the callout function for initialisation.
	The callout function is passed the result of CVoidType void pointerType malloc = a CPointer {03873AD8} (void * *), 
	the contents/referent of which is a CPointer {01541060} (void *). [A pointer to a pointer?]. Some functions require this as an argument.
	The callback sdRef is a CCompositePointer {0141060) {struct _DNSServiceRef_t *} - this is what is required to pass to the deallocation function.	
	Not sure if this is the correct way to do this regarding C, but it works!	
	"
	
	
]

{ #category : #api }
AReadMeBonjour >> serviceTypeNotes [
	"From https://developer.apple.com/library/prerelease/content/documentation/Cocoa/Conceptual/NetServices/Articles/domainnames.html

	Bonjour services are named according to the existing Internet standard for IP services (described in RFC 2782). Bonjour service names combine service types and transport protocols to form a registration type. The registration type is used to register a service and create DNS resource records for it. To distinguish registration types from domain names in DNS resource records, registration types use underscore prefixes to separate the components that make up a registration type. The format is

_ServiceType._TransportProtocolName.

The service type is the official IANA-registered name for the service, for example, ftp, http or printer. The transport protocol name is tcp or udp, depending on the transport protocol the service uses. An FTP service running over TCP would have a registration type of _ftp._tcp. and would register a DNS PTR record named _ftp._tcp.local. with its hosts’ Multicast DNS responder. "
	
	
]

{ #category : #api }
AReadMeBonjour >> txtRecordNotes [
	"
See http://www.zeroconf.org/Rendezvous/txtrecords.html regarding OSX CStrings.	
	
From https://developer.apple.com/reference/dnssd/1804733-dnsserviceregister
txtLen	
The length of the txtRecord, in bytes. Must be zero if the txtRecord is NULL.
txtRecord	
The TXT record rdata. A non-NULL txtRecord MUST be a properly formatted DNS TXT record, i.e. <length byte> <data> <length byte> <data> ... Passing NULL for the txtRecord is allowed as a synonym for txtLen=1, txtRecord="
	", i.e. it creates a TXT record of length one containing a single empty string. RFC 1035 doesn't allow a TXT record to contain *zero* strings, so a single empty string is the smallest legal DNS TXT record. As with the other parameters, the DNSServiceRegister call copies the txtRecord data; e.g. if you allocated the storage for the txtRecord parameter with malloc() then you can safely free that memory right after the DNSServiceRegister call returns.


From http://agnat.github.io/node_mdns/user_guide.html

	TXT Records
Each service has an associated DNS TXT record. The application can use it to publish a small amount of metadata. The record contains key-value pairs. The keys must be all printable ascii characters excluding ‘=’. The value may contain any data.

The TXT record is passed to the Advertisement as an object:

var txt_record = {
    name: 'bacon'
  , chunky: true
  , strips: 5
};
var ad = mdns.createAdvertisement(mdns.tcp('http'), 4321, {txtRecord: txt_record});
Non-string values are automatically converted. Buffer objects as values work too.

The size of the TXT record is very limited. That is because everything has to fit into a single DNS message (512 bytes)1. The documentation mentions a “typical size” of 100-200 bytes, whatever that means. There also is a hard limit of 255 bytes for each key-value pair. That’s why they also recommend short keys (9 bytes max). The bottom line is: Keep it brief.

DNS distinguishes between keys with no value and keys with an empty value:

var record = {
    empty: ''
  , just_a_flag: null // or undefined
};
When browsing for services, the incoming TXT record is automatically decoded and attached to the txtRecord property of the service object.

Now, what to put into a TXT record? Let’s start with what not to put in there. You should not put anything in the TXT record that is required to successfully establish a connection to your service. Things like the protocol version should be negotiated in-band whenever possible. Multicast DNS is pretty much a local thing. If your application relies to much on mDNS it will not work in a wide area network. So, just think twice before depending on the TXT record. That said, the TXT record may be used to help with legacy or proprietary protocols. Another application is to convey additional information to the user. Think about a printer dialog. It is very helpful to display the printers location, information about color support &c. before the user makes a choice.

1 This is not entirely accurate. It is possible to use larger TXT records. But you should read the relevant sections of the internet draft before doing so."
	
	
]

{ #category : #utilities }
AReadMeBonjour >> utilities [
	"
	Note: Bonjour SDK is in both Program Files and Program Files (x86)
	Run dns-sd from command line. - see dnssdNotes
	Run monitor - C:\Program Files (x86)\Bonjour SDK\Bin\mDNSNetMonitor.exe
	Run C:\Program Files (x86)\Bonjour SDK\Bin\mDNSNetMonitor.exe
	Mark Nelson - Mark's article kick started this development - thanks Mark!	
		utility: C:\Knowledge Base\ZeroConf\API dnssd\ServiceBrowser.exe
		http://marknelson.us/2011/10/25/dns-service-discovery-on-windows/
	Or the app/program Discovery.

	
	Links to general information:
	http://www.smallegan.com/blog/2005/06/09/dns-based-service-discovery-dnssd/
	
	"
	
	
]
