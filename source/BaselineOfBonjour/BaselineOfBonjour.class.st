Class {
	#name : #BaselineOfBonjour,
	#superclass : #BaselineOf,
	#category : #BaselineOfBonjour
}

{ #category : #baselines }
BaselineOfBonjour >> baseline: spec [
	<baseline>

	spec for: #common do: 
		[spec 
			postLoadDoIt: #'postload:package:';
			package: 'SIM-Base-Extensions';
			package: 'SIM-Base-Fixes';
			package: 'SIM-CodeEnhancements';
			package: 'SIM-Bonjour' with: [spec requires: #('OSSubprocess')].
		
		spec baseline: 'OSSubprocess' with: 
    			[spec repository: 'github://pharo-contributions/OSSubprocess:master/repository']]
]

{ #category : #actions }
BaselineOfBonjour >> postload: loader package: packageSpec [

	Smalltalk tools browser 
		openOnClass: BonjourCommandLineInterface 
		selector: #openApp

]
