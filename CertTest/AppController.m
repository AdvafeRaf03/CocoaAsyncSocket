#import "AppController.h"
#import "AsyncSocket.h"
#import "X509Certificate.h"


@implementation AppController

- (id)init
{
	if(self = [super init])
	{
		asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
	}
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSLog(@"Ready");
	
	NSError *err = nil;
	if(![asyncSocket connectToHost:@"paypal.com" onPort:443 error:&err])
	{
		NSLog(@"Error: %@", err);
	}
}

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock
{
	// Connecting to a secure server
	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithCapacity:4];
	
	// Use the highest possible security
	[settings setObject:(NSString *)kCFStreamSocketSecurityLevelNegotiatedSSL
				 forKey:(NSString *)kCFStreamSSLLevel];
	
	// Allow expired certificates
	[settings setObject:[NSNumber numberWithBool:YES]
				 forKey:(NSString *)kCFStreamSSLAllowsExpiredCertificates];
	
	// Allow self-signed certificates
	[settings setObject:[NSNumber numberWithBool:YES]
				 forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	
	// In fact, don't even validate the certificate chain
	[settings setObject:[NSNumber numberWithBool:NO]
				 forKey:(NSString *)kCFStreamSSLValidatesCertificateChain];
	
	CFReadStreamSetProperty([asyncSocket getCFReadStream],
							kCFStreamPropertySSLSettings, (CFDictionaryRef)settings);
	CFWriteStreamSetProperty([asyncSocket getCFWriteStream],
							 kCFStreamPropertySSLSettings, (CFDictionaryRef)settings);
	
	return YES;
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	NSLog(@"onSocket:%p didConnectToHost:%@ port:%hu", sock, host, port);
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
	NSLog(@"onSocket:%p willDisconnectWithError:%@", sock, err);
}

- (IBAction)printCert:(id)sender
{
	NSDictionary *cert = [X509Certificate extractCertDictFromReadStream:[asyncSocket getCFReadStream]];
	NSLog(@"X509 Certificate: \n%@", cert);
}

@end
