//
//  DataLoader.h
//
//
//  Created by Nguyen Chi Dung on 3/25/14.
//
//


#import "DataLoader.h"

@implementation DataLoader

- (void)cancelDownload {
    self.delegate = nil;
    [_connection cancel];
}

- (void)loadDataWithStringURL:(NSString *)strURL delegate:(id<DataLoaderDelegate>) delegate withKey:(NSInteger)key {
    self.delegate = delegate;
    self.key = key;
    
#ifdef DEBUG
#endif
    
    NSURL *url = [[NSURL alloc] initWithString:strURL];
    NSTimeInterval _timeIterval = (_timeOut > 30) ? _timeOut : 30;
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:_timeIterval];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    self.connection = connection;
}

- (void)loadDataWithURLRequest:(NSURLRequest*)request delegate:(id<DataLoaderDelegate>) delegate {
    self.delegate = delegate;
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    self.connection = connection;
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSMutableData *data = [[NSMutableData alloc] initWithLength:0];
    self.data = data;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [_delegate didFailWithError:error forKey:_key];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [_delegate didFinishLoadData:_data forKey:_key];
}

@end
