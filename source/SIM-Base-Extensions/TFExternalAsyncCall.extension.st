Extension { #name : #TFExternalAsyncCall }

{ #category : #'*SIM-Base-Extensions' }
TFExternalAsyncCall >> doExecuteOn: aRunner [
	
	| aTaskAddress | 
	
	Stdio stdout lf; nextPutAll: Processor activeProcess identifier, ' |||| doExecuteOn: entry ', aRunner printString; lf.
	
	aTaskAddress := aRunner
		executeFunction: function
		withArguments: parameterArray
		usingSemaphore: self semaphoreIndex.
	
	"I check if the semaphore is already signaled, because doing it in this way 
	is thousands of times faster than just executing the wait. 
	I think is a bug in the VM"
	
	Stdio stdout 
		nextPutAll: Processor activeProcess identifier, 
		' |||| doExecuteOn: isSignaled ', 
		self semaphore isSignaled  printString; lf.
		
	self semaphore isSignaled 
		ifFalse: 
			[ Stdio stdout nextPutAll: Processor activeProcess identifier, ' |||| doExecuteOn: BLOCKED '; lf.
			self semaphore wait ].
		
	Stdio stdout nextPutAll: Processor activeProcess identifier, ' |||| doExecuteOn: UNBLOCKED'; lf.
	^ aRunner readReturnValueFromTask: aTaskAddress
]
