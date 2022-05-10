Extension { #name : #PositionableStream }

{ #category : #'*SIM-Base-Extensions' }
PositionableStream >> nextAlphabeticWord [

	| answer |

	answer := self upTo: Character space.
	self skipSeparators.
	
	^answer
]

{ #category : #'*SIM-Base-Extensions' }
PositionableStream >> through: anObject [
	"Answer a subcollection from the current position to the occurrence (if any, inclusive)
	of anObject. If not there, answer everything."

	| newStream element |
	newStream := (collection species new: 64) writeStream.
	[self atEnd]
		whileFalse:
			[element := self next.
			newStream nextPut: element.
			element = anObject ifTrue: [^newStream contents]].
	^newStream contents
]
