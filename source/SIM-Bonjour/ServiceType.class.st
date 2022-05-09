Class {
	#name : #ServiceType,
	#superclass : #BonjourModelObject,
	#instVars : [
		'interfaceIndex',
		'protocol',
		'domain',
		'services',
		'domainObject'
	],
	#category : #'SIM-Bonjour-Model'
}

{ #category : #'As yet unclassified' }
ServiceType class >> name: aServiceTypeName protocol: aTransportProtocol [
	
	^(self new)
		name: aServiceTypeName;
		protocol: aTransportProtocol
]

{ #category : #'instance creation' }
ServiceType class >> new [
	
	^super new initialize
]

{ #category : #'As yet unclassified' }
ServiceType class >> tcpName: aString [
	
	^self name: aString protocol: 'tcp'
]

{ #category : #'As yet unclassified' }
ServiceType class >> udpName: aString [
	
	^self name: aString protocol: 'udp'
]

{ #category : #accessing }
ServiceType >> addService: aService [
	
	services add: aService.
	services := (services asSortedCollection: 
		[: a : b | a name < b name]) asOrderedCollection.
	aService serviceType: self.
	
	^aService
]

{ #category : #callback }
ServiceType >> calledback: sv for: anInterface [
	
	"anInterface
		log: 'Service Type Callback: ' , sv event , ' ' , self printString."
	sv event = 'Added'
		ifTrue: [anInterface serviceTypeFound: self]
		ifFalse: [anInterface serviceTypeLost: self]
]

{ #category : #accessing }
ServiceType >> children [

	^services
]

{ #category : #printing }
ServiceType >> displayNodes [

	^services
]

{ #category : #printing }
ServiceType >> displayStringUI [

	^self registrationType
]

{ #category : #accessing }
ServiceType >> domain [
	
	^domain
]

{ #category : #accessing }
ServiceType >> domain: anObject [
	
	domain := anObject
]

{ #category : #accessing }
ServiceType >> domainObject: aDomain [

	domainObject := aDomain
]

{ #category : #'initialize-release' }
ServiceType >> initialize [
	
	super initialize.
	protocol := ''.
	domain := '.'.	"What gets returned when browsing using mDNSResponder"
	domain := 'local.'. "What gets returned when browsing using dns-sd"
	interfaceIndex := '0'.
	services := OrderedCollection new
]

{ #category : #accessing }
ServiceType >> interfaceIndex [
	
	^interfaceIndex
]

{ #category : #accessing }
ServiceType >> interfaceIndex: anObject [
	
	interfaceIndex := anObject
]

{ #category : #accessing }
ServiceType >> isAppleLGREMOTETCP [
	
	^self registrationType = '_apple-lgremote._tcp.'
]

{ #category : #accessing }
ServiceType >> isAppleMIDIUDP [
	
	^self registrationType = '_apple-midi._udp.'
]

{ #category : #accessing }
ServiceType >> isOSCTCP [
	
	^self registrationType = '_osc._tcp.'
]

{ #category : #accessing }
ServiceType >> isOSCUDP [
	
	^self registrationType = '_osc._udp.'
]

{ #category : #printing }
ServiceType >> isService [

	^true
]

{ #category : #accessing }
ServiceType >> name [
	
	^name
]

{ #category : #accessing }
ServiceType >> name: aString [
	"The service type (name). 
	Eg:
		ftp
		osc
		ftb
		apple-midi
	"
	
	name := aString copyWithout: $_	"Remove the underscore prefix returned by the api"
]

{ #category : #accessing }
ServiceType >> parent [

	^domainObject
]

{ #category : #printing }
ServiceType >> printOn: aStream [
	"super printOn: aStream."
	
	aStream 
		nextPutAll: 'ServiceType';
		nextPut: $(;
		nextPutAll: name;
		space;
		space;
		nextPutAll: protocol;
		space;
		space;
		nextPutAll: domain;
		space;
		space;
		nextPutAll: interfaceIndex "printString".
	aStream nextPut: $)
]

{ #category : #accessing }
ServiceType >> protocol [
	
	^protocol
]

{ #category : #accessing }
ServiceType >> protocol: aString [
	"The transport protocol must be either tcp or udp"
	
	protocol := (aString copyWithout: $_) copyWithout: $.	"Remove the underscore prefix separator and trailing dot returned by the api"
]

{ #category : #accessing }
ServiceType >> registrationType [
	"Service type followed by the protocol, separated by a dot, and suffexed with a dot.
	The transport protocol must be _tcp or _udp
	Bonjour service names combine service types and transport protocols to form a registration type. 
	The registration type is used to register a service and create DNS resource records for it. 
	To distinguish registration types from domain names in DNS resource records, registration types use 
	underscore prefixes to separate the components that make up a registration type. 
	The format is

	_ServiceType._TransportProtocolName.

	E.g.

	_ftp._tcp.
	_osc._udp.
	_osc._tcp.
	_apple-lgremote._tcp.

	"
	
	^'_' , name , '._' , protocol , '.'
]

{ #category : #accessing }
ServiceType >> removeService: aService [
	
	services remove: aService.	"aService serviceType: nil.  keep as may reference when printing"
	^aService
]

{ #category : #accessing }
ServiceType >> services [

	^services
]

{ #category : #printing }
ServiceType >> systemIcon [

	 ^Smalltalk ui icons iconNamed: #magnitudeIcon 
]
