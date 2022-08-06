Extension { #name : #Process }

{ #category : #'*SIM-Base-Extensions' }
Process >> identifier [

	^(self identityHash \\ 999999) printString
]
