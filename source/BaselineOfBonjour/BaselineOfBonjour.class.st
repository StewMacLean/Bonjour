Class {
	#name : #BaselineOfBonjour,
	#superclass : #Object,
	#category : #BaselineOfBonjour
}

{ #category : #baselines }
BaselineOfBonjour >> baseline: spec [
	<baseline>

	spec for: #common do: 
		[spec 
			package: 'SIM-Base-Extensions';
			package: 'SIM-Base-Fixes';
			package: 'SIM-CodeEnhancements';
			package: 'SIM-Bonjour' with: [spec requires: #('OSSubprocess')].
		
		spec baseline: 'OSSubprocess' with: 
    			[spec repository: 'github://pharo-contributions/OSSubprocess:master/repository']]
]
