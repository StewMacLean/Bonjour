Class {
	#name : #TextRecordPair,
	#superclass : #BonjourModelObject,
	#instVars : [
		'key',
		'value'
	],
	#category : #'SIM-Bonjour-Model'
}

{ #category : #accessing }
TextRecordPair class >> key: aKeyString value: aValueString [

	^self new
		key: aKeyString;
		value: aValueString

]

{ #category : #printing }
TextRecordPair >> displayStringUI [

	^self keyValueString
]

{ #category : #accessing }
TextRecordPair >> initialize [

	super initialize.
	
	key := ''.
	value := ''
]

{ #category : #accessing }
TextRecordPair >> key [

	^key
]

{ #category : #accessing }
TextRecordPair >> key: aString [

	key := aString
]

{ #category : #printing }
TextRecordPair >> keyValueString [

	^key, '=', value
]

{ #category : #printing }
TextRecordPair >> printOn: aStream [

	aStream
		nextPutAll: 'TextRecordPair(';
		nextPutAll: key;
		nextPutAll: '=';
		nextPutAll: value;
		nextPut: $)
]

{ #category : #accessing }
TextRecordPair >> value [

	^value
]

{ #category : #accessing }
TextRecordPair >> value: aString [

	value := aString
]
