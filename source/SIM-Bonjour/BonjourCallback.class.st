Class {
	#name : #BonjourCallback,
	#superclass : #FFICallback,
	#category : #'SIM-Bonjour'
}

{ #category : #accessing }
BonjourCallback class >> ffiLibraryName [

	^  BonjourLibraryFFI
]

{ #category : #accessing }
BonjourCallback >> ffiLibraryName [

	^ BonjourLibraryFFI
]
