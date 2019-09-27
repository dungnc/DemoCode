//
//  FlightLogObject.m
//  Helicopter
//
//  Created by Judge Man on 12/03/15.
//  Copyright (c) 2015 Era Helicopter. All rights reserved.
//

#import "FlightLogObject.h"
#import "ERA_Location.h"
#import "ERA_Model.h"
#import "ERA_Customer.h"
#import "ERA_Employee.h"
#import "ERA_SlotPurpose.h"
#import "ERA_AC.h"
#import "ERA_FuelOwner.h"
#import "NSDictionary+Additions.h"
#import "NSDate+Helper.h"
#import "Singleton.h"

@implementation FlightLogObject

+ (FlightLogObject*)flightLogFromDict:(NSDictionary*)dict {
    FlightLogObject * flightLog = [[FlightLogObject alloc] init];
    flightLog.logNumber = [[dict objectForKeyNotNull:@"log_number"] integerValue];
    
    NSArray *locationDicts = [dict objectForKeyNotNull:@"locations"];
    NSMutableArray *locationArray = [NSMutableArray new];
    
    if (locationDicts) {
        for (NSDictionary *locationDict in locationDicts) {
            NSString *locationName = [locationDict objectForKeyNotNull:@"name"];
            ERA_Location *location = [ERA_Location findFirstDDLByAttribute:@"name" withValue:locationName];
            if (!location) {
                location = [ERA_Location createEntity];
                location.locationID = [NSNumber numberWithInteger:[[locationDict objectForKeyNotNull:@"locationId"]integerValue]];
            }
            
            if ([locationDict objectForKeyNotNull:@"latitude"]) {
                location.latGeo = [NSNumber numberWithDouble:[[locationDict objectForKeyNotNull:@"latitude"] doubleValue]];
            }
            if ([dict objectForKeyNotNull:@"longitude"]) {
                location.longGeo = [NSNumber numberWithDouble:[[locationDict objectForKeyNotNull:@"longitude"]doubleValue]];
            }
            if (locationName) {
                location.name = locationName;
            }
            if ([locationDict objectForKeyNotNull:@"base"]) {
                location.isBase = [NSNumber numberWithBool:[[locationDict objectForKeyNotNull:@"base"] boolValue]];
            }
            if ([locationDict objectForKeyNotNull:@"createdBy"]) {
                location.createdByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[locationDict objectForKeyNotNull:@"createdBy"]];
            }
            if ([locationDict objectForKeyNotNull:@"modifiedBy"]) {
                location.modifiedByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[locationDict objectForKeyNotNull:@"modifiedBy"]];
            }
            if ([locationDict objectForKeyNotNull:@"creationDate"]) {
                location.createdDate =[NSDate sharedNewDateValueFromString:[locationDict objectForKeyNotNull:@"creationDate"]];
            }
            if ([locationDict objectForKeyNotNull:@"modifiedDate"]) {
                location.modifiedDate =[NSDate sharedNewDateValueFromString:[locationDict objectForKeyNotNull:@"modifiedDate"]];
            }
            
            [locationArray addObject:location];
            
        }
        if (locationArray.count) {
            flightLog.locations = [NSArray arrayWithArray:locationArray];
            NSMutableArray *locationNames = [[[Singleton sharedManager] getLocationNames] mutableCopy];
            NSMutableArray *baseNames = [[[Singleton sharedManager] getBaseNames] mutableCopy];
            BOOL isAddNewLocation;
            BOOL isAddNewBase;
            for (ERA_Location *value in locationArray) {
                if (![locationNames containsObject:value.name]) {
                    [locationNames addObject:value.name];
                    isAddNewLocation = YES;
                }
                
                if (value.isBase.boolValue) {
                    if (![baseNames containsObject:value.name]) {
                        [baseNames addObject:value.name];
                        isAddNewBase = YES;
                    }
                }
            }
            
            if (isAddNewLocation) {
                [[Singleton sharedManager] setLocationNames:[locationNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
            }
            if (isAddNewBase) {
                [[Singleton sharedManager] setBaseNames:[baseNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
            }
            
            
        }
    }
    
    NSArray *modelDicts = [dict objectForKeyNotNull:@"models"];
    NSMutableArray *modelArray = [NSMutableArray new];
    
    if (modelDicts) {
        for (NSDictionary *modelDict in modelDicts) {
            NSInteger modelId = [[modelDict objectForKeyNotNull:@"modelId"] integerValue];
            ERA_Model *model = [ERA_Model findFirstByAttribute:@"modelID" withValue:[NSString stringWithFormat:@"%ld",(long)modelId]];
            
            if (!model) {
                model = [ERA_Model createEntity];
                if ([modelDict objectForKeyNotNull:@"modelId"]) {
                    model.modelID = [NSNumber numberWithInteger:modelId];
                }
            }
            
            if ([modelDict objectForKeyNotNull:@"modelName"]) {
                model.name = [modelDict objectForKeyNotNull:@"modelName"];
            }
            if ([modelDict objectForKeyNotNull:@"maxGrossWeight"]) {
                model.maxGrossWeight = [NSNumber numberWithDouble:[[modelDict objectForKeyNotNull:@"maxGrossWeight"] doubleValue]];
            }
            if ([modelDict objectForKeyNotNull:@"maxPassenger"]) {
                model.maxPassenger = [NSNumber numberWithInteger:[[modelDict objectForKeyNotNull:@"maxPassenger"] integerValue]];
            }
            if ([modelDict objectForKeyNotNull:@"meLoadScheduleCgRangeFrom"]) {
                model.meLoadScheduleCGRangeFrom = [NSNumber numberWithDouble:[[modelDict objectForKeyNotNull:@"meLoadScheduleCgRangeFrom"] doubleValue]];
            }
            if ([modelDict objectForKeyNotNull:@"meLoadScheduleCgRangeTo"]) {
                model.meLoadScheduleCGRangeTo = [NSNumber numberWithDouble:[[modelDict objectForKeyNotNull:@"meLoadScheduleCgRangeTo"]doubleValue]];
            }
            if ([modelDict objectForKeyNotNull:@"crewCount"]) {
                model.crewCount = [NSNumber numberWithInt:[[modelDict objectForKeyNotNull:@"crewCount"] intValue]];
            }
            if ([modelDict objectForKeyNotNull:@"acEmptyWeight"]) {
                model.emptyWeight = [NSNumber numberWithDouble:[[modelDict objectForKeyNotNull:@"acEmptyWeight"] doubleValue]];
            }
            if ([modelDict objectForKeyNotNull:@"createdBy"]) {
                model.createdByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[modelDict objectForKeyNotNull:@"createdBy"]];
            }
            if ([modelDict objectForKeyNotNull:@"modifiedBy"]) {
                model.modifiedByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[modelDict objectForKeyNotNull:@"modifiedBy"]];
            }
            if ([modelDict objectForKeyNotNull:@"creationDate"]) {
                model.createdDate =[NSDate sharedDateValueFromString:[modelDict objectForKeyNotNull:@"creationDate"]];
            }
            if ([modelDict objectForKeyNotNull:@"modifiedDate"]) {
                model.modifiedDate =[NSDate sharedDateValueFromString:[modelDict objectForKeyNotNull:@"modifiedDate"]];
            }
            
            [modelArray addObject:model];
        }
        if (modelArray.count) {
            flightLog.models = [NSArray arrayWithArray:modelArray];
        }
    }
    
    NSArray *customerDicts = [dict objectForKeyNotNull:@"customers"];
    NSMutableArray *customerArray = [NSMutableArray new];
    
    if (customerDicts) {
        for (NSDictionary *customerDict in customerDicts) {
            NSInteger customerId = [[customerDict objectForKeyNotNull:@"custId"] integerValue];
            ERA_Customer *customer = [ERA_Customer findFirstByAttribute:@"customerID" withValue:[NSString stringWithFormat:@"%ld",(long)customerId]];
            if (!customer) {
                customer = [ERA_Customer createEntity];
                customer.customerID = [NSNumber numberWithInteger:customerId];
                
            }
            if ([customerDict objectForKeyNotNull:@"custName"] ) {
                customer.name =[customerDict objectForKeyNotNull:@"custName"];
            }
            if ([customerDict objectForKeyNotNull:@"address"]) {
                customer.address =[customerDict objectForKeyNotNull:@"address"];
            }
            if ([customerDict objectForKeyNotNull:@"altName"]) {
                customer.altName =[customerDict objectForKeyNotNull:@"altName"];
            }
            if ([customerDict objectForKeyNotNull:@"arSiteNumber"]) {
                customer.arSiteNumber =[NSNumber numberWithInteger:[[customerDict objectForKeyNotNull:@"arSiteNumber"] integerValue]];
            }
            if ([customerDict objectForKeyNotNull:@"city"]) {
                customer.city =[customerDict objectForKeyNotNull:@"city"];
            }
            if ([customerDict objectForKeyNotNull:@"country"]) {
                customer.country =[customerDict objectForKeyNotNull:@"country"];
            }
            if ([customerDict objectForKeyNotNull:@"processed"]) {
                customer.processed = [NSNumber numberWithInteger:[[customerDict objectForKeyNotNull:@"processed"] integerValue]];
            }
            if ([customerDict objectForKeyNotNull:@"state"]) {
                customer.state =[customerDict objectForKeyNotNull:@"state"];
            }
            if ([customerDict objectForKeyNotNull:@"createdBy"]) {
                customer.createdByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[customerDict objectForKeyNotNull:@"createdBy"]];
            }
            if ([customerDict objectForKeyNotNull:@"modifiedBy"]) {
                customer.modifiedByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[customerDict objectForKeyNotNull:@"modifiedBy"]];
            }
            if ([customerDict objectForKeyNotNull:@"creationDate"]) {
                customer.createdDate =[NSDate sharedDateValueFromString:[customerDict objectForKeyNotNull:@"creationDate"]];
            }
            if ([customerDict objectForKeyNotNull:@"modifiedDate"]) {
                customer.modifiedDate =[NSDate sharedDateValueFromString:[customerDict objectForKeyNotNull:@"modifiedDate"]];
            }
            
            [customerArray addObject:customer];
            
            
        }
        if (customerArray.count) {
            flightLog.customers = [NSArray arrayWithArray:customerArray];
        }
    }
    
    NSArray *employeeDicts = [dict objectForKeyNotNull:@"employees"];
    NSMutableArray *employeeArray = [NSMutableArray new];
    
    if (employeeDicts) {
        for (NSDictionary *employeeDict in employeeDicts) {
            NSInteger employeeId = [[employeeDict objectForKeyNotNull:@"employeeId"] integerValue];
            ERA_Employee *employee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[NSString stringWithFormat:@"%ld",(long)employeeId]];
            if (!employee) {
                employee = [ERA_Employee createEntity];
                employee.employeeID = [NSNumber numberWithInteger:employeeId];
            }
            if ([employeeDict objectForKeyNotNull:@"firstName"]) {
                employee.firstName =[employeeDict objectForKeyNotNull:@"firstName"];
            }
            if ([employeeDict objectForKeyNotNull:@"lastName"]) {
                employee.lastName =[employeeDict objectForKeyNotNull:@"lastName"];
            }
            if ([employeeDict objectForKeyNotNull:@"employeeNumber"]) {
                employee.employeeNumber =[NSNumber numberWithInteger:[[employeeDict objectForKeyNotNull:@"employeeNumber"] integerValue]];
            }
            if ([employeeDict objectForKeyNotNull:@"email"]) {
                employee.email =[employeeDict objectForKeyNotNull:@"email"];
            }
            if ([employeeDict objectForKeyNotNull:@"phone"]) {
                employee.phone =[employeeDict objectForKeyNotNull:@"phone"];
            }
            if ([employeeDict objectForKeyNotNull:@"processed"]) {
                employee.processed =[NSNumber numberWithInteger:[[employeeDict objectForKeyNotNull:@"processed"] integerValue]];
            }
            if ([employeeDict objectForKeyNotNull:@"creationDate"]) {
                employee.createdDate =[NSDate sharedDateValueFromString:[employeeDict objectForKeyNotNull:@"creationDate"]];
            }
            if ([employeeDict objectForKeyNotNull:@"modifiedDate"]) {
                employee.modifiedDate =[NSDate sharedDateValueFromString:[employeeDict objectForKeyNotNull:@"modifiedDate"]];
            }
            
            [employeeArray addObject:employee];
            
        }
        if (employeeArray.count) {
            flightLog.employees = [NSArray arrayWithArray:employeeArray];
        }
    }
    
    NSArray *slotPurposeDicts = [dict objectForKeyNotNull:@"slot_purposes"];
    NSMutableArray *slotPurposeArray = [NSMutableArray new];
    
    if (slotPurposeDicts) {
        for (NSDictionary *slotPurposeDict in slotPurposeDicts) {
            NSInteger slotPurposeId = [[slotPurposeDict objectForKeyNotNull:@"baseId"] integerValue];
            ERA_SlotPurpose *slotPurpose = [ERA_SlotPurpose findFirstByAttribute:@"slotPurposeID" withValue:[NSString stringWithFormat:@"%ld",(long)slotPurposeId]];
            if (!slotPurpose) {
                slotPurpose = [ERA_SlotPurpose createEntity];
                slotPurpose.slotPurposeID = [NSNumber numberWithInteger:slotPurposeId];
            }
            if ([slotPurposeDict objectForKeyNotNull:@"baseName"]) {
                slotPurpose.name =[slotPurposeDict objectForKeyNotNull:@"baseName"];
            }
            if ([slotPurposeDict objectForKeyNotNull:@"createdBy"]) {
                slotPurpose.createdByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[slotPurposeDict objectForKeyNotNull:@"createdBy"]];
            }
            if ([slotPurposeDict objectForKeyNotNull:@"modifiedBy"]) {
                slotPurpose.modifiedByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[slotPurposeDict objectForKeyNotNull:@"modifiedBy"]];
            }
            if ([slotPurposeDict objectForKeyNotNull:@"creationDate"]) {
                slotPurpose.createdDate =[NSDate sharedDateValueFromString:[dict objectForKeyNotNull:@"creationDate"]];
            }
            if ([slotPurposeDict objectForKeyNotNull:@"modifiedDate"]) {
                slotPurpose.modifiedDate =[NSDate sharedDateValueFromString:[dict objectForKeyNotNull:@"modifiedDate"]];
            }
            
            [slotPurposeArray addObject:slotPurpose];
            
        }
        if (slotPurposeArray.count) {
            flightLog.slotPurposes = [NSArray arrayWithArray:slotPurposeArray];
        }
    }
    
    NSArray *acDicts = [dict objectForKeyNotNull:@"acs"];
    NSMutableArray *acArray = [NSMutableArray new];
    
    if (acDicts) {
        for (NSDictionary *acDict in acDicts) {
            NSInteger aCId = [[acDict objectForKeyNotNull:@"acId"] integerValue];
            ERA_AC *ac = [ERA_SlotPurpose findFirstByAttribute:@"aCID" withValue:[NSString stringWithFormat:@"%ld",(long)aCId]];
            if (!ac) {
                if([dict objectForKeyNotNull:@"status"] && [[[dict objectForKeyNotNull:@"status"] lowercaseString] isEqualToString:@"a"]) {
                    ac = [ERA_AC createEntity];
                    ac.aCID = [NSNumber numberWithInteger:aCId];
                }
            }
            if (ac) {
                if ([acDict objectForKeyNotNull:@"acName"]) {
                    ac.name =[dict objectForKey:@"acName"];
                }
                if ([acDict objectForKeyNotNull:@"createdBy"]) {
                    ac.createdByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[acDict objectForKeyNotNull:@"createdBy"]];
                }
                if ([acDict objectForKeyNotNull:@"modifiedBy"]) {
                    ac.modifiedByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[acDict objectForKeyNotNull:@"modifiedBy"]];
                }
                if ([acDict objectForKeyNotNull:@"creationDate"]) {
                    ac.createdDate =[NSDate sharedDateValueFromString:[acDict objectForKeyNotNull:@"creationDate"]];
                }
                if ([acDict objectForKeyNotNull:@"modifiedDate"]) {
                    ac.modifiedDate =[NSDate sharedDateValueFromString:[acDict objectForKeyNotNull:@"modifiedDate"]];
                }
                [acArray addObject:ac];
            }
        }
        if (acArray.count) {
            flightLog.acs = [NSArray arrayWithArray:acArray];
        }
    }
    
    NSArray *fuelOwnersDicts = [dict objectForKeyNotNull:@"acs"];
    NSMutableArray *fuelOwnerArray = [NSMutableArray new];
    
    if (fuelOwnersDicts) {
        for (NSDictionary *fuelOwnersDict in fuelOwnersDicts) {
            NSInteger fuelOwnerId = [[fuelOwnersDict objectForKeyNotNull:@"fuelOwnerId"] integerValue];
            ERA_FuelOwner *fuelOwner = [ERA_FuelOwner findFirstByAttribute:@"fuelOwnerID" withValue:[NSString stringWithFormat:@"%ld",(long)fuelOwnerId]];
            if (!fuelOwner) {
                fuelOwner = [ERA_FuelOwner createEntity];
                fuelOwner.fuelOwnerID = [NSNumber numberWithInteger:fuelOwnerId];
            }
            if ([fuelOwnersDict objectForKeyNotNull:@"name"]) {
                fuelOwner.name =[fuelOwnersDict objectForKeyNotNull:@"name"];
            }
            if ([fuelOwnersDict objectForKeyNotNull:@"createdBy"]) {
                fuelOwner.createdByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[fuelOwnersDict objectForKeyNotNull:@"createdBy"]];
            }
            if ([fuelOwnersDict objectForKeyNotNull:@"modifiedBy"]) {
                fuelOwner.modifiedByEmployee = [ERA_Employee findFirstByAttribute:@"employeeID" withValue:[fuelOwnersDict objectForKeyNotNull:@"modifiedBy"]];
            }
            if ([fuelOwnersDict objectForKeyNotNull:@"creationDate"]) {
                fuelOwner.createdDate =[NSDate sharedDateValueFromString:[fuelOwnersDict objectForKeyNotNull:@"creationDate"]];
            }
            if ([fuelOwnersDict objectForKeyNotNull:@"modifiedDate"]) {
                fuelOwner.modifiedDate =[NSDate sharedDateValueFromString:[fuelOwnersDict objectForKeyNotNull:@"modifiedDate"]];
            }
            
            [fuelOwnerArray addObject:fuelOwner];
            
        }
        if (fuelOwnerArray.count) {
            flightLog.fuelOwners = [NSArray arrayWithArray:fuelOwnerArray];
        }
    }
    

    [[CDHelper shareManager] saveContext];
    return flightLog;
}

@end
