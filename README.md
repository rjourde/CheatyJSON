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

The `JSONData()` and `toDictionary()` functions basically do the same, but returns object data as NSData or Dictionary

**What should I do if I want to change the JSON output ?**
For example, if you'd like to change how a field of your class is displayed, you can use the `registerVariable` or `registerVariables` functions.

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
        "postal_code": 93309
     }

}
```

We want to translate that JSON to these Swift objects:

```swift
class Address:JSONSerializable {
    var objID: Int?
    var streetAddress: String?
    var city: String?
    var state: String?
    var postalCode: String?

}

class User:JSONSerializable {
    var objID: Int?
    var firstName: String?
    var lastName: String?
    var age: Int?
    var address = Address()

}
```

To do so, simply implement the `decode(decoder:JSONDecoder)` function

```swift
class Address:JSONSerializable {
    
    ...
    
    func decode(decoder:JSONDecoder) -> Address {
        self.objID = decoder["id"].integer
        self.streetAddress = decoder["street_address"].string
        self.city = decoder["city"].string
        self.state = decoder["state"].string
        self.postalCode = decoder["postal_code"].string
        return self
    }

}

class User:JSONSerializable {
   
   ...
   
   func decode(decoder:JSONDecoder) -> User {
        self.objID = decoder["id"].integer
        self.firstName = decoder["first_name"].string
        self.lastName = decoder["last_name"].string
        self.age = decoder["age"].integer
        self.address = self.address.decode(decoder["address"])
        return self
   }

}
```

Now that the decode function has been implemented

```swift

var data:NSData?
// here you get your data

var person = User().decode(JSONDecoder(data!))
// Now your object is fully created and filled
// We now want to change some value
person.firstName = "new name"
// We want to see our object JSON
println(person.JSONString())
```

This will produce the following output:

```json
{
  "objID": 1,
  "firstName": "new name",
  "lastName": "Smith",
  "address": {
    "objID": 1,
    "state": "CA",
    "city": "Bakersfield",
    "streetAddress": "2nd Street"
  }
}
```

