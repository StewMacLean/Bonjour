Class {
	#name : #BonjourLibraryInterface,
	#superclass : #BonjourInterface,
	#instVars : [
		'asynchronousInterface'
	],
	#category : #'SIM-Bonjour'
}

{ #category : #parsing }
BonjourLibraryInterface >> addressFrom: aHandle [

	"Note - structure doesn't work for callback? Doesn't return correct data...?
	Different structures for IPv4 and IPv6"
	
	| array stream readStream |
	
	stream := String new writeStream.
	(aHandle uint8AtOffset: 0) = 16
		ifTrue:
			["aHandle uint8AtOffset: 0."  	"length = 16"
			"aHandle uint8AtOffset: 1."		"family = 2 - IPv4"
			"aHandle uint16AtOffset: 2."  	"port = bug, not set - zero!"
			array := (4 to: 7) collect: [: each | aHandle uint8AtOffset: each].
			array do: [:each | stream nextPutAll: each printString]
				separatedBy: [stream nextPut: $.]]
		ifFalse:
			[readStream := ((8 to: 23) collect: [: each | aHandle uint8AtOffset: each]) readStream.
			[readStream atEnd] whileFalse:
				[readStream next printOn: stream base: 16 length: 1 padded: false.
				readStream next printOn: stream base: 16 length: 1 padded: false.
				stream nextPut: $:].
			stream skip: -1].
		
	^stream contents
]

{ #category : #'callouts - raw' }
BonjourLibraryInterface >> browseSDRef: sdRef flags: flags interfaceIndex: interfaceIndex registrationType: regtype domain: domain callback: callback context: context [
	"When you first start browsing, all the callbacks will be for services added. 
	As services are added and removed from the system, additional 
	callbacks will be generated with this bit both set and cleared."
	
	| result |
	
	result := interface 
			DNSServiceBrowse: sdRef 
				with: flags 
				with: interfaceIndex 
				with: regtype 
				with: domain 
				with: callback 
				with: context.
		self checkResult: result for: 'DNSServiceBrowse'
		
"
	DNSServiceRef            	*sdRef,
	DNSServiceFlags     			flags,
    	uint32_t              	interfaceIndex,
    	const char            	*regtype,
    	const char            	*domain,    /* may be NULL */
    	DNSServiceBrowseReply  	callBack,
    	void                     *context    /* may be NULL */
	"
		
"/* DNSServiceBrowse() Parameters:
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

{ #category : #'callouts - api' }
BonjourLibraryInterface >> browseServiceTypes [
	
	| flags interfaceIndex regtype domain context callback 
	sdRef connectionSV connectionID sdRefHandle |
	
	"Create uninitialised sdRef - pointer to a pointer"
	sdRefHandle := ByteArray new: 8.
	connectionID := self nextConnectionID.
	flags := 0.
	interfaceIndex := interface kDNSServiceInterfaceIndexAny.	"0"
	regtype := '_services._dns-sd._udp'.
	domain := ''. 								
	context := ExternalAddress null.
	callback := self browseServiceTypesCallback: connectionID.
		
	"Initializes sdRef..."
	self log: '**> Browse Service Types...'.
	self 
		browseSDRef: sdRefHandle
		flags: flags 
		interfaceIndex: interfaceIndex
		registrationType: regtype 
		domain: domain 
		callback: callback 
		context: context.	
	sdRef := sdRefHandle pointerAt: 1.
			
	connectionSV := StateVector new
		id: connectionID;
		sdRef: sdRef;
		name: 'Browse Service Types: ' , regtype;
		callback: callback.
		
	"Fire off callbacks..."						
	self runResultsPumpOn: sdRef stateVector: connectionSV

	
]

{ #category : #'callbacks - raw' }
BonjourLibraryInterface >> browseServiceTypesCallback: connectionID [

	^BonjourCallback 
		signature: interface DNSServiceBrowseReply
		block:
			[:sdRefCB :flagsCB :interfaceIndexCB :errorCodeCB :serviceTypeNameCB :protocolDomainCB :domainCB :contextCB | 
			| sv stream protocol object |
			sv := StateVector new
				sdRef: sdRefCB;
				id: connectionID;
				flags: flagsCB;
				isMoreComing: (self isMoreComing: flagsCB);
				interfaceIndex: interfaceIndexCB printString;
				name: serviceTypeNameCB;							
				registrationType: protocolDomainCB;				
				domain: domainCB. 								
			(self isAdd: sv flags)
				ifTrue: [sv event: 'Added']
				ifFalse: [sv event: 'Removed'].
				
			self log: '<** Service Type ', 
				sv event, 
				': ', sv name, '.', sv registrationType,
				' interface: ', interfaceIndexCB printString.
				
			stream := ReadStream on: sv registrationType.
			protocol := stream through: $..
			object := ServiceType new
				name: sv name;
				protocol: protocol;
				domain: sv domain";
				interfaceIndex: sv interfaceIndex".
			sv object: object.	
			callbackQueue nextPut: sv.
			nil].

]

{ #category : #'callouts - api' }
BonjourLibraryInterface >> browseServicesOf: aServiceType [
	
	| flags interfaceIndex regtype domain context callback sdRef connectionSV connectionID sdRefHandle |
	
	sdRefHandle := ByteArray new: 8.
	connectionID := self nextConnectionID.
	flags := 0.
	interfaceIndex := interface kDNSServiceInterfaceIndexAny.	"0"
	regtype := aServiceType registrationType.
	domain := ''.
	context := ExternalAddress null.
	callback := self browseServicesOfCallback: connectionID.
		
	"Initialize sdRef..."
	self log: '**> Browse Services of type ', aServiceType registrationType.
	self 
		browseSDRef: sdRefHandle
		flags: flags 
		interfaceIndex: interfaceIndex
		registrationType: regtype 
		domain: domain 
		callback: callback 
		context: context.
	sdRef := sdRefHandle pointerAt: 1.
				
	connectionSV := StateVector new
		id: connectionID;
		sdRef: sdRef;
		name: 'Browse Services of type: ' , regtype;
		serviceType: aServiceType;
		callback: callback.
		
	"Fire off callbacks..."
	self runResultsPumpOn: sdRef stateVector: connectionSV
]

{ #category : #'callbacks - raw' }
BonjourLibraryInterface >> browseServicesOfCallback: connectionID [

	^BonjourCallback 
		signature: interface DNSServiceBrowseReply
		block:
			[:sdRefCB :flagsCB :interfaceIndexCB :errorCodeCB :serviceNameCB :regtypeCB :domainCB :contextCB | 
			| sv object |
			(sv := StateVector new)
				sdRef: sdRefCB;
				id: connectionID;
				flags: flagsCB;
				isMoreComing: (self isMoreComing: flagsCB);
				interfaceIndex: interfaceIndexCB printString;
				name: serviceNameCB; 
				registrationType: regtypeCB; 							
				domain: domainCB. 													
			(self isAdd: sv flags)
				ifTrue: [sv event: 'Added']
				ifFalse: [sv event: 'Removed'].	
					
			self log: '<** Service ', sv event, 
				' : ', serviceNameCB, 
				' type: ', regtypeCB, 
				' interface: ', interfaceIndexCB printString.
				
			object := Service new
				name: sv name;
				domain: sv domain;
				serviceType: (connections at: connectionID) serviceType.
			sv object: object.	
			callbackQueue nextPut: sv.
			nil]
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

{ #category : #'_testing' }
BonjourLibraryInterface >> cleanUpCommands [

	self current.

	"FFI modifies the method - recompile to remove when changing runners etc.
	BonjourLibraryFFIAbstract compileAll.
	BonjourLibraryFFICalloutCallback compileAll.
	BonjourLibraryFFIPump  compileAll
	"

	LibC runCommand:  'echo sim123 | sudo -S killall –HUP mDNSResponder'.
	LibC runCommand:  'echo sim123 | sudo -S killall –HUP mDNSHelper'.
	
	self log: 'Bouncing Bonjour (mDNSResponder)... and setting log level...'.
	LibC runCommand:  'echo sim123 | sudo -S killall –HUP mDNSResponder'.
	LibC runCommand:  'echo sim123 | sudo -S killall –HUP mDNSHelper'.
	LibC runCommand: 'echo sim123 | sudo killall -USR1 mDNSResponder'. "warning and notice logging"
	LibC runCommand:  'echo sim123 | syslog -c mDNSResponder -d'. "log levels Emergency to Debug"
	LibC runCommand: 'echo sim123  killall -INFO mDNSResponder'. "current state in console"
	
	self current.
	BonjourLibraryInterface allInstances do: [: each | each shutDown].
	BonjourLibraryInterface allInstances do: [: each | each become: Object new].
	BonjourLibraryInterface resetCurrent.
	BonjourLibraryInterface shutDown.
	SpaceTally new printSpaceAnalysis

]

{ #category : #'callouts - raw' }
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

{ #category : #'callouts - raw' }
BonjourLibraryInterface >> deallocateSDRef: sdRef [
	
	"Note: no error checking - result is nil/void"
	
	[self log: '**> Deallocating ' , sdRef printString.	"true ifTrue: [^self]."
		interface DNSServiceRefDeallocate: sdRef]
			on: Error
			do: [:ex | self log: 'Error when deallocating: ', sdRef printString, ' error: ', ex printString]	
]

{ #category : #'callouts - api' }
BonjourLibraryInterface >> getAddressesOf: aService [
	
	| flags interfaceIndex context callback sdRef hostNameutf8 protocol connectionSV connectionID sdRefHandle |

	sdRefHandle := ByteArray new: 8.
	connectionID := self nextConnectionID.
	flags := 0.	"Note, can set to timeout via flags"
	interfaceIndex := interface kDNSServiceInterfaceIndexAny.	"0"
	protocol := 0. "requesting both the IPv4 and IPv6 addresses"
	hostNameutf8 := aService hostName.
	context := ExternalAddress null.
	callback := self getAddressesOf: aService connectionCallback: connectionID.
		
	"Initializes sdRef..."
	self log: '**> Get addresses of: ', aService fullName.
	self 
		getAddressesSDRef: sdRefHandle
		flags: flags 
		interfaceIndex: interfaceIndex
		protocol: protocol 
		hostName: hostNameutf8 
		callback: callback 
		context: context.	
	sdRef := sdRefHandle pointerAt: 1.	
				
	connectionSV := StateVector new
		id: connectionID;
		sdRef: sdRef;
		name: 'Get addresses of ', aService fullName;
		service: aService;
		callback: callback.	
			
	"Fire off callbacks..."
	self runResultsPumpOn: sdRef stateVector: connectionSV
]

{ #category : #'callbacks - raw' }
BonjourLibraryInterface >> getAddressesOf: aService connectionCallback: connectionID [

	^BonjourCallback 
		signature: interface DNSServiceGetAddrInfoReply
		block:
			[:sdRefCB :flagsCB :interfaceIndexCB :errorCodeCB :hostNameCB :addressCB :timeValidCB :contextCB | 
			| sv |
			sv := StateVector new
				sdRef: sdRefCB;
				id: connectionID;
				flags: flagsCB;
				isMoreComing: (self isMoreComing: flagsCB);
				interfaceIndex: interfaceIndexCB printString;
				hostName: hostNameCB;
				address: (self addressFrom: addressCB).	
				"Note: port returned in structure is zero - bug?. Verified from mDNSResponder code, use port from resolve."
						
			self log: '<** Address of service ', aService fullName,' is ', sv address.
				
			sv
				event: 'ServiceAddress';
				object: (connections at: connectionID) service.	
			callbackQueue nextPut: sv.
			nil]
]

{ #category : #'callouts - raw' }
BonjourLibraryInterface >> getAddressesSDRef: sdRef flags: flags interfaceIndex: interfaceIndex protocol: protocol hostName: hostName callback: callback context: context [
	
	| result |
	
	result := interface 
		DNSServiceGetAddrInfo: sdRef 
		with: flags 
		with: interfaceIndex 
		with: protocol 
		with: hostName 
		with: callback 
		with: context.
	self checkResult: result for: 'DNSServiceBrowse'
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

	"Testing notes:
	Run Pharo from the terminal - see startUpPharoInTerminalViaBashScript.
	Compare results with Discovery - DNS-SD Browser available from the Mac App Store:
		https://apps.apple.com/us/app/discovery-dns-sd-browser/id1381004916?mt=12
	Open the Process Browser to observe the Smalltalk processes. 
	Set the registration types you want to browse, or empty for all (default).
	Run this script to open the app.
	When the callbacks 'log jam/fail to fire':
	- if a new service type, such as rdlink is found it most of the time it sets of some callbacks
	- otherwise try creating a new service to set it off - don't know why this does this.
	Note that shutting down also caused callbacks to fire.
	On the first window close click, it shuts down without closing so you can see the result.
	The second click closes the window
	
	Copy and paste into terminal, then execute:
	dns-sd -R TestService01 _smb._tcp. local. 1111
	dns-sd -R TestService02 _smb._tcp. local. 1112
	dns-sd -R TestService03 _smb._tcp. local. 1113
	dns-sd -R TestService04 _smb._tcp. local. 1114
	dns-sd -R TestService05 _smb._tcp. local. 1114
	dns-sd -R TestService06 _smb._tcp. local. 1114
	dns-sd -R TestService07 _smb._tcp. local. 1114	
	"

	<script: 'self uniqueInstance openApp'>
	
	registrationTypesToBrowse := #('_osc._udp.').				 	
	registrationTypesToBrowse := #('_apple-lgremote._tcp.'). 
	registrationTypesToBrowse := #('_net-assistant._udp.').
	registrationTypesToBrowse := #().  "All services of all service types."
	registrationTypesToBrowse := #('_smb._tcp.').	
	registrationTypesToBrowse := #('_airplay._tcp.').
	registrationTypesToBrowse := #('_companion-link._tcp.').
	registrationTypesToBrowse := #('_rdlink._tcp.').
	registrationTypesToBrowse := #('_osc._udp.'). 
	
	DiscoveryApp openOn: self class uniqueInstance.
	
	1 seconds wait.
	self registerOSCUDPService
	
		
	
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

{ #category : #'callouts - api' }
BonjourLibraryInterface >> register: aService [
	
	| flags interfaceIndex regtype context callback sdRef nameutf8 textLength textRecord 
	domain hostName portNetworkByteOrder connectionSV connectionID sdRefHandle |

	sdRefHandle := ByteArray new: 8.
	connectionID := self nextConnectionID.
	flags := 0.	"No renaming"
	interfaceIndex := interface kDNSServiceInterfaceIndexAny.	"0"	 "All available"	
	nameutf8 := aService name.
	regtype := aService registrationType.
	domain := ExternalAddress null.	"Default domains"
	hostName := ExternalAddress null.	"Use the machine's default host name(s)."
	portNetworkByteOrder := aService port asInteger asByteArray reverse asInteger.
	textLength := aService textLengthFromTextRecordPairs.	"0."
	textRecord := aService textRecordLibraryCalloutParameter.	"nil."
	context := ExternalAddress null.
	callback := self register: aService connectionCallback: connectionID.
		
	"Initializes sdRef..."
	self log: '**> Register Service: ', aService printString.
	self 
		registerSDRef: sdRefHandle
		flags: flags 
		interfaceIndex: interfaceIndex
		name: nameutf8 
		registrationType: regtype 
		domain: domain 
		hostName: hostName 
		port: portNetworkByteOrder 
		textLength: textLength 
		textRecord: textRecord 
		callback: callback 
		context: context.	
	sdRef := sdRefHandle pointerAt: 1.	
	aService sdRef: sdRef.	"Need to hang onto this to use for deregistering"
				
	connectionSV := StateVector new
		id: connectionID;
		sdRef: sdRef;
		name: 'Register service ', aService fullName;
		service: aService;
		callback: callback.
		
	"Fire off callbacks..."
	self runResultsPumpOn: sdRef stateVector: connectionSV
]

{ #category : #'callbacks - raw' }
BonjourLibraryInterface >> register: aService connectionCallback: connectionID [
	
	^BonjourCallback 
		signature: interface DNSServiceRegisterReply
		block:
			[:sdRefCB :flagsCB :errorCodeCB :nameCB :regtypeCB :domainCB :contextCB | 
			| sv |
			sv := StateVector new
				sdRef: sdRefCB;
				id: connectionID;
				domain: domainCB;
				event: 'ServiceRegistered';
				object: aService.
				
			self log: '<** Service Registered: ', aService printString.
			
			aService domain: sv domain.
			callbackQueue nextPut: sv.	
			nil]
]

{ #category : #'callouts - raw' }
BonjourLibraryInterface >> registerSDRef: sdRef flags: flags interfaceIndex: interfaceIndex name: name registrationType: regtype domain: domain hostName: host port: port textLength: txtLen textRecord: txtRecord callback: callback context: context [
	
	| result |
	
	result := interface 
		DNSServiceRegister: sdRef 
		with: flags 
		with: interfaceIndex 
		with: name 
		with: regtype 
		with: domain 
		with: host 
		with: port 
		with: txtLen 
		with: txtRecord 
		with: callback 
		with: context.
	self checkResult: result for: 'DNSServiceRegister'
]

{ #category : #'callouts - api' }
BonjourLibraryInterface >> resolve: aService [
	
	| flags interfaceIndex regtype context callback sdRef domainutf8 
	nameutf8 connectionSV connectionID sdRefHandle |

	sdRefHandle := ByteArray new: 8.
	connectionID := self nextConnectionID.
	flags := 0.
	interfaceIndex := interface kDNSServiceInterfaceIndexAny.	"0"
	nameutf8 := aService name.	"Note the header documentation is incorrect - it says full service name, only need the name"
	regtype := aService registrationType.
	domainutf8 := aService domain.
	context := ExternalAddress null.
	callback := self resolve: aService connectionIDCallback: connectionID.
		
	"Initialize sdRef..."
	self log: '**> Resolve Service: ', aService fullName.
	self 
		resolveSDRef: sdRefHandle
		flags: flags 
		interfaceIndex: interfaceIndex 
		name: nameutf8 
		registrationType: regtype 
		domain: domainutf8 
		callback: callback
		context: context.	
	sdRef := sdRefHandle pointerAt: 1.	
			
	connectionSV := StateVector new
		id: connectionID;
		sdRef: sdRef;
		name: 'Resolve: ', aService fullName;
		service: aService;
		callback: callback.
		
	"Fire off callbacks..."	
	self runResultsPumpOn: sdRef stateVector: connectionSV
]

{ #category : #'callbacks - raw' }
BonjourLibraryInterface >> resolve: aService connectionIDCallback: connectionID [
	
	^BonjourCallback 
		signature: interface DNSServiceResolveReply
		block:
			[:sdRefCB :flagsCB :interfaceIndexCB :errorCodeCB :nameCB :hostCB :portCB :textLengthCB :textRecordCB :contextCB | 
			| sv |
			sv := StateVector new
				id: connectionID;
				sdRef: sdRefCB;
				flags: flagsCB;
				isMoreComing: (self isMoreComing: flagsCB);
				interfaceIndex: interfaceIndexCB printString;
				name: nameCB;
				hostName: hostCB;								
				port: portCB asByteArray reverse asInteger asString;
				textLength: textLengthCB;
				textRecord: textRecordCB.
				
			self log: '<** Service Resolved: ', 
				aService fullName,  
				' host: ', sv hostName,
				' port: ', sv port,
				' interface: ', sv interfaceIndex.
				
			sv
				event: 'ServiceResolved';
				object: (connections at: connectionID) service.
			callbackQueue nextPut: sv.
			nil]
]

{ #category : #'callouts - raw' }
BonjourLibraryInterface >> resolveSDRef: sdRef flags: flags interfaceIndex: interfaceIndex name: name registrationType: regtype domain: domain callback: callBack context: context [
	
	| result |
	
	result := interface 
		DNSServiceResolve: sdRef 
		with: flags 
		with: interfaceIndex 
		with: name 
		with: regtype 
		with: domain 
		with: callBack
		with: ExternalAddress null.
		self checkResult: result for: 'DNSServiceResolve'	
		
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
		
"	/* DNSServiceResolve()
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

{ #category : #'results processing' }
BonjourLibraryInterface >> runResultsPumpOn: sdRef stateVector: sv [

	"If you want to run the callback function synchronously instead of setting 
	up a run loop or a select loop, you can call <the api call> and immediately 
	call DNSServiceProcessResult. The DNSServiceProcessResult function will block 
	until the mDNSResponder daemon has a response, at which time the callback specified 
	when DNSServiceResolve was called will be invoked. 
	This entire process should probably be run within a loop of its own 
	for each service you wish to resolve."
	
	| pump connectionID label | 
	
	connectionID := sv id.
	label := 'Pump ', connectionID, ' ', sv name, ' sdRef: ', sdRef printString.
	pump := 
		[self log:  'Starting ', label.
		[true]
			whileTrue:
				[self log: '**>| Threaded ', label.
				"Threaded call so doesn't block Smalltalk engine."
				"This blocks the current process, (but not the UI!), until data is available. 
				When it unblocks it fires off one or more callbacks."
				self serviceProcessResult: sdRef. 
				self log: '|<** Threaded return ', label]]
					newProcess.
	connections
		at: connectionID
		put: (sv pump: pump).	
			
	^pump
		name: label;
		priority: self resultsPumpPriority;  
		resume		
]

{ #category : #'callbacks - application' }
BonjourLibraryInterface >> serviceAddress: sv [
	
	super serviceAddress: sv.
	
	sv isMoreComing
		ifFalse: [self removeConnectionOf: sv]
]

{ #category : #'callbacks - application' }
BonjourLibraryInterface >> serviceFound: aService on: anInterfaceIndex [

	"Invoked following service added callback whilst browsing for instances of a server type.
	There are separate callbacks for each interface on which the service is found.
	Only one service is create for all interfaces - the interface indexes are added each address."
	
	| theService |
		
	theService := services
		detect: [:each | each fullName = aService fullName]
		ifNone: [aService].
	"theService addInterface: anInterfaceIndex.	"
	"If this is the first discovery, invoke the resolve to get host and port."
	services
		detect: [:each | each fullName = theService fullName]
		ifNone:
			[self addService: aService.
			self resolve: theService]	
]

{ #category : #'callbacks - application' }
BonjourLibraryInterface >> serviceLost: aService on: anInterfaceIndex callback: aCallbackSV [

	"One lost callback for each interface the service is on..."
	
	| theService pendingConnections |
	
	theService := services
		detect: [:each | each fullName = aService fullName]
		ifNone:
			["As services only get added after they have been fully resolved (and addresses got), 
			check to see if it got lost whilst still resolving. - not true anymore, but leave code"
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
									self removeConnectionOf: each]]
						ifTrue: [^self log: 'Service to remove not found' , aService fullName]].	"Don't error - timing issue?"
				
	aCallbackSV object: theService.
	self announce: (ServiceRemoved new service: theService).
	self removeService: theService
]

{ #category : #'callouts - raw' }
BonjourLibraryInterface >> serviceProcessResult: sdRef [

	| result |

	result := asynchronousInterface DNSServiceProcessResult: sdRef.
	self checkResult: result for: 'DNSServiceProcessResult'
	

	
]

{ #category : #'callbacks - application' }
BonjourLibraryInterface >> serviceRegistered: sv [

	"Service has been registered.
	
	Note that it is not added as a service here, but is added through the service discovery service found callback.
	If not already browsing for the service's service type, browsing has already been started when registering the service"
	
	self log:	'### Service Registered for: ' , sv object fullName.
		
	registeredServices
		at: sv object fullName
		put: sv object.	
			
	"Remove the register connection, as the sdRef is held by the service.
	Don't deallocate the sdRef though."
	connections
		at: sv id
		ifPresent:
			[:value | 
			value pump terminate.
			connections removeKey: sv id]
		ifAbsent: [self log: 'ERROR: connection: ', sv id printString, ' not found within service registered callback']
]

{ #category : #'callbacks - application' }
BonjourLibraryInterface >> serviceResolved: sv [

	"There are separate resolve callbacks for each interface on which the service is found."
	
	sv object hostName = '' "Is this the first resolution?"
		ifTrue:
			[sv object
				hostName: sv hostName;
				port: sv port;
				textRecordPairs: 
					(self 
						textRecordPairsFromTextLength: sv textLength
						textRecord: sv textRecord).	
			self log:	'### Service updated: ' , sv object fullName, ' host: ', sv hostName, ' port: ', sv port.
			self announce: (ServiceUpdated new service: sv object)].
	
	sv isMoreComing
		ifFalse:
			["Resolve callbacks have finished, get the addresses."
			self getAddressesOf: sv object.
			self removeConnectionOf: sv]
]

{ #category : #'startUp - shutDown' }
BonjourLibraryInterface >> shutDown [

	super shutDown.
	"interface class unloadLibraries."
]

{ #category : #'startUp - shutDown' }
BonjourLibraryInterface >> startUp [

	self log: 'Starting up on mDNSResponder'.
	self initializeOnStartUp.
	
	"Need to recompile ffi methods, as they are holding onto the previous runner in the byteCodes.
	This causes a crash when running for the second time without restarting the image."
	BonjourLibraryFFIAbstract compileAll.
	BonjourLibraryFFICalloutCallback compileAll.
	BonjourLibraryFFIPump  compileAll.
	
	BonjourLibraryFFICalloutCallback reset.  "In case change runner type..."
	BonjourLibraryFFIPump reset.
	interface := BonjourLibraryFFICalloutCallback uniqueInstance.
	asynchronousInterface := BonjourLibraryFFIPump uniqueInstance.
		
	self log: 'Threaded runner for synchronous callouts is: ', interface runner printString.
	self log: 'Threaded runner for asynchronous callouts is: ', asynchronousInterface runner printString.

	(registrationTypesToBrowse 
		ifEmpty: [self log: 'Browsing for all services off all types'] 
		ifNotEmpty: 
			[: value | 
			self log: 'Browsing for services with types of: ', value printString]).
			
	[self browseServiceTypes] forkAt: self callbackStreamPriority
]

{ #category : #'_testing' }
BonjourLibraryInterface >> startUpPharoInTerminalViaBashScript [

"

#!/bin/sh

# Execute this after saving to remove from quarantine:
# xattr -r -d com.apple.quarantine /Users/stewart/Desktop/OverDrive.P10.command

cd /Volumes/Data/Projects/OverDrive/Pharo/Application/OverDrive
/Volumes/Data/Development/Smalltalk/Engines/Pharo/Pharo10.0/Pharo.app/Contents/MacOS/Pharo --logLevel=4 /Volumes/Data/Projects/OverDrive/Pharo/Application/OverDrive/Pharo.image

"
]

{ #category : #parsing }
BonjourLibraryInterface >> textRecordPairsFromTextLength: textLength textRecord: externalAddress [

	"Unmarshal the key/value pairs from within the string pointed to by externalAddress."
	
	| stream pairs textRecord |
	
	textRecord := externalAddress copyFrom: 1 to: textLength.
	stream := ReadStream on: textRecord.
	pairs := OrderedCollection new.
	[stream atEnd]
		whileFalse:
			[| keyValue |
			(keyValue := (stream next: stream next asInteger) utf8Decoded splitOn: $=) size = 2
				ifTrue:
					[pairs add: 
						(TextRecordPair
							key: (keyValue at: 1)
							value: (keyValue at: 2))]
				ifFalse:
					[(keyValue at: 1) 
						ifNotEmpty:
							[pairs add: 
								(TextRecordPair
									key: (keyValue at: 1)
									value: '')]]].
				
	^pairs
					
	"(OrderedCollection new
		add: recordLengthCB;
		add: textLength;
		add: cString;
		add: textRecord;
		add: nameValueMap;
		yourself) inspect"
]

{ #category : #'_testing' }
BonjourLibraryInterface >> troubleShooting [
	
	"
	Callbacks:
	TFCallbackQueue>>executeCallback: - traced - removed as it runs on the queue thread.
	To guarantee the stack is not modified while this method runs, 
	this method should be called from a high priority process.
	  => no callbacks should finish while this method runs.
	
	TFCallbackInvocation>>execute - traced
	TFRunner>>returnCallback: - traced
	
	Callouts:
	FFICalloutAPI>>function: functionSignature library: moduleNameOrLibrary
	
	TFExternalAsyncCall
		TFPooledExternalAsyncCall>>doExecute: - traced
		
	TFPooledExternalAsyncCall allInstances.
	TFRunner allInstances
	
	"
	self current.
	self allInstances.

	BonjourLibraryFFICalloutCallback uniqueInstance runner.
	BonjourLibraryFFIPump uniqueInstance runner.

	SpApplication defaultApplication: nil.
	
	SpNullApplication allInstances do: [: each | each reset].

	SpaceTally new printSpaceAnalysis.

	TFWorker allInstances.

	MCHttpRepository
      location: 'http://smalltalkhub.com/mc/JohnBrant/ReferenceFinder/main'
      user: ''
      password: ''.

	ReferenceFinder findPathTo:  BonjourLibraryFFICalloutCallback allInstances first.
	
	ReferenceFinder findPathTo: TFWorker allInstances first.
	
	ReferenceFinder findPathTo: DiscoveryApp allInstances first
]
