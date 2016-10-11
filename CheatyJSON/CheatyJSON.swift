//
//  CheatyJSON.swift
//  CheatyJSON
//
//  Created by Alexandre Ronse on 13/03/2015.
//  Copyright (c) 2015 Alexandre Ronse. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


/// Using JSONDecoder from JSONJoy, all credits goes to https://github.com/daltoniam/JSONJoy-Swift
open class JSONDecoder {
    var value: Any?
    
    ///print the description of the JSONDecoder
    open var description: String {
        return self.print()
    }
    ///convert the value to a String
    open var string: String? {
        return value as? String
    }
    ///convert the value to an Int
    open var integer: Int? {
        return value as? Int
    }
    ///convert the value to an UInt
    open var unsigned: UInt? {
        return value as? UInt
    }
    ///convert the value to a Double
    open var double: Double? {
        return value as? Double
    }
    ///convert the value to a float
    open var float: Float? {
        return value as? Float
    }
    ///treat the value as a bool
    open var boolean: Bool {
        if let str = self.string {
            let lower = str.lowercased()
            if lower == "true" || Int(lower) > 0 {
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
    open var error: NSError? {
        return value as? NSError
    }
    //get  the value if it is a dictionary
    open var dictionary: Dictionary<String,JSONDecoder>? {
        return value as? Dictionary<String,JSONDecoder>
    }
    //get  the value if it is an array
    open var array: Array<JSONDecoder>? {
        return value as? Array<JSONDecoder>
    }
    //pull the raw values out of an array
    open func getArray<T>(_ collect: inout Array<T>?) {
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
    open func getDictionary<T>(_ collect: inout Dictionary<String,T>?) {
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
    public init(_ raw: Any) {
        var rawObject: Any = raw
        if let data = rawObject as? Data {
            do {
                let response = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                
                rawObject = response as Any
            } catch {
                value = error as Any
                return
            }
        }
        if let array = rawObject as? NSArray {
            var collect = [JSONDecoder]()
            for val in array {
                collect.append(JSONDecoder(val))
            }
            value = collect as AnyObject?
        } else if let dict = rawObject as? NSDictionary {
            var collect = Dictionary<String,JSONDecoder>()
            for (key,val) in dict {
                collect[key as! String] = JSONDecoder(val as AnyObject)
            }
            value = collect as AnyObject?
        } else {
            value = rawObject
        }
    }
    ///Array access support
    open subscript(index: Int) -> JSONDecoder {
        get {
            if let array = self.value as? NSArray {
                if array.count > index {
                    return array[index] as! JSONDecoder
                }
            }
            return JSONDecoder(createError("index: \(index) is greater than array or this is not an Array type."))
        }
    }
    ///Dictionary access support
    open subscript(key: String) -> JSONDecoder {
        get {
            if let dict = self.value as? NSDictionary {
                if let value = dict[key] {
                    return value as! JSONDecoder
                }
            }
            return JSONDecoder(createError("key: \(key) does not exist or this is not a Dictionary type"))
        }
    }
    ///private method to create an error
    func createError(_ text: String) -> NSError {
        return NSError(domain: "JSONJoy", code: 1002, userInfo: [NSLocalizedDescriptionKey: text]);
    }
    
    ///print the decoder in a JSON format. Helpful for debugging.
    open func print() -> String {
        if let arr = self.array {
            var str = "["
            for decoder in arr {
                str += decoder.print() + ","
            }
            str.remove(at: str.characters.index(str.endIndex, offsetBy: -1))
            return str + "]"
        } else if let dict = self.dictionary {
            var str = "{"
            for (key, decoder) in dict {
                str += "\"\(key)\": \(decoder.print()),"
            }
            str.remove(at: str.characters.index(str.endIndex, offsetBy: -1))
            return str + "}"
        }
        if value != nil {
            if self.string != nil {
                return "\"\(value!)\""
            }
            return "\(value!)"
        }
        return ""
    }
}

@objc open class JSONSerializable : NSObject {
    
    override init() {
        super.init()
    }
    
    open func registerVariables() {
        
    }
    
    public init(decoder:JSONDecoder) {
        super.init()
        _ = self.fromJSONDecoder(decoder)
    }
    
    public init(JSONString:String) {
        super.init()
        _ = self.fromJSONString(JSONString)
    }
    
    public init(JSONData:Data?) {
        super.init()
        if JSONData != nil {
            _ = self.fromJSONData(JSONData!)
        }
    }
    
    fileprivate var registeredVars:[(String,String)] = []
    
    
    public final func registerVariable(_ variableName:String, JSONName:String) {
        self.registeredVars.append((variableName, JSONName))
    }
    
    public final func registerVariables(_ variables:[(String,String)]) {
        for variable in variables {
            self.registeredVars.append(variable)
        }
    }
    
    open func JSONCompletion(_ decoder:JSONDecoder) {
        
    }
    
    public final func fromJSONData(_ data:Data!) -> JSONSerializable {
        return self.fromJSONDecoder(JSONDecoder(data as AnyObject))
    }
    
    public final func fromJSONString(_ string:String) -> JSONSerializable {
        return self.fromJSONData(string.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
    }
    
    public final func fromJSONDecoder(_ decoder:JSONDecoder) -> JSONSerializable {
        self.registeredVars.removeAll(keepingCapacity: false)
        self.registerVariables()
        let aClass : AnyClass? = type(of: self)
        var propertiesCount : CUnsignedInt = 0
        let propertiesInAClass : UnsafeMutablePointer<objc_property_t?> = class_copyPropertyList(aClass, &propertiesCount)
        
        for i in 0 ..< Int(propertiesCount) {
            let property = propertiesInAClass[i]
            let propName = NSString(cString: property_getName(property), encoding: String.Encoding.utf8.rawValue)!
            
            var jsonName = propName
            for elem in self.registeredVars {
                if elem.0 == propName as String {
                    jsonName = elem.1 as NSString
                    break
                }
            }
            
            let value: Any? = decoder[jsonName as String].value
            
            if value is NSError {continue}
            if value is Array<Any> {
                self.setValue([], forKey: propName as String)
                let objectArray = self.mutableSetValue(forKey: propName as String)
                
                if let array = decoder[propName as String].array {
                    for elem in array {
                        if elem.value != nil {objectArray.add(elem.value!)}
                    }
                }
            } else {
                self.setValue(value, forKey: propName as String)
            }
        }
        propertiesInAClass.deallocate(capacity: Int(propertiesCount))
        self.JSONCompletion(decoder)
        return self
    }
    
    open func toDictionary() -> NSDictionary {
        self.registeredVars.removeAll(keepingCapacity: false)
        self.registerVariables()
        let aClass : AnyClass? = type(of: self)
        var propertiesCount : CUnsignedInt = 0
        let propertiesInAClass : UnsafeMutablePointer<objc_property_t?> = class_copyPropertyList(aClass, &propertiesCount)
        let propertiesDictionary : NSMutableDictionary = NSMutableDictionary()
        for i in 0 ..< Int(propertiesCount) {
            let property = propertiesInAClass[i]
            var propName = NSString(cString: property_getName(property), encoding: String.Encoding.utf8.rawValue)!
            let propValue:AnyObject! = self.value(forKey: propName as String) as AnyObject!
            
            for variable in self.registeredVars {
                if variable.0 == propName as String {
                    propName = variable.1 as NSString
                    break
                }
            }
            
            if propValue is JSONSerializable {
                propertiesDictionary.setValue((propValue as! JSONSerializable).toDictionary(), forKey: propName as String)
            } else if propValue is Array<JSONSerializable> {
                var subArray = Array<NSDictionary>()
                for item in (propValue as! Array<JSONSerializable>) {
                    subArray.append(item.toDictionary())
                }
                propertiesDictionary.setValue(subArray, forKey: propName as String)
            } else {
                propertiesDictionary.setValue(propValue, forKey: propName as String)
            }
        }
        propertiesInAClass.deallocate(capacity: Int(propertiesCount))
        return propertiesDictionary
    }
    
    open func JSONData() -> Data! {
        let dictionary = self.toDictionary()
        return try! JSONSerialization.data(withJSONObject: dictionary, options:JSONSerialization.WritingOptions(rawValue: 0))
    }
    
    open func JSONString() -> NSString! {
        return NSString(data: self.JSONData(), encoding: String.Encoding.utf8.rawValue)
    }
}
