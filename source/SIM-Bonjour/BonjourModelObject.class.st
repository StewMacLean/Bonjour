Class {
	#name : #BonjourModelObject,
	#superclass : #Object,
	#instVars : [
		'name'
	],
	#category : #'SIM-Bonjour-Model'
}

{ #category : #accessing }
BonjourModelObject >> childNumber [

	^self parent children indexOf: self
	
	
]

{ #category : #accessing }
BonjourModelObject >> children [

	self subclassResponsibility
]

{ #category : #accessing }
BonjourModelObject >> data [ 

	^self
]

{ #category : #accessing }
BonjourModelObject >> displayNodes [

	^#()
]

{ #category : #accessing }
BonjourModelObject >> displayStringUI [

	^name
]

{ #category : #accessing }
BonjourModelObject >> doToRoot: aBlock [

	aBlock value: self.
	
	self parent 
		ifNotNil: [self parent doToRoot: aBlock]
]

{ #category : #accessing }
BonjourModelObject >> initialize [

	super initialize.
	name := ''.
]

{ #category : #accessing }
BonjourModelObject >> isService [

	^false
]

{ #category : #accessing }
BonjourModelObject >> name [

	^name
]

{ #category : #accessing }
BonjourModelObject >> name: aString [

	name := aString
]

{ #category : #accessing }
BonjourModelObject >> parent [

	self subclassResponsibility
]

{ #category : #accessing }
BonjourModelObject >> path [

	| answer |
	
	answer := OrderedCollection new.
	
	self doToRoot: 
		[: node |
		answer addFirst: node childNumber].
	
	^answer
]

{ #category : #accessing }
BonjourModelObject >> pathString [

	^self path printString
]
