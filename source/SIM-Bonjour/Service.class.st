Class {
	#name : #Service,
	#superclass : #BonjourModelObject,
	#instVars : [
		'serviceType',
		'domain',
		'hostName',
		'addresses',
		'textRecordPairs',
		'port',
		'sdRef',
		'interfaces'
	],
	#category : #'SIM-Bonjour-Model'
}

{ #category : #'instance creation' }
Service class >> new [
	
	^super new initialize
]

{ #category : #'text record/pairs' }
Service >> _textRecordDocumentation [
	"Each service has an associated DNS TXT record. 
	The application can use it to publish a small amount of metadata. The record contains key-value pairs. 
	The keys must be all printable ascii characters excluding ‘=’. 
	The value may contain any data.
	Non-string values are automatically converted. Buffer objects as values work too.
	The size of the TXT record is very limited. That is because everything has to fit into a single DNS message (512 bytes).
	The documentation mentions a “typical size” of 100-200 bytes, whatever that means. 
	There also is a hard limit of 255 bytes for each key-value pair. That’s why they also recommend short keys (9 bytes max). "
	"
	https://agnat.github.io/node_mdns/user_guide.html#txt_records
	http://www.zeroconf.org/Rendezvous/txtrecords.html
	"
	"Rules for Names in DNS-SD Name/Value pairs
The "
	"Name"
	" MUST be at least one character. Strings beginning with an '=' character (i.e. the name is missing) SHOULD be silently ignored.

The characters of "
	"Name"
	" MUST be printable US-ASCII values (0x20-0x7E), excluding '=' (0x3D).

Spaces in the name are significant, whether leading, trailing, or in the middle — so don't include any spaces unless you really indend that!

Case is ignored when interpreting a name, so "
	"papersize=A4"
	", "
	"PAPERSIZE=A4"
	" and "
	"Papersize=A4"
	" are all identical.

If there is no '=', then it is a boolean attribute, and is simply identified as being present, with no value.

When examining a TXT record for a given named attribute, there are therefore four broad categories of result which may be returned:

Attribute not present (Absent)
Attribute present, with no value (e.g. "
	"Anon Allowed"
	" — server allows anonymous connections)
Attribute present, with empty value (e.g. "
	"Installed PlugIns="
	" — server supports plugins, but none are presently installed)
Attribute present, with non-empty value (e.g. "
	"Installed PlugIns=JPEG,MPEG2,MPEG4"
	")
Unless specified otherwise by a particular DNS-SD (Rendezvous) profile, a given attribute name may appear at most once in a TXT record. If a client receives a TXT record containing the same attribute name more than once, then the client SHOULD silently ignore all but the first occurrence of that attribute. For client implementations that process a DNS-SD TXT record from start to end, placing name/value pairs into a hash table, using the name as the hash table key, this means that if the implementation attempts to add a new name/value pair into the table and finds an entry with the same name already present, then the new entry being added should be silently discarded instead. For client implementations that retrieve name/value pairs by searching the TXT record for the requested name, they should search the TXT record from the start, and simply return the first matching name they find.

Each author defining a DNS-SD (Rendezvous) profile for discovering instances of a particular type of service should define the interpretation of these different kinds of result. For example, for some keys, there may be a natural boolean interpretation:

Absent implies 'false'
Present with no value implies 'true'
For other keys it may be sensible to define other semantics, such as:

Present with value implies that value. E.g. "
	"Color=4"
	" for a four-color ink-jet printer, or "
	"Color=6"
	" for a six-color ink-jet printer.
Present with emply value implies 'false'. E.g. Not a color printer.
Absent implies 'Unknown'. E.g. A print server connected to some unknown printer where the print server doesn't actually know if the printer does color or not — which gives a very bad user experience and should be avoided wherever possible.
(Note that this is a hypothetical example, not an example of real name/value keys for printing.)

As a general rule, names that contain no dots are defined as part of the open-standard definition written by the person or group defining the DNS-SD (Rendezvous) profile for discovering that particular service type. Vendor-specific extensions should be given names of the form keyname.company.com=value, using a domain name legitimately registered to the person or organization creating the vendor-specific key. This reduces the risk of accidental conflict if different organizations each define their own vendor-specific keys.

Rules for values in DNS-SD Name/Value pairs
If there is an '=', then everything after the first '=' to the end of the string is the value. The value can contain any eight-bit values including '='. Leading or trailing spaces are part of the value, so don't put them there unless you intend them to be there. Any quotation marks around the value are part of the value, so don't put them there unless you intend them to be part of the value.

The value is opaque binary data. Often the value for a particular attribute will be US-ASCII (or UTF-8) text, but it is legal for a value to be any binary data. For example, if the value of a key is an IPv4 address, that address should simply be stored as four bytes of binary data, not as a variable-length 7-15 byte ASCII string giving the address represented in textual dotted decimal notation.

Generic debugging tools should generally display all attribute values as if they were UTF-8 text, except for attributes where the debugging tool has embedded knowledge that the value is some other kind of data.

Authors defining DNS-SD (Rendezvous) profiles SHOULD NOT convert binary attribute data types into printable text (e.g. using hexadecimal, Base64 or UU encoding) merely for the sake of making the data be printable text when seen in a generic debugging tool. Doing this simply bloats the size of the TXT record, without truly making the data any more understandable to someone looking at it in a generic debugging tool.

Example TXT record containing three name/value pairs
-------------------------------------------------------------------
| 0x0A | name=value | 0x08 | paper=A4 | 0x12 | Rendezvous Is Cool |
-------------------------------------------------------------------"
	
	
]

{ #category : #accessing }
Service >> addAddress: anIPAddress [

	| theAddress |
	
	theAddress := addresses detect: [: each |
		each address = anIPAddress address]
			ifNone: [addresses add: anIPAddress].
			
	theAddress 
		service: self;
		addInterface: anIPAddress interfaces asOrderedCollection first
]

{ #category : #accessing }
Service >> addAddressv1: anIPAddressString [
	
	anIPAddressString = '0.0.0.0' ifTrue: [^self].	"INADDR_ANY, which is the same as the address 0.0.0.0?"
	^addresses
		add: anIPAddressString;
		yourself
]

{ #category : #accessing }
Service >> addInterface: anInterfaceIndex [
	
	^interfaces
		add: anInterfaceIndex;
		yourself
]

{ #category : #'text record/pairs' }
Service >> addTextRecordPair: aPair [

	textRecordPairs add: aPair.
	textRecordPairs := (textRecordPairs asSortedCollection: [: a : b | a key < b key]) asOrderedCollection.
	
	^aPair
]

{ #category : #accessing }
Service >> address [
	
	^addresses isEmpty
		ifFalse: [addresses first]
		ifTrue: ['']
]

{ #category : #'attributes - virtual' }
Service >> addressAsByteArray [
	
	^IPSocketAddress stringToBytes: self address
]

{ #category : #printing }
Service >> addressPortString [
	
	^self address , ':' , port "printString"
]

{ #category : #accessing }
Service >> addresses [

	^addresses
]

{ #category : #callback }
Service >> calledback: sv for: anInterface [
	
	sv event = 'ServiceRegistered' 
		ifTrue: [anInterface serviceRegistered: sv].
	sv event = 'Added'
		ifTrue:
			[anInterface
				serviceFound: self
				on: sv interfaceIndex].
	sv event = 'Removed'
		ifTrue:
			[anInterface
				serviceLost: self
				on: sv interfaceIndex
				callback: sv].
	sv event = 'ServiceResolved' 
		ifTrue: [anInterface serviceResolved: sv].
	sv event = 'ServiceAddress' 
		ifTrue: [anInterface serviceAddress: sv]
]

{ #category : #printing }
Service >> displayNodes [

	| nodes |

	^(nodes := OrderedCollection new)
		add: (StateVector new displayStringUI: hostName; displayNodes: #());
		addAll: addresses;
		addAll: textRecordPairs;
		yourself
		
]

{ #category : #printing }
Service >> displayString [
	
	| aStream |
	aStream := WriteStream on: String new.
	aStream
		nextPutAll: self name;
		space.
	addresses isEmpty
		ifTrue:
			[aStream
				nextPutAll: ' no address';
				space]
		ifFalse:
			[addresses
				do:
					[:each | 
					aStream
						nextPutAll: each;
						space].
			aStream skip: -1.
			aStream nextPut: $:].
	aStream
		nextPutAll: port;
		space.
	textRecordPairs do: [: each |
			aStream
				nextPutAll: each displayString;
				space].
	aStream skip: -1.
	^aStream contents
]

{ #category : #accessing }
Service >> domain [
	"^serviceType domain"
	"local domain for ServiceType is '.', local domain returned for Service is 'local.' - use this to see if it fixes bad argument"
	
	^domain
]

{ #category : #accessing }
Service >> domain: anObject [
	
	domain := anObject
]

{ #category : #'attributes - virtual' }
Service >> fullName [
	"The service name followed by the service type name followed the protocol followed by the domain in the format of:
	name dot underscore type dot underscore protocol dot domain.
	E.g:
	MusicMac._rfb._tcp.local. 
	MusicMac._apple-midi._udp.local.
	MusicMac._osc._udp.local.
	Cameron’s MacBook Air._osc._udp.local. 
	Pauline Ann's iPad._apple-midi._udp.local.
	"
	
	^name , '.' , self registrationType , domain
]

{ #category : #accessing }
Service >> hostName [
	
	^hostName
]

{ #category : #accessing }
Service >> hostName: aString [
	
	hostName := aString
]

{ #category : #'initialize-release' }
Service >> initialize [
	
	super initialize.
	serviceType := ServiceType new.	"address := IPSocketAddress hostName: '' port: 0."
	hostName := ''.
	port := '0'.
	domain := ''.
	textRecordPairs := OrderedCollection new.
	addresses := OrderedCollection new.
	interfaces := OrderedCollection new
]

{ #category : #accessing }
Service >> interface [
	
	^interfaces first
]

{ #category : #accessing }
Service >> interfaces [
	
	^interfaces
]

{ #category : #printing }
Service >> interfacesPrintString [

	| stream |
	
	stream := String new writeStream.

	interfaces isEmpty
		ifFalse:
			[stream nextPut: ${.
			interfaces
				do:
					[:each | 
					stream
						nextPutAll: each "printString";
						space].
			stream skip: -1.
			stream
				nextPut: $};
				space].	
			
		^stream contents
]

{ #category : #testing }
Service >> isAppleLGREMOTETCP [
	
	^serviceType isAppleLGREMOTETCP
]

{ #category : #testing }
Service >> isAppleMIDIUDP [
	
	^serviceType isAppleMIDIUDP
]

{ #category : #testing }
Service >> isOSCUDP [
	
	^serviceType isOSCUDP
]

{ #category : #printing }
Service >> log: aString for: aLogger [
	
	aLogger log: aString
]

{ #category : #accessing }
Service >> name [
	
	^name
]

{ #category : #accessing }
Service >> name: anObject [
	
	name := anObject
]

{ #category : #accessing }
Service >> parent [

	^serviceType
]

{ #category : #accessing }
Service >> port [
	
	^port
]

{ #category : #accessing }
Service >> port: anObject [
	
	port := anObject asString
]

{ #category : #printing }
Service >> printOn: aStream [
		
	aStream
		nextPutAll: self fullName;
		space.	
	aStream nextPutAll: self interfacesPrintString. 
	addresses isEmpty
		ifTrue:
			[aStream
				nextPutAll: ' no address';
				space]
		ifFalse:
			[aStream nextPut: $[.
			addresses
				do:
					[:each | 
					aStream
						nextPutAll: each printString;
						space].
			aStream skip: -1.
			aStream
				nextPut: $];
				space].
	aStream
		nextPutAll: port;
		space.	
	textRecordPairs do: [: each |
			aStream
				nextPutAll: each displayString;
				space].
	aStream skip: -1
]

{ #category : #registering }
Service >> registerOn: aBonjourInterface [
	
	aBonjourInterface registerService: self
]

{ #category : #'attributes - virtual' }
Service >> registrationType [
	"The service type followed by the protocol, separated by a dot. 
	The transport protocol must be _tcp or _udp
	E.g.
	_ftp._tcp
	_osc._udp
	_apple-midi._udp
	"
	
	^serviceType
		ifNotNil: [serviceType registrationType]
		ifNil: [nil]
]

{ #category : #accessing }
Service >> removeInterface: anInterfaceIndex [
	
	^[interfaces remove: anInterfaceIndex]
		on: Error
		do: [:ex | ]
]

{ #category : #accessing }
Service >> sdRef [
	
	^sdRef
]

{ #category : #accessing }
Service >> sdRef: anObject [
	
	sdRef := anObject
]

{ #category : #accessing }
Service >> serviceType [
	
	^serviceType
]

{ #category : #accessing }
Service >> serviceType: anObject [
	
	serviceType := anObject
]

{ #category : #printing }
Service >> systemIcon [

	 ^Smalltalk ui icons iconNamed: #announcementIcon
]

{ #category : #'text record/pairs' }
Service >> textLengthFromTextRecordPairs [
	"The TXT record rdata. A non-NULL txtRecord MUST be a properly formatted DNS
	TXT record, i.e. <length byte> <data> <length byte> <data> ...
	Passing NULL for the txtRecord is allowed as a synonym for txtLen=1, txtRecord="
	",
	 i.e. it creates a TXT record of length one containing a single empty string.
	RFC 1035 doesn't allow a TXT record to contain *zero* strings, so a single empty
	string is the smallest legal DNS TXT record."
	
	| size |
	size := 0.
	textRecordPairs do:
			[: each | 
			size := size + 1.	"Single byte with value of key/value size <length byte>"
			size := size + each key size.	"+ key size"
			each value isEmpty ifFalse: [size := size + 1 + each value size]].	"+1 for $= + size of value"
	^size
]

{ #category : #'text record/pairs' }
Service >> textRecordLibraryCalloutParameter [
	
	^self textLengthFromTextRecordPairs = 0
		ifTrue: [nil]
		ifFalse: 
			[| stream |
			stream := ByteArray new writeStream.
			textRecordPairs do:
					[: each | 
					stream
						nextPut:
							each key size
								+
							(each value isEmpty
								ifTrue: [0]
								ifFalse: [1]) + each value size.
					each key do: [:char | stream nextPut: char asInteger].
					each value isEmpty
						ifFalse:
							[stream nextPut: $= asInteger.
							each value do: [:char | stream nextPut: char asInteger]]].
			stream contents asString]
]

{ #category : #'text record/pairs' }
Service >> textRecordPairs [

	^textRecordPairs

]

{ #category : #'text record/pairs' }
Service >> textRecordPairs: someTextRecordPairs [

	someTextRecordPairs do: [: each | self addTextRecordPair: each]

]

{ #category : #'text record/pairs' }
Service >> textRecordPairsCommandLineCalloutParameters [

	| stream |
	
	
	^textRecordPairs inject: OrderedCollection new into: [: result : each |
		stream := String new writeStream.
		each keyValueString do: [: ch |
			ch = Character space
				ifFalse: [stream nextPut: ch]
				ifTrue: [stream nextPut: $\; nextPut: ch]].
		result 
			add: stream contents;
			yourself] 
	

	
]

{ #category : #'text record/pairs' }
Service >> valueForTextPairKey: aKey [

	^(textRecordPairs 
		detect: [: each |each key = aKey] 
		ifNone: [TextRecordPair key: 'dummy' value: ''])
			value

]
