Class {
	#name : #BonjourLibraryFFI,
	#superclass : #FFILibrary,
	#instVars : [
		'dnsServiceErr',
		'dnsServiceFlags'
	],
	#category : #'SIM-Bonjour'
}

{ #category : #structs }
BonjourLibraryFFI >> CompileTimeAssertionChecks_DNS_SD [
	
	"<C: struct CompileTimeAssertionChecks_DNS_SD {
			char assert0[1];
		}>"
	
]

{ #category : #types }
BonjourLibraryFFI >> DNSRecordRef [
	
	"<C: typedef struct _DNSRecordRef_t * DNSRecordRef>"
	
]

{ #category : #'defines - unused' }
BonjourLibraryFFI >> DNSSD_API [
	
	"<C: #define DNSSD_API>"
	
]

{ #category : #'callouts - unused' }
BonjourLibraryFFI >> DNSServiceAddRecord: sdRef with: RecordRef with: flags with: rrtype with: rdlen with: rdata with: ttl [
	
	"<C: DNSServiceErrorType DNSServiceAddRecord(DNSServiceRef sdRef, DNSRecordRef * RecordRef, DNSServiceFlags flags, uint16_t rrtype, uint16_t rdlen, const void * rdata, uint32_t ttl)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #callouts }
BonjourLibraryFFI >> DNSServiceBrowse: sdRef with: flags with: interfaceIndex with: regtype with: domain with: callBack with: context [

	^self ffiCall: #(int DNSServiceBrowse (void **sdRef, uint32 flags, uint32 interfaceIndex, char * regtype, char * domain, FFICallback callBack, void * context))
	
	
	"<C: DNSServiceErrorType DNSServiceBrowse(DNSServiceRef * sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, const char * regtype, const char * domain, DNSServiceBrowseReply callBack, void * context)>
	^self externalAccessFailedWith: _errorCode"
	
]

{ #category : #'callbacks types' }
BonjourLibraryFFI >> DNSServiceBrowseReply [
	
	^#(void * (void *sdRef, uint32 flags, uint32 interfaceIndex, int errorCode, char * serviceName, char * regtype, char * replyDomain, void * context))
	
		"<C: typedef VOID (__stdcall * DNSServiceBrowseReply)(DNSServiceRef sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, DNSServiceErrorType errorCode, const char * serviceName, const char * regtype, const char * replyDomain, void * context)>"
	
]

{ #category : #'callbacks types' }
BonjourLibraryFFI >> DNSServiceBrowseReplyJames [
	
	"<C: typedef VOID (__stdcall * DNSServiceBrowseReply)(DNSServiceRef sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, DNSServiceErrorType errorCode, const char * serviceName, const char * regtype, const char * replyDomain, void * context)>"
	
]

{ #category : #'callbacks types' }
BonjourLibraryFFI >> DNSServiceBrowseReplyOriginal [
	
	"<C: typedef void ( * DNSServiceBrowseReply)(DNSServiceRef sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, DNSServiceErrorType errorCode, const char * serviceName, const char * regtype, const char * replyDomain, void * context)>"
	
]

{ #category : #'enums - unused' }
BonjourLibraryFFI >> DNSServiceClass [
	
	"<C: enum DNSServiceClass {
			kDNSServiceClass_IN = 1
		}>"
	
]

{ #category : #'callouts - unused' }
BonjourLibraryFFI >> DNSServiceConstructFullName: fullName with: service with: regtype with: domain [
	
	"<C: DNSServiceErrorType DNSServiceConstructFullName(char * fullName, const char * service, const char * regtype, const char * domain)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #'callouts - unused' }
BonjourLibraryFFI >> DNSServiceCreateConnection: sdRef [
	
	"<C: DNSServiceErrorType DNSServiceCreateConnection(DNSServiceRef * sdRef)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #types }
BonjourLibraryFFI >> DNSServiceDomainEnumReply [
	
	"<C: typedef void (* DNSServiceDomainEnumReply)(DNSServiceRef sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, DNSServiceErrorType errorCode, const char * replyDomain, void * context)>"
	
]

{ #category : #'callouts - unused' }
BonjourLibraryFFI >> DNSServiceEnumerateDomains: sdRef with: flags with: interfaceIndex with: callBack with: context [
	
	"<C: DNSServiceErrorType DNSServiceEnumerateDomains(DNSServiceRef * sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, DNSServiceDomainEnumReply callBack, void * context)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #enums }
BonjourLibraryFFI >> DNSServiceErr [
	
	^dnsServiceErr
]

{ #category : #enums }
BonjourLibraryFFI >> DNSServiceErrString [

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
BonjourLibraryFFI >> DNSServiceErrorType [
	
	"<C: typedef int32_t DNSServiceErrorType>"
	
]

{ #category : #types }
BonjourLibraryFFI >> DNSServiceErrorTypeOriginal [
	"Tried changing this to long (following changing int32_t), but this made no difference.
	Function calls still returning a pointer to the error code"
	
	"<C: typedef int32_t DNSServiceErrorType>"
	
]

{ #category : #types }
BonjourLibraryFFI >> DNSServiceFlags [
	
	"<C: typedef uint32_t DNSServiceFlags>"
	
]

{ #category : #enums }
BonjourLibraryFFI >> DNSServiceFlagsEnum [
	
	^dnsServiceFlags
]

{ #category : #enums }
BonjourLibraryFFI >> DNSServiceFlagsString [
	
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
BonjourLibraryFFI >> DNSServiceGetAddrInfo: sdRef with: flags with: interfaceIndex with: protocol with: hostName with: callBack with: context [


	^self ffiCall: #(int DNSServiceGetAddrInfo (void **sdRef, uint32 flags, uint32 interfaceIndex, uint32 * protocol, char * hostName, FFICallback callBack, void * context))
	
	
	"<C: DNSServiceErrorType DNSServiceGetAddrInfo(DNSServiceRef * sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, DNSServiceProtocolType protocol, const char * hostName, DNSServiceGetAddrInfoReply callBack, void * context)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #'callbacks types' }
BonjourLibraryFFI >> DNSServiceGetAddrInfoReply [


	^#(void * (void *sdRef, uint32 flags, uint32 interfaceIndex, int errorCode, char * hostname, SocketAddressStructure * sockaddr, uint32 ttl, void * context))
	
	"<C: typedef void (__stdcall * DNSServiceGetAddrInfoReply)(DNSServiceRef sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, DNSServiceErrorType errorCode, const char * hostname, const struct sockaddr * address, uint32_t ttl, void * context)>"
	
]

{ #category : #callouts }
BonjourLibraryFFI >> DNSServiceGetProperty: property with: result with: size [


	^ self ffiCall: #(int32 DNSServiceGetProperty (char * property, void * result, uint32 * size))
	
	"<C: DNSServiceErrorType DNSServiceGetProperty(const char * property, void * result, uint32_t * size)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #types }
BonjourLibraryFFI >> DNSServiceNATPortMappingReply [
	
	"<C: typedef void (* DNSServiceNATPortMappingReply)(DNSServiceRef sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, DNSServiceErrorType errorCode, uint32_t externalAddress, enum DNSServiceProtocol protocol, uint16_t internalPort, uint16_t externalPort, uint32_t ttl, void * context)>"
	
]

{ #category : #callouts }
BonjourLibraryFFI >> DNSServiceProcessResult: sdRef [ 

	^self ffiCall: #(int DNSServiceProcessResult (void *sdRef))
	
	"^self ffiCall: #(int DNSServiceProcessResult (DNSServiceRef *sdRef)) - freezes image"

	"^self ffiCall: #(int DNSServiceProcessResult (void *sdRef))" "Works non threading (but freezes if doesn't return), threading: crashes seg fault"
	
	" ^self ffiCall: #(int DNSServiceProcessResult (void sdRef)) - threading - primititve failed"

	"^self ffiCall: #(int DNSServiceProcessResult (void **sdRef)) - get bad parameter"
	
	"<C: DNSServiceErrorType _threaded DNSServiceProcessResult(DNSServiceRef sdRef)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #'enums - unused' }
BonjourLibraryFFI >> DNSServiceProtocol [
	"Got name conflick when trying to compile this type - was a enum. Machinery hanging on to it?
	Similar problem with types not being reflected, had to recompile methods"
	
	
]

{ #category : #'enums - unused' }
BonjourLibraryFFI >> DNSServiceProtocolEnum [
	
	"<C: enum DNSServiceProtocol {
			kDNSServiceProtocol_IPv4 = 1, 
			kDNSServiceProtocol_IPv6, 
			kDNSServiceProtocol_UDP = 16, 
			kDNSServiceProtocol_TCP = 32
		}>"
	
]

{ #category : #types }
BonjourLibraryFFI >> DNSServiceProtocolType [
	
	"<C: typedef uint32_t DNSServiceProtocolType>"
	
]

{ #category : #'callouts - unused' }
BonjourLibraryFFI >> DNSServiceQueryRecord: sdRef with: flags with: interfaceIndex with: fullname with: rrtype with: rrclass with: callBack with: context [
	
	"<C: DNSServiceErrorType DNSServiceQueryRecord(DNSServiceRef * sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, const char * fullname, uint16_t rrtype, uint16_t rrclass, DNSServiceQueryRecordReply callBack, void * context)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #types }
BonjourLibraryFFI >> DNSServiceQueryRecordReply [
	
	"<C: typedef void (* DNSServiceQueryRecordReply)(DNSServiceRef sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, DNSServiceErrorType errorCode, const char * fullname, uint16_t rrtype, uint16_t rrclass, uint16_t rdlen, const void * rdata, uint32_t ttl, void * context)>"
	
]

{ #category : #'callouts - unused' }
BonjourLibraryFFI >> DNSServiceReconfirmRecord: flags with: interfaceIndex with: fullname with: rrtype with: rrclass with: rdlen with: rdata [
	
	"<C: DNSServiceErrorType DNSServiceReconfirmRecord(DNSServiceFlags flags, uint32_t interfaceIndex, const char * fullname, uint16_t rrtype, uint16_t rrclass, uint16_t rdlen, const void * rdata)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #types }
BonjourLibraryFFI >> DNSServiceRef [
	
	"<C: typedef struct _DNSServiceRef_t * DNSServiceRef>"
	
]

{ #category : #callouts }
BonjourLibraryFFI >> DNSServiceRefDeallocate: sdRef [


	^self ffiCall: #(int DNSServiceRefDeallocate (void * sdRef))
	
	"<C: void DNSServiceRefDeallocate(DNSServiceRef sdRef)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #'callouts - unused' }
BonjourLibraryFFI >> DNSServiceRefSockFD: sdRef [
	
	"<C: int DNSServiceRefSockFD(DNSServiceRef sdRef)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #callouts }
BonjourLibraryFFI >> DNSServiceRegister: sdRef with: flags with: interfaceIndex with: name with: regtype with: domain with: host with: port with: txtLen with: txtRecord with: callBack with: context [


	^self ffiCall: #(int DNSServiceRegister (void **sdRef, uint32 flags, uint32 interfaceIndex, char * name, char * regtype, char * domain, char * host, uint16 port, unint16 txtLen, void * txtRecord, FFICallback callBack, void * context))
	
	"<C: DNSServiceErrorType DNSServiceRegister(DNSServiceRef * sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, const char * name, const char * regtype, const char * domain, const char * host, uint16_t port, uint16_t txtLen, const void * txtRecord, DNSServiceRegisterReply callBack, void * context)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #'callouts - unused' }
BonjourLibraryFFI >> DNSServiceRegisterRecord: sdRef with: RecordRef with: flags with: interfaceIndex with: fullname with: rrtype with: rrclass with: rdlen with: rdata with: ttl with: callBack with: context [
	
	"<C: DNSServiceErrorType DNSServiceRegisterRecord(DNSServiceRef sdRef, DNSRecordRef * RecordRef, DNSServiceFlags flags, uint32_t interfaceIndex, const char * fullname, uint16_t rrtype, uint16_t rrclass, uint16_t rdlen, const void * rdata, uint32_t ttl, DNSServiceRegisterRecordReply callBack, void * context)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #types }
BonjourLibraryFFI >> DNSServiceRegisterRecordReply [
	
	"<C: typedef void (* DNSServiceRegisterRecordReply)(DNSServiceRef sdRef, DNSRecordRef RecordRef, DNSServiceFlags flags, DNSServiceErrorType errorCode, void * context)>"
	
]

{ #category : #'callbacks types' }
BonjourLibraryFFI >> DNSServiceRegisterReply [


	^#(void * (void *sdRef, uint32 flags, int errorCode, char * name, char * regtype, char * domain, void * context))
	
	"<C: typedef void (__stdcall * DNSServiceRegisterReply)(DNSServiceRef sdRef, DNSServiceFlags flags, DNSServiceErrorType errorCode, const char * name, const char * regtype, const char * domain, void * context)>"
	
]

{ #category : #'callouts - unused' }
BonjourLibraryFFI >> DNSServiceRemoveRecord: sdRef with: RecordRef with: flags [
	
	"<C: DNSServiceErrorType DNSServiceRemoveRecord(DNSServiceRef sdRef, DNSRecordRef RecordRef, DNSServiceFlags flags)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #callouts }
BonjourLibraryFFI >> DNSServiceResolve: sdRef with: flags with: interfaceIndex with: name with: regtype with: domain with: callBack with: context [


	^self ffiCall: #(int DNSServiceResolve (void **sdRef, uint32 flags, uint32 interfaceIndex, char * name, char * regtype, char * domain, FFICallback callBack, void * context))
	
	"<C: DNSServiceErrorType DNSServiceResolve(DNSServiceRef * sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, const char * name, const char * regtype, const char * domain, DNSServiceResolveReply callBack, void * context)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #'callbacks types' }
BonjourLibraryFFI >> DNSServiceResolveReply [


		^#(void * (void *sdRef, uint32 flags, uint32 interfaceIndex, int errorCode, char * fullName, char * hosttarget, uint16 port, uint16 txtLen, char * txtRecord, void * context))
	
	
	"<C: typedef VOID (__stdcall * DNSServiceResolveReply)(DNSServiceRef sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, DNSServiceErrorType errorCode, const char * fullname, const char * hosttarget, uint16_t port, uint16_t txtLen, const unsigned char * txtRecord, void * context)>"
	
]

{ #category : #'enums - unused' }
BonjourLibraryFFI >> DNSServiceType [
	
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
BonjourLibraryFFI >> DNSServiceUpdateRecord: sdRef with: RecordRef with: flags with: rdlen with: rdata with: ttl [
	
	"<C: DNSServiceErrorType DNSServiceUpdateRecord(DNSServiceRef sdRef, DNSRecordRef RecordRef, DNSServiceFlags flags, uint16_t rdlen, const void * rdata, uint32_t ttl)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #'callouts - unused' }
BonjourLibraryFFI >> TXTRecordContainsKey: txtLen with: txtRecord with: key [
	
	"<C: int TXTRecordContainsKey(uint16_t txtLen, const void * txtRecord, const char * key)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #'callouts - unused' }
BonjourLibraryFFI >> TXTRecordCreate: txtRecord with: bufferLen with: buffer [
	
	"<C: void TXTRecordCreate(TXTRecordRef * txtRecord, uint16_t bufferLen, void * buffer)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #'callouts - unused' }
BonjourLibraryFFI >> TXTRecordDeallocate: txtRecord [
	
	"<C: void TXTRecordDeallocate(TXTRecordRef * txtRecord)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #'callouts - unused' }
BonjourLibraryFFI >> TXTRecordGetBytesPtr: txtRecord [
	
	"<C: const void *  TXTRecordGetBytesPtr(const TXTRecordRef * txtRecord)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #'callouts - unused' }
BonjourLibraryFFI >> TXTRecordGetCount: txtLen with: txtRecord [
	
	"<C: uint16_t TXTRecordGetCount(uint16_t txtLen, const void * txtRecord)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #'callouts - unused' }
BonjourLibraryFFI >> TXTRecordGetItemAtIndex: txtLen with: txtRecord with: itemIndex with: keyBufLen with: key with: valueLen with: value [
	
	"<C: DNSServiceErrorType TXTRecordGetItemAtIndex(uint16_t txtLen, const void * txtRecord, uint16_t itemIndex, uint16_t keyBufLen, char * key, uint8_t * valueLen, const void * * value)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #'callouts - unused' }
BonjourLibraryFFI >> TXTRecordGetLength: txtRecord [
	
	"<C: uint16_t TXTRecordGetLength(const TXTRecordRef * txtRecord)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #'callouts - unused' }
BonjourLibraryFFI >> TXTRecordGetValuePtr: txtLen with: txtRecord with: key with: valueLen [
	
	"<C: const void *  TXTRecordGetValuePtr(uint16_t txtLen, const void * txtRecord, const char * key, uint8_t * valueLen)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #types }
BonjourLibraryFFI >> TXTRecordRef [
	
	"<C: typedef union _TXTRecordRef_t TXTRecordRef>"
	
]

{ #category : #'callouts - unused' }
BonjourLibraryFFI >> TXTRecordRemoveValue: txtRecord with: key [
	
	"<C: DNSServiceErrorType TXTRecordRemoveValue(TXTRecordRef * txtRecord, const char * key)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #'callouts - unused' }
BonjourLibraryFFI >> TXTRecordSetValue: txtRecord with: key with: valueSize with: value [
	
	"<C: DNSServiceErrorType TXTRecordSetValue(TXTRecordRef * txtRecord, const char * key, uint8_t valueSize, const void * value)>
	^self externalAccessFailedWith: _errorCode"
]

{ #category : #structs }
BonjourLibraryFFI >> _DNSRecordRef_t [
	
	"<C: struct _DNSRecordRef_t>"
	
]

{ #category : #structs }
BonjourLibraryFFI >> _DNSServiceRef_t [
	
	"<C: struct _DNSServiceRef_t>"
	
]

{ #category : #'defines - unused' }
BonjourLibraryFFI >> _DNS_SD_H [
	
	"<C: #define _DNS_SD_H 2140308>"
	
]

{ #category : #unions }
BonjourLibraryFFI >> _TXTRecordRef_t [
	
	"<C: union _TXTRecordRef_t {
			char PrivateData[16];
			char * ForceNaturalAlignment;
		}>"
	
]

{ #category : #'defines - unused' }
BonjourLibraryFFI >> __DATE__ [
	
	"<C: #define __DATE__ ""12 December 2014"">"
	
]

{ #category : #'defines - unused' }
BonjourLibraryFFI >> __FILE__ [
	
	"<C: #define __FILE__ c:\OverDrive\image.Bonjour\library\14.12d 0.12d.dns_sd.h>"
	
]

{ #category : #'defines - unused' }
BonjourLibraryFFI >> __LINE__ [
	
	"<C: #define __LINE__ 0>"
	
]

{ #category : #'defines - unused' }
BonjourLibraryFFI >> __STDC__ [
	
	"<C: #define __STDC__ 1>"
	
]

{ #category : #'defines - unused' }
BonjourLibraryFFI >> __TIME__ [
	
	"<C: #define __TIME__ ""7:28:13 PM"">"
	
]

{ #category : #types }
BonjourLibraryFFI >> basicTypeNotes [
	"
	uint8_t, uint16_t, uint32_t and uint64_t.

	It turns out that they are equal respectively to: unsigned char, unsigned short, unsigned int and unsigned long long.
	"
	
	
]

{ #category : #configuration }
BonjourLibraryFFI >> calloutAPIClass [

	"super calloutAPIClass"

	"^FFICalloutAPI "

	^TFCalloutAPI 
]

{ #category : #configuration }
BonjourLibraryFFI >> calloutAPIClassTest [

	"super calloutAPIClass"

	"^FFICalloutAPI "

	^TFCalloutAPI 
]

{ #category : #enums }
BonjourLibraryFFI >> dictionaryFrom: aString [

	| lines dictionary |
	
	dictionary := Dictionary new.
	lines := aString asArrayOfSubstringsSeparatedBy: $,.
			
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
BonjourLibraryFFI >> ffiLibrary [

	^self
]

{ #category : #configuration }
BonjourLibraryFFI >> ffiLibraryName [

	self halt.

	"
	'/usr/lib/system/libsystem_dnssd.dylib' asFileReference exists
	"

	"^FFIMacLibraryFinder findLibrary: 'libsystem_dnssd.dylib'."
	
	^'/usr/lib/system/libsystem_dnssd.dylib'
]

{ #category : #initialization }
BonjourLibraryFFI >> initialize [

	"
	self new
	"

	super initialize.
	self initializeEnums.
]

{ #category : #enums }
BonjourLibraryFFI >> initializeEnums [

	dnsServiceErr := self dictionaryFrom: self DNSServiceErrString.
	dnsServiceFlags := self dictionaryFrom: self DNSServiceFlagsString 
]

{ #category : #types }
BonjourLibraryFFI >> int32_t [
	
	"<C: typedef long int32_t>"
	
]

{ #category : #types }
BonjourLibraryFFI >> int32_tOriginal [
	
	"<C: typedef void * int32_tOriginal>"
	
]

{ #category : #defines }
BonjourLibraryFFI >> kDNSServiceInterfaceIndexAny [


	^0
	
	"<C: #define kDNSServiceInterfaceIndexAny 0>"
	
]

{ #category : #'defines - unused' }
BonjourLibraryFFI >> kDNSServiceInterfaceIndexLocalOnly [
	
	"<C: #define kDNSServiceInterfaceIndexLocalOnly ((uint32_t)-1)>"
	
]

{ #category : #'defines - unused' }
BonjourLibraryFFI >> kDNSServiceInterfaceIndexUnicast [
	
	"<C: #define kDNSServiceInterfaceIndexUnicast ((uint32_t)-2)>"
	
]

{ #category : #'defines - unused' }
BonjourLibraryFFI >> kDNSServiceMaxDomainName [
	
	"<C: #define kDNSServiceMaxDomainName 1009>"
	
]

{ #category : #'defines - unused' }
BonjourLibraryFFI >> kDNSServiceMaxServiceName [
	
	"<C: #define kDNSServiceMaxServiceName 64>"
	
]

{ #category : #defines }
BonjourLibraryFFI >> kDNSServiceProperty_DaemonVersion [

	^'DaemonVersion'
	
	"<C: #define kDNSServiceProperty_DaemonVersion ""DaemonVersion"">"
	
]

{ #category : #configuration }
BonjourLibraryFFI >> macLibraryName [

	"
	'/usr/lib/system/libsystem_dnssd.dylib' asFileReference exists
	"

	"^FFIMacLibraryFinder findLibrary: 'libsystem_dnssd.dylib'."
	
	^'/usr/lib/system/libsystem_dnssd.dylib'
]

{ #category : #configuration }
BonjourLibraryFFI >> runner [

	^super runner


	"
	^super runner
	"

	"
	^TFWorker default
	"
	
	"
	^TFMainThreadRunner uniqueInstance
	"

	"
	^TFProcessLocalWorker new
  		defaultWorker: TFWorker default;
  		yourself
	"

 	"
	^TFProcessLocalWorker new
  		defaultWorker: (TFWorker named: 'QUEUE');
  		yourself
	"
		
	"
	^TFProcessLocalWorker new
  		defaultWorker: super runner;
  		yourself
	"
]

{ #category : #structs }
BonjourLibraryFFI >> sockaddr [
	
	"<C: struct sockaddr {
		char				sin_len;
		char		 		sin_family;
		char				sin_port[2];    
		char				sin_addr[4];
		char				sin_zero[8]; 
		}>"
	
]

{ #category : #structs }
BonjourLibraryFFI >> sockaddrAsParsed [
	
	"<C: struct sockaddr>"
	
]

{ #category : #structs }
BonjourLibraryFFI >> sockaddrv1 [
	
	"<C: struct sockaddr {
		uint8_t         	sin_len;     
		uint16_t   		sin_family;  
		uint16_t       	sin_port;    
		uint64_t  		sin_addr;  
		char            	sin_zero[8]; 
		}>"
	
]

{ #category : #structs }
BonjourLibraryFFI >> sockaddrv2 [
	
	"<C: struct sockaddr {
		short				sin_len;
		unsigned short 		sin_family;
		unsigned long  		sin_port;    
		unsigned long long	sin_addr;  
		char				sin_zero[8]; 
		}>"
	
]

{ #category : #structs }
BonjourLibraryFFI >> sockaddrv3 [
	
	"<C: struct sockaddr {
		short				sin_len;
		unsigned short 		sin_family;
		char				sin_port[2];    
		char				sin_addr[4];
		char				sin_zero[8]; 
		}>"
	
]

{ #category : #structs }
BonjourLibraryFFI >> socketNotes [
	"	From IPSocket class comment:
	That is, an Internet address has a 2-byte port number and a 4-byte host address.
	struct in_addr {
		union {
			struct { u_char s_b1,s_b2,s_b3,s_b4; } S_un_b;
			struct { u_short s_w1,s_w2; } S_un_w;
			u_long S_addr;
		} S_un;
	struct sockaddr_in {
		short sin_family;
		u_short sin_port;
		struct in_addr sin_addr;	
		char sin_zero[8];
	};
=========================================================
http://www.informit.com/articles/article.aspx?p=169505&seqNum=2
The Internet (IPv4) socket address structure: sockaddr_in.
struct in_addr {
  in_addr_t   s_addr;           /* 32-bit IPv4 address */
                                /* network byte ordered */
};

struct sockaddr_in {
  uint8_t         sin_len;      /* length of structure (16) */
  sa_family_t     sin_family;   /* AF_INET */
  in_port_t       sin_port;     /* 16-bit TCP or UDP port number */
                                /* network byte ordered */
  struct in_addr  sin_addr;     /* 32-bit IPv4 address */
                                /* network byte ordered */
  char            sin_zero[8];  /* unused */
};
===============================================
From: http://stackoverflow.com/questions/11924068/what-is-sa-family-t
struct sockaddr {
        u_short sa_family;              /* address family */
        char    sa_data[14];            /* up to 14 bytes of direct address */
};

"
	
	
]

{ #category : #types }
BonjourLibraryFFI >> uint16_t [
	
	"<C: typedef unsigned short uint16_t>"
	
]

{ #category : #types }
BonjourLibraryFFI >> uint16_tOriginal [
	"Changed this as when used in resolve for the port, it was returning a 32 bit value - needs to be 16 bit"
	
	"<C: typedef void * uint16_tOriginal>"
	
]

{ #category : #types }
BonjourLibraryFFI >> uint32_t [
	
	"<C: typedef unsigned long uint32_t>"
	
]

{ #category : #types }
BonjourLibraryFFI >> uint64_t [
	
	"<C: typedef unsigned long long uint64_t>"
	
]

{ #category : #types }
BonjourLibraryFFI >> uint8_t [
	
	"<C: typedef unsigned char uint8_t>"
	
]
