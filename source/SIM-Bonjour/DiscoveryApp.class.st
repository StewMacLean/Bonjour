Class {
	#name : #DiscoveryApp,
	#superclass : #SpPresenter,
	#instVars : [
		'title',
		'treeView',
		'lastAddServceAddedTimestamp',
		'bonjour'
	],
	#category : #'SIM-Bonjour-UI'
}

{ #category : #'interface opening' }
DiscoveryApp class >> basicNew [ 

	^super basicNew basicInitialize
]

{ #category : #'interface opening' }
DiscoveryApp class >> openOn: aBonjourInterface [

	^self basicNew 
		interface: aBonjourInterface;
		initialize;
		open
]

{ #category : #'initialize-release' }
DiscoveryApp >> basicInitialize [

	title := 'Discovery'.
	
	

]

{ #category : #'building window' }
DiscoveryApp >> connectPresenters [


]

{ #category : #'startUp - shutDown' }
DiscoveryApp >> initialize [

	super initialize.
	
	bonjour
		when: ServiceTypeAdded send: #serviceTypeAdded: to: self;
		when: ServiceAdded send: #serviceAdded: to: self;
		when: ServiceUpdated send: #serviceUpdated: to: self;
		when: ServiceRemoved send: #serviceRemoved: to: self.
	
	self 
		log: '=====================================================================';
		log: 'Opening Discovery...'.
	treeView 
		hideColumnHeaders;
		"lazilyComputeChildren: true; - shows expand icon on elements (have no children)"
		expandAll
	
	
	
	

]

{ #category : #'building window' }
DiscoveryApp >> initializeLayout [
	
	self layout: self layoutSpec
]

{ #category : #'building window' }
DiscoveryApp >> initializePresenters [

	self instantiatePresenters.
	self setStyles.
	self initializeLayout

]

{ #category : #'building window' }
DiscoveryApp >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	
	aWindowPresenter 
		title: title;
		initialExtent: 500@800;
		initialPosition: 10@20;
		whenOpenedDo: [bonjour startUp];
		whenClosedDo: [self shutDown]
]

{ #category : #'building window' }
DiscoveryApp >> instantiatePresenters [

	treeView := self newTreeTable.
	treeView
		addColumn: (SpCompositeTableColumn new
			title: '';
			addColumn: ((SpImageTableColumn evaluated: #systemIcon)
				width: 20;
				yourself);
			addColumn: (SpStringTableColumn evaluated: #displayStringUI);
			yourself);
		roots: {StateVector new displayStringUI: 'Discovering services. Please wait...'; displayNodes: #()}; "BonjourCommandLineInterface current domains;"
		children: [: aNode | aNode displayNodes];
		beResizable
		"contextMenu: self menu;
		activateOnDoubleClick;
		whenActivatedDo: [ :selection | selection selectedItem browse ]"
	
	
]

{ #category : #'initialize-release' }
DiscoveryApp >> interface: aBonjourInterface [

	bonjour := aBonjourInterface
	
	

]

{ #category : #'building window' }
DiscoveryApp >> layoutSpec [

	^ SpBoxLayout newTopToBottom
		add: treeView;
		yourself
]

{ #category : #logging }
DiscoveryApp >> log: aString [

	bonjour log: aString
]

{ #category : #'startUp - shutDown' }
DiscoveryApp >> openAppUsingCommandLineInterface [

	<script: 'self basicNew openAppUsingCommandLineInterface'>

	self class openOn: BonjourCommandLineInterface uniqueInstance
]

{ #category : #'model updates' }
DiscoveryApp >> refreshTree [

	treeView roots: bonjour domains.
	bonjour serviceTypes do: [: each | treeView expandPath: each path].
	bonjour class = BonjourLibraryInterface
		ifTrue: [	bonjour services do: [: each | treeView expandPath: each path]]. "for testing"
	
	
	

	
]

{ #category : #'building window' }
DiscoveryApp >> requestWindowClose [

	bonjour class = BonjourCommandLineInterface
		ifTrue: [^true].

	^bonjour class current
		ifNil: [true]
		ifNotNil: 
			[UIManager default alert: 'About to shut down Bonjour - observe how callbacks get fired as sdRefs get deallocated - why?'. 
			self shutDown.
			1 seconds wait.
			self refreshTree.
			false]

]

{ #category : #'model updates' }
DiscoveryApp >> serviceAdded: anEvent [

	self refreshTree
	
	

	
]

{ #category : #'model updates' }
DiscoveryApp >> serviceRemoved: anEvent [

	self refreshTree
	
]

{ #category : #'model updates' }
DiscoveryApp >> serviceTypeAdded: anEvent [

	self refreshTree
	
	

	
]

{ #category : #'model updates' }
DiscoveryApp >> serviceUpdated: anEvent [

	self refreshTree

	
]

{ #category : #'building window' }
DiscoveryApp >> setStyles [
]

{ #category : #'startUp - shutDown' }
DiscoveryApp >> shutDown [

	bonjour class shutDown
]

{ #category : #accessing }
DiscoveryApp >> title [

	^title
]

{ #category : #accessing }
DiscoveryApp >> title: anObject [

	title := anObject
]
