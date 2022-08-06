Class {
	#name : #ServiceUpdated,
	#superclass : #Announcement,
	#instVars : [
		'service'
	],
	#category : #'SIM-Bonjour-Events'
}

{ #category : #accessing }
ServiceUpdated >> service [
	
	^service
]

{ #category : #accessing }
ServiceUpdated >> service: anObject [
	
	service := anObject
]
