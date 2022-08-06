Class {
	#name : #SocketAddressStructure,
	#superclass : #FFIExternalStructure,
	#classVars : [
		'OFFSET_ADDRESS',
		'OFFSET_FAMILY',
		'OFFSET_LENGTH',
		'OFFSET_PORT',
		'OFFSET_ZERO_PART1',
		'OFFSET_ZERO_PART2'
	],
	#category : #'SIM-Bonjour'
}

{ #category : #'field definition' }
SocketAddressStructure class >> fieldsDesc [

	"
	self rebuildFieldAccessors
	"

	^#(
	uint8		length;
	uint8 		family;
	uint16 	port;
	uint32 	address;
	uint32 	zero_part1;
	uint32 	zero_part2;	
	)



  "^#(
   char				sin_len;
	char		 		sin_family;
	char				sin_port[2];    
	char				sin_addr[4];
	char				sin_zero[8]; 
    )"
]

{ #category : #'accessing - structure variables' }
SocketAddressStructure >> address [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_ADDRESS
]

{ #category : #'accessing - structure variables' }
SocketAddressStructure >> address: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_ADDRESS put: anObject
]

{ #category : #'accessing - structure variables' }
SocketAddressStructure >> family [
	"This method was automatically generated"
	^handle unsignedByteAt: OFFSET_FAMILY
]

{ #category : #'accessing - structure variables' }
SocketAddressStructure >> family: anObject [
	"This method was automatically generated"
	handle unsignedByteAt: OFFSET_FAMILY put: anObject
]

{ #category : #'accessing - structure variables' }
SocketAddressStructure >> length [
	"This method was automatically generated"
	^handle unsignedByteAt: OFFSET_LENGTH
]

{ #category : #'accessing - structure variables' }
SocketAddressStructure >> length: anObject [
	"This method was automatically generated"
	handle unsignedByteAt: OFFSET_LENGTH put: anObject
]

{ #category : #'accessing - structure variables' }
SocketAddressStructure >> port [
	"This method was automatically generated"
	^handle unsignedShortAt: OFFSET_PORT
]

{ #category : #'accessing - structure variables' }
SocketAddressStructure >> port: anObject [
	"This method was automatically generated"
	handle unsignedShortAt: OFFSET_PORT put: anObject
]

{ #category : #'accessing - structure variables' }
SocketAddressStructure >> zero_part1 [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_ZERO_PART1
]

{ #category : #'accessing - structure variables' }
SocketAddressStructure >> zero_part1: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_ZERO_PART1 put: anObject
]

{ #category : #'accessing - structure variables' }
SocketAddressStructure >> zero_part2 [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_ZERO_PART2
]

{ #category : #'accessing - structure variables' }
SocketAddressStructure >> zero_part2: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_ZERO_PART2 put: anObject
]
