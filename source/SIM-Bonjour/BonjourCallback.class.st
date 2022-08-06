Class {
	#name : #BonjourCallback,
	#superclass : #FFICallback,
	#category : #'SIM-Bonjour'
}

{ #category : #'library path' }
BonjourCallback class >> ffiLibraryName [ 

	^BonjourLibraryFFICalloutCallback
]

{ #category : #'library path' }
BonjourCallback >> ffiLibraryName [ 

	^BonjourLibraryFFICalloutCallback
]
