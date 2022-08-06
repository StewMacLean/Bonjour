Class {
	#name : #BonjourLibraryFFIPump,
	#superclass : #BonjourLibraryFFIAbstract,
	#category : #'SIM-Bonjour'
}

{ #category : #accessing }
BonjourLibraryFFIPump >> runner [

	^runner ifNil: [runner := TFWorker named: 'Bonjour - Pump']
]
