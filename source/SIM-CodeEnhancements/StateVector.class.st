Class {
	#name : #StateVector,
	#superclass : #Object,
	#instVars : [
		'attributes'
	],
	#category : #'SIM-CodeEnhancements'
}

{ #category : #'instance creation' }
StateVector class >> new [
	"Answer a newly created and initialized instance."
	
	^super new initialize
]

{ #category : #'error handling' }
StateVector >> attributeAt: aKey [
	
	^attributes
		at: aKey
		ifAbsent: [nil]
]

{ #category : #'error handling' }
StateVector >> attributeAt: aKey ifAbsent: aBlock [
	
	^attributes
		ifNil: [aBlock value]
		ifNotNil: [:value | value at: aKey ifAbsent: aBlock]
]

{ #category : #'error handling' }
StateVector >> attributeAt: aKey ifAbsent: anAbsentBlock ifPresent: aPresentBlock [
	
	^attributes
		ifNil: [anAbsentBlock value]
		ifNotNil:
			[:value | value at: aKey ifPresent: aPresentBlock ifAbsent: anAbsentBlock]
]

{ #category : #'error handling' }
StateVector >> attributeAt: aKey ifAbsentOrNilPut: aBlock [
	
	| absentOrNil |
	absentOrNil := attributes
		at: aKey
		ifAbsent: [nil].
	^absentOrNil
		ifNil:
			[self
				attributeAt: aKey
				put: aBlock value]
		ifNotNil: [:value | value]
]

{ #category : #'error handling' }
StateVector >> attributeAt: aKey ifAbsentPut: aBlock [
	
	^attributes at: aKey ifAbsentPut: aBlock
]

{ #category : #'error handling' }
StateVector >> attributeAt: aKey ifPresent: aBlock [
	
	^attributes at: aKey ifPresent: aBlock
]

{ #category : #'error handling' }
StateVector >> attributeAt: aKey ifPresent: aPresentBlock ifAbsent: anAbsentBlock [
	
	^attributes
		ifNil: [anAbsentBlock value]
		ifNotNil:
			[:value | value at: aKey ifPresent: aPresentBlock ifAbsent: anAbsentBlock]
]

{ #category : #'error handling' }
StateVector >> attributeAt: aKey put: aValue [
	
	^attributes at: aKey put: aValue
]

{ #category : #'error handling' }
StateVector >> basicAttributes [
	
	^attributes
]

{ #category : #printing }
StateVector >> data [

	"For printing in Spec Tree View"

	^self
]

{ #category : #printing }
StateVector >> data: anArgument [

	self error: 'Reserved - see data'
]

{ #category : #'error handling' }
StateVector >> doesNotUnderstand: aMessage [
	"
	StateVector new a1: 'value'; a1; yourself
	"
	
	aMessage selector last = $:
		ifTrue:
			[attributes
				at:
					(aMessage selector asString
						copyFrom: 1
						to: aMessage selector size - 1)
				put: aMessage arguments first]
		ifFalse:
			[^attributes
				at: aMessage selector asString
				ifAbsent: [super doesNotUnderstand: aMessage]]
]

{ #category : #'error handling' }
StateVector >> hasAttribute: aString [
	
	^attributes
		at: aString
		ifAbsent: [false]
		ifPresent: [:value | true]
]

{ #category : #'initialize-release' }
StateVector >> initialize [
	
	super initialize.
	attributes := Dictionary new
]

{ #category : #'error handling' }
StateVector >> initializeAttributes [
	
	attributes := Dictionary new
]

{ #category : #printing }
StateVector >> printOn: aStream [
	"super printOn: aStream."
	
	aStream
		nextPutAll: 'Vector';
		nextPut: $(.	"attributes printOn: aStream."
	attributes associations do: [: assoc |  
			aStream
				nextPutAll: assoc key;
				nextPutAll: ' : ';
				nextPutAll: assoc value printString] separatedBy: [aStream nextPutAll: ' '].
	aStream nextPut: $)
]

{ #category : #'error handling' }
StateVector >> removeAttributeAt: aKey [
	
	^self
		removeAttributeAt: aKey
		ifAbsent: [nil]
]

{ #category : #'error handling' }
StateVector >> removeAttributeAt: aKey ifAbsent: aBlock [
	
	^attributes
		ifNotNil: [attributes removeKey: aKey ifAbsent: aBlock]
		ifNil: [nil]
]

{ #category : #'error handling' }
StateVector >> resetAttributes [
	
	attributes := nil
]

{ #category : #'error handling' }
StateVector >> restoreTo: anObject [
	
	attributes
		associationsDo:
			[:assoc | 
			anObject
				perform: (assoc key , ':') asSymbol
				with: assoc value]
]
