CheatyJSON
===================


CheatyJSON is a Swift framework designed to handle JSON easily

----------


Installation
-------------

To install this, simply add the **.xcodeproj** to your project, and whenever you want to use it in your code, simply type :

import CheatyJSON

Usage
-------------

This framework couldn't be simpler to use.
It provides a class named **JSONSerializable** you can inherit from.
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

The `JSONData()` and `toDictionary()` functions basically do the same, but returns object data as NSData of Dictionary

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

Obviously, you can put your `registerVariable` calls directly in `init` if you want all your objects to behave the same.

----------
