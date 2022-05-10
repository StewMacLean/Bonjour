Class {
	#name : #BonjourCommandLineInterface,
	#superclass : #BonjourInterface,
	#instVars : [
		'busyWaitingForServiceResolutionStart'
	],
	#category : #'SIM-Bonjour'
}

{ #category : #structural }
BonjourCommandLineInterface >> addService: aService [

	aService serviceType addService: aService.
	services add: aService.
	self announce: (ServiceAdded new service: aService).
	(connections select: [: connection | 
			(#('Resolve Host Name' 'Get Addresses') includes: connection type)
				and: [connection service = aService]]) 
				do: [: connection |
					connection pump terminate.
					self deallocateSDRef: connection sdRef.
					connections removeKey: connection id]
]

{ #category : #api }
BonjourCommandLineInterface >> browseServiceTypes [

	| connection pump sdRef |
	
	sdRef := OSSUnixSubprocess new.
	pump :=
		[sdRef 
			command: 'dns-sd'; 
			arguments: #('-B' '_services._dns-sd._udp');
			redirectStdout;
			runAndWaitPollingEvery: (Delay forMilliseconds: 500)
			doing: [: process : outStream  |  
				self emitBrowseServiceTypeCallbacks: outStream upToEnd]
			onExitDo: [: process : outStream : errStream  |
				process closeAndCleanStreams.
				self 
					log: 'Browse Service Types OS Process has exited with status: ', 
						process exitStatusInterpreter printString]] newProcess.
 
	connection := StateVector new
		id: self nextConnectionID;
		name: 'Browse Service Types';
		type: 'Browse Service Types';
		pump: pump;
		sdRef: sdRef.
			
	connections
		at: connection id
		put: connection.	
			
	self log: '==> ', connection name, ' ', connection id printString.
		
	pump
		name: connection name;
		priority: 50;
		resume
]

{ #category : #api }
BonjourCommandLineInterface >> browseServicesOf: aServiceType [

	| connection pump sdRef |
	
	sdRef := OSSUnixSubprocess new.
	pump :=
		[sdRef 
			command: 'dns-sd'; 
			arguments: {'-B'. aServiceType registrationType};
			redirectStdout;
			runAndWaitPollingEvery: (Delay forMilliseconds: 500)
			doing: [: process : outStream  |  
				self emitBrowseServiceCallbacks: outStream upToEnd serviceType: aServiceType]
			onExitDo: [: process : outStream : errStream  |
				process closeAndCleanStreams.
				self 
					log: 'Browse Services OS Process has exited with status: ', 
						process exitStatusInterpreter printString]] newProcess.
 
	connection := StateVector new
		id: self nextConnectionID;
		name: 'Browse Services of type: ' , aServiceType registrationType;
		type: 'Browse Services';
		serviceType: aServiceType;
		pump: pump;
		sdRef: sdRef.
			
	connections
		at: connection id
		put: connection.	
		
	self log: '==> ', connection name, ' ', connection id printString.	
		
	pump
		name: connection name;
		priority: 50;
		resume
]

{ #category : #api }
BonjourCommandLineInterface >> deallocateSDRef: sdRef [

	self log: '==> ', 'Deallocating: ', sdRef printString.

	[sdRef sigterm] on: Error do: [: error | self log: 'sigterm error: ', error printString]

	
]

{ #category : #'_testing' }
BonjourCommandLineInterface >> deregisterRegisteredServices [

	<script: 'self current deregisterRegisteredServices'>
	
	self deregisterServices
]

{ #category : #'callback emitters' }
BonjourCommandLineInterface >> elapsedTimeWaitingForServiceResolution [

	^Timestamp now - busyWaitingForServiceResolutionStart
]

{ #category : #'callback emitters' }
BonjourCommandLineInterface >> emitBrowseServiceCallbacks: aString serviceType: aServiceType [

	| lines sv events theString linesAsSubstrings eventLines serviceIndex callbacks |
	
	aString ifEmpty: [^self]. "We're polling after all!"
	theString := aString asByteArray utf8Decoded.
	
	self log: '<<====================================================='.
	self log: 'EMIT Services for: ', aServiceType printString.
	self log: theString.
	
	
	false ifTrue: [^self].
	
	lines := theString substrings: {Character lf}.
	linesAsSubstrings := (lines collect: [: each | each substrings]).
	eventLines := OrderedCollection new.
	lines with: linesAsSubstrings do: [: line : substrings | 
		(#('Add' 'Rmv') includes: (substrings at: 2))
			ifTrue: [eventLines add: line trimmed]].
	events := eventLines collect: 
		 [: line | | readStream name registrationType addRemove domain interfaceIndex |
			readStream := line readStream.
			readStream nextAlphabeticWord.
			addRemove := readStream nextAlphabeticWord.
			readStream nextAlphabeticWord.
			interfaceIndex := readStream nextAlphabeticWord.
			domain := readStream nextAlphabeticWord.
			registrationType := readStream nextAlphabeticWord.
			name := readStream upToEnd.  "This can have spaces, so can't use substring."
			(sv := StateVector new)
				name: name;
				registrationType: registrationType;
				interfaceIndex: interfaceIndex.
				addRemove = 'Add'
					ifTrue: [sv event: 'Added']
					ifFalse: [sv event: 'Removed'].	
				sv domain: domain].
		
		serviceIndex := events "Remove the duplicates on each interface"
			groupedBy: [: each | 
				(StateVector new 
					event: each event; 
					name: each name; registrationType: 
					each registrationType; 
					domain: each domain) printString].
			
		callbacks := serviceIndex associations collect: [: each | | svEvent service |
				svEvent := StateVector new 
					object: 
						(service := Service new
							name: each value first name;
							serviceType: aServiceType; 
							domain: each value first domain).
				each value do: [: each1 | service addInterface: each1 interfaceIndex].
				(each key includesSubstring: 'Add')
					ifTrue: [svEvent event: 'Added']
					ifFalse: [svEvent event: 'Removed'].
				svEvent interfaceIndex: 'dummy index'. "to comply with framework"
				svEvent].	
				
		callbacks do: [: each | 
			callbackQueue nextPut: each.
			self log: 'Starting busy wait for...', each object printString.
			busyWaitingForServiceResolutionStart := Timestamp now.
			[(each object hostName isEmpty | each object addresses isEmpty)
			and: [self elapsedTimeWaitingForServiceResolution < 5 seconds]] "In case doesn't resolve fully..."
				whileTrue:
					[250 milliSeconds wait.
					self log: 'Busy waiting for...', each object printString.
					Processor yield].
			self log: 'Ended Busy wait for ', each object printString.
			each event = 'Added'
				ifTrue: [self addService: each object]
				ifFalse: ["Already removed in callback"]]  
				
		
						
		
		  
		
]

{ #category : #'callback emitters' }
BonjourCommandLineInterface >> emitBrowseServiceCallbacksv1: aString serviceType: aServiceType [

	| lines sv events theString linesAsSubstrings eventLines serviceIndex callbacks |
	
	aString ifEmpty: [^self]. "We're polling after all!"
	theString := aString asByteArray utf8Decoded.
	
	self log: '<<====================================================='.
	self log: 'EMIT Services for: ', aServiceType printString.
	self log: theString.
	
	
	false ifTrue: [^self].
	
	lines := theString substrings: {Character lf}.
	linesAsSubstrings := (lines collect: [: each | each substrings]).
	eventLines := OrderedCollection new.
	lines with: linesAsSubstrings do: [: line : substrings | 
		(#('Add' 'Rmv') includes: (substrings at: 2))
			ifTrue: [eventLines add: line trimmed]].
	events := eventLines collect: 
		 [: line | | readStream name registrationType addRemove domain interfaceIndex |
			readStream := line readStream.
			readStream nextAlphabeticWord.
			addRemove := readStream nextAlphabeticWord.
			readStream nextAlphabeticWord.
			interfaceIndex := readStream nextAlphabeticWord.
			domain := readStream nextAlphabeticWord.
			registrationType := readStream nextAlphabeticWord.
			name := readStream upToEnd.  "This can have spaces, so can't use substring."
			(sv := StateVector new)
				name: name;
				registrationType: registrationType;
				interfaceIndex: interfaceIndex.
				addRemove = 'Add'
					ifTrue: [sv event: 'Added']
					ifFalse: [sv event: 'Removed'].	
				sv domain: domain].
		
		serviceIndex := events 
			groupedBy: [: each | 
				(StateVector new 
					event: each event; 
					name: each name; registrationType: 
					each registrationType; 
					domain: each domain) printString].
			
		callbacks := serviceIndex associations collect: [: each | | svEvent service |
				svEvent := StateVector new 
					object: 
						(service := Service new
							name: each value first name;
							serviceType: aServiceType; 
							domain: each value first domain).
					(each value collect: [: each1 | service addInterface: each1 interfaceIndex]).
				(each key includesSubstring: 'Add')
					ifTrue: [svEvent event: 'Added']
					ifFalse: [svEvent event: 'Removed'].
				svEvent interfaceIndex: 'dummy index'. "to comply with framework"
				svEvent].	
				
		callbacks do: [: each | 
			callbackQueue nextPut: each.
			"self halt."
			[self log: self elapsedTimeWaitingForServiceResolution printMMSSlllccc.
			self elapsedTimeWaitingForServiceResolution > 1000 milliSeconds]
			whileFalse:
				[100 milliSeconds wait.
				self log: 'Busy wait...'.
				Processor yield].
			self log: 'Finished Busy wait for ', each object printString.
			each event = 'Added'
				ifTrue: [self addService: each object]
				ifFalse: ["self removeService: each object - already done in callback"]]  
				
		
						
		
		  
		
]

{ #category : #'callback emitters' }
BonjourCommandLineInterface >> emitBrowseServiceTypeCallbacks: aString [

	| lines sv stream domain protocol object events theString |

	aString ifEmpty: [^self].
	theString := aString asByteArray utf8Decoded.
	
	self log: '<<====================================================='.
	self log: 'EMIT Service Types: '.
	self log: aString.
	
	lines := theString substrings: {Character lf}.
	lines := lines collect: [: each | each substrings].
	lines := lines select: [: each | #('Add' 'Rmv') includes: (each at: 2)].
	events := lines collect: 
		 [: line | 
		(sv := StateVector new)
			name: (line at: 7);
			registrationType: (line at: 6);
			interfaceIndex: (line at: 4).
			 (line at: 2) = 'Add'
				ifTrue: [sv event: 'Added']
				ifFalse: [sv event: 'Removed'].	
			stream := ReadStream on: sv registrationType.
			protocol := stream through: $..
			domain := stream upToEnd.
			object := ServiceType new
				name: sv name;
				protocol: protocol;
				domain: domain;
				interfaceIndex: sv interfaceIndex.
			sv object: object.	
			callbackQueue nextPut: sv.
			]
]

{ #category : #'callback emitters' }
BonjourCommandLineInterface >> emitGetAddressesOfServiceCallbacks: aString service: aService connectionID: id [

	| lines sv events theString filteredLines |
	
	aString ifEmpty: [^self]. "We're polling after all!"
	theString := aString asByteArray utf8Decoded.
	
	self log: '<<====================================================='.
	self log: 'EMIT Addresses for: ', aService printString.
	self log: theString.
	
	
	false ifTrue: [^self].

	lines := theString substrings: {Character lf}.
	lines := lines collect: [: each | each substrings].
	lines := lines select: [: each | (each size > 1) and: [#('Add' 'Rmv') includes: (each at: 2)]].
	
	events := lines collect: 
		 [: line | 
		(sv := StateVector new)
			name: (line at: 5);
			interfaceIndex: (line at: 4);
			address: (line at: 6).
			 (line at: 2) = 'Add'
				ifTrue: [sv event: 'Added']
				ifFalse: [sv event: 'Removed'].	
			sv
				event: 'ServiceAddress';
				object: (connections at: id) service.
			callbackQueue nextPut: sv] 
]

{ #category : #'callback emitters' }
BonjourCommandLineInterface >> emitGetAddressesOfServiceCallbacksv1: aString service: aService connectionID: id [

	| lines sv events theString filteredLines |
	
	aString ifEmpty: [^self]. "We're polling after all!"
	theString := aString asByteArray utf8Decoded.
	
	self log: '<<====================================================='.
	self log: 'EMIT Addresses for: ', aService printString.
	self log: theString.
	
	
	false ifTrue: [^self].

	lines := theString substrings: {Character lf}.
	lines := lines collect: [: each | each substrings].
	lines := lines select: [: each | (each size > 1) and: [#('Add' 'Rmv') includes: (each at: 2)]].
	"Remove duplicates - note ip6 are suffixed with interface, so differs from Discovery"
	lines := (lines groupedBy: [: each | each at: 6]) values collect: [: oc | oc first].
	
	events := lines collect: 
		 [: line | 
		(sv := StateVector new)
			name: (line at: 5);
			interfaceIndex: (line at: 4);
			address: (line at: 6).
			 (line at: 2) = 'Add'
				ifTrue: [sv event: 'Added']
				ifFalse: [sv event: 'Removed'].	
			sv
				event: 'ServiceAddress';
				object: (connections at: id) service.
			callbackQueue nextPut: sv] 
]

{ #category : #'callback emitters' }
BonjourCommandLineInterface >> emitRegisterServiceCallbacks: aString service: aService connectionID: id [

	| lines errorLines theString connection sv |

	aString ifEmpty: [^self].
	theString := aString asByteArray utf8Decoded.
	

	self log: '<<====================================================='.
	self log: 'EMIT Register Service: '.
	self log: aString.
	
	lines := theString substrings: {Character lf}.
	errorLines := lines select: [: each | 
			(each includesSubstring: 'DNSServiceRegister failed') | 
			(each includesSubstring: '<Name> <Type> <Domain>')].
		
	errorLines 
		ifNotEmpty: 
			[self log: 'Registration of Service: ', aService printString, ' failed'.
			connection := connections at: id.
			connection pump terminate.
			self deallocateSDRef: connection sdRef.
			connections removeKey: connection id]
		ifEmpty: 
			[aService sdRef: (connections at: id) sdRef.
			(sv := StateVector new)
				id: id;
				sdRef: (connections at: id) sdRef;
				event: 'ServiceRegistered';
				object: aService.
			callbackQueue nextPut: sv]
				
			
			
			
			
		
	
			
]

{ #category : #'callback emitters' }
BonjourCommandLineInterface >> emitResolveServiceCallbacks: aString service: aService connectionID: id [

	| lines sv stream theString filteredLines |

	aString ifEmpty: [^self]. "We're polling after all!"
	theString := aString asByteArray utf8Decoded.

	self log: '<<====================================================='.
	self log: 'EMIT Resolve Host for: ', aService printString.
	self log: theString.
	
	false ifTrue: [^self].

	lines := theString substrings: {Character lf}.
	lines := lines reject: [: each | 
			(each includesSubstring: 'Lookup') | 
			(each includesSubstring: 'DATE') | 
			(each includesSubstring: 'STARTING')].
		
	filteredLines := OrderedCollection new
		add: lines first; yourself.
	(lines size > 1 and: [lines second includes: $=])
		ifTrue: [filteredLines add: lines second].

	stream := filteredLines readStream.
	[stream atEnd] whileFalse: [| host port interfaceIndex line textRecord textLength |
		textLength := 0. textRecord := ''.
		line := stream next trimmed.
		host := line readStream upToAll: 'reached at'; next; upTo: $:.
		port := line readStream upToAll: 'reached at'; next; upTo: $:; upTo: Character space.
		interfaceIndex := line readStream upToAll: 'interface'; next; upTo: $).
		(stream peek ifNil: [false] ifNotNil: [: value | value includesSubstring: '='])
			ifTrue: [textRecord := stream next trimmed. textLength := textRecord size].
		(sv := StateVector new)
			id: id;
			sdRef: (connections at: id) sdRef;
			event: 'ServiceResolved';
			hostName: host;
			port: port;
			interfaceIndex: interfaceIndex;
			textLength: textLength;
			textRecord: textRecord.
			sv object: aService.
		callbackQueue nextPut: sv].
]

{ #category : #api }
BonjourCommandLineInterface >> getAddressesOf: aService [

	| connection pump sdRef | 
	
	false ifTrue: [^self].
	
	sdRef := OSSUnixSubprocess new.
	pump :=
		[sdRef 
			command: 'dns-sd'; 
			arguments: {'-G'. 'v4v6'. aService hostName};
			redirectStdout;
			runAndWaitPollingEvery: (Delay forMilliseconds: 500)
			doing: [: process : outStream  |  
				self 
					emitGetAddressesOfServiceCallbacks: outStream upToEnd 
					service: aService 
					connectionID: connection id]
			onExitDo: [: process : outStream : errStream  |
				process closeAndCleanStreams.
				self 
					log: 'Get Addresses of Service OS Process has exited with status: ', 
						process exitStatusInterpreter printString]] newProcess.
 
	connection := StateVector new
		id: self nextConnectionID;
		name: 'Get Addresses of: ' , aService printString;
		type: 'Get Addresses';
		service: aService;
		pump: pump;
		sdRef: sdRef.
			
	connections
		at: connection id
		put: connection.	
			
	self log: '==> ', connection name, ' ', connection id printString.	
		
	pump
		name: connection name;
		priority: 50;
		resume
]

{ #category : #'_testing' }
BonjourCommandLineInterface >> inspectInterface [

	<script: 'self current inspect'>
]

{ #category : #'_testing' }
BonjourCommandLineInterface >> listServices [

	<script: 'self current logAllServices'>
	
	self listServicesHierarchically inspect 
]

{ #category : #'_testing' }
BonjourCommandLineInterface >> openApp [

	"
	BonjourCommandLineInterface allInstances do: [: each | each shutDown].
	BonjourCommandLineInterface allInstances do: [: each | each become: Object new].
	BonjourCommandLineInterface resetCurrent.
	BonjourCommandLineInterface shutDown.
	"

	<script: 'self new openApp'>

	^DiscoveryApp openOn: self class uniqueInstance
		
	
]

{ #category : #api }
BonjourCommandLineInterface >> register: aService [

	| connection pump sdRef | 
	
	sdRef := OSSUnixSubprocess new.
	pump :=
		[sdRef 
			command: 'dns-sd'; 
			arguments: 
				({'-R'. aService name. aService registrationType. aService domain. aService port} asOrderedCollection
					addAll: aService textRecordPairsCommandLineCalloutParameters; yourself);
			redirectStdout;
			runAndWaitPollingEvery: (Delay forMilliseconds: 500)
			doing: [: process : outStream  |  
				self 
					emitRegisterServiceCallbacks: outStream upToEnd 
					service: aService 
					connectionID: connection id]
			onExitDo: [: process : outStream : errStream  |
				process closeAndCleanStreams.
				self 
					log: 'Register Service OS Process has exited with status: ', 
						process exitStatusInterpreter printString]] newProcess.
 
	connection := StateVector new
		id: self nextConnectionID;
		name: 'Register Service: ' , aService printString;
		type: 'Register Service';
		service: aService;
		pump: pump;
		sdRef: sdRef.
			
	connections
		at: connection id
		put: connection.	
			
	self log: '==> ', connection name, ' ', connection id printString.	
		
	pump
		name: connection name;
		priority: 50;
		resume
]

{ #category : #api }
BonjourCommandLineInterface >> resolve: aService [ 

	| connection pump sdRef | 
	
	false ifTrue: [^self].
	
	sdRef := OSSUnixSubprocess new.
	pump :=
		[sdRef 
			command: 'dns-sd'; 
			arguments: {'-L'. aService name. aService registrationType. aService domain};
			redirectStdout;
			runAndWaitPollingEvery: (Delay forMilliseconds: 500)
			doing: [: process : outStream  |  
				self 
					emitResolveServiceCallbacks: outStream upToEnd 
					service: aService 
					connectionID: connection id]
			onExitDo: [: process : outStream : errStream  |
				process closeAndCleanStreams.
				self 
					log: 'Resolve Host Name of Service OS Process has exited with status: ', 
						process exitStatusInterpreter printString]] newProcess.
 
	connection := StateVector new
		id: self nextConnectionID;
		name: 'Resolve Host Name of: ' , aService printString;
		type: 'Resolve Host Name';
		service: aService;
		pump: pump;
		sdRef: sdRef.
			
	connections
		at: connection id
		put: connection.	
			
	self log: '==> ', connection name, ' ', connection id printString.	
		
	pump
		name: connection name;
		priority: 50;
		resume
]

{ #category : #'_testing' }
BonjourCommandLineInterface >> runRegistrationTests [

	<script: 'self current runRegistrationTests'>


	self registerOSCUDPService. "- don't upset Cameron!"
	self registerappleLGREMOTETCPService
]

{ #category : #callbacks }
BonjourCommandLineInterface >> serviceAddress: sv [

	| address | 
	
	self log:	'<== Service Address: ', sv address, ' for: ' , sv object printString, ' interface ', sv interfaceIndex.
	
	(sv address includes: $:)
		ifTrue: 
			[address := (sv address splitOn: $%) first.
			interface := (sv address splitOn: $%) last.
			interface := sv interfaceIndex, '/', interface]
		ifFalse:
			[address := sv address.
			interface := sv interfaceIndex].
			
	sv object
		addAddress: 
			(IPAddress new
				service: sv object;
				address: address;
				addInterface: interface)
]

{ #category : #callbacks }
BonjourCommandLineInterface >> serviceAddressv1: sv [
	
	| theService |
	
	self log:	'<== Service Address for: ' , sv object printString, ' interface ', sv interfaceIndex.
	
	self log: 'address: ', sv address.
	
	(theService := sv object) addAddress: sv address.
]

{ #category : #callbacks }
BonjourCommandLineInterface >> serviceFound: aService on: anInterfaceIndex [
	
	self log:	'<== Service Found for: ' , aService printString.
	
	self resolve: aService	
]

{ #category : #callbacks }
BonjourCommandLineInterface >> serviceLost: aService on: anInterfaceIndex callback: aCallbackSV [
	
	| theService |
	
	self log:	'<== Service Lost for: ' , aService printString, ' interface: ', anInterfaceIndex.
	
	theService := services
		detect: [:each | each fullName = aService fullName]
		ifNone: 
			[self 
				log: 'WARNING: Service to remove not found: ', aService printString;
				log: 'This can occur when two separate Rmv emits occur for separate interfaces'.
			^aService addAddress: 
				(IPAddress new 
					address: 'Don''t wait for me, dummy!'; 
					addInterface: anInterfaceIndex)].
		
	aCallbackSV object: theService.
	
	self removeService: theService
]

{ #category : #callbacks }
BonjourCommandLineInterface >> serviceRegistered: sv [
	"Service has been registered.
	Note that it is not added as a service here, but is added through the service discovery service found callback.
	Assumption: - that service discovery includes the registered service type."
	
	self log:	'<== Service Registered for: ' , sv object printString.
		
	registeredServices
		at: sv object fullName
		put: sv object
]

{ #category : #callbacks }
BonjourCommandLineInterface >> serviceResolved: sv [

	self log:	'<== Service Resolved for: ' , sv object printString, ' interface: ', sv interfaceIndex.
				
	sv object 
		hostName: sv hostName;
		port: sv port;
		textRecordPairs: (self textRecordPairsFrom: sv textRecord).
		self log: 'Fire off get Addresses...'.
		self getAddressesOf: sv object
]

{ #category : #'startUp - shutDown' }
BonjourCommandLineInterface >> shutDown [

	<script: 'self shutDown'>
	
	super shutDown
]

{ #category : #'startUp - shutDown' }
BonjourCommandLineInterface >> startUp [

	<script: 'self startUp'>
	
	self log: 'Starting Up on dns-sd'.
	
	self initializeOnStartUp.
	
	"self browseServiceTypes"
	
	"self startUpOnRegistrationTypes: #('_airplay._tcp.')."
	
	"self startUpOnRegistrationTypes: #('_companion-link._tcp.')."
	
	self startUpOnRegistrationTypes: #('_rdlink._tcp.')
	
]

{ #category : #parsing }
BonjourCommandLineInterface >> textRecordPairsFrom: aString [

	"
	'NoSpacesKey=NoMessCharlie Rendezvous\ Is\ Cool=coolio\ value key=value keyNoValue'
	"

	| stream pairStream pairs keyValue next parsePair |
	
	aString ifEmpty: [^#()]. 
	
	stream :=  aString readStream.
	pairs := OrderedCollection new.
	
	parsePair := 
		[(keyValue := pairStream contents splitOn: $=) size = 2
			ifTrue:
				[pairs add:
					(TextRecordPair 
						key: (keyValue at: 1)
						value: (keyValue at: 2))]
			ifFalse: 
				[pairs add:
					(TextRecordPair 
						key: (keyValue at: 1)
						value: '')].
			pairStream := String new writeStream.
			stream next].
	
	pairStream := String new writeStream.
	[stream atEnd] whileFalse: 
		[next := stream peek.
		next = $\
			ifTrue: 
				[stream next.
				stream atEnd ifFalse: [pairStream nextPut: stream next]] ifFalse: 
		[next = Character space
			ifTrue:
				[parsePair value] ifFalse: 
		[pairStream nextPut: stream next]]].
	parsePair value. "Consume the leftovers!"
		
	^pairs
		
		
]

{ #category : #'startUp - shutDown' }
BonjourCommandLineInterface >> viewLog [

	<script: 'self current viewLog'>
	
	self viewLogFile
	

	
	
	
]
