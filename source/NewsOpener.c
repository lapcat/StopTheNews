#import <CoreServices/CoreServices.h>

int main(int argc, const char* argv[]) {
	if (argc != 2) {
		fprintf(stderr, "Usage: NewsOpener [url]\n");
		return EXIT_FAILURE;
	}
	
	uint8_t buffer;
	ssize_t numberOfBytes;
	do {
		numberOfBytes = read(STDIN_FILENO, &buffer, 1);
	} while (numberOfBytes < 0 && errno == EINTR);
	if (numberOfBytes < 0) {
		perror("read");
		return EXIT_FAILURE;
	} else if (numberOfBytes > 0) {
		fprintf(stderr, "Unexpected numberOfBytes: %li\n", numberOfBytes);
		return EXIT_FAILURE;
	}
	
	const char* arg = argv[1];
	CFURLRef newsURL = CFURLCreateWithBytes(NULL, (const UInt8*)arg, (CFIndex)strlen(arg), kCFStringEncodingUTF8, NULL);
	if (newsURL == NULL) {
		fprintf(stderr, "Non-URL string: %s\n", arg);
		return EXIT_FAILURE;
	}
	CFMutableArrayRef itemURLs = CFArrayCreateMutable(NULL, 1, NULL);
	CFArrayAppendValue(itemURLs, newsURL);
	
	CFURLRef appURL = CFURLCreateWithFileSystemPath(NULL, CFSTR("/System/Applications/News.app"), kCFURLPOSIXPathStyle, true);
	if (appURL == NULL) {
		fprintf(stderr, "Could not create News app from path!\n");
		CFRelease(itemURLs);
		CFRelease(newsURL);
		return EXIT_FAILURE;
	}
	
	LSLaunchURLSpec launchSpec;
	bzero(&launchSpec, sizeof(LSLaunchURLSpec));
	launchSpec.appURL = appURL;
	launchSpec.itemURLs = itemURLs;
	OSStatus status = LSOpenFromURLSpec(&launchSpec, NULL);
	if (status != noErr)
		fprintf(stderr, "LSOpenFromURLSpec: %i\n", status);
	
	CFRelease(newsURL);
	return EXIT_SUCCESS;
}
