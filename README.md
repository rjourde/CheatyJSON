CheatyJSON
===================


CheatyJSON is a Swift framework designed to handle JSON easily

----------


Installation
-------------

To install this, simply add the **.xcodeproj** to your project, and whenever you want to use it in your code, simply type :

> ```swift
> import CheatyJSON

Usage
-------------

This framework provides a class named **JSONSerializable** you can inherit from.

When inherited, this class gives you some useful functions, such as

`JSONString()`
`JSONData()`
`toDictionary()`

> **JSONString()** simply transforms your object to a JSON String
> Example :
> ```swift
> class Person:JSONSerializable {
>   var name:String = "foo"
>   var age:Int = 42
>   var isAwesome:Bool = true
> }
> var me = Person()
> me.JSONString()

Will return a String containing
> ```json
> {"name":"foo","age":42,"isAwesome":true}

The `JSONData()` and `toDictionary()` functions basically do the same, but return object data as NSData or Dictionary

**What should I do if I want to change the JSON output ?**
For example, if you'd like to change the way a field of your class is displayed, you can use the `registerVariable` or `registerVariables` functions.

Let's take a look back at our `Person` class

> ```swift
> class Person:JSONSerializable {
>   var firstName:String
>   var age:Int
>   var isAwesome:Bool
>   
>   init(name:String, age:Int, isAwesome:Bool) {
>     self.firstName = name
>     self.age = age
>     self.isAwesome = isAwesome
>   }
> }
> var person = Person(name:"foobar", age:42, isAwesome:false)
> println(person.JSONString())

This will produce the following output:
> ```json
> {"firstName":"foobar","age":42,"isAwesome":false}

Now, let's use the `registerVariable` function.

> ```swift
> person.registerVariable("firstName", JSONName: "myNewAwesomeJSONOutputName")
> println(person.JSONString())

This will now produce the following output:
> ```json
> {"age":42,"myNewAwesomeJSONOutputName":"foobar","isAwesome":false}

Obviously, you can put your `registerVariable` calls directly in `init` if you want all of your objects to behave the same.

Parsing JSON
----------

Thanks to [Daltoniam's awesome library](https://github.com/daltoniam/JSONJoy-Swift) , parsing JSON is as simple as generating it !

## Example

First here is some example JSON we have to parse.

```javascript
{
    "id" : 1,
    "first_name": "John",
    "last_name": "Smith",
    "age": 25,
    "address": {
        "id": 1
        "street_address": "2nd Street",
        "city": "Bakersfield",
        "state": "CA",
        "postal_code": "93309"
     }

}
```

We want to translate that JSON to these Swift objects:

(Consider not to use optional variables as they might not be rendered correctly)

```swift
class Address:JSONSerializable {
    var objID: Int = 0
    var streetAddress: String = ""
    var city: String = ""
    var state: String = ""
    var postalCode: String = ""

}

class User:JSONSerializable {
    var objID: Int = 0
    var firstName: String = ""
    var lastName: String = ""
    var age: Int = 0
    var address = Address()

}
```

To do so, simply implement the `class func fromJSON(decoder:JSONDecoder)` function.

```swift
class Address:JSONSerializable {
    
    ...
    
    class func fromJSON(decoder:JSONDecoder) -> Address {
        var object = Address()
        object.objID = decoder["id"].integer!
        object.streetAddress = decoder["street_address"].string!
        object.city = decoder["city"].string!
        object.state = decoder["state"].string!
        object.postalCode = decoder["postal_code"].string!
        return object
    }

}

class User:JSONSerializable {
   
   ...
   
   class func fromJSON(decoder:JSONDecoder) -> User {
        var object = User()
        object.objID = decoder["id"].integer!
        object.firstName = decoder["first_name"].string!
        object.lastName = decoder["last_name"].string!
        object.age = decoder["age"].integer!
        object.address = Address.fromJSON(decoder["address"])
        return object
    }

}
```

Now that the decode function has been implemented:

```swift

var data:NSData?
// here you get your data

var person = User.fromJSON(JSONDecoder(data!))
// Now your object is fully created and filled
// We now want to change some value
person.firstName = "new name"
// We want to see our object as JSON
println(person.JSONString())
```

This will produce the following output:

```json
{
  "objID": 1,
  "firstName": "new name",
  "lastName": "Smith",
  "age": 25,
  "address": {
    "objID": 1,
    "state": "CA",
    "city": "Bakersfield",
    "streetAddress": "2nd Street",
    "postalCode": "93309"
  }
}
```

---

Now we'd like to parse a JSON Array of users

##Example

```json
[
  {
    "objID": 1,
    "firstName": "John",
    "lastName": "Smith",
    "age": 25,
    "address": {
      "objID": 1,
      "state": "CA",
      "city": "Bakersfield",
      "streetAddress": "2nd Street",
      "postalCode": "93309"
    }
  },
  {
    "objID": 2,
    "firstName": "Tom",
    "lastName": "Smith",
    "age": 22,
    "address": {
      "objID": 2,
      "state": "CA",
      "city": "Bakersfield",
      "streetAddress": "2nd Street",
      "postalCode": "93309"
    }
  }
]
```

---




