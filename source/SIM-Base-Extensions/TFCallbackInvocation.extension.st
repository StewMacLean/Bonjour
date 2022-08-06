Extension { #name : #TFCallbackInvocation }

{ #category : #'*SIM-Base-Extensions' }
TFCallbackInvocation >> execute [ 
	| returnValue transformedArguments |

	transformedArguments := [ self arguments 
		with: callback parameterTypes 
		collect: [ :anArgument :aType | aType marshallFromPrimitive: anArgument ] ] 
	on: Exception 
	fork: [ :e | e debug ] 
	return: [ self arguments ].

	Stdio stdout lf; nextPutAll: Processor activeProcess identifier, ' <<<< execute - evaluating callback block... '; lf.
	[ returnValue := callback frontendCallback valueWithArguments: transformedArguments ] 
	ensure: [ 
		returnValue := callback returnType marshallToPrimitive: (callback isSuccess 
			ifTrue: [ returnValue ]
			ifFalse: [ callback frontendCallback returnOnError ]).

		self isNull ifFalse: [ 
			callback returnType isVoid 
				ifFalse: [ self writeReturnValue: returnValue ].
				Stdio stdout nextPutAll: Processor activeProcess identifier, ' <<<< evaluate - calling returnCallback:...'; lf.
			self runner returnCallback: self.
			Stdio stdout nextPutAll: Processor activeProcess identifier, ' <<<< evaluate - exiting'; lf] ]
]
