//
//  DataLoader.h
//
//
//  Created by Nguyen Chi Dung on 3/25/14.
//
//

#import <Foundation/Foundation.h>

@protocol DataLoaderDelegate<NSObject>

- (void) didFinishLoadData:(NSMutableData*) data forKey:(NSInteger) key;
- (void) didFailWithError:(NSError*) error forKey:(NSInteger) key;

@end

@interface DataLoader : NSObject

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, assign) NSTimeInterval timeOut;
@property (nonatomic, strong) id<DataLoaderDelegate> delegate;
@property (nonatomic, assign) NSInteger key;

- (void) loadDataWithStringURL:(NSString *)strURL delegate:(id<DataLoaderDelegate>) delegate withKey:(NSInteger) key;
- (void) loadDataWithURLRequest:(NSURLRequest *) request delegate:(id<DataLoaderDelegate>) delegate;

@end
