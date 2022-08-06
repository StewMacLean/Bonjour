Class {
	#name : #BonjourLibraryFFIAbstract,
	#superclass : #FFILibrary,
	#instVars : [
		'dnsServiceErr',
		'dnsServiceFlags',
		'runner'
	],
	#category : #'SIM-Bonjour'
}

{ #category : #types }
BonjourLibraryFFIAbstract >> DNSRecordRef [
	
	"<C: typedef struct _DNSRecordRef_t * DNSRecordRef>"
	
]

{ #category : #'defines - unused' }
BonjourLibraryFFIAbstract >> DNSSD_API [
	
	"<C: #define DNSSD_API>"
	
]

{ #category : #'callouts - unused' }
BonjourLibraryFFIAbstract >> DNSServiceAddRecord: sdRef with: RecordRef with: flags with: rrtype with: rdlen with: rdata with: ttl [
	
	"<C: DNSServiceErrorType DNSServiceAddRecord(DNSServiceRef sdRef, DNSRecordRef * RecordRef, DNSServiceFlags flags, uint16_t rrtype, uint16_t rdlen, const void * rdata, uint32_t ttl)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #callouts }
BonjourLibraryFFIAbstract >> DNSServiceBrowse: sdRef with: flags with: interfaceIndex with: regtype with: domain with: callBack with: context [ 

	^self ffiCall: #(
		int DNSServiceBrowse 
			(void * sdRef,   "DNSServiceRef *" 
			uint32 flags, 
			uint32 interfaceIndex, 
			char *regtype, 
			char *domain, 
			BonjourCallback callBack, 
			void *context))
]

{ #category : #'callbacks types' }
BonjourLibraryFFIAbstract >> DNSServiceBrowseReply [
	
	^#(void * (void *sdRef, uint32 flags, uint32 interfaceIndex, int errorCode, char * serviceName, char * regtype, char * replyDomain, void * context))
	
]

{ #category : #'enums - unused' }
BonjourLibraryFFIAbstract >> DNSServiceClass [
	
	"<C: enum DNSServiceClass {
			kDNSServiceClass_IN = 1
		}>"
	
]

{ #category : #'callouts - unused' }
BonjourLibraryFFIAbstract >> DNSServiceConstructFullName: fullName with: service with: regtype with: domain [
	
	"<C: DNSServiceErrorType DNSServiceConstructFullName(char * fullName, const char * service, const char * regtype, const char * domain)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #'callouts - unused' }
BonjourLibraryFFIAbstract >> DNSServiceCreateConnection: sdRef [
	
	"<C: DNSServiceErrorType DNSServiceCreateConnection(DNSServiceRef * sdRef)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #types }
BonjourLibraryFFIAbstract >> DNSServiceDomainEnumReply [
	
	"<C: typedef void (* DNSServiceDomainEnumReply)(DNSServiceRef sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, DNSServiceErrorType errorCode, const char * replyDomain, void * context)>"
	
]

{ #category : #'callouts - unused' }
BonjourLibraryFFIAbstract >> DNSServiceEnumerateDomains: sdRef with: flags with: interfaceIndex with: callBack with: context [
	
	"<C: DNSServiceErrorType DNSServiceEnumerateDomains(DNSServiceRef * sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, DNSServiceDomainEnumReply callBack, void * context)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #enums }
BonjourLibraryFFIAbstract >> DNSServiceErr [
	
	^dnsServiceErr
]

{ #category : #enums }
BonjourLibraryFFIAbstract >> DNSServiceErrString [

	^'kDNSServiceErr_NoError = 0, 
			kDNSServiceErr_Unknown = -65537, 
			kDNSServiceErr_NoSuchName = -65538, 
			kDNSServiceErr_NoMemory = -65539, 
			kDNSServiceErr_BadParam = -65540, 
			kDNSServiceErr_BadReference = -65541, 
			kDNSServiceErr_BadState = -65542, 
			kDNSServiceErr_BadFlags = -65543, 
			kDNSServiceErr_Unsupported = -65544, 
			kDNSServiceErr_NotInitialized = -65545, 
			kDNSServiceErr_AlreadyRegistered = -65547, 
			kDNSServiceErr_NameConflict = -65548, 
			kDNSServiceErr_Invalid = -65549, 
			kDNSServiceErr_Firewall = -65550, 
			kDNSServiceErr_Incompatible = -65551, 
			kDNSServiceErr_BadInterfaceIndex = -65552, 
			kDNSServiceErr_Refused = -65553, 
			kDNSServiceErr_NoSuchRecord = -65554, 
			kDNSServiceErr_NoAuth = -65555, 
			kDNSServiceErr_NoSuchKey = -65556, 
			kDNSServiceErr_NATTraversal = -65557, 
			kDNSServiceErr_DoubleNAT = -65558, 
			kDNSServiceErr_BadTime = -65559, 
			kDNSServiceErr_BadSig = -65560, 
			kDNSServiceErr_BadKey = -65561, 
			kDNSServiceErr_Transient = -65562, 
			kDNSServiceErr_ServiceNotRunning = -65563, 
			kDNSServiceErr_NATPortMappingUnsupported = -65564, 
			kDNSServiceErr_NATPortMappingDisabled = -65565, 
			kDNSServiceErr_NoRouter = -65566, 
			kDNSServiceErr_PollingMode = -65567, 
			kDNSServiceErr_Timeout = -65568' 
			
			
	
]

{ #category : #types }
BonjourLibraryFFIAbstract >> DNSServiceErrorType [
	
	"<C: typedef int32_t DNSServiceErrorType>"
	
]

{ #category : #types }
BonjourLibraryFFIAbstract >> DNSServiceErrorTypeOriginal [
	"Tried changing this to long (following changing int32_t), but this made no difference.
	Function calls still returning a pointer to the error code"
	
	"<C: typedef int32_t DNSServiceErrorType>"
	
]

{ #category : #types }
BonjourLibraryFFIAbstract >> DNSServiceFlags [
	
	"<C: typedef uint32_t DNSServiceFlags>"
	
]

{ #category : #enums }
BonjourLibraryFFIAbstract >> DNSServiceFlagsEnum [
	
	^dnsServiceFlags
]

{ #category : #enums }
BonjourLibraryFFIAbstract >> DNSServiceFlagsString [
	
	^'kDNSServiceFlagsMoreComing = 1, 
			kDNSServiceFlagsAdd = 2, 
			kDNSServiceFlagsDefault = 4, 
			kDNSServiceFlagsNoAutoRename = 8, 
			kDNSServiceFlagsShared = 16, 
			kDNSServiceFlagsUnique = 32, 
			kDNSServiceFlagsBrowseDomains = 64, 
			kDNSServiceFlagsRegistrationDomains = 128, 
			kDNSServiceFlagsLongLivedQuery = 256, 
			kDNSServiceFlagsAllowRemoteQuery = 512, 
			kDNSServiceFlagsForceMulticast = 1024, 
			kDNSServiceFlagsForce = 2048, 
			kDNSServiceFlagsReturnIntermediates = 4096, 
			kDNSServiceFlagsNonBrowsable = 8192, 
			kDNSServiceFlagsShareConnection = 16384, 
			kDNSServiceFlagsSuppressUnusable = 32768'
	
]

{ #category : #callouts }
BonjourLibraryFFIAbstract >> DNSServiceGetAddrInfo: sdRef with: flags with: interfaceIndex with: protocol with: hostName with: callBack with: context [

	^self ffiCall: #(
		int DNSServiceGetAddrInfo 
			(void * sdRef, 
			uint32 flags, 
			uint32 interfaceIndex, 
			uint32 protocol, 
			char * hostName, 
			BonjourCallback callBack, 
			void * context))
	
]

{ #category : #'callbacks types' }
BonjourLibraryFFIAbstract >> DNSServiceGetAddrInfoReply [

	^#(void * (void *sdRef, uint32 flags, uint32 interfaceIndex, int errorCode, char * hostname, SocketAddressStructure * sockaddr, uint32 ttl, void * context))
	
	"typedef void (*DNSServiceGetAddrInfoReply)(
                       DNSServiceRef          sdRef,
                       DNSServiceFlags        flags,
                       uint32_t               interfaceIndex,
                       DNSServiceErrorType    errorCode,
                       const char*            hostname,
                       const struct sockaddr* address,
                       uint32_t               ttl,
                       void*                  context);
	"
]

{ #category : #callouts }
BonjourLibraryFFIAbstract >> DNSServiceGetProperty: property with: result with: size [

	^ self ffiCall: #(
		int32 DNSServiceGetProperty 
			(char * property, 
			void * result, 
			uint32 * size))

]

{ #category : #types }
BonjourLibraryFFIAbstract >> DNSServiceNATPortMappingReply [
	
	"<C: typedef void (* DNSServiceNATPortMappingReply)(DNSServiceRef sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, DNSServiceErrorType errorCode, uint32_t externalAddress, enum DNSServiceProtocol protocol, uint16_t internalPort, uint16_t externalPort, uint32_t ttl, void * context)>"
	
]

{ #category : #callouts }
BonjourLibraryFFIAbstract >> DNSServiceProcessResult: sdRef [ 

	^self ffiCall: #(
		int DNSServiceProcessResult 
			(void *sdRef))
]

{ #category : #'enums - unused' }
BonjourLibraryFFIAbstract >> DNSServiceProtocol [
	"Got name conflick when trying to compile this type - was a enum. Machinery hanging on to it?
	Similar problem with types not being reflected, had to recompile methods"
	
	
]

{ #category : #'enums - unused' }
BonjourLibraryFFIAbstract >> DNSServiceProtocolEnum [
	
	"<C: enum DNSServiceProtocol {
			kDNSServiceProtocol_IPv4 = 1, 
			kDNSServiceProtocol_IPv6, 
			kDNSServiceProtocol_UDP = 16, 
			kDNSServiceProtocol_TCP = 32
		}>"
	
]

{ #category : #types }
BonjourLibraryFFIAbstract >> DNSServiceProtocolType [
	
	"<C: typedef uint32_t DNSServiceProtocolType>"
	
]

{ #category : #'callouts - unused' }
BonjourLibraryFFIAbstract >> DNSServiceQueryRecord: sdRef with: flags with: interfaceIndex with: fullname with: rrtype with: rrclass with: callBack with: context [
	
	"<C: DNSServiceErrorType DNSServiceQueryRecord(DNSServiceRef * sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, const char * fullname, uint16_t rrtype, uint16_t rrclass, DNSServiceQueryRecordReply callBack, void * context)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #types }
BonjourLibraryFFIAbstract >> DNSServiceQueryRecordReply [
	
	"<C: typedef void (* DNSServiceQueryRecordReply)(DNSServiceRef sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, DNSServiceErrorType errorCode, const char * fullname, uint16_t rrtype, uint16_t rrclass, uint16_t rdlen, const void * rdata, uint32_t ttl, void * context)>"
	
]

{ #category : #'callouts - unused' }
BonjourLibraryFFIAbstract >> DNSServiceReconfirmRecord: flags with: interfaceIndex with: fullname with: rrtype with: rrclass with: rdlen with: rdata [
	
	"<C: DNSServiceErrorType DNSServiceReconfirmRecord(DNSServiceFlags flags, uint32_t interfaceIndex, const char * fullname, uint16_t rrtype, uint16_t rrclass, uint16_t rdlen, const void * rdata)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #types }
BonjourLibraryFFIAbstract >> DNSServiceRef [
	
	"<C: typedef struct _DNSServiceRef_t * DNSServiceRef>"
	
]

{ #category : #callouts }
BonjourLibraryFFIAbstract >> DNSServiceRefDeallocate: sdRef [

	^self ffiCall: #(
		void DNSServiceRefDeallocate 
			(void *sdRef))
	
]

{ #category : #'callouts - unused' }
BonjourLibraryFFIAbstract >> DNSServiceRefSockFD: sdRef [


	^self ffiCall: #(int DNSServiceRefSockFD(void *sdRef))
	
	"<C: int DNSServiceRefSockFD(DNSServiceRef sdRef)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #callouts }
BonjourLibraryFFIAbstract >> DNSServiceRegister: sdRef with: flags with: interfaceIndex with: name with: regtype with: domain with: host with: port with: txtLen with: txtRecord with: callBack with: context [

	^self ffiCall: #(
		int DNSServiceRegister 
			(void * sdRef, 
			uint32 flags, 
			uint32 interfaceIndex, 
			char * name, 
			char * regtype, 
			char * domain, 
			char * host, 
			uint16 port, 
			uint16 txtLen, 
			void * txtRecord, 
			BonjourCallback callBack, 
			void * context))
]

{ #category : #'callouts - unused' }
BonjourLibraryFFIAbstract >> DNSServiceRegisterRecord: sdRef with: RecordRef with: flags with: interfaceIndex with: fullname with: rrtype with: rrclass with: rdlen with: rdata with: ttl with: callBack with: context [
	
	"<C: DNSServiceErrorType DNSServiceRegisterRecord(DNSServiceRef sdRef, DNSRecordRef * RecordRef, DNSServiceFlags flags, uint32_t interfaceIndex, const char * fullname, uint16_t rrtype, uint16_t rrclass, uint16_t rdlen, const void * rdata, uint32_t ttl, DNSServiceRegisterRecordReply callBack, void * context)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #types }
BonjourLibraryFFIAbstract >> DNSServiceRegisterRecordReply [
	
	"<C: typedef void (* DNSServiceRegisterRecordReply)(DNSServiceRef sdRef, DNSRecordRef RecordRef, DNSServiceFlags flags, DNSServiceErrorType errorCode, void * context)>"
	
]

{ #category : #'callbacks types' }
BonjourLibraryFFIAbstract >> DNSServiceRegisterReply [


	^#(void * (void *sdRef, uint32 flags, int errorCode, char * name, char * regtype, char * domain, void * context))
	
	
]

{ #category : #callouts }
BonjourLibraryFFIAbstract >> DNSServiceRegisterv1: sdRef with: flags with: interfaceIndex with: name with: regtype with: domain with: host with: port with: txtLen with: txtRecord with: callBack with: context [

	^self ffiCall: #(
		int DNSServiceRegister 
			(void * sdRef, 
			uint32 flags, 
			uint32 interfaceIndex, 
			char * name, 
			char * regtype, 
			char * domain, 
			char * host, 
			uint16 port, 
			uint16 txtLen, 
			void * txtRecord, 
			BonjourCallback callBack, 
			void * context))
]

{ #category : #'callouts - unused' }
BonjourLibraryFFIAbstract >> DNSServiceRemoveRecord: sdRef with: RecordRef with: flags [
	
	"<C: DNSServiceErrorType DNSServiceRemoveRecord(DNSServiceRef sdRef, DNSRecordRef RecordRef, DNSServiceFlags flags)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #callouts }
BonjourLibraryFFIAbstract >> DNSServiceResolve: sdRef with: flags with: interfaceIndex with: name with: regtype with: domain with: callBack with: context [

	^self ffiCall: #(
		int DNSServiceResolve 
			(void * sdRef, 
			uint32 flags, 
			uint32 interfaceIndex, 
			char * name, 
			char * regtype, 
			char * domain, 
			BonjourCallback callBack, 
			void * context))
]

{ #category : #'callbacks types' }
BonjourLibraryFFIAbstract >> DNSServiceResolveReply [

		^#(void * (void *sdRef, uint32 flags, uint32 interfaceIndex, int errorCode, char * fullName, char * hosttarget, uint16 port, uint16 txtLen, void * txtRecord, void * context))
	
	
]

{ #category : #'enums - unused' }
BonjourLibraryFFIAbstract >> DNSServiceType [
	
	"<C: enum DNSServiceType {
			kDNSServiceType_A = 1, 
			kDNSServiceType_NS, 
			kDNSServiceType_MD, 
			kDNSServiceType_MF, 
			kDNSServiceType_CNAME, 
			kDNSServiceType_SOA, 
			kDNSServiceType_MB, 
			kDNSServiceType_MG, 
			kDNSServiceType_MR, 
			kDNSServiceType_NULL, 
			kDNSServiceType_WKS, 
			kDNSServiceType_PTR, 
			kDNSServiceType_HINFO, 
			kDNSServiceType_MINFO, 
			kDNSServiceType_MX, 
			kDNSServiceType_TXT, 
			kDNSServiceType_RP, 
			kDNSServiceType_AFSDB, 
			kDNSServiceType_X25, 
			kDNSServiceType_ISDN, 
			kDNSServiceType_RT, 
			kDNSServiceType_NSAP, 
			kDNSServiceType_NSAP_PTR, 
			kDNSServiceType_SIG, 
			kDNSServiceType_KEY, 
			kDNSServiceType_PX, 
			kDNSServiceType_GPOS, 
			kDNSServiceType_AAAA, 
			kDNSServiceType_LOC, 
			kDNSServiceType_NXT, 
			kDNSServiceType_EID, 
			kDNSServiceType_NIMLOC, 
			kDNSServiceType_SRV, 
			kDNSServiceType_ATMA, 
			kDNSServiceType_NAPTR, 
			kDNSServiceType_KX, 
			kDNSServiceType_CERT, 
			kDNSServiceType_A6, 
			kDNSServiceType_DNAME, 
			kDNSServiceType_SINK, 
			kDNSServiceType_OPT, 
			kDNSServiceType_APL, 
			kDNSServiceType_DS, 
			kDNSServiceType_SSHFP, 
			kDNSServiceType_IPSECKEY, 
			kDNSServiceType_RRSIG, 
			kDNSServiceType_NSEC, 
			kDNSServiceType_DNSKEY, 
			kDNSServiceType_DHCID, 
			kDNSServiceType_NSEC3, 
			kDNSServiceType_NSEC3PARAM, 
			kDNSServiceType_HIP = 55, 
			kDNSServiceType_SPF = 99, 
			kDNSServiceType_UINFO, 
			kDNSServiceType_UID, 
			kDNSServiceType_GID, 
			kDNSServiceType_UNSPEC, 
			kDNSServiceType_TKEY = 249, 
			kDNSServiceType_TSIG, 
			kDNSServiceType_IXFR, 
			kDNSServiceType_AXFR, 
			kDNSServiceType_MAILB, 
			kDNSServiceType_MAILA, 
			kDNSServiceType_ANY
		}>"
	
]

{ #category : #'callouts - unused' }
BonjourLibraryFFIAbstract >> DNSServiceUpdateRecord: sdRef with: RecordRef with: flags with: rdlen with: rdata with: ttl [
	
	"<C: DNSServiceErrorType DNSServiceUpdateRecord(DNSServiceRef sdRef, DNSRecordRef RecordRef, DNSServiceFlags flags, uint16_t rdlen, const void * rdata, uint32_t ttl)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #'callouts - unused' }
BonjourLibraryFFIAbstract >> TXTRecordContainsKey: txtLen with: txtRecord with: key [
	
	"<C: int TXTRecordContainsKey(uint16_t txtLen, const void * txtRecord, const char * key)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #'callouts - unused' }
BonjourLibraryFFIAbstract >> TXTRecordCreate: txtRecord with: bufferLen with: buffer [
	
	"<C: void TXTRecordCreate(TXTRecordRef * txtRecord, uint16_t bufferLen, void * buffer)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #'callouts - unused' }
BonjourLibraryFFIAbstract >> TXTRecordDeallocate: txtRecord [
	
	"<C: void TXTRecordDeallocate(TXTRecordRef * txtRecord)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #'callouts - unused' }
BonjourLibraryFFIAbstract >> TXTRecordGetBytesPtr: txtRecord [
	
	"<C: const void *  TXTRecordGetBytesPtr(const TXTRecordRef * txtRecord)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #'callouts - unused' }
BonjourLibraryFFIAbstract >> TXTRecordGetCount: txtLen with: txtRecord [
	
	"<C: uint16_t TXTRecordGetCount(uint16_t txtLen, const void * txtRecord)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #'callouts - unused' }
BonjourLibraryFFIAbstract >> TXTRecordGetItemAtIndex: txtLen with: txtRecord with: itemIndex with: keyBufLen with: key with: valueLen with: value [
	
	"<C: DNSServiceErrorType TXTRecordGetItemAtIndex(uint16_t txtLen, const void * txtRecord, uint16_t itemIndex, uint16_t keyBufLen, char * key, uint8_t * valueLen, const void * * value)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #'callouts - unused' }
BonjourLibraryFFIAbstract >> TXTRecordGetLength: txtRecord [
	
	"<C: uint16_t TXTRecordGetLength(const TXTRecordRef * txtRecord)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #'callouts - unused' }
BonjourLibraryFFIAbstract >> TXTRecordGetValuePtr: txtLen with: txtRecord with: key with: valueLen [
	
	"<C: const void *  TXTRecordGetValuePtr(uint16_t txtLen, const void * txtRecord, const char * key, uint8_t * valueLen)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #types }
BonjourLibraryFFIAbstract >> TXTRecordRef [
	
	"<C: typedef union _TXTRecordRef_t TXTRecordRef>"
	
]

{ #category : #'callouts - unused' }
BonjourLibraryFFIAbstract >> TXTRecordRemoveValue: txtRecord with: key [
	
	"<C: DNSServiceErrorType TXTRecordRemoveValue(TXTRecordRef * txtRecord, const char * key)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #'callouts - unused' }
BonjourLibraryFFIAbstract >> TXTRecordSetValue: txtRecord with: key with: valueSize with: value [
	
	"<C: DNSServiceErrorType TXTRecordSetValue(TXTRecordRef * txtRecord, const char * key, uint8_t valueSize, const void * value)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #structs }
BonjourLibraryFFIAbstract >> _DNSRecordRef_t [
	
	"<C: struct _DNSRecordRef_t>"
	
]

{ #category : #structs }
BonjourLibraryFFIAbstract >> _DNSServiceRef_t [
	
	"<C: struct _DNSServiceRef_t>"
	
]

{ #category : #'defines - unused' }
BonjourLibraryFFIAbstract >> _DNS_SD_H [
	
	"<C: #define _DNS_SD_H 2140308>"
	
]

{ #category : #unions }
BonjourLibraryFFIAbstract >> _TXTRecordRef_t [
	
	"<C: union _TXTRecordRef_t {
			char PrivateData[16];
			char * ForceNaturalAlignment;
		}>"
	
]

{ #category : #'defines - unused' }
BonjourLibraryFFIAbstract >> __DATE__ [
	
	"<C: #define __DATE__ ""12 December 2014"">"
	
]

{ #category : #'defines - unused' }
BonjourLibraryFFIAbstract >> __FILE__ [
	
	"<C: #define __FILE__ c:\OverDrive\image.Bonjour\library\14.12d 0.12d.dns_sd.h>"
	
]

{ #category : #'defines - unused' }
BonjourLibraryFFIAbstract >> __LINE__ [
	
	"<C: #define __LINE__ 0>"
	
]

{ #category : #'defines - unused' }
BonjourLibraryFFIAbstract >> __STDC__ [
	
	"<C: #define __STDC__ 1>"
	
]

{ #category : #'defines - unused' }
BonjourLibraryFFIAbstract >> __TIME__ [
	
	"<C: #define __TIME__ ""7:28:13 PM"">"
	
]

{ #category : #types }
BonjourLibraryFFIAbstract >> basicTypeNotes [
	"
	uint8_t, uint16_t, uint32_t and uint64_t.

	It turns out that they are equal respectively to: unsigned char, unsigned short, unsigned int and unsigned long long.
	"
	
	
]

{ #category : #configuration }
BonjourLibraryFFIAbstract >> calloutAPIClass [

	"super calloutAPIClass"

	"^FFICalloutAPI - get subclass responsibility error"

	^TFCalloutAPI "Default - required for threaded back end - should be used for non threaded?"
]

{ #category : #configuration }
BonjourLibraryFFIAbstract >> calloutAPIClassTest [

	"super calloutAPIClass"

	"^FFICalloutAPI "

	^TFCalloutAPI 
]

{ #category : #enums }
BonjourLibraryFFIAbstract >> dictionaryFrom: aString [

	| lines dictionary |
	
	dictionary := Dictionary new.
	lines := aString substrings: ','.
			
	lines do: [ : line | | stream key value |
		stream := line trimmed readStream.
		key := stream upTo: Character space.
		key := key asSymbol.
		stream upTo: Character space.
		value := stream upToEnd.
		dictionary at: key put: value asInteger].
			
	^dictionary

	
]

{ #category : #configuration }
BonjourLibraryFFIAbstract >> ffiLibrary [

	^self
]

{ #category : #configuration }
BonjourLibraryFFIAbstract >> ffiLibraryName [

	self halt.

	"
	'/usr/lib/system/libsystem_dnssd.dylib' asFileReference exists
	"

	"^FFIMacLibraryFinder findLibrary: 'libsystem_dnssd.dylib'."
	
	^'/usr/lib/system/libsystem_dnssd.dylib'
]

{ #category : #initialization }
BonjourLibraryFFIAbstract >> initialize [

	"
	self new
	"

	super initialize.
	self initializeEnums.
]

{ #category : #enums }
BonjourLibraryFFIAbstract >> initializeEnums [

	dnsServiceErr := self dictionaryFrom: self DNSServiceErrString.
	dnsServiceFlags := self dictionaryFrom: self DNSServiceFlagsString 
]

{ #category : #types }
BonjourLibraryFFIAbstract >> int32_t [
	
	"<C: typedef long int32_t>"
	
]

{ #category : #types }
BonjourLibraryFFIAbstract >> int32_tOriginal [
	
	"<C: typedef void * int32_tOriginal>"
	
]

{ #category : #defines }
BonjourLibraryFFIAbstract >> kDNSServiceInterfaceIndexAny [


	^0
	
	"<C: #define kDNSServiceInterfaceIndexAny 0>"
	
]

{ #category : #'defines - unused' }
BonjourLibraryFFIAbstract >> kDNSServiceInterfaceIndexLocalOnly [
	
	"<C: #define kDNSServiceInterfaceIndexLocalOnly ((uint32_t)-1)>"
	
]

{ #category : #'defines - unused' }
BonjourLibraryFFIAbstract >> kDNSServiceInterfaceIndexUnicast [
	
	"<C: #define kDNSServiceInterfaceIndexUnicast ((uint32_t)-2)>"
	
]

{ #category : #'defines - unused' }
BonjourLibraryFFIAbstract >> kDNSServiceMaxDomainName [
	
	"<C: #define kDNSServiceMaxDomainName 1009>"
	
]

{ #category : #'defines - unused' }
BonjourLibraryFFIAbstract >> kDNSServiceMaxServiceName [
	
	"<C: #define kDNSServiceMaxServiceName 64>"
	
]

{ #category : #defines }
BonjourLibraryFFIAbstract >> kDNSServiceProperty_DaemonVersion [

	^'DaemonVersion'
	
	"<C: #define kDNSServiceProperty_DaemonVersion ""DaemonVersion"">"
	
]

{ #category : #configuration }
BonjourLibraryFFIAbstract >> macLibraryName [

	"
	'/usr/lib/system/libsystem_dnssd.dylib' asFileReference exists
	"

	"^FFIMacLibraryFinder findLibrary: 'libsystem_dnssd.dylib'."
	
	^'/usr/lib/system/libsystem_dnssd.dylib'
]

{ #category : #configuration }
BonjourLibraryFFIAbstract >> runner [

	self subclassResponsibility
	
	"^runner ifNil: [runner := TFSameThreadRunner uniqueInstance]  - default == super runner"
	
	"^runner ifNil: [runner := TFWorker named: 'Bonjour']"
	
	"^runner ifNil: [runner := TFMainThreadRunner uniqueInstance] - not referenced?"

	"^TFProcessLocalWorker new   - how does this work - not referenced?
  		defaultWorker: super runner;
  		yourself"
	

	
	
	

	

]

{ #category : #structs }
BonjourLibraryFFIAbstract >> sockaddr [
	
	"<C: struct sockaddr {
		char				sin_len;
		char		 		sin_family;
		char				sin_port[2];    
		char				sin_addr[4];
		char				sin_zero[8]; 
		}>"
	
]

{ #category : #structs }
BonjourLibraryFFIAbstract >> sockaddrAsParsed [
	
	"<C: struct sockaddr>"
	
]

{ #category : #structs }
BonjourLibraryFFIAbstract >> sockaddrv1 [
	
	"<C: struct sockaddr {
		uint8_t         	sin_len;     
		uint16_t   		sin_family;  
		uint16_t       	sin_port;    
		uint64_t  		sin_addr;  
		char            	sin_zero[8]; 
		}>"
	
]

{ #category : #structs }
BonjourLibraryFFIAbstract >> sockaddrv2 [
	
	"<C: struct sockaddr {
		short				sin_len;
		unsigned short 		sin_family;
		unsigned long  		sin_port;    
		unsigned long long	sin_addr;  
		char				sin_zero[8]; 
		}>"
	
]

{ #category : #structs }
BonjourLibraryFFIAbstract >> sockaddrv3 [
	
	"<C: struct sockaddr {
		short				sin_len;
		unsigned short 		sin_family;
		char				sin_port[2];    
		char				sin_addr[4];
		char				sin_zero[8]; 
		}>"
	
]

{ #category : #types }
BonjourLibraryFFIAbstract >> uint16_t [
	
	"<C: typedef unsigned short uint16_t>"
	
]

{ #category : #types }
BonjourLibraryFFIAbstract >> uint16_tOriginal [
	"Changed this as when used in resolve for the port, it was returning a 32 bit value - needs to be 16 bit"
	
	"<C: typedef void * uint16_tOriginal>"
	
]

{ #category : #types }
BonjourLibraryFFIAbstract >> uint32_t [
	
	"<C: typedef unsigned long uint32_t>"
	
]

{ #category : #types }
BonjourLibraryFFIAbstract >> uint64_t [
	
	"<C: typedef unsigned long long uint64_t>"
	
]

{ #category : #types }
BonjourLibraryFFIAbstract >> uint8_t [
	
	"<C: typedef unsigned char uint8_t>"
	
]
