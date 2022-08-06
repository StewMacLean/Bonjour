Class {
	#name : #BonjourInterface,
	#superclass : #Object,
	#instVars : [
		'interface',
		'logFile',
		'logMutex',
		'domains',
		'serviceTypes',
		'services',
		'registeredServices',
		'connections',
		'callbackProcess',
		'callbackQueue',
		'registrationTypesToBrowse',
		'announcer',
		'lastConnectionID',
		'loggingEnabled',
		'logger',
		'logFileStream',
		'connectionIDMutex',
		'logToTranscript'
	],
	#classInstVars : [
		'current'
	],
	#category : #'SIM-Bonjour'
}

{ #category : #'class initialization' }
BonjourInterface class >> current [
	
	^current
]

{ #category : #'class initialization' }
BonjourInterface class >> current: anInterface [
	
	current := anInterface
]

{ #category : #'class initialization' }
BonjourInterface class >> resetCurrent [
	
	current := nil
]

{ #category : #'instance creation' }
BonjourInterface class >> shutDown [
	
	[current ifNotNil: [current shutDown]]
		ensure: [	current := nil]
]

{ #category : #'instance creation' }
BonjourInterface class >> startUp [
	
	current ifNotNil: [current shutDown].
	^(current := self new) startUp
]

{ #category : #'instance creation' }
BonjourInterface class >> startUpOnOSC [
	
	self startUpOnRegistrationTypes: #('_osc._udp.' '_osc._tcp.')
]

{ #category : #'instance creation' }
BonjourInterface class >> startUpOnRegistrationTypes: registrationTypes [
	
	current ifNotNil: [current shutDown].
	^(current := self new) startUpOnRegistrationTypes: registrationTypes
]

{ #category : #'instance creation' }
BonjourInterface class >> uniqueInstance [

	^current ifNil: [current := self new]

	
]

{ #category : #structural }
BonjourInterface >> addService: aService [

	self log:	'### Service created: ' , aService fullName.

	aService serviceType addService: aService.
	services add: aService.
	self announce: (ServiceAdded new service: aService).
]

{ #category : #structural }
BonjourInterface >> addServiceType: aServiceType [

	| domain theDomain |

	theDomain := domains
		detect: [:each | each name = aServiceType domain]  "local. == . ???"
		ifNone: [domains add: (domain := Domain new name: aServiceType domain; parent: self)].
		
	theDomain addServiceType: aServiceType.

	serviceTypes add: aServiceType.
	
	self log:	'### Service Type created: ' , aServiceType registrationType.
	self announce: (ServiceTypeAdded new serviceType: aServiceType).
	
	^aServiceType

]

{ #category : #announcements }
BonjourInterface >> announce: anEvent [
	
	announcer announce: anEvent
]

{ #category : #'service types' }
BonjourInterface >> appleLGREMOTETCPServiceType [
	
	^serviceTypes
		detect: [:each | each isAppleLGREMOTETCP]
		ifNone: [self addServiceType: (ServiceType tcpName: 'apple-lgremote')]
]

{ #category : #'service types' }
BonjourInterface >> appleMIDIUDPServiceType [
	
	^serviceTypes
		detect: [:each | each isAppleMIDIUDP]
		ifNone: [self addServiceType: (ServiceType udpName: 'apple-midi')]
]

{ #category : #configuration }
BonjourInterface >> callbackStreamPriority [

	"Must be greater than incomming system callbacks which is 69 to avoid seg fault on shut down.
	Also runs further - browse services of service type returns sometimes..."
	
	^71
	
	"^71" "v4 - runs to end when shutting down without crash"

	"^71"  "v1 seems to go further, and not crash on initial run"
	
	"^68" "v2 less than callback queue - jams on callback instead"
	
	"^70"  "v3" "Original - NOTE: for some reason, this has to be of lower priority than the message pump, 
	otherwise callbacks don't get fired"
]

{ #category : #'accessing - domain' }
BonjourInterface >> children [

	^domains
]

{ #category : #api }
BonjourInterface >> deregister: aService [
	
	self log: '==> Deregister Service: ' , aService printString.
	registeredServices
		at: aService fullName
		ifPresent: [:value | registeredServices removeKey: value fullName].
	self deallocateSDRef: aService sdRef
]

{ #category : #api }
BonjourInterface >> deregisterServiceNamed: aServiceName [
	
	| service |
	self log: 'Deregistering service ' , aServiceName printString.
	registeredServices keys
		detect: [:each | each beginsWith: aServiceName]
		ifFound:
			[:fullName | 
			service := registeredServices
				at: fullName
				ifPresent: [:value | registeredServices removeKey: value fullName]
				ifAbsent:
					[self
						log:
							'Deregistering service failed (service not registered) '
								, aServiceName printString.
					^self].
			self deallocateSDRef: service sdRef]
]

{ #category : #api }
BonjourInterface >> deregisterServices [
	
	registeredServices do: [:each | self deregister: each]
]

{ #category : #'accessing - domain' }
BonjourInterface >> domains [

	^domains
]

{ #category : #logging }
BonjourInterface >> error: aString [

	self log: 'ERROR walkback: ***************************************'.
	self log: aString.
	super error: aString.
	
	"self shutDown"
]

{ #category : #'startUp - shutDown' }
BonjourInterface >> initialize [
	
	super initialize.
	logMutex := Semaphore forMutualExclusion.
	loggingEnabled := true.
	domains := OrderedCollection new.
	serviceTypes := OrderedCollection new.
	services := OrderedCollection new.
	registeredServices := Dictionary new.
	connections := Dictionary new.
	registrationTypesToBrowse := OrderedCollection new.
	announcer := Announcer new.
	lastConnectionID := 0.
	connectionIDMutex := Semaphore forMutualExclusion.
	self initializeLogFile
	
	
]

{ #category : #'startUp - shutDown' }
BonjourInterface >> initializeLogFile [ 

	| directory |
	
	logToTranscript := true.
	
	Transcript clear; flush.
		
	logger
		ifNil:
			[(directory := FileLocator imageDirectory / 'logs - bonjour') exists
				ifFalse: [directory ensureCreateDirectory].
			logFile := directory / (Timestamp now printFilenameSuffix, '.txt').
			logFileStream := logFile writeStream].
		
]

{ #category : #'startUp - shutDown' }
BonjourInterface >> initializeOnStartUp [
	
	self openCallbackStream
	
	
]

{ #category : #logging }
BonjourInterface >> listServices [

	| stream |
	
	Transcript clear; flush.
	
	stream := String new writeStream.
	
	stream nextPutAll: 'All Services ========================================'.
	services do: [:each | stream nextPutAll: each printString].
	stream nextPutAll: '======================================================'.
	
	^stream contents
	

]

{ #category : #logging }
BonjourInterface >> listServicesHierarchically [

	| stream |

	stream := String new writeStream.
	
	(serviceTypes asSortedCollection: [: a : b| a registrationType < b registrationType]) do: [: serviceType |
		stream nextPutAll: serviceType registrationType; cr.
		(serviceType services asSortedCollection: [: a : b| a name < b name]) do: [: service |
				stream tab; 
					nextPutAll: service name; space;
					cr.
				stream tab; tab; nextPutAll: service hostName; cr.
				(service addresses asSortedCollection: [: a : b| a < b]) do: [: address |
					stream tab; tab; nextPutAll: address; cr].
				service textRecordPairs do: [: each | 
					stream 
						tab; tab; nextPutAll: each key;
						nextPutAll: '=';	
						nextPutAll: each value;
						cr
						]]].
		
	^stream contents
]

{ #category : #logging }
BonjourInterface >> log: aString [
	
	loggingEnabled ifFalse: [^self].
	logger
		ifNil: [self logLocal: aString]
		ifNotNil:
			[: value | 
			value
				log: aString
				prefix: self logPrefix]
]

{ #category : #logging }
BonjourInterface >> logLocal: aString [  
	
	logMutex
		critical:
			[| line |
			line := String new writeStream
				nextPutAll: Timestamp now printLogTimestamp;
				space;
				nextPutAll: Processor activeProcess identifier;
				space;
				nextPutAll: (Processor activeProcess priority) printString;
				space;
				nextPutAll: aString;
				cr;
				contents.
			"Standard out..."
			Stdio stdout 
				nextPutAll: line;
				lf.
			"Log file..."
			logFileStream closed ifFalse:
				[logFileStream
					nextPutAll: line;
					flush].
			"Transcript..."
			logToTranscript 
				ifTrue:
					[Transcript
					cr;
					nextPutAll: Timestamp now printLogTimestamp;
					space;
					nextPutAll: (Processor activeProcess identityHash \\ 999999) printString;
					space;
					show: aString;
					flush]]
]

{ #category : #logging }
BonjourInterface >> logPrefix [
	
	^'Bonjour'
]

{ #category : #logging }
BonjourInterface >> logger: anObject [
	
	logger := anObject
]

{ #category : #logging }
BonjourInterface >> loggingEnabled: anObject [
	
	loggingEnabled := anObject
]

{ #category : #'callback processing' }
BonjourInterface >> nextConnectionID [
	
	"self log: 'nextConnectionID - lastConnectionID: ', lastConnectionID printString."
	
	connectionIDMutex
		critical: [lastConnectionID := lastConnectionID + 1].
		
	^lastConnectionID printString padLeftTo: 5 with: $0
]

{ #category : #'callback processing' }
BonjourInterface >> openCallbackStream [

	callbackQueue := SharedQueue new.
	callbackProcess := 
		[self log: 'Callback Stream opened'.
		[true]
			whileTrue:
				[| callback |
				callback := callbackQueue next.
				self log: '@@@@ Invoking dequeued callback: ', callback printString.
				"Don't fork, these need to be serialised"
				callback object calledback: callback for: self   ]]
			newProcess.	
	
	callbackProcess
		name: 'Bonjour Callback Stream';
		priority: self callbackStreamPriority;
		resume	
]

{ #category : #'service types' }
BonjourInterface >> oscUDPServiceType [
	
	^serviceTypes
		detect: [:each | each isOSCUDP]
		ifNone: [self addServiceType: (ServiceType udpName: 'osc')]
]

{ #category : #commands }
BonjourInterface >> registerAppleLGREMOTEServiceNamed: aName port: aPort [
	
	^self
		registerAppleLGREMOTETCPServiceNamed: aName
		port: aPort
		textRecordPairs: OrderedCollection new
]

{ #category : #commands }
BonjourInterface >> registerAppleLGREMOTETCPServiceNamed: aName port: aPort textRecordPairs: anOrderedCollection [
	
	^Service new
		serviceType: self appleLGREMOTETCPServiceType;
		name: aName;
		port: aPort;
		textRecordPairs: anOrderedCollection;
		registerOn: self
]

{ #category : #commands }
BonjourInterface >> registerAppleMIDIUDPServiceNamed: aName port: aPort [
	
	^self
		registerAppleMIDIUDPServiceNamed: aName
		port: aPort
		textRecordPairs: OrderedCollection new
]

{ #category : #commands }
BonjourInterface >> registerAppleMIDIUDPServiceNamed: aName port: aPort textRecordPairs: anOrderedCollection [
	
	^Service new
		serviceType: self appleMIDIUDPServiceType;
		name: aName;
		port: aPort;
		textRecordPairs: anOrderedCollection;
		registerOn: self
]

{ #category : #commands }
BonjourInterface >> registerOSCServiceNamed: aName port: aPort [
	
	^self
		registerOSCUDPServiceNamed: aName
		port: aPort
		textRecordPairs: OrderedCollection new
]

{ #category : #'_testing' }
BonjourInterface >> registerOSCUDPService [

	"Must contain literals 'iPhone' and 'TouchOSC' for Logic TouchOSC to respond"
	
	Service new
		serviceType: self oscUDPServiceType;
		name: 'MacMini [iPhone] (OverDrive)';
		port: 12345;
		textRecordPairs:
			(OrderedCollection new
				add: (TextRecordPair key: 'name' value: 'value');
				add: (TextRecordPair key: 'paper' value: 'A4');
				add: (TextRecordPair key: 'Rendezvous Is Cool' value: '');
				yourself);
		registerOn: self	
]

{ #category : #commands }
BonjourInterface >> registerOSCUDPServiceNamed: aName port: aPort textRecordPairs: anOrderedCollection [
	
	^Service new
		serviceType: self oscUDPServiceType;
		name: aName;
		port: aPort;
		textRecordPairs: anOrderedCollection;
		registerOn: self
]

{ #category : #api }
BonjourInterface >> registerService: aService [
	
	self register: aService.	
		
	"If not already browsing for the service's service type, 
	start browsing to trigger discovery callbacks.
	The meta query service types browser doesn't trigger a found Service Type for some reason."
	connections
		detect:
			[:sv | 
			sv
				attributeAt: 'serviceType'
				ifPresent: [:serviceType | serviceType = aService serviceType]
				ifAbsent: [false]]
		ifNone: [self browseServicesOf: aService serviceType]
]

{ #category : #'_testing' }
BonjourInterface >> registerappleLGREMOTETCPService [

	"Must contain literals 'iPhone' and 'TouchOSC' for Logic TouchOSC to respond"
	
	Service new
		serviceType: self appleLGREMOTETCPServiceType;
		name: 'Spoofy Doofy - iPhone TouchOSC';
		port: 8888;
		textRecordPairs:
			(OrderedCollection new
				add: (TextRecordPair key: 'key' value: 'value');
				add: (TextRecordPair key: 'NoSpacesKey' value: 'NoMessCharlie');
				add: (TextRecordPair key: 'Rendezvous Is Cool' value: 'coolio value');
				yourself);
		registerOn: self	
]

{ #category : #'startUp - shutDown' }
BonjourInterface >> registrationTypesToBrowse: someRegistrationTypes [

	registrationTypesToBrowse := someRegistrationTypes

	
]

{ #category : #'results processing' }
BonjourInterface >> removeConnectionOf: sv [

	connectionIDMutex critical: 
		[connections
			at: sv id
			ifPresent:
				[: value | 
				self log: 'Removing Pump ', value id, ' ', value name, ' sdRef ', value sdRef printString.
				value pump terminate.
				connections removeKey: sv id]
			ifAbsent:
				[self log: 'Pump not found when removing ' , sv printString.
				self log: sv sdRef printString].
		self deallocateSDRef: sv sdRef]
]

{ #category : #'results processing' }
BonjourInterface >> removeConnectionOfv1: sv [

	connectionIDMutex critical: 
		[self log: 'Removing connection of ', sv printString.
		connections
			at: sv id
			ifPresent:
				[: value | 
				value pump terminate.
				connections removeKey: sv id]
			ifAbsent:
				[self log: 'Connection not found when removing ' , sv printString.
				self log: sv sdRef printString].
		self deallocateSDRef: sv sdRef]
]

{ #category : #'results processing' }
BonjourInterface >> removeConnectionOfv2: sv [

		self log: 'Removing connection of ', sv printString.
		connections
			at: sv id
			ifPresent:
				[: value | 
				value pump terminate.
				connections removeKey: sv id]
			ifAbsent:
				[self log: 'Connection not found when removing ' , sv printString.
				self log: sv sdRef printString].
		self deallocateSDRef: sv sdRef
]

{ #category : #structural }
BonjourInterface >> removeService: theService [

	self log:	'### Service removed: ' , theService fullName.

	theService serviceType removeService: theService.
	services remove: theService.
	self announce: (ServiceRemoved new service: theService) 
	

]

{ #category : #'_testing' }
BonjourInterface >> resetmDNSResponder [

	<script: 'self new resetmDNSResponder'>

	LibC runCommand:  'echo sim123 | sudo -S killall –HUP mDNSResponder'.
	LibC runCommand:  'echo sim123 | sudo -S killall –HUP mDNSHelper'.

]

{ #category : #configuration }
BonjourInterface >> resultsPumpPriority [

	"Must be greater than incomming system callbacks which is 69 to avoid seg fault on shut down.
	Also runs further - browse services of service type returns sometimes..."
	
	^72
	
	"^72" "v4 - runs to end when shutting down without crash"

	"^70"  "v1"
	
	"^70" "v2 > callback queue - jams on callback processing"
	
	"^71 "   "v3 - original"
]

{ #category : #callbacks }
BonjourInterface >> serviceAddress: sv [

	| address interfaceIndex | 
	
	self log:	'### Address: ', sv address, ' on interface: ', sv interfaceIndex, ' added to: ' , sv object fullName.
		
	(sv address includes: $:) & (sv address includes: $%)
		ifTrue: 
			[address := (sv address splitOn: $%) first.  "dns-sd looks up the interface name from the interface index"
			interfaceIndex := (sv address splitOn: $%) last.
			interfaceIndex := sv interfaceIndex, '/', interfaceIndex]
		ifFalse:
			[address := sv address.
			interfaceIndex := sv interfaceIndex].
			
	sv object
		addAddress: 
			(IPAddress new
				service: sv object;
				address: address;
				addInterface: interfaceIndex).
				
	self announce: (ServiceUpdated new service: sv object).
]

{ #category : #'accessing - domain' }
BonjourInterface >> serviceNamed: aServiceFullName [
	
	^services
		detect: [:each | each fullName = aServiceFullName]
		ifNone: [nil]
]

{ #category : #callbacks }
BonjourInterface >> serviceTypeFound: aServiceType [
	
	"A service type is returned for each machine interface - only interested in the type, 
	not the interfaces"
	serviceTypes
		detect: [:each | each registrationType = aServiceType registrationType]
		ifFound: [^self	].	
	
	registrationTypesToBrowse isEmpty
		ifTrue: 
			[self 
				addServiceType: aServiceType;
				browseServicesOf: aServiceType]
		ifFalse:
			[registrationTypesToBrowse
				detect: [:each | aServiceType registrationType = each]
				ifFound: [:value | 
						self 
							addServiceType: aServiceType;
							browseServicesOf: aServiceType]]
]

{ #category : #callbacks }
BonjourInterface >> serviceTypeLost: aServiceType [

	"Remove when last service of the type is removed?.
	
	Don't remove the service type as can have multiple types with the same name - one for each interface.
	Only interested in the type. "
	
	"
	| theServiceType | 

	self log:	'Service Type Lost: ' , aServiceType printString, ' interface ', aServiceType interfaceIndex.
	
	theServiceType := 
		serviceTypes 
			detect: [: each | each registrationType = aServiceType registrationType]
			ifNone: [self error: 'Service Type to remove not found', aServiceType registrationType].
	
	serviceTypes remove: theServiceType.

	self log: 'Removed ', theServiceType printString. "
	
	
	
	
]

{ #category : #'accessing - domain' }
BonjourInterface >> serviceTypes [
	
	^serviceTypes
]

{ #category : #'accessing - domain' }
BonjourInterface >> services [
	
	^services
]

{ #category : #'startUp - shutDown' }
BonjourInterface >> shutDown [

	"
	BonjourCommandLineInterface allInstances do: [: each | each shutDown]
	"

	<script: 'self shutDown'>
	
	self 
		log: '==============================================================================';
		log: 'Shutting down on ', self class name.
	
	registeredServices do: [:each | self deregister: each].
	0.5 seconds wait.	"Give the callbacks a chance to fire"

	(connections copy asSortedCollection: [: a : b | a id < b id]) do: [:each | 
			0.25 seconds wait.
			self removeConnectionOf: each].
	callbackProcess ifNotNil: [: value | value terminate].
	"interface class unloadLibraries."
	logFile ifNotNil: [logFileStream closed ifFalse: [logFileStream close]].
]

{ #category : #'startUp - shutDown' }
BonjourInterface >> startUpOnRegistrationTypes: registrationTypes [
	"Start browsing for regsitrationTypes. If empty, browse for all.
	E.g. _osc._udp. _osc._tcp. _rfb._tcp. _apple-midi_udp. _apple-lgremote._tcp.
	_rdlink._tcp. "
	
	registrationTypesToBrowse := registrationTypes.
	
	self startUp
]

{ #category : #'announcements-configuring' }
BonjourInterface >> unsubscribe: aSubscriber [
	
	announcer unsubscribe: aSubscriber
]

{ #category : #logging }
BonjourInterface >> viewLogFile [

	| aString |
	
	logFileStream flush.
	logFileStream  = Transcript ifTrue: [^self].
	
	logFile streamWritable: false do: [: stream | aString := stream upToEnd].
	
	(UIManager default edit: aString label: 'Log File: ' , logFile basename)
		extent: 800@900;
		position: 0@10
	
]

{ #category : #'callback processing' }
BonjourInterface >> waitForSeconds: seconds [

	self waitForSeconds: seconds for: ''

]

{ #category : #'callback processing' }
BonjourInterface >> waitForSeconds: seconds for: aString [

	self log: 'Waiting for ', seconds printString, ' seconds ', aString.
	1 second wait

]

{ #category : #announcements }
BonjourInterface >> when: anEvent send: aSelector to: anObject [
	
	announcer when: anEvent send: aSelector to: anObject
]
