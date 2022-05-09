Class {
	#name : #IPAddress,
	#superclass : #BonjourModelObject,
	#instVars : [
		'interfaces',
		'service'
	],
	#category : #'SIM-Bonjour-Model'
}

{ #category : #accessing }
IPAddress >> addInterface: aString [

	interfaces add: aString
]

{ #category : #accessing }
IPAddress >> address [

	^name
]

{ #category : #accessing }
IPAddress >> address: aString [

	name := aString
]

{ #category : #accessing }
IPAddress >> displayStringUI [

	| stream |

	stream := String new writeStream.
	
	stream
		nextPutAll: self address;
		nextPut: $:;
		nextPutAll: service port;
		space;
		nextPut: ${.
	(interfaces asSortedCollection: [: a : b | a < b]) do: [: each |
		stream 
			nextPutAll: each;
			space].
	stream skip: -1.
	stream nextPut: $}.

	^stream contents
]

{ #category : #accessing }
IPAddress >> initialize [

	super initialize.
	
	interfaces := Set new
]

{ #category : #accessing }
IPAddress >> interfaces [

	^interfaces
]

{ #category : #accessing }
IPAddress >> service: aService [

	service := aService
]
