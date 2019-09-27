//
//  WSHelper.m
//
//
//  Created by Nguyen Chi Dung on 3/25/14.
//
//


#import "WSHelper.h"
#import "DataLoader.h"
#import "ERA_AC.h"
#import "ERA_Customer.h"
#import "ERA_ContractCharter.h"
#import "ERA_Employee.h"
#import "ERA_Model.h"
#import "ERA_Location.h"
#import "ERA_LocationType.h"
#import "ERA_SlotPurpose.h"
#import "ERA_JobName.h"
#import "ERA_FuelOwner.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "NSString+AES.h"
#import "NSManagedObject+CDHelper.h"
#import "NSDate+Helper.h"
#import "NSDictionary+Additions.h"

@interface WSHelper()<DataLoaderDelegate> {
}
@end

@implementation WSHelper

- (id)init {
    self = [super init];
    if(self) {
    }
    return self;
}

+ (WSHelper *)sharedManager {
    static WSHelper *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)dealloc {
    if(_handler) {
        _handler = nil;
    }
}

- (void)getDataForKey:(WSKey)key completionHandler:(WSCompletionHandler)handler {
    _key = key;
    _handler = handler;
    NSString *stringUrl = nil;
    switch (key) {
        case WSKey_Customer: {
            stringUrl = WS_GET_CUSTOMER_URL;
        }
            break;
            
        case WSKey_Employee: {
            stringUrl = WS_GET_EMPLOYEE_URL;
        }
            break;
            
        case WSKey_Model: {
            stringUrl = WS_GET_MODEL_URL;
        }
            break;
            
        case WSKey_SplotPurpose: {
            stringUrl = WS_GET_SPLOT_PURPOSE_URL;
        }
            break;
            
        case WSKey_LocationType: {
            stringUrl = WS_GET_LOCATION_TYPE_URL;
        }
            break;
            
        case WSKey_FuelOwner: {
            stringUrl = WS_GET_FUEL_OWNER;
        }
            break;
            
        default:
            break;
    }
    if (stringUrl) {
        DataLoader *dataLoader = [[DataLoader alloc] init];
        [dataLoader loadDataWithStringURL:stringUrl delegate:self withKey:_key];
    }
    else{
        _handler(NO,0,self);
    }
}

- (void)getDataForKey:(WSKey)key params:(NSDictionary *)params completionHandler:(WSCompletionHandler)handler {
    _key = key;
    _handler = handler;
    
    NSString *stringUrl = nil;
    switch (key) {
        case WSKey_Location: {
            NSString *limit = [params objectForKey:@"limit"];
            NSString *offset = [params objectForKey:@"offset"];
            stringUrl = WS_GET_LOCATION_URL(limit, offset);
        }
            break;
            
        case WSKey_ContractChater: {
            NSString *customer_id = [params objectForKey:@"customer_id"];
            stringUrl = WS_GET_CONTRACT_CHATER_URL(customer_id);
        }
            break;
            
        case WSKey_AC: {
            NSString *model_id = [params objectForKey:@"model_id"];
            stringUrl = WS_GET_AC_URL(model_id);
        }
            break;
            
        default:
            break;
    }
    
    if (stringUrl) {
        DataLoader *dataLoader = [[DataLoader alloc] init];
        [dataLoader loadDataWithStringURL:stringUrl delegate:self withKey:_key];
    }
    else{
        _handler(NO,_key,self);
    }
}

#pragma mark - DataLoaderDelegate

- (void)didFinishLoadData:(NSMutableData*)data forKey:(NSInteger)key {
    [self parserData:data];
}

- (void)didFailWithError:(NSError*) error forKey:(NSInteger) key {
    NSLog(@"error");
    _handler(NO,_key,nil);
}

