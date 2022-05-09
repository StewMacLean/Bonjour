Class {
	#name : #BonjourLibraryInterface,
	#superclass : #BonjourInterface,
	#category : #'SIM-Bonjour'
}

{ #category : #constants }
BonjourLibraryInterface >> addressFrom: aCPointer [
	
	| array stream |
	array := aCPointer contents datum asByteArray copyFrom: 5 to: 8.
	stream := String new writeStream.
	array
		do: [:each | stream nextPutAll: each printString]
		separatedBy: [stream nextPut: $.].
	^stream contents
]

{ #category : #constants }
BonjourLibraryInterface >> addressFromv1: aCPointer [
	
	| array stream |
	aCPointer
		copyAt: 0
		to: (array := ByteArray new: 4)
		size: 4
		startingAt: 1.
	stream := String new writeStream.
	array
		do: [:each | stream nextPutAll: each printString]
		separatedBy: [stream nextPut: $.].
	^stream contents
]

{ #category : #callouts }
BonjourLibraryInterface >> browseSDRef: sdRef flags: flags interfaceIndex: interfaceIndex registrationType: regtype domain: domain callback: callback context: context [
	"When you first start browsing, all the callbacks will be for services added. 
	As services are added and removed from the system, additional callbacks will be generated with this bit both set and cleared."
	
	| result |
	"
	DNSServiceRef             		*sdRef,
	DNSServiceFlags     		flags,
    	uint32_t                           	interfaceIndex,
    	const char                          	*regtype,
    	const char                          	*domain,    /* may be NULL */
    	DNSServiceBrowseReply  	callBack,
    	void                          		*context    /* may be NULL */
	"
	calloutMutex criticalReleasingOnError: 
		[result := interface DNSServiceBrowse: sdRef with: flags with:
				interfaceIndex with: regtype with: domain with: callback with: context.
		self checkResult: result for: 'DNSServiceBrowse']	"/* DNSServiceBrowse() Parameters:
 *
 * sdRef:           A pointer to an uninitialized DNSServiceRef. If the call succeeds
 *                  then it initializes the DNSServiceRef, returns kDNSServiceErr_NoError,
 *                  and the browse operation will run indefinitely until the client
 *                  terminates it by passing this DNSServiceRef to DNSServiceRefDeallocate().
 *
 * flags:           Currently ignored, reserved for future use.
 *
 * interfaceIndex:  If non-zero, specifies the interface on which to browse for services
 *                  (the index for a given interface is determined via the if_nametoindex()
 *                  family of calls.) Most applications will pass 0 to browse on all available
 *                  interfaces. See "	"Constants for specifying an interface index"	" for more details.
 *
 * regtype:         The service type being browsed for followed by the protocol, separated by a
 *                  dot (e.g. "	"_ftp._tcp"	"). The transport protocol must be "	"_tcp"	" or "	"_udp"	".
 *                  A client may optionally specify a single subtype to perform filtered browsing:
 *                  e.g. browsing for "	"_primarytype._tcp,_subtype"	" will discover only those
 *                  instances of "	"_primarytype._tcp"	" that were registered specifying "	"_subtype"	"
 *                  in their list of registered subtypes.
 *
 * domain:          If non-NULL, specifies the domain on which to browse for services.
 *                  Most applications will not specify a domain, instead browsing on the
 *                  default domain(s).
 *
 * callBack:        The function to be called when an instance of the service being browsed for
 *                  is found, or if the call asynchronously fails.
 *
 * context:         An application context pointer which is passed to the callback function
 *                  (may be NULL).
 *
 * return value:    Returns kDNSServiceErr_NoError on success (any subsequent, asynchronous
 *                  errors are delivered to the callback), otherwise returns an error code indicating
 *                  the error that occurred (the callback is not invoked and the DNSServiceRef
 *                  is not initialized).
 */

DNSServiceErrorType DNSSD_API DNSServiceBrowse
    (
    DNSServiceRef                       *sdRef,
    DNSServiceFlags                     flags,
    uint32_t                            interfaceIndex,
    const char                          *regtype,
    const char                          *domain,    /* may be NULL */
    DNSServiceBrowseReply               callBack,
    void                                *context    /* may be NULL */
    );"
]

{ #category : #api }
BonjourLibraryInterface >> browseServiceTypes [
	
	| flags interfaceIndex regtype domain context callback sdRef connectionSV connectionID |

	sdRef := ExternalAddress new.
	connectionID := self nextConnectionID.
	flags := 0.
	interfaceIndex := interface kDNSServiceInterfaceIndexAny.	"0"
	regtype := '_services._dns-sd._udp' utf8Encoded.
	domain := '' utf8Encoded.
	context := nil.
	callback := 
		"interface newCallbackWithSignature: interface DNSServiceBrowseReply"
		FFICallback signature: interface DNSServiceBrowseReply
		block:
			[:sdRefCB :flagsCB :interfaceIndexCB :errorCodeCB :serviceNameCB :regtypeCB :domainCB :contextCB | 
			| sv stream protocol object |
			self log: '<== ServiceType Add/Remove: ', serviceNameCB, ' interface: ', interfaceIndexCB printString.
			connectionSV sdRef: sdRefCB.	"The actual service discovery reference that was initialized by DNSServiceBrowse that is used to deallocate."
			(sv := StateVector new)
				id: connectionID;
				flags: flagsCB;
				isMoreComing: (self isMoreComing: flagsCB);
				interfaceIndex: interfaceIndexCB printString;
				name: serviceNameCB "utf8Decoded" "readStringUTF8" "asStringFromUnicodeStringOnHeap";
				registrationType: regtypeCB "copyCStringFromHeap";
				domain: domainCB "copyCStringFromHeap".	"sv registrationType = '_osc._udp.' ifTrue: [self halt]."
			(self isAdd: sv flags)
				ifTrue: [sv event: 'Added']
				ifFalse: [sv event: 'Removed'].
			stream := ReadStream on: sv registrationType.
			protocol := stream through: $..
			object := ServiceType new
				name: sv name;
				protocol: protocol;
				domain: sv domain;
				interfaceIndex: sv interfaceIndex.
			sv object: object.	
			callbackQueue nextPut: sv.
			nil].
	"Initializes sdRef..."

	self log: '==> Browse Service Types...'.
	self browseSDRef: sdRef flags: flags interfaceIndex: interfaceIndex
		registrationType: regtype domain: domain callback: callback context:
			context.	"Fire off callbacks..."	"Note: - Need to hang on to callback, otherwise they don't fire"
	connectionSV := StateVector new
		id: connectionID;
		sdRef: sdRef;
		name: 'Browse Service Types: ' , regtype;
		callback: callback.
	self waitForSeconds: 1.
	"NOTE: should use:
	self openResultsStreamOn: sdRef stateVector: connectionSV
	but using the call in same process, as it seems to freeze less when in blocking mode."
	self serviceProcessResult: sdRef.
	
]

{ #category : #api }
BonjourLibraryInterface >> browseServicesOf: aServiceType [
	
	| flags interfaceIndex regtype domain context callback sdRef connectionSV connectionID |
	
	sdRef := ExternalAddress new.
	connectionID := self nextConnectionID.
	flags := 0.
	interfaceIndex := interface kDNSServiceInterfaceIndexAny.	"0"
	regtype := aServiceType registrationType utf8Encoded.
	domain := '' utf8Encoded.
	context := nil.
	callback := 
		"interface newCallbackWithSignature: interface DNSServiceBrowseReply"
		FFICallback signature: interface DNSServiceBrowseReply
		block:
			[:sdRefCB :flagsCB :interfaceIndexCB :errorCodeCB :serviceNameCB :regtypeCB :domainCB :contextCB | 
			| sv object |
			"self halt."
			self log: '<== Service Added/Removed: ', serviceNameCB.
			connectionSV sdRef: sdRefCB.	"The actual service discovery reference that was initialized by DNSServiceBrowse that is used to deallocate."
			(sv := StateVector new)
				id: connectionID;
				flags: flagsCB;
				isMoreComing: (self isMoreComing: flagsCB);
				interfaceIndex: interfaceIndexCB printString;
				name: serviceNameCB "asStringFromUnicodeStringOnHeap";
				registrationType: regtypeCB "copyCStringFromHeap";
				domain: domainCB "copyCStringFromHeap".	"sv registrationType = '_osc._udp.' ifTrue: [self halt]."
			(self isAdd: sv flags)
				ifTrue: [sv event: 'Added']
				ifFalse: [sv event: 'Removed'].	"Transcript cr; show: 'Call back with '; cr; show: sv printString."
			object := (Service new)
				name: sv name;
				domain: sv domain;
				serviceType: (connections at: connectionID) serviceType.
			sv object: object.	"self log: 'CALLBACK Service'."
			callbackQueue nextPut: sv.
			nil].
	"Initializes sdRef..."
	
	self log: '==> Browse Services of type ', aServiceType registrationType.
	"doHalts ifTrue: [self halt]."
	self browseSDRef: sdRef flags: flags interfaceIndex: interfaceIndex
		registrationType: regtype domain: domain callback: callback context:
			context.	"Fire off callbacks..."
	connectionSV := StateVector new
		id: connectionID;
		sdRef: sdRef;
		name: 'Browse Services of type: ' , regtype;
		serviceType: aServiceType;
		callback: callback.

	(#('_rdlink._tcp.' '_rdlink._udp.') includes: aServiceType registrationType) "These block as none exist."
		ifTrue: [self log: 'Skipping getting services of service type _rdlink' ]
		ifFalse: [self openResultsStreamOn: sdRef stateVector: connectionSV]
]

{ #category : #'error handling' }
BonjourLibraryInterface >> checkResult: result for: call [
	"Removed coercion of result, as change int32_t type in external interface from void to long, as it should be.
	Note: needed to recompile external methods after changing the definition of the error code type."
	
	| errorCode |
	(errorCode := result) = self noError
		ifFalse:
			[self
				error:
					call , ' error: '
						,
							((interface DNSServiceErr keyAtValue: errorCode)
								ifNotNil: [:value | value asString]
								ifNil: ['- unknown - ']) , ' (' , errorCode printString , ')']	"asSigned32Integer"
]

{ #category : #callouts }
BonjourLibraryInterface >> daemonVersion [
	"
	self new daemonVersion = (LibC resultOfCommand: 'dns-sd -V') substrings last
	
	See daemonVersionNotes for api.
	"
	
	| versionPointer sizePointer version major minor patch property result |
	
	[versionPointer := FFIUInt32 newBuffer.
	sizePointer := (FFIExternalType sizeOf: FFIUInt32).
	property := interface kDNSServiceProperty_DaemonVersion.
	result := interface 
		DNSServiceGetProperty: property 
		with: versionPointer
		with: sizePointer.
	result asInteger = self noError  
		ifFalse: [self error: 'DNSServiceGetProperty (version) failed'].
	version := versionPointer unsignedLongAt: 1.
	major := version // 10000.
	minor := version // 100 \\ 100.
	patch := version \\ 100.
	^major printString , '.' , minor printString, '.', patch printString]
		ensure: []
]

{ #category : #callouts }
BonjourLibraryInterface >> deallocateSDRef: sdRef [
	
	calloutMutex criticalReleasingOnError: 
		[[self log: '==> Deallocating ' , sdRef printString.	"true ifTrue: [^self]."
		interface DNSServiceRefDeallocate: sdRef]
			on: Error
			do: [:ex | ]]	"no error checking - result is nil/void"
]

{ #category : #api }
BonjourLibraryInterface >> getAddressesOf: aService [
	
	| flags interfaceIndex context callback sdRef hostNameutf8 protocol connectionSV connectionID |

	sdRef := ExternalAddress new.
	connectionID := self nextConnectionID.
	flags := 0.	"Note, can set to timeout via flags"
	interfaceIndex := interface kDNSServiceInterfaceIndexAny.	"0"
	protocol := 0.	"requesting both the IPv4 and IPv6 addresses"
	hostNameutf8 := aService hostName utf8Encoded.
	context := nil.	
	callback := 
		"interface newCallbackWithSignature: interface DNSServiceGetAddrInfoReply"
		FFICallback signature: interface DNSServiceGetAddrInfoReply
		block:
			[:sdRefCB :flagsCB :interfaceIndexCB :errorCodeCB :hostNameCB :addressCB :timeValidCB :contextCB | 
			| sv |
			self log: '<== Address of Service : ', aService printString.
			(sv := StateVector new)
				id: connectionID;
				sdRef: sdRefCB;
				flags: flagsCB;
				isMoreComing: (self isMoreComing: flagsCB);
				interfaceIndex: interfaceIndexCB;
				hostName: hostNameCB "copyCStringFromHeap";
				address: (self addressFrom: addressCB).	"address: (self addressFrom: (addressCB memberAt: #sin_addr))."	"port: (self portFrom: (addressCB memberAt: #sin_port)).  - returns a zero port, looked at mDNSResponder code to verify, use port from resolve"
			sv
				event: 'ServiceAddress';
				object: (connections at: connectionID) service.	"self log: 'CALLBACK: - Get Addresses', sv printString."
			callbackQueue nextPut: sv.
			nil].
	"Initializes sdRef..."
	self log: '==> Get addresses of: ', aService printString.
	self getAddressesSDRef: sdRef flags: flags interfaceIndex: interfaceIndex
		protocol: protocol hostName: hostNameutf8 callback: callback context:
			context.	"Fire off callbacks..."
	connectionSV := StateVector new
		id: connectionID;
		sdRef: sdRef;
		name: 'Get Addresses of service ', aService printString;
		service: aService;
		callback: callback.
		
	self openResultsStreamOn: sdRef stateVector: connectionSV
]

{ #category : #callouts }
BonjourLibraryInterface >> getAddressesSDRef: sdRef flags: flags interfaceIndex: interfaceIndex protocol: protocol hostName: hostName callback: callback context: context [
	
	| result |
	
	calloutMutex criticalReleasingOnError: 
		[result := interface DNSServiceGetAddrInfo: sdRef with: flags with:
				interfaceIndex with: protocol with: hostName with: callback with:
				context.
		self checkResult: result for: 'DNSServiceBrowse']
]

{ #category : #constants }
BonjourLibraryInterface >> isAdd: flags [
	
	^(flags bitAnd: self kDNSServiceFlagsAdd) ~= 0
]

{ #category : #constants }
BonjourLibraryInterface >> isMoreComing: flags [
	
	^(flags bitAnd: self kDNSServiceFlagsMoreComing) ~= 0
]

{ #category : #constants }
BonjourLibraryInterface >> isRemove: flags [
	"No explicit flag - just not of Add - as per dsn-sd.c code "
	
	^(self isAdd: flags) not
]

{ #category : #constants }
BonjourLibraryInterface >> kDNSServiceFlagsAdd [
	
	^interface DNSServiceFlagsEnum at: #kDNSServiceFlagsAdd
]

{ #category : #constants }
BonjourLibraryInterface >> kDNSServiceFlagsMoreComing [
	
	^interface DNSServiceFlagsEnum at: #kDNSServiceFlagsMoreComing
]

{ #category : #constants }
BonjourLibraryInterface >> kDNSServiceFlagsNoAutoRename [
	
	^interface DNSServiceFlagsEnum at: #kDNSServiceFlagsNoAutoRename
]

{ #category : #constants }
BonjourLibraryInterface >> kDNSServiceFlagsShareConnection [
	
	^interface DNSServiceFlagsEnum at:
			#kDNSServiceFlagsShareConnection
]

{ #category : #constants }
BonjourLibraryInterface >> noError [
	
	^interface DNSServiceErr at: #kDNSServiceErr_NoError
]

{ #category : #'_testing' }
BonjourLibraryInterface >> openApp [

	"
	LibC runCommand:  'echo sim123 | sudo -S killall –HUP mDNSResponder'.
	LibC runCommand:  'echo sim123 | sudo -S killall –HUP mDNSHelper'.
	
	self current.
	BonjourLibraryInterface allInstances do: [: each | each shutDown].
	BonjourLibraryInterface allInstances do: [: each | each become: Object new].
	BonjourLibraryInterface resetCurrent.
	BonjourLibraryInterface shutDown.
	SpaceTally new printSpaceAnalysis
	"

	<script: 'self new openApp'>

	^DiscoveryApp openOn: self class uniqueInstance
		
	
]

{ #category : #'data streams' }
BonjourLibraryInterface >> openResultsStreamOn: sdRef stateVector: sv [
	
	| pump connectionID label worker | 
	
	connectionID := sv id.
	label := 'Pump ', connectionID, ' ', sv name, ' sdRef: ', sdRef printString.
	self waitForSeconds: 1 for: 'Spawning ', label.
	"worker := TFWorker named: 'QUEUE'."
	pump := 
		[self log:  'Opening ', label.
		
		[true]
			whileTrue:
				["TFProcessLocalWorker worker: worker."
				self log: '==> ', label.
				"Threaded call so doesn't block Smalltalk engine"
				"This blocks until data is available. When it unblocks it fires off one or more callbacks"
				"self doHalt."
				self serviceProcessResult: sdRef. "Works for non threaded, crashes threaded"
				"result := interface DNSServiceProcessResult: (sdRef pointerAt: 1)." "answers a null pointer -> BadParam"
				"result := interface DNSServiceProcessResult: sdRef pointer." "Answers a pointer -> BadReference"
				self log: '==>|<== RETURNED ', label.
				"UIManager default alert: sv printString."
				"self halt."]]
					newProcess.
	connections
		at: connectionID
		put: (sv pump: pump).	"UserBackgroundPriority := 30.  userBackgroundPriority
	UserSchedulingPriority := 50. userSchedulingPriority"
	
	^pump
		name: label;
		priority: 50;
		resume	"priority: Processor userInterruptPriority;"
]

{ #category : #constants }
BonjourLibraryInterface >> portFrom: aCPointer [
	
	| array |
	aCPointer
		copyAt: 0
		to: (array := ByteArray new: 2)
		size: 2
		startingAt: 1.
	^array reverse asInteger	"Convert from network byte order"
]

{ #category : #constants }
BonjourLibraryInterface >> promiseTimeout [
	
	^5000000
]

{ #category : #api }
BonjourLibraryInterface >> register: aService [
	
	| flags interfaceIndex regtype context callback sdRef nameutf8 textLength textRecord domain hostName portNetworkByteOrder connectionSV connectionID |

	sdRef := ExternalAddress new.
	connectionID := self nextConnectionID.
	aService sdRef: sdRef.	"Need to hang onto this to use for deregistering"
	flags := 0.	"No renaming"
	interfaceIndex := interface kDNSServiceInterfaceIndexAny.	"0"	"All available"	"aService registrationType = '_osc._udp.' ifTrue: [self halt]."
	nameutf8 := aService name utf8Encoded.
	regtype := aService registrationType utf8Encoded.
	domain := nil.	"Default domains"
	hostName := nil.	"Use the machine's default host name(s)."
	portNetworkByteOrder := aService port reverseByteOrderSIM.
	textLength := aService textLengthFromTextRecordPairs.	"0."
	textRecord := aService textRecordLibraryCalloutParameter.	" nil."
	callback := 
		"interface newCallbackWithSignature: interface DNSServiceRegisterReply"
		FFICallback signature: interface DNSServiceRegisterReply
		block:
			[:sdRefCB :flagsCB :errorCodeCB :nameCB :regtypeCB :domainCB :contextCB | 
			| sv |
			self log: '<== Service Registered: ', aService printString.
			aService sdRef: sdRefCB.	"The actual service discovery reference that was initialized by DNSServiceBrowse that is used to deallocate."
			(sv := StateVector new)
				id: connectionID;
				domain: domainCB "copyCStringFromHeap";
				event: 'ServiceRegistered';
				object: aService.
			aService domain: sv domain.
			callbackQueue nextPut: sv.	
			nil].
	context := nil.	"Initializes sdRef..."
		
	self log: '==> Register Service: ', aService printString.
	self registerSDRef: sdRef flags: flags interfaceIndex: interfaceIndex
		name: nameutf8 registrationType: regtype domain: domain hostName:
			hostName port: portNetworkByteOrder textLength: textLength textRecord:
			textRecord callback: callback context: context.	"Fire off callbacks..."
	connectionSV := StateVector new
		id: connectionID;
		sdRef: sdRef;
		name: 'Register service ', aService printString;
		service: aService;
		callback: callback.

	self openResultsStreamOn: sdRef stateVector: connectionSV
]

{ #category : #callouts }
BonjourLibraryInterface >> registerSDRef: sdRef flags: flags interfaceIndex: interfaceIndex name: name registrationType: regtype domain: domain hostName: host port: port textLength: txtLen textRecord: txtRecord callback: callback context: context [
	
	| result |
	
	calloutMutex criticalReleasingOnError: 
		[result := interface DNSServiceRegister: sdRef with: flags with:
				interfaceIndex with: name with: regtype with: domain with: host with:
				port with: txtLen with: txtRecord with: callback with: context.
		self checkResult: result for: 'DNSServiceRegister']
]

{ #category : #api }
BonjourLibraryInterface >> resolve: aService [
	
	| flags interfaceIndex regtype context callback sdRef domainutf8 nameutf8 connectionSV connectionID |

	sdRef := ExternalAddress new.
	connectionID := self nextConnectionID.
	flags := 0.
	interfaceIndex := interface kDNSServiceInterfaceIndexAny.	"0"
	nameutf8 := aService name utf8Encoded.	"Note the header documentation is incorrect - it says full service name, only need the name"
	regtype := aService registrationType utf8Encoded.
	domainutf8 := aService domain utf8Encoded.
	context := nil.	
	callback := 
		"interface newCallbackWithSignature: interface DNSServiceResolveReply"
		FFICallback signature: interface DNSServiceResolveReply
		block:
			[:sdRefCB :flagsCB :interfaceIndexCB :errorCodeCB :nameCB :hostCB :portCB :textLengthCB :textRecordCB :contextCB | 
			| sv |
			self log: '<== Service Resolved: ', aService printString.
			aService sdRef: sdRefCB.	"The actual service discovery reference that was initialized by DNSServiceBrowse that is used to deallocate."
			(sv := StateVector new)
				id: connectionID;
				sdRef: sdRefCB;
				flags: flagsCB;
				isMoreComing: (self isMoreComing: flagsCB);
				interfaceIndex: interfaceIndexCB;
				name: nameCB "asStringFromUnicodeStringOnHeap";
				hostName: hostCB "copyCStringFromHeap";
				port: portCB reverseByteOrderSIM asString;
				textLength: textLengthCB;
				textRecord: textRecordCB "copyCStringFromHeap".
			sv
				event: 'ServiceResolved';
				object: (connections at: connectionID) service.
			callbackQueue nextPut: sv.
			nil].
	"Initializes sdRef..."
	self log: '==> Resolve Service: ', aService printString.
	self resolveSDRef: sdRef flags: flags interfaceIndex: interfaceIndex name:
			nameutf8 registrationType: regtype domain: domainutf8 callback: callback
		context: context.	"Fire off callbacks..."
	connectionSV := StateVector new
		id: connectionID;
		sdRef: sdRef;
		name: 'Resolve service ', aService printString;
		service: aService;
		callback: callback.
		
	self openResultsStreamOn: sdRef stateVector: connectionSV
]

{ #category : #callouts }
BonjourLibraryInterface >> resolveSDRef: sdRef flags: flags interfaceIndex: interfaceIndex name: name registrationType: regtype domain: domain callback: callBack context: context [
	"Once you have the name, registration type, and domain of a service, you can get information about the service, such as the interface(s) on which the service is registered, the full domain name of the service, name of the host that provides the service, and the content of the service’s primary TXT record, by calling DNSServiceResolve."
	"DNSServiceErrorType DNSSD_API DNSServiceResolve
    (
    DNSServiceRef                       *sdRef,
    DNSServiceFlags                     flags,
    uint32_t                            interfaceIndex,
    const char                          *name,
    const char                          *regtype,
    const char                          *domain,
    DNSServiceResolveReply              callBack,
    void                                *context  /* may be NULL */
    );"
	
	| result |
	
	calloutMutex criticalReleasingOnError: 
		[result := interface DNSServiceResolve: sdRef with: flags with:
				interfaceIndex with: name with: regtype with: domain with: callBack
			with: context.
		self checkResult: result for: 'DNSServiceResolve']	"	/* DNSServiceResolve()
 *
 * Resolve a service name discovered via DNSServiceBrowse() to a target host name, port number, and
 * txt record.
 *
 * Note: Applications should NOT use DNSServiceResolve() solely for txt record monitoring - use
 * DNSServiceQueryRecord() instead, as it is more efficient for this task.
 *
 * Note: When the desired results have been returned, the client MUST terminate the resolve by calling
 * DNSServiceRefDeallocate().
 *
 * Note: DNSServiceResolve() behaves correctly for typical services that have a single SRV record
 * and a single TXT record. To resolve non-standard services with multiple SRV or TXT records,
 * DNSServiceQueryRecord() should be used.
 *
 * DNSServiceResolveReply Callback Parameters:
 *
 * sdRef:           The DNSServiceRef initialized by DNSServiceResolve().
 *
 * flags:           Possible values: kDNSServiceFlagsMoreComing
 *
 * interfaceIndex:  The interface on which the service was resolved.
 *
 * errorCode:       Will be kDNSServiceErr_NoError (0) on success, otherwise will
 *                  indicate the failure that occurred. Other parameters are undefined if
 *                  the errorCode is nonzero.
 *
 * fullname:        The full service domain name, in the form <servicename>.<protocol>.<domain>.
 *                  (This name is escaped following standard DNS rules, making it suitable for
 *                  passing to standard system DNS APIs such as res_query(), or to the
 *                  special-purpose functions included in this API that take fullname parameters.
 *                  See "	"Notes on DNS Name Escaping"	" earlier in this file for more details.)
 *
 * hosttarget:      The target hostname of the machine providing the service. This name can
 *                  be passed to functions like gethostbyname() to identify the host's IP address.
 *
 * port:            The port, in network byte order, on which connections are accepted for this service.
 *
 * txtLen:          The length of the txt record, in bytes.
 *
 * txtRecord:       The service's primary txt record, in standard txt record format.
 *
 * context:         The context pointer that was passed to the callout.
 *
 * NOTE: In earlier versions of this header file, the txtRecord parameter was declared "	"const char *"	"
 * This is incorrect, since it contains length bytes which are values in the range 0 to 255, not -128 to +127.
 * Depending on your compiler settings, this change may cause signed/unsigned mismatch warnings.
 * These should be fixed by updating your own callback function definition to match the corrected
 * function signature using "	"const unsigned char *"	"txtRecord"	". Making this change may also fix inadvertent
 * bugs in your callback function, where it could have incorrectly interpreted a length byte with value 250
 * as being -6 instead, with various bad consequences ranging from incorrect operation to software crashes.
 * If you need to maintain portable code that will compile cleanly with both the old and new versions of
 * this header file, you should update your callback function definition to use the correct unsigned value,
 * and then in the place where you pass your callback function to DNSServiceResolve(), use a cast to eliminate
 * the compiler warning, e.g.:
 *   DNSServiceResolve(sd, flags, index, name, regtype, domain, (DNSServiceResolveReply)MyCallback, context);
 * This will ensure that your code compiles cleanly without warnings (and more importantly, works correctly)
 * with both the old header and with the new corrected version.
 *
 */

typedef void (DNSSD_API *DNSServiceResolveReply)
    (
    DNSServiceRef                       sdRef,
    DNSServiceFlags                     flags,
    uint32_t                            interfaceIndex,
    DNSServiceErrorType                 errorCode,
    const char                          *fullname,
    const char                          *hosttarget,
    uint16_t                            port,
    uint16_t                            txtLen,
    const unsigned char                 *txtRecord,
    void                                *context
    );


/* DNSServiceResolve() Parameters
 *
 * sdRef:           A pointer to an uninitialized DNSServiceRef. If the call succeeds
 *                  then it initializes the DNSServiceRef, returns kDNSServiceErr_NoError,
 *                  and the resolve operation will run indefinitely until the client
 *                  terminates it by passing this DNSServiceRef to DNSServiceRefDeallocate().
 *
 * flags:           Specifying kDNSServiceFlagsForceMulticast will cause query to be
 *                  performed with a link-local mDNS query, even if the name is an
 *                  apparently non-local name (i.e. a name not ending in "	".local."	")
 *
 * interfaceIndex:  The interface on which to resolve the service. If this resolve call is
 *                  as a result of a currently active DNSServiceBrowse() operation, then the
 *                  interfaceIndex should be the index reported in the DNSServiceBrowseReply
 *                  callback. If this resolve call is using information previously saved
 *                  (e.g. in a preference file) for later use, then use interfaceIndex 0, because
 *                  the desired service may now be reachable via a different physical interface.
 *                  See "	"Constants for specifying an interface index"	" for more details.
 *
 * name:            The name of the service instance to be resolved, as reported to the
 *                  DNSServiceBrowseReply() callback.
 *
 * regtype:         The type of the service instance to be resolved, as reported to the
 *                  DNSServiceBrowseReply() callback.
 *
 * domain:          The domain of the service instance to be resolved, as reported to the
 *                  DNSServiceBrowseReply() callback.
 *
 * callBack:        The function to be called when a result is found, or if the call
 *                  asynchronously fails.
 *
 * context:         An application context pointer which is passed to the callback function
 *                  (may be NULL).
 *
 * return value:    Returns kDNSServiceErr_NoError on success (any subsequent, asynchronous
 *                  errors are delivered to the callback), otherwise returns an error code indicating
 *                  the error that occurred (the callback is never invoked and the DNSServiceRef
 *                  is not initialized).
 */

DNSServiceErrorType DNSSD_API DNSServiceResolve
    (
    DNSServiceRef                       *sdRef,
    DNSServiceFlags                     flags,
    uint32_t                            interfaceIndex,
    const char                          *name,
    const char                          *regtype,
    const char                          *domain,
    DNSServiceResolveReply              callBack,
    void                                *context  /* may be NULL */
    );
"
]

{ #category : #callbacks }
BonjourLibraryInterface >> serviceAddress: sv [
	
	| theService |
	
	self log:	'<= Service Address for: ' , sv object printString, ' interface ', sv interfaceIndex.
		
	(theService := sv object) addAddress: sv address.	"self log: 'Service Address - top: ', sv object printString."
	sv isMoreComing
		ifFalse:
			[connections
				at: sv id
				ifPresent:
					[:value | 
					value pump terminate.
					connections removeKey: sv id]
				ifAbsent:
					[self
						log:
							'No Bonjour connection found when receiving service address for: '
								, theService printString , ' during service resolution'].
			self deallocateSDRef: sv sdRef.	
			"The service is fully resolved now, so add it to the collection."
			theService serviceType addService: theService.
			services add: theService.
			self announce: (ServiceAdded new service: theService)]
]

{ #category : #callbacks }
BonjourLibraryInterface >> serviceFound: aService on: anInterfaceIndex [

	"Called asynchronously when a service is found whilst browsing for instances of a server type.
	There are separate callbacks for each interface on which the service is found.
	One service is created, and the interface indexes are added to that."
	
	| theService |
	
	self log:	'<= Service Found for: ' , aService printString, ' interface ', anInterfaceIndex.
	
	theService := services
		detect: [:each | each fullName = aService fullName]
		ifNone: [aService].
	theService addInterface: anInterfaceIndex.	
	"If this is the first discovery, fire off the resolve and stash the object."
	services
		detect: [:each | each fullName = theService fullName]
		ifNone:
			[self log: 'First discovery - fire off resolve'.
			self announce: (ServiceAdded new service: aService).
			self resolve: theService]	
]

{ #category : #callbacks }
BonjourLibraryInterface >> serviceLost: aService on: anInterfaceIndex callback: aCallbackSV [

	"One lost callback for each interface there service is on..."
	
	| theService pendingConnections |
	
	self log:	'<= Service Lost for: ' , aService printString, ' interface: ', anInterfaceIndex.
	
	theService := services
		detect: [:each | each fullName = aService fullName]
		ifNone:
			["As services only get added after they have been fully resolved (and addresses got), 
			check to see if it got lost whilst still resolving."
			(pendingConnections := connections values
				select:
					[:each | 
					(#('Resolve' 'Get Addresses') includes: each name)
						and: [each service fullName = aService fullName]]) isEmpty
				ifFalse:
					[self log: 'LOSING SERVICE BEFORE FULLY RESOLVED: ' , aService printString.
					pendingConnections
						do:
							[:each | 
							self log: 'Removing pending Bonjour connection: ' , each printString.
							self log: each sdRef "contents - still needed in Pharo?" printString.
							each pump terminate.
							connections removeKey: each id.
							^self deallocateSDRef: each sdRef "contents - still needed in Pharo?"]]
				ifTrue: [self error: 'Service to remove not found' , aService fullName]].	
				
	aCallbackSV object: theService.
	theService removeInterface: anInterfaceIndex.
	theService interfaces isEmpty
		ifTrue: [self removeService: theService]
]

{ #category : #callouts }
BonjourLibraryInterface >> serviceProcessResult: sdRef [

	| result |

	calloutMutex criticalReleasingOnError: 
		[result := interface DNSServiceProcessResult: sdRef.
		self checkResult: result for: 'DNSServiceProcessResult']
	

	
]

{ #category : #callbacks }
BonjourLibraryInterface >> serviceRegistered: sv [
	"Service has been registered.
	Note that it is not added as a service here, but is added through the service discovery service found callback.
	Assumption: - that service discovery includes the registered service type."
	
	self log:	'<= Service Registered for: ' , sv object printString.
		
	registeredServices
		at: sv object fullName
		put: sv object.	
	"Remove the register connection, as the sdRef is held by the service."
	connections
		at: sv id
		ifPresent:
			[:value | 
			value pump terminate.
			connections removeKey: sv id]
		ifAbsent: [self halt]
]

{ #category : #callbacks }
BonjourLibraryInterface >> serviceResolved: sv [
	"There are separate resolve callbacks for each interface on which the service is found."
	
	self log:	'<= Service Resolved for: ' , sv object printString, ' interface: ', sv interfaceIndex.
	
	sv object
		hostName: sv hostName;
		port: sv port;
		textRecordPairs: 
			(self 
				textRecordPairsFromTextLength: sv textLength
				textRecord: sv textRecord).	
	"The identical service created when service found."	
	"self log: 'Resolved: ', sv object printString."
	sv isMoreComing
		ifFalse:
			["Resolve callbacks have finished, get the addresses."
			self getAddressesOf: sv object.
			connections
				at: sv id
				ifPresent:
					[:value | 
					value pump terminate.
					connections removeKey: sv id]
				ifAbsent:
					[self log: 'CONNECTION NOT FOUND FOR RESOLVED CALLBACK: ' , sv printString.
					self log: sv sdRef printString].
			self deallocateSDRef: sv sdRef	"sv sdRef free - causes VW to crash, as allready deallocated by previous statement"]
]

{ #category : #'startUp - shutDown' }
BonjourLibraryInterface >> shutDown [

	<script: 'self shutDown'>
	
	super shutDown.
	"interface class unloadLibraries."
]

{ #category : #'startUp - shutDown' }
BonjourLibraryInterface >> startUp [

	<script: 'self startUp'>


	"
	LibC runCommand:  'echo sim123 | sudo -S killall –HUP mDNSResponder'.
	LibC runCommand:  'echo sim123 | sudo -S killall –HUP mDNSHelper'.
	"
	
	self log: 'Starting up on mDNSResponder'.
	self initializeOnStartUp.
	
	doHalts := true.
	"self log: 'Halt before CALLOUTS: ', doHalts printString."
	[self log: 'Bouncing Bonjour (mDNSResponder)... and setting log level...'.
	LibC runCommand:  'echo sim123 | sudo -S killall –HUP mDNSResponder'.
	LibC runCommand:  'echo sim123 | sudo -S killall –HUP mDNSHelper'.
	LibC runCommand: 'echo sim123 | sudo killall -USR1 mDNSResponder'. "warning and notice logging"
	LibC runCommand:  'echo sim123 | syslog -c mDNSResponder -d'. "log levels Emergency to Debug"
	LibC runCommand: 'echo sim123  killall -INFO mDNSResponder'.]. "current state in console"
	500 milliSecond wait.
	self log: 'Recompiling all FFILibrary (BonjourLibraryInterface) interface methods'.
	BonjourLibraryFFI compileAll. 
	interface := BonjourLibraryFFI uniqueInstance.
	self log: 'Threaded runner is: ', interface runner printString.
	
	
	"self startUpOnRegistrationTypes: registrationTypesToBrowse"
	
	"self startUpOnRegistrationTypes: #('_airplay._tcp.')"
	
	self browseServiceTypes
	
]

{ #category : #parsing }
BonjourLibraryInterface >> textRecordPairsFromTextLength: recordLengthCB textRecord: cString [
	"Unmarshal the key/value pairs from within cString."
	
	| stream textLength textRecord pairs |
	
	textLength := recordLengthCB.
	textRecord := cString.
	textRecord := textRecord isEmpty
		ifTrue: ['']
		ifFalse: [textRecord copyFrom: 1 to: textLength].
	stream := ReadStream on: textRecord.
	pairs := OrderedCollection new.
	[stream atEnd]
		whileFalse:
			[| keyValue |
			(keyValue := (stream next: stream next asInteger) splitOn: $=) size = 2
				ifTrue:
					[pairs add: 
						(TextRecordPair
							key: (keyValue at: 1) "unicodeStringToHostString"
							value: (keyValue at: 2)) "unicodeStringToHostString"]
				ifFalse:
					[pairs add: 
						(TextRecordPair
							key: (keyValue at: 1) "unicodeStringToHostString"
							value: '')]].
				
	^pairs
					
	"(OrderedCollection new
		add: recordLengthCB;
		add: textLength;
		add: cString;
		add: textRecord;
		add: nameValueMap;
		yourself) inspect"
]

{ #category : #troubleshooting }
BonjourLibraryInterface >> usingThreadedCallout [

"BenchTFFIWorker>>runCall - works ok.

^TFWorker default

1) Test

Thread 0 Crashed::  Dispatch queue: com.apple.main-thread
0   libsystem_kernel.dylib        	       0x1841319b8 __pthread_kill + 8
1   libsystem_pthread.dylib       	       0x18416515c pthread_kill + 288
2   libsystem_c.dylib             	       0x1840a23a0 __abort + 128
3   libsystem_c.dylib             	       0x18409418c __stack_chk_fail + 96
4   libPharoVMCore.dylib          	       0x102986a10 compileCogMethod + 12960
	
2) Test
Application Specific Information:
BUG IN CLIENT OF LIBPLATFORM: Trying to recursively lock an os_once_t
Abort Cause 67611
stack buffer overflow


Thread 0 Crashed:: SDLTimer
0   libsystem_kernel.dylib        	       0x18412d0c0 __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x184165ab4 _pthread_cond_wait + 1228
2   libSDL2.dylib                 	       0x107edba14 SDL_CondWaitTimeout_REAL + 148
3   libSDL2.dylib                 	       0x107edb574 SDL_SemWaitTimeout_REAL + 76
4   libSDL2.dylib                 	       0x107e7c7f0 SDL_TimerThread + 84
5   libSDL2.dylib                 	       0x107e7c3d0 SDL_RunThread + 48
6   libSDL2.dylib                 	       0x107edb174 RunThread + 12
7   libsystem_pthread.dylib       	       0x1841654ec _pthread_start + 148
8   libsystem_pthread.dylib       	       0x1841602d0 thread_start + 8
	
3) Test - UI responsive, but hasn't returned results:

Thread 0x18a19    1001 samples (1-1001)    priority 31 (base 31)
  1001  thread_start + 8 (libsystem_pthread.dylib + 8912) [0x1841602d0]
    1001  _pthread_start + 148 (libsystem_pthread.dylib + 29932) [0x1841654ec]
      1001  worker_run + 172 (libPharoVMCore.dylib + 46560) [0x10239f5e0]
        1001  ffi_call_int + 948 (libffi.dylib + 68068) [0x19222c9e4]
          1001  ffi_call_SYSV + 80 (libffi.dylib + 32848) [0x192224050]
            1001  DNSServiceProcessResult + 248 (libsystem_dnssd.dylib + 11196) [0x18ebedbbc]
              1001  __recvfrom_nocancel + 8 (libsystem_kernel.dylib + 24156) [0x18412de5c]
               *1001  ??? (kernel.release.t8101 + 30712) [0xfffffe00079137f8]
                 *1001  ??? (kernel.release.t8101 + 1567524) [0xfffffe0007a8ab24]
                   *1001  ??? (kernel.release.t8101 + 6934044) [0xfffffe0007fa8e1c]
                     *1001  ??? (kernel.release.t8101 + 6260520) [0xfffffe0007f04728]
                       *1001  ??? (kernel.release.t8101 + 6260848) [0xfffffe0007f04870]
                         *1001  soreceive + 1920 (kernel.release.t8101 + 6194252) [0xfffffe0007ef444c]
                           *1001  ??? (kernel.release.t8101 + 6236188) [0xfffffe0007efe81c]
                             *1001  ??? (kernel.release.t8101 + 5874920) [0xfffffe0007ea64e8]
                               *1001  lck_mtx_sleep + 136 (kernel.release.t8101 + 428264) [0xfffffe00079748e8]
                                 *1001  ??? (kernel.release.t8101 + 524964) [0xfffffe000798c2a4]
                                   *1001  ??? (kernel.release.t8101 + 531352) [0xfffffe000798db98]

4) Attempting to shut down, after asynchronous call hasn't returned

0x16f430938 M [] in Semaphore>criticalReleasingOnError: 0x3c3437b78: a(n) Semaphore
       0x16f430978 M FullBlockClosure(BlockClosure)>ensure: 0x39fd5dd10: a(n) FullBlockClosure
       0x16f4309b8 M Semaphore>criticalReleasingOnError: 0x3c3437b78: a(n) Semaphore
       0x16f430a00 I BonjourLibraryInterface>deallocateSDRef: 0x3c4c1b240: a(n) BonjourLibraryInterface
       0x16f430a38 M [] in BonjourLibraryInterface>shutDown 0x3c4c1b240: a(n) BonjourLibraryInterface

	
	"

]
