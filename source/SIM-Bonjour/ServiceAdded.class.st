Class {
	#name : #ServiceAdded,
	#superclass : #Announcement,
	#instVars : [
		'service'
	],
	#category : #'SIM-Bonjour-Events'
}

{ #category : #accessing }
ServiceAdded >> service [
	
	^service
]

{ #category : #accessing }
ServiceAdded >> service: anObject [
	
	service := anObject
]
