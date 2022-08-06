Class {
	#name : #BonjourLibraryFFICalloutCallback,
	#superclass : #BonjourLibraryFFIAbstract,
	#category : #'SIM-Bonjour'
}

{ #category : #accessing }
BonjourLibraryFFICalloutCallback >> runner [

	"Tried this so that inherently synchronous callouts don't use the threaded machinery.
	Result - the first threaded callout crashes!!!"
	"^runner ifNil: [runner := TFSameThreadRunner uniqueInstance]"
	
	"This causes a callback registration error.
	If change the calloutAPIClass to FFICalloutAPI get a subresponsibility error.
	^runner ifNil: [runner := TFMainThreadRunner uniqueInstance]"
	
	^runner ifNil: [runner := TFWorker named: 'Bonjour - Callout/Callback']
	

]
