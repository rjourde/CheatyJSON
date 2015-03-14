CheatyJSON
===================


CheatyJSON is a Swift framework designed to handle JSON easily

----------


Installation
-------------

To install this, simply add the **.xcodeproj** to your project, and do not forget to link the **.framework** 

Whenever you want to use it in your code, simply type :

> ```swift
> import CheatyJSON

Usage
-------------

This framework provides a class named **JSONSerializable** you can inherit from.

When you create your classes, please consider using objc types such as NSNumber (for Bool as well), NSString because Swift optionals bridged types may not be rendered correctly.

When inherited, this class gives you some useful functions, such as

`JSONString()`
`JSONData()`
`toDictionary()`

> **JSONString()** simply transforms your object to a JSON String
> Example :
> ```swift
> ```swift
class Person:JSONSerializable {
    var firstName:NSString?
    var age:NSNumber?
    var isAwesome:NSNumber?
    init(name:NSString, age:NSNumber, isAwesome:NSNumber) {
        super.init()
        self.firstName = name
        self.age = age
        self.isAwesome = isAwesome
    }
}
>
> var me = Person(name:"foobar", age:42, isAwesome:true)
> me.JSONString()

Will return a String containing
> ```json
> {"name":"foo","age":42,"isAwesome":true}

The `JSONData()` and `toDictionary()` functions basically do the same, but return object data as NSData or Dictionary

**What should I do if I want to change the JSON output ?**

For example, if you'd like to change the way a field of your class is displayed, you can implement the `registerVariables` function.

Let's take a look back at our `Person` class

> ```swift
class Person:JSONSerializable {
    var firstName:NSString?
    var age:NSNumber?
    var isAwesome:NSNumber?
    init(name:NSString, age:NSNumber, isAwesome:NSNumber) {
        super.init()
        self.firstName = name
        self.age = age
        self.isAwesome = isAwesome
    }
}
>
> var person = Person(name:"foobar", age:42, isAwesome:true)
> println(person.JSONString())

This will produce the following output:
> ```json
> {"firstName":"foobar","age":42,"isAwesome":true}

Now, let's use the `registerVariable` function.

> ```swift
override func registerVariables() {
        self.registerVariable("firstName", JSONName: "my_name")
    }
> println(person.JSONString())

This will now produce the following output:
> ```json
> {"my_name":"foobar","age":42,"isAwesome":true}


Parsing JSON
----------

Thanks to [Daltoniam's JSONDecoder](https://github.com/daltoniam/JSONJoy-Swift) , parsing JSON is as simple as generating it !

## Example

First here is some example JSON we have to parse.

```json
> {
>   "first_name": "Hank",
>   "last_name": "Schrader",
>   "age": 42,
>   "address": {
>     "street_name": "Hank's street",
>     "postal_code": "",
>     "city": "Albuquerque"
>   },
>   "friends": [
>     {
>       "first_name": "Walter",
>       "last_name": "White",
>       "age": 52,
>       "address": {
>         "street_name": "Walter's street",
>         "postal_code": "",
>         "city": "Albuquerque"
>       },
>       "friends": []
>     },
>     {
>       "first_name": "Jesse",
>       "last_name": "Pinkman",
>       "age": 26,
>       "address": {
>         "street_name": "Jesse's street",
>         "postal_code": "",
>         "city": "Albuquerque"
>       },
>       "friends": [
>         {
>           "first_name": "Jane",
>           "last_name": "Margolis",
>           "age": 27,
>           "address": {
>             "street_name": "Jane's street",
>             "postal_code": "",
>             "city": "Albuquerque"
>           },
>           "friends": []
>         }
>       ]
>     }
>   ]
> }
```

We want to translate that JSON to these Swift objects:


```swift
class Address:JSONSerializable {
    var objID: NSNumber?
    var streetAddress: NSString?
    var city: NSString?
    var state: NSString?
    var postalCode: NSString?

}

class User:JSONSerializable {
    var objID: NSNumber?
    var firstName: NSString?
    var lastName: NSString?
    var age: NSNumber?
    var address = Address()

}
```

To do so, simply implement the `class func fromJSON(decoder:JSONDecoder)` function.

```swift
class Address:JSONSerializable {
    
    ...
    
    class func fromJSON(decoder:JSONDecoder) -> Address {
        var object = Address()
        object.objID = decoder["id"].integer
        object.streetAddress = decoder["street_address"].string
        object.city = decoder["city"].string
        object.state = decoder["state"].string
        object.postalCode = decoder["postal_code"].string
        return object
    }

}

class User:JSONSerializable {
   
   ...
   
   class func fromJSON(decoder:JSONDecoder) -> User {
        var object = User()
        object.objID = decoder["id"].integer
        object.firstName = decoder["first_name"].string
        object.lastName = decoder["last_name"].string
        object.age = decoder["age"].integer
        object.address = Address.fromJSON(decoder["address"])
        return object
    }

}
```

Now that the `fromJSON` function has been implemented:

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

Simply, we're gonna create an array and fill it.

```swift
var data:NSData?
/// ... get your data here
// once you have your data, simply do
var users:[User] = []
var decoder = JSONDecoder(data!)
if let array = decoder.array {
    for element in array {
        users.append(User(element))
    }
}

// Here you have an User array completely filled in just a few lines of code

```

---




