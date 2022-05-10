Class {
	#name : #ServiceRemoved,
	#superclass : #Announcement,
	#instVars : [
		'service'
	],
	#category : #'SIM-Bonjour-Events'
}

{ #category : #accessing }
ServiceRemoved >> service [
	
	^service
]

{ #category : #accessing }
ServiceRemoved >> service: anObject [
	
	service := anObject
]