#pragma mark - Privates
- (void)parserData:(NSData *)data {
    BOOL success = NO;
    id responseObj = nil;
 
    NSError *error;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
   
    if (error) {
        if (_handler) {
            _handler(success,_key,responseObj);
        }
        return;
    }
   
    switch (_key) {
        case WSKey_AC: {
            if (![responseDictionary objectForKeyNotNull:@"acs"]) {
                break;
            }
            NSMutableArray *ERA_ACs = [[NSMutableArray alloc] init];
            NSArray *locations = [responseDictionary objectForKeyNotNull:@"acs"];
            for (NSDictionary *dict in locations) {
                if([dict objectForKeyNotNull:@"status"] && [[[dict objectForKeyNotNull:@"status"] lowercaseString] isEqualToString:@"a"]) {
                    ERA_AC *obj = [ERA_AC createEntity];
                    obj.aCID = [NSNumber numberWithInteger:[[dict objectForKeyNotNull:@"acId"]integerValue]];
                    if ([dict objectForKeyNotNull:@"acName"]) {
                        obj.name =[dict objectForKey:@"acName"];
                    }
                    if ([dict objectForKeyNotNull:@"createdBy"]) {
                        obj.createdByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[dict objectForKeyNotNull:@"createdBy"]];
                    }
                    if ([dict objectForKeyNotNull:@"modifiedBy"]) {
                        obj.modifiedByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[dict objectForKeyNotNull:@"modifiedBy"]];
                    }
                    if ([dict objectForKeyNotNull:@"creationDate"]) {
                        obj.createdDate =[NSDate sharedDateValueFromString:[dict objectForKeyNotNull:@"creationDate"]];
                    }
                    if ([dict objectForKeyNotNull:@"modifiedDate"]) {
                        obj.modifiedDate =[NSDate sharedDateValueFromString:[dict objectForKeyNotNull:@"modifiedDate"]];
                    }

                    [ERA_ACs addObject:obj];
                    if (_model) {
                        obj.model = _model;
                    }
                }
            }
           
            [[CDHelper shareManager] saveContext];
            responseObj = ERA_ACs;
        }
            break;
            
        case WSKey_ContractChater: {
            if (![responseDictionary objectForKeyNotNull:@"jobs"] && ![responseDictionary objectForKeyNotNull:@"constracts"] ) {
                break;
            }
            
            NSMutableArray *ERA_constracts;
            if([responseDictionary objectForKeyNotNull:@"constracts"]) {
                ERA_constracts = [[NSMutableArray alloc] init];
                NSArray *constracts = [responseDictionary objectForKeyNotNull:@"constracts"];
                for (NSDictionary *dict  in constracts) {
                    ERA_ContractCharter *obj = [ERA_ContractCharter createEntity];
                    obj.contractCharterID = [NSNumber numberWithInteger:[[dict objectForKeyNotNull:@"baseId"] integerValue]];
                    if ([dict objectForKeyNotNull:@"baseName"]) {
                        obj.name =[dict objectForKeyNotNull:@"baseName"];
                    }
                    if ([dict objectForKeyNotNull:@"createdBy"]) {
                        obj.createdByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[dict objectForKeyNotNull:@"createdBy"]];
                    }
                    if ([dict objectForKeyNotNull:@"modifiedBy"]) {
                        obj.modifiedByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[dict objectForKeyNotNull:@"modifiedBy"]];
                    }
                    if ([dict objectForKeyNotNull:@"creationDate"]) {
                        obj.createdDate =[NSDate sharedDateValueFromString:[dict objectForKeyNotNull:@"creationDate"]];
                    }
                    if ([dict objectForKeyNotNull:@"modifiedDate"]) {
                        obj.modifiedDate =[NSDate sharedDateValueFromString:[dict objectForKeyNotNull:@"modifiedDate"]];
                    }
                    [ERA_constracts addObject:obj];
                    if(_customer) {
                        obj.customer = _customer;
                    }
                }
            }
            
            if([responseDictionary objectForKeyNotNull:@"jobs"]) {
                NSMutableArray *ERA_jobs = [[NSMutableArray alloc] init];
                NSArray *jobs = [responseDictionary objectForKeyNotNull:@"jobs"];
                for (NSDictionary *dict  in jobs) {
                    ERA_JobName *obj = [ERA_JobName createEntity];
                    obj.jobNameID = [NSNumber numberWithInteger:[[dict objectForKeyNotNull:@"jobTitleId"] integerValue]];
                    if ([dict objectForKeyNotNull:@"jobNameNew"]) {
                        
                        obj.name =[dict objectForKeyNotNull:@"jobNameNew"];
                    }
                    if ([dict objectForKeyNotNull:@"contractId"]) {
                        for (ERA_ContractCharter *constract in ERA_constracts) {
                            if (constract.contractCharterID.integerValue == [[dict objectForKeyNotNull:@"contractId"] integerValue]) {
                                obj.contractCharter = constract;
                                break;
                            }
                        }
                    }
                    [ERA_jobs addObject:obj];
                }
            }

            [[CDHelper shareManager] saveContext];
        }
            break;
            
        case WSKey_Customer: {
            if (![responseDictionary objectForKeyNotNull:@"customers"]) {
                break;
            }
            
            NSMutableArray *ERA_Cus = [[NSMutableArray alloc] init];
            NSArray *locations = [responseDictionary objectForKeyNotNull:@"customers"];
            
            for (NSDictionary *dict in locations) {
                ERA_Customer *obj = [ERA_Customer createEntity];
                obj.customerID = [NSNumber numberWithInteger:[[dict objectForKeyNotNull:@"custId"]integerValue]];
                if ([dict objectForKeyNotNull:@"custName"] ) {
                    obj.name =[dict objectForKeyNotNull:@"custName"];
                }
                if ([dict objectForKeyNotNull:@"lstContractCharterVO"]) {
//                    obj =[dict objectForKey:@"lstContractCharterVO"];
                }
                if ([dict objectForKeyNotNull:@"lstJobTitleVO"]) {
//                    obj.employeeNumber =[NSNumber numberWithInteger:[[dict objectForKey:@"lstJobTitleVO"] integerValue]];
                }
                if ([dict objectForKeyNotNull:@"address"]) {
                    obj.address =[dict objectForKeyNotNull:@"address"];
                }
                if ([dict objectForKeyNotNull:@"altName"]) {
                    obj.altName =[dict objectForKeyNotNull:@"altName"];
                }
                if ([dict objectForKeyNotNull:@"arSiteNumber"]) {
                    obj.arSiteNumber =[NSNumber numberWithInteger:[[dict objectForKeyNotNull:@"arSiteNumber"] integerValue]];
                }
                if ([dict objectForKeyNotNull:@"city"]) {
                    obj.city =[dict objectForKeyNotNull:@"city"];
                }
                if ([dict objectForKeyNotNull:@"country"]) {
                    obj.country =[dict objectForKeyNotNull:@"country"];
                }
                if ([dict objectForKeyNotNull:@"processed"]) {
                    obj.processed = [NSNumber numberWithInteger:[[dict objectForKeyNotNull:@"processed"] integerValue]];
                }
                if ([dict objectForKeyNotNull:@"state"]) {
                    obj.state =[dict objectForKeyNotNull:@"state"];
                }
                if ([dict objectForKeyNotNull:@"createdBy"]) {
                    obj.createdByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[dict objectForKeyNotNull:@"createdBy"]];
                }
                if ([dict objectForKeyNotNull:@"modifiedBy"]) {
                    obj.modifiedByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[dict objectForKeyNotNull:@"modifiedBy"]];
                }
                if ([dict objectForKeyNotNull:@"creationDate"]) {
                    obj.createdDate =[NSDate sharedDateValueFromString:[dict objectForKeyNotNull:@"creationDate"]];
                }
                if ([dict objectForKeyNotNull:@"modifiedDate"]) {
                    obj.modifiedDate =[NSDate sharedDateValueFromString:[dict objectForKeyNotNull:@"modifiedDate"]];
                }
                
                [ERA_Cus addObject:obj];
            }
            responseObj = ERA_Cus;
        }
            break;
            
        case WSKey_Employee: {
            if (![responseDictionary objectForKeyNotNull:@"employees"]) {
                break;
            }
            
            NSMutableArray *ERA_Employees = [[NSMutableArray alloc] init];
            NSArray *locations = [responseDictionary objectForKeyNotNull:@"employees"];
            
            for (NSDictionary *dict in locations) {
                ERA_Employee *obj = [ERA_Employee createEntity];
                obj.employeeID = [NSNumber numberWithInteger:[[dict objectForKeyNotNull:@"employeeId"]integerValue]];
                
                if ([dict objectForKeyNotNull:@"firstName"]) {
                    obj.firstName =[dict objectForKeyNotNull:@"firstName"];
                }
                if ([dict objectForKeyNotNull:@"lastName"]) {
                    obj.lastName =[dict objectForKeyNotNull:@"lastName"];
                }
                if ([dict objectForKeyNotNull:@"employeeNumber"]) {
                    obj.employeeNumber =[NSNumber numberWithInteger:[[dict objectForKeyNotNull:@"employeeNumber"] integerValue]];
                }
                if ([dict objectForKeyNotNull:@"email"]) {
                    obj.email =[dict objectForKeyNotNull:@"email"];
                }
                if ([dict objectForKeyNotNull:@"phone"]) {
                    obj.phone =[dict objectForKeyNotNull:@"phone"];
                }
                if ([dict objectForKeyNotNull:@"processed"]) {
                    obj.processed =[NSNumber numberWithInteger:[[dict objectForKeyNotNull:@"processed"] integerValue]];
                }
                if ([dict objectForKeyNotNull:@"jobTitle"]) {
//                    obj.jobTitle =[dict objectForKey:@"jobTitle"];
                }
                if ([dict objectForKeyNotNull:@"creationDate"]) {
                    obj.createdDate =[NSDate sharedDateValueFromString:[dict objectForKeyNotNull:@"creationDate"]];
                }
                if ([dict objectForKeyNotNull:@"modifiedDate"]) {
                    obj.modifiedDate =[NSDate sharedDateValueFromString:[dict objectForKeyNotNull:@"modifiedDate"]];
                }
                
                [ERA_Employees addObject:obj];
            }
            for (int i = 0; i < locations.count; i++) {
                NSDictionary *dict = [locations objectAtIndex:i];
                ERA_Employee *employee = [ERA_Employees objectAtIndex:i];
                if ([dict objectForKeyNotNull:@"createdBy"]) {
                    for (ERA_Employee *obj in ERA_Employees) {
                        if (obj.employeeID.integerValue == [[dict objectForKeyNotNull:@"createdBy"] integerValue]) {
                            employee.createdByEmployee = obj;
                            break;
                        }
                    }
                }
                if ([dict objectForKeyNotNull:@"modifiedBy"]) {
                    for (ERA_Employee *obj in ERA_Employees) {
                        if (obj.employeeID.integerValue == [[dict objectForKeyNotNull:@"modifiedBy"] integerValue]) {
                            employee.createdByEmployee = obj;
                            break;
                        }
                    }
                }
            }
            responseObj = ERA_Employees;
        }
            break;
            
        case WSKey_Location: {
            if (![responseDictionary objectForKeyNotNull:@"locations"]) {
                break;
            }
            
            NSMutableArray *ERA_locations = [[NSMutableArray alloc] init];
            NSArray *locations = [responseDictionary objectForKeyNotNull:@"locations"];
            
            for (NSDictionary *dict in locations) {
                NSString *locationName = [dict objectForKeyNotNull:@"name"];
                if(locationName && [locationName length]>0) {
                    
                    BOOL isExist = NO;
                    for(ERA_Location *location in ERA_locations) {
                        if ([location.name isEqualToString:locationName]) {
                            isExist = YES;
                            break;
                        }
                    }
                    if (!isExist) {
                        ERA_Location *obj = [ERA_Location createEntity];
                        obj.locationID = [NSNumber numberWithInteger:[[dict objectForKeyNotNull:@"locationId"]integerValue]];
                        
                        if ([dict objectForKeyNotNull:@"latitude"]) {
                            obj.latGeo = [NSNumber numberWithDouble:[[dict objectForKeyNotNull:@"latitude"] doubleValue]];
                        }
                        if ([dict objectForKeyNotNull:@"longitude"]) {
                            obj.longGeo = [NSNumber numberWithDouble:[[dict objectForKeyNotNull:@"longitude"]doubleValue]];
                        }
                        if (locationName) {
                            obj.name = locationName;
                        }
                        if ([dict objectForKeyNotNull:@"location_type_id"]) {
                            //                    obj. = [dict objectForKey:@"location_type_id"];
                        }
                        if ([dict objectForKeyNotNull:@"base"]) {
                            obj.isBase = [NSNumber numberWithBool:[[dict objectForKeyNotNull:@"base"] boolValue]];
                        }
                        if ([dict objectForKeyNotNull:@"createdBy"]) {
                            obj.createdByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[dict objectForKeyNotNull:@"createdBy"]];
                        }
                        if ([dict objectForKeyNotNull:@"modifiedBy"]) {
                            obj.modifiedByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[dict objectForKeyNotNull:@"modifiedBy"]];
                        }
                        if ([dict objectForKeyNotNull:@"creationDate"]) {
                            obj.createdDate =[NSDate sharedDateValueFromString:[dict objectForKeyNotNull:@"creationDate"]];
                        }
                        if ([dict objectForKeyNotNull:@"modifiedDate"]) {
                            obj.modifiedDate =[NSDate sharedDateValueFromString:[dict objectForKeyNotNull:@"modifiedDate"]];
                        }
                        
                        
                        [ERA_locations addObject:obj];
                    }
                }
            }
            responseObj = ERA_locations;
        }
            break;
            
        case WSKey_LocationType: {
            if ([[responseDictionary objectForKey:@"locationtypes"] isEqual:[NSNull null]]) {
                break;
            }
        }
            break;
            
        case WSKey_Model: {
            if (![responseDictionary objectForKeyNotNull:@"models"]) {
                break;
            }
            
            NSMutableArray *ERA_models = [[NSMutableArray alloc] init];
            NSArray *models = [responseDictionary objectForKeyNotNull:@"models"];
            for (NSDictionary *dict in models) {
                ERA_Model *obj = [ERA_Model createEntity];
                
                if ([dict objectForKeyNotNull:@"modelId"]) {
                    obj.modelID = [NSNumber numberWithInteger:[[dict objectForKeyNotNull:@"modelId"] integerValue]];
                }
                if ([dict objectForKeyNotNull:@"modelName"]) {
                    obj.name = [dict objectForKeyNotNull:@"modelName"];
                }
                if ([dict objectForKeyNotNull:@"modelSubName"]) {
//                    obj. = [dict objectForKey:@"name"];
                }
                if ([dict objectForKeyNotNull:@"maxGrossWeight"]) {
                    obj.maxGrossWeight = [NSNumber numberWithDouble:[[dict objectForKeyNotNull:@"maxGrossWeight"] doubleValue]];
                }
                if ([dict objectForKeyNotNull:@"maxPassenger"]) {
                    obj.maxPassenger = [NSNumber numberWithInteger:[[dict objectForKeyNotNull:@"maxPassenger"] integerValue]];
                }
                if ([dict objectForKeyNotNull:@"meLoadScheduleCgRangeFrom"]) {
                    obj.meLoadScheduleCGRangeFrom = [NSNumber numberWithDouble:[[dict objectForKeyNotNull:@"meLoadScheduleCgRangeFrom"] doubleValue]];
                }
                if ([dict objectForKeyNotNull:@"meLoadScheduleCgRangeTo"]) {
                    obj.meLoadScheduleCGRangeTo = [NSNumber numberWithDouble:[[dict objectForKeyNotNull:@"meLoadScheduleCgRangeTo"]doubleValue]];
                }
                if ([dict objectForKeyNotNull:@"valueModel"]) {
//                    obj. = [dict objectForKey:@"name"];
                }
                if ([dict objectForKeyNotNull:@"crewCount"]) {
                    obj.crewCount = [NSNumber numberWithInt:[[dict objectForKeyNotNull:@"crewCount"] intValue]];
                }
                if ([dict objectForKeyNotNull:@"acEmptyWeight"]) {
                    obj.emptyWeight = [NSNumber numberWithDouble:[[dict objectForKeyNotNull:@"acEmptyWeight"] doubleValue]];
                }
                if ([dict objectForKeyNotNull:@"createdBy"]) {
                    obj.createdByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[dict objectForKeyNotNull:@"createdBy"]];
                }
                if ([dict objectForKeyNotNull:@"modifiedBy"]) {
                    obj.modifiedByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[dict objectForKeyNotNull:@"modifiedBy"]];
                }
                if ([dict objectForKeyNotNull:@"creationDate"]) {
                    obj.createdDate =[NSDate sharedDateValueFromString:[dict objectForKeyNotNull:@"creationDate"]];
                }
                if ([dict objectForKeyNotNull:@"modifiedDate"]) {
                    obj.modifiedDate =[NSDate sharedDateValueFromString:[dict objectForKeyNotNull:@"modifiedDate"]];
                }

               
                [ERA_models addObject:obj];
            }
            responseObj  = ERA_models;
        }
            break;
            
        case WSKey_SplotPurpose: {
            if (![responseDictionary objectForKeyNotNull:@"slot_purposes"]) {
                break;
            }
            
            NSMutableArray *ERA_Splots = [[NSMutableArray alloc] init];
            NSArray *locations = [responseDictionary objectForKeyNotNull:@"slot_purposes"];
            
            for (NSDictionary *dict in locations) {
                ERA_SlotPurpose *obj = [ERA_SlotPurpose createEntity];
                obj.slotPurposeID = [NSNumber numberWithInteger:[[dict objectForKeyNotNull:@"baseId"]integerValue]];
                
                if ([dict objectForKeyNotNull:@"baseName"]) {
                    obj.name =[dict objectForKeyNotNull:@"baseName"];
                }
                if ([dict objectForKeyNotNull:@"createdBy"]) {
                    obj.createdByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[dict objectForKeyNotNull:@"createdBy"]];
                }
                if ([dict objectForKeyNotNull:@"modifiedBy"]) {
                    obj.modifiedByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[dict objectForKeyNotNull:@"modifiedBy"]];
                }
                if ([dict objectForKeyNotNull:@"creationDate"]) {
                    obj.createdDate =[NSDate sharedDateValueFromString:[dict objectForKeyNotNull:@"creationDate"]];
                }
                if ([dict objectForKeyNotNull:@"modifiedDate"]) {
                    obj.modifiedDate =[NSDate sharedDateValueFromString:[dict objectForKeyNotNull:@"modifiedDate"]];
                }

                [ERA_Splots addObject:obj];
            }
            responseObj = ERA_Splots;
        }
            break;
            
        case WSKey_FuelOwner: {
            if (![responseDictionary objectForKeyNotNull:@"fuel_owners"]) {
                break;
            }
            
            NSMutableArray *ERA_FuelOwners = [[NSMutableArray alloc] init];
            NSArray *locations = [responseDictionary objectForKeyNotNull:@"fuel_owners"];
            
            for (NSDictionary *dict in locations) {
                ERA_FuelOwner *obj = [ERA_FuelOwner createEntity];
                obj.fuelOwnerID = [NSNumber numberWithInteger:[[dict objectForKeyNotNull:@"fuelOwnerId"]integerValue]];
                
                if ([dict objectForKeyNotNull:@"name"]) {
                    obj.name =[dict objectForKeyNotNull:@"name"];
                }
                if ([dict objectForKeyNotNull:@"createdBy"]) {
                    obj.createdByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[dict objectForKeyNotNull:@"createdBy"]];
                }
                if ([dict objectForKeyNotNull:@"modifiedBy"]) {
                    obj.modifiedByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[dict objectForKeyNotNull:@"modifiedBy"]];
                }
                if ([dict objectForKeyNotNull:@"creationDate"]) {
                    obj.createdDate =[NSDate sharedDateValueFromString:[dict objectForKeyNotNull:@"creationDate"]];
                }
                if ([dict objectForKeyNotNull:@"modifiedDate"]) {
                    obj.modifiedDate =[NSDate sharedDateValueFromString:[dict objectForKeyNotNull:@"modifiedDate"]];
                }

                [ERA_FuelOwners addObject:obj];
            }
            responseObj = ERA_FuelOwners;
        }
            break;
            
        default:
            break;
    }
    
    success = YES;
    
    if (_handler) {
        _handler(success,_key,responseObj);
    }
}

@end
