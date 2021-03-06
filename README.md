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

or simply use pod
> pod 'CheatyJSON'

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
```swift
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
```

This will produce the following output:

```
Optional(Hank)
Optional(Schrader)
Optional(42)
```

If you try to access the other fields, you'll get an error.

Automatic JSON deserialization cannot retrieve nested class or array of nested classes automatically.

To get them, you will have to write a little bit of code

if your class have nested classes of array of nested classes, you will have to implement the `JSONCompletion(decoder:JSONDecoder)` function.

in our Person class, add:

```swift
    override func JSONCompletion(decoder: JSONDecoder) {
        self.address = Address(decoder: decoder["address"])
        // Basically, this code creates your Address object given the "address" field of our JSON
        // Now, we want to fill our friends array
        // To do so, we're gonna simply create and fill it
        self.friends = []
        // First, we get our array from the "friends" JSON field
        if let friendsArray = decoder["friends"].array {
            // We then loop through all our 'friend' decoders
            for friendDecoder in friendsArray {
                // for each decoder, we will create a Person object
                self.friends!.append(Person(decoder: friendDecoder))
            }
        }
    }
```

That's it! You now have all your JSON as Swift objects

To check it, we can simply print the `person.JSONString()`, it will produce the following output:

```json
{
  "age": 42,
  "friends": [
    {
      "age": 52,
      "friends": [],
      "last_name": "White",
      "first_name": "Walter",
      "address": {
        "street_name": "Walter's street",
        "city": "Albuquerque",
        "postal_code": "123"
      }
    },
    {
      "age": 26,
      "friends": [
        {
          "age": 27,
          "friends": [],
          "last_name": "Margolis",
          "first_name": "Jane",
          "address": {
            "street_name": "Jane's street",
            "city": "Albuquerque",
            "postal_code": "123"
          }
        }
      ],
      "last_name": "Pinkman",
      "first_name": "Jesse",
      "address": {
        "street_name": "Jesse's street",
        "city": "Albuquerque",
        "postal_code": "123"
      }
    }
  ],
  "last_name": "Schrader",
  "first_name": "Hank",
  "address": {
    "street_name": "Hank's street",
    "city": "Albuquerque",
    "postal_code": "123"
  }
}
```

---




