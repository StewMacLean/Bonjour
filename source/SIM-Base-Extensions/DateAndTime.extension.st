Extension { #name : #DateAndTime }

{ #category : #'*SIM-Base-Extensions' }
DateAndTime >> milliseconds [ 

	^(self nanoSecond // 1000000) \\ 1000
	
	

  
]
