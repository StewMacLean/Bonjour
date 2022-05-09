Class {
	#name : #ServiceTypeAdded,
	#superclass : #Announcement,
	#instVars : [
		'serviceType'
	],
	#category : #'SIM-Bonjour-Events'
}

{ #category : #accessing }
ServiceTypeAdded >> serviceType [
	
	^serviceType
]

{ #category : #accessing }
ServiceTypeAdded >> serviceType: aServiceType [
	
	serviceType := aServiceType
]
