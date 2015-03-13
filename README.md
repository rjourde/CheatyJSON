CheatyJSON
===================


CheatyJSON is a Swift framework designed to handle JSON easily

----------


Installation
-------------

To install this, simply add the **.xcodeproj** to your project, and whenever you want to use it in your code, simply type :

import CheatyJSON



#### <i class="icon-file"></i> How does it work ?

This framework couldn't be simpler to use.
It provides a class named **JSONSerializable** you can inherit from.
When inherited, this class gives you some useful functions, such as

JSONString()
JSONData()
toDictionary()

> **JSONString()** simply transforms your object to a JSON String
> Example :
> ```swift
> class Person:JSONSerializable {
> var name:String = "foo"
> var age:Int = 42
> var isAwesome:Bool = true
> }
> var me = Person()
> me.JSONString()```
Will return a String containing
{"name":"foo","age":42,"isAwesome":true}

Readme is still under construction ;)


----------
