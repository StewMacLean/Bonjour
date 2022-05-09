Class {
	#name : #Timestamp,
	#superclass : #DateAndTime,
	#category : #'SIM-Base-Extensions'
}

{ #category : #conversion }
Timestamp >> asNTPSecondFraction [
	"Answer the NTP faction of a second.
	Note: (536870912 / 125) = 4.29497e6 = ((2 raisedTo: 32) / 1000).
	Note: 16r100000000 = 2 raisedTo: 32"
	
	^(self millisecond * (536870912 / 125)) asInteger	"NTP - Network Time Protocol.
	The 64-bit timestamps used by NTP consist of a 32-bit part for seconds and a 32-bit part for fractional second, 
	giving a time scale that rolls over every 232 seconds (136 years) and a theoretical resolution of 2−32 seconds (233 picoseconds). 

	NTP uses an epoch of January 1, 1900 so the first roll over will be in 2036."
]

{ #category : #conversion }
Timestamp >> asNTPSeconds [
	"Convert self to seconds since 1900, which is the NTP Epoch.(See asNTPMilliseconds)
	Note: 31536000 = (60 * 60 * 24 * 365) - Seconds per year"
	
	| secondslv |
	"Gets us the number of seconds since Jan 1. 1901, the Smalltalk Epoch"
	secondslv := self asSeconds.	"Convert that to be GMT-based"
	secondslv := TimeZone default convertLocalSecondsToGMT: secondslv.	"Add one year worth of seconds, to get to NTP Epoch"
	^secondslv + 31536000	"Seconds per year"
]

{ #category : #printing }
Timestamp >> printFilenameSuffix [ 

	"Answer the receiver as a String in 'ccyy.mm.dd-hh.mm.ss' format.
	Timestamp now printFilenameSuffix
	"

	| stream |

	stream := WriteStream on: String new.
	self asDate printOn: stream format: #(3 2 1 $. 1 1 2).
	stream nextPut: $-.
	self printHMSOn: stream separatedBy: $..

	^stream contents
]

{ #category : #printing }
Timestamp >> printHHMMSSlll [

	| aStream|
	
	aStream :=   String new writeStream.
	
	aStream 
		nextPutAll: (self hours printString padLeftTo: 2 with: $0); 
		nextPut: $:;
		nextPutAll: (self minutes printString padLeftTo: 2 with: $0); 
		nextPut: $:;
		nextPutAll: (self seconds printString padLeftTo: 2 with: $0); 
		nextPut: $:;
		nextPutAll:  (self milliseconds printString padLeftTo: 3 with: $0).
		": $.;
		nextPutAll: ((self microseconds \\ 1000) printString padWith: $0 left: 3)."
	
	^aStream contents
]

{ #category : #printing }
Timestamp >> printLogTimestamp [

	"Answer the receiver as a String in yyyy-mm-dd hh:mm:ss.lll format."

	| stream |

	stream := WriteStream on: String new.
	self asDate printOn: stream format: #(3 2 1 $- 1 1 2).
	stream space.
	stream nextPutAll: self printHHMMSSlll.

	^stream contents
]

{ #category : #printing }
Timestamp >> printMMSSlll [

	| aStream|
	
	aStream :=   String new writeStream.
	
	aStream 
		nextPutAll: (self minutes printString padLeftTo: 2 with: $0); 
		nextPut: $:;
		nextPutAll: (self seconds printString padLeftTo: 2 with: $0); 
		nextPut: $:;
		nextPutAll:  (self milliseconds printString padLeftTo: 3 with: $0).
	
	^aStream contents
]

{ #category : #printing }
Timestamp >> printMMSSlllccc [

	| aStream|
	
	aStream :=   String new writeStream.
	
	aStream 
		nextPutAll: (self minutes printString padLeftTo: 2 with: $0); 
		nextPut: $:;
		nextPutAll: (self seconds printString padLeftTo: 2 with: $0); 
		nextPut: $:;
		nextPutAll:  (self milliseconds printString padLeftTo: 3 with: $0);
		nextPut: $.;
		nextPutAll: ((self microseconds \\ 1000) padLeftTo: 3 with: $0).
	
	^aStream contents
]
