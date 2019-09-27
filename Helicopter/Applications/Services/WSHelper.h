//
//  WSHelper.h
//
//
//  Created by Nguyen Chi Dung on 3/25/14.
//
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define WS_URL                                  @"private""
#define WS_GET_LOCATION_URL(limit,offset)       [NSString stringWithFormat:@"%@get_all_location?limit=%@&offset=%@",WS_URL,limit,offset]
#define WS_GET_CONTRACT_CHATER_URL(customerId)  [NSString stringWithFormat:@"%@get_list_contract_and_job_by_customer?customer_id=%@",WS_URL,customerId]
#define WS_GET_MODEL_URL                        [NSString stringWithFormat:@"%@get_all_model",WS_URL]
#define WS_GET_AC_URL(modelId)                  [NSString stringWithFormat:@"%@get_list_ac_by_model?model_id=%@",WS_URL,modelId]
#define WS_GET_CUSTOMER_URL                     [NSString stringWithFormat:@"%@get_all_customer",WS_URL]
#define WS_GET_EMPLOYEE_URL                     [NSString stringWithFormat:@"%@get_all_employee",WS_URL]
#define WS_GET_SPLOT_PURPOSE_URL                [NSString stringWithFormat:@"%@get_all_slot_purpose",WS_URL]
#define WS_GET_LOCATION_TYPE_URL                [NSString stringWithFormat:@"%@get_all_location_type",WS_URL]
#define WS_GET_FUEL_OWNER                       [NSString stringWithFormat:@"%@get_all_fuelowner",WS_URL]

typedef NS_ENUM(NSInteger, WSKey) {
    WSKey_Location,
    WSKey_ContractChater,
    WSKey_Model,
    WSKey_AC,
    WSKey_Customer,
    WSKey_Employee,
    WSKey_SplotPurpose,
    WSKey_LocationType,
    WSKey_FuelOwner
};

@class ERA_Model,ERA_Customer;

typedef void  (^WSCompletionHandler) (BOOL successfully,NSInteger key, id object);

@interface WSHelper : NSObject {
    NSInteger _key;
    WSCompletionHandler _handler;
}

@property (nonatomic) BOOL isBusy;
@property (nonatomic, strong) ERA_Model *model;
@property (nonatomic, strong) ERA_Customer *customer;

+ (WSHelper *) sharedManager;

- (void) getDataForKey:(WSKey)key completionHandler:(WSCompletionHandler)handler;

- (void) getDataForKey:(WSKey)key params:(NSDictionary *)params completionHandler:(WSCompletionHandler)handler;

@end
