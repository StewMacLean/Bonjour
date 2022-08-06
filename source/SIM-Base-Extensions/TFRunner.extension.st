Extension { #name : #TFRunner }

{ #category : #'*SIM-Base-Extensions' }
TFRunner >> returnCallback: aCallbackInvocation [
	"Entry point to return a callback invocation.
	Check the callbackInvocation stack to see if the given invocation is the last one.
	If so, it can return safely.
	Otherwise, throw an exception as returning means a bug in your application.
	The user must guarantee callbacks return in the correct order"
	
	Stdio stdout nextPutAll: Processor activeProcess identifier, ' <<<< returnCallback: popping stack... '; lf.

	callbackReturnSemaphore ifNil: [ 
		callbackReturnSemaphore := Semaphore new ].

	aCallbackInvocation isNull 
		ifTrue: [ ^ self ].

	callbackInvocationStack isEmptyOrNil ifTrue: [ 
		^ self cannotReturnCallbackFromOldSession: aCallbackInvocation].

	stackProtect critical: [
		(callbackInvocationStack top == aCallbackInvocation) 
			ifTrue: [
				aCallbackInvocation returnExecution
					ifTrue: [
						"If we are starting a session and an execution was executed, it 
						 may happen that the stack is empty."
						callbackInvocationStack ifEmpty: [ ^ self ].
						callbackInvocationStack pop.
						[ callbackReturnSemaphore signalAll ] valueUnpreemptively.
						Stdio stdout nextPutAll: Processor activeProcess identifier, ' <<<< returnCallback: stack popped'; lf.
						^ self ]] ].
	"failed"
	Stdio stdout nextPutAll: Processor activeProcess identifier, ' <<<< returnCallback: FAILED - not on top of stack - waiting on semaphore...'; lf.
	callbackReturnSemaphore wait.
	self returnCallback: aCallbackInvocation.
	Stdio stdout nextPutAll: Processor activeProcess identifier, ' <<<< returnCallback: POST FAILED - not on top of stack - post recursive returnCallback: '; lf.
]
