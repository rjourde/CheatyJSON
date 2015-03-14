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
{
  "first_name": "Hank",
  "last_name": "Schrader",
  "age": 42,
  "address": {
    "street_name": "Hank's street",
    "postal_code": "123",
    "city": "Albuquerque"
  },
  "friends": [
    {
      "first_name": "Walter",
      "last_name": "White",
      "age": 52,
      "address": {
        "street_name": "Walter's street",
        "postal_code": "123",
        "city": "Albuquerque"
      },
      "friends": []
    },
    {
      "first_name": "Jesse",
      "last_name": "Pinkman",
      "age": 26,
      "address": {
        "street_name": "Jesse's street",
        "postal_code": "123",
        "city": "Albuquerque"
      },
      "friends": [
        {
          "first_name": "Jane",
          "last_name": "Margolis",
          "age": 27,
          "address": {
            "street_name": "Jane's street",
            "postal_code": "123",
            "city": "Albuquerque"
          },
          "friends": []
        }
      ]
    }
  ]
}
```

We want to translate that JSON to these Swift objects:


```swift
class Address:JSONSerializable {
    var streetAddress: NSString?
    var city: NSString?
    var postalCode: NSString?
    
    override func registerVariables() {
        // Here we implement the function to match our JSON
        self.registerVariable("streetAddress", JSONName: "street_name")
        self.registerVariable("postalCode", JSONName: "postal_code")
        // Note that city has not been registered because its name already matches our JSON
    }

}

class Person:JSONSerializable {
    var firstName: NSString?
    var lastName: NSString?
    var age: NSNumber?
    var friends: [Person]?
    var address = Address()
    
    override func registerVariables() {
        // Again, we register our variables to match the JSON
        self.registerVariable("firstName", JSONName: "first_name")
        self.registerVariable("lastName", JSONName: "last_name")
        // Again, age, friends and address variables have not been registered as they already match our JSON
    }

}
```

Now, let's see how to create our object

```swift

var data:NSData?
// here you get your data

var person = Person(JSONData:data!)

println(person.firstName)
println(person.lastName)
println(person.age)

println(person.JSONString())

```

This will produce the following output:


---

Now we'd like to parse a JSON Array of users

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




