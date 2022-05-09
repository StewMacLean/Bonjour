Extension { #name : #ClassDescription }

{ #category : #'*SIM-Base-Fixes' }
ClassDescription >> notifyRepackage: selector method: compiledMethod oldProtocol: oldProtocol newProtocol: newProtocol [

	"Stewart MacLean 24/03/22 - fix so that a newPackage is created, if it doesn't exist.
	This can happen when filing in an existing method that has been moved to a new non-base package."
	
	| oldPackage newPackage organizer |
	
	(newProtocol = oldProtocol)
		ifTrue: [ ^ self ].
		
	"This indirection is because we need to abstract RPackage from the kernel"
	self class environment at: #RPackage ifPresent: [ :rPackageClass | 
			"Original code: - answers nil if package doesn't exist. This causes problems later on in recategorisation, as expects a Package.
			=====================================
			newPackage := rPackageClass organizer 
				packageForProtocol: newProtocol 
				inClass: self.
			======================================="
			"Fix code: if a package for the Class/Protocol exists answer it, otherwise create one."
			"======================================="
			organizer := rPackageClass organizer.
			newPackage := (organizer hasPackageForProtocol: newProtocol inClass: self)
				ifTrue: [organizer packageForProtocol: newProtocol inClass: self]
				ifFalse: [organizer registerPackage: (organizer packageClass named: (newProtocol copyWithout: $*))].
			"========================================"
			oldPackage := rPackageClass organizer 
				packageForProtocol: oldProtocol 
				inClass: self.
			
			"Announce recategorization"
			newPackage = oldPackage
				ifFalse: [ 
					SystemAnnouncer uniqueInstance 
						methodRepackaged: compiledMethod 
						from: oldPackage 
						to: newPackage ] ].	
	
	SystemAnnouncer uniqueInstance methodRecategorized: compiledMethod oldProtocol: oldProtocol
]
