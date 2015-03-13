//
//  CheatyJSON.swift
//  CheatyJSON
//
//  Created by Alexandre Ronse on 13/03/2015.
//  Copyright (c) 2015 Alexandre Ronse. All rights reserved.
//


/// Using JSONDecoder from JSONJoy, all credits goes to https://github.com/daltoniam/JSONJoy-Swift
@objc public class JSONDecoder {
    var value: AnyObject?
    
    ///print the description of the JSONDecoder
    public var description: String {
        return self.print()
    }
    ///convert the value to a String
    public var string: String? {
        return value as? String
    }
    ///convert the value to an Int
    public var integer: Int? {
        return value as? Int
    }
    ///convert the value to an UInt
    public var unsigned: UInt? {
        return value as? UInt
    }
    ///convert the value to a Double
    public var double: Double? {
        return value as? Double
    }
    ///convert the value to a float
    public var float: Float? {
        return value as? Float
    }
    ///treat the value as a bool
    public var boolean: Bool {
        if let str = self.string {
            let lower = str.lowercaseString
            if lower == "true" || lower.toInt() > 0 {
                return true
            }
        } else if let num = self.integer {
            return num > 0
        } else if let num = self.double {
            return num > 0.99
        } else if let num = self.float {
            return num > 0.99
        }
        return false
    }
    //get  the value if it is an error
    public var error: NSError? {
        return value as? NSError
    }
    //get  the value if it is a dictionary
    public var dictionary: Dictionary<String,JSONDecoder>? {
        return value as? Dictionary<String,JSONDecoder>
    }
    //get  the value if it is an array
    public var array: Array<JSONDecoder>? {
        return value as? Array<JSONDecoder>
    }
    //pull the raw values out of an array
    public func getArray<T>(inout collect: Array<T>?) {
        if let array = value as? Array<JSONDecoder> {
            if collect == nil {
                collect = Array<T>()
            }
            for decoder in array {
                if let obj = decoder.value as? T {
                    collect?.append(obj)
                }
            }
        }
    }
    ///pull the raw values out of a dictionary.
    public func getDictionary<T>(inout collect: Dictionary<String,T>?) {
        if let dictionary = value as? Dictionary<String,JSONDecoder> {
            if collect == nil {
                collect = Dictionary<String,T>()
            }
            for (key,decoder) in dictionary {
                if let obj = decoder.value as? T {
                    collect?[key] = obj
                }
            }
        }
    }
    ///the init that converts everything to something nice
    public init(_ raw: AnyObject) {
        var rawObject: AnyObject = raw
        if let data = rawObject as? NSData {
            var error: NSError?
            var response: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: &error)
            if error != nil || response == nil {
                value = error
                return
            }
            rawObject = response!
        }
        if let array = rawObject as? NSArray {
            var collect = [JSONDecoder]()
            for val: AnyObject in array {
                collect.append(JSONDecoder(val))
            }
            value = collect
        } else if let dict = rawObject as? NSDictionary {
            var collect = Dictionary<String,JSONDecoder>()
            for (key,val: AnyObject) in dict {
                collect[key as String] = JSONDecoder(val)
            }
            value = collect
        } else {
            value = rawObject
        }
    }
    ///Array access support
    public subscript(index: Int) -> JSONDecoder {
        get {
            if let array = self.value as? NSArray {
                if array.count > index {
                    return array[index] as JSONDecoder
                }
            }
            return JSONDecoder(createError("index: \(index) is greater than array or this is not an Array type."))
        }
    }
    ///Dictionary access support
    public subscript(key: String) -> JSONDecoder {
        get {
            if let dict = self.value as? NSDictionary {
                if let value: AnyObject = dict[key] {
                    return value as JSONDecoder
                }
            }
            return JSONDecoder(createError("key: \(key) does not exist or this is not a Dictionary type"))
        }
    }
    ///private method to create an error
    func createError(text: String) -> NSError {
        return NSError(domain: "JSONJoy", code: 1002, userInfo: [NSLocalizedDescriptionKey: text]);
    }
    
    ///print the decoder in a JSON format. Helpful for debugging.
    public func print() -> String {
        if let arr = self.array {
            var str = "["
            for decoder in arr {
                str += decoder.print() + ","
            }
            str.removeAtIndex(advance(str.endIndex, -1))
            return str + "]"
        } else if let dict = self.dictionary {
            var str = "{"
            for (key, decoder) in dict {
                str += "\"\(key)\": \(decoder.print()),"
            }
            str.removeAtIndex(advance(str.endIndex, -1))
            return str + "}"
        }
        if value != nil {
            if let str = self.string {
                return "\"\(value!)\""
            }
            return "\(value!)"
        }
        return ""
    }
}

@objc protocol JSONJoy {
    optional class func fromJSON(decoder: JSONDecoder) -> JSONSerializable
}


public class JSONSerializable : NSObject, JSONJoy {
    
    public override init() {
        super.init()
    }
    
    private var registeredVars:[(String,String)] = []
    
    
    public func registerVariable(variableName:String, JSONName:String) {
        self.registeredVars.append((variableName, JSONName))
    }
    
    public func registerVariables(variables:[(String,String)]) {
        for variable in variables {
            self.registeredVars.append(variable)
        }
    }
    
    public func toDictionary() -> NSDictionary {
        var aClass : AnyClass? = self.dynamicType
        var propertiesCount : CUnsignedInt = 0
        let propertiesInAClass : UnsafeMutablePointer<objc_property_t> = class_copyPropertyList(aClass, &propertiesCount)
        var propertiesDictionary : NSMutableDictionary = NSMutableDictionary()
        for var i = 0; i < Int(propertiesCount); i++ {
            var property = propertiesInAClass[i]
            var propName = NSString(CString: property_getName(property), encoding: NSUTF8StringEncoding)!
            var propType = property_getAttributes(property)
            var propValue:AnyObject! = self.valueForKey(propName);
            
            for variable in self.registeredVars {
                if variable.0 == propName {
                    propName = variable.1
                    break
                }
            }
            
            if propValue is JSONSerializable {
                propertiesDictionary.setValue((propValue as JSONSerializable).toDictionary(), forKey: propName)
            } else if propValue is Array<JSONSerializable> {
                var subArray = Array<NSDictionary>()
                for item in (propValue as Array<JSONSerializable>) {
                    subArray.append(item.toDictionary())
                }
                propertiesDictionary.setValue(subArray, forKey: propName)
            } else {
                propertiesDictionary.setValue(propValue, forKey: propName)
            }
        }
        propertiesInAClass.dealloc(Int(propertiesCount))
        return propertiesDictionary
    }
    
    public func JSONData() -> NSData! {
        var dictionary = self.toDictionary()
        var err: NSError?
        return NSJSONSerialization.dataWithJSONObject(dictionary, options:NSJSONWritingOptions(0), error: &err)
    }
    
    public func JSONString() -> NSString! {
        return NSString(data: self.JSONData(), encoding: NSUTF8StringEncoding)
    }
}









