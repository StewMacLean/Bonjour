Class {
	#name : #Domain,
	#superclass : #BonjourModelObject,
	#instVars : [
		'serviceTypes',
		'parent'
	],
	#category : #'SIM-Bonjour-Model'
}

{ #category : #initialization }
Domain >> addServiceType: aServiceType [
	
	serviceTypes add: aServiceType.
	serviceTypes := (serviceTypes asSortedCollection: 
		[: a : b | a registrationType < b registrationType]) asOrderedCollection.
	aServiceType domainObject: self.
	
	^aServiceType
]

{ #category : #initialization }
Domain >> children [

	^serviceTypes
]

{ #category : #initialization }
Domain >> displayNodes [

	^serviceTypes
]

{ #category : #initialization }
Domain >> displayStringUI [

	^name
]

{ #category : #initialization }
Domain >> doToRoot: aBlock [

	aBlock value: self
]

{ #category : #initialization }
Domain >> initialize [

	super initialize.
	
	serviceTypes := OrderedCollection new
]

{ #category : #initialization }
Domain >> name [

	^name
]

{ #category : #initialization }
Domain >> name: aString [

	name := aString
]

{ #category : #initialization }
Domain >> parent [

	^parent
]

{ #category : #initialization }
Domain >> parent: aBonjourInterface [

	parent := aBonjourInterface
]

{ #category : #initialization }
Domain >> systemIcon [

	 ^Smalltalk ui icons iconNamed: #morphIcon
]
