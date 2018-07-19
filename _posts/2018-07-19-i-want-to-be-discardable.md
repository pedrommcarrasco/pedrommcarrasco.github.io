---
title: "I want to be discardable"
categories:
- tips and tricks
tags:
- Chaining
- Discard
layout: post
image: /assets/posts/i-want-to-be-discardable/banner.jpg
permalink: i-want-to-be-discardable
actions:
    - label: "Source Code"
      icon: github
      url: "https://github.com/pedrommcarrasco/pedrommcarrasco.github.io/blob/master/Articles-Source-Code/I%20want%20to%20be%20discardable/Discardable.swift"
---

Ever wanted to ignore a value returned from a function but if you do so you'll end up with the following warning? 

![](https://github.com/pedrommcarrasco/pedrommcarrasco.github.io/blob/master/assets/posts/i-want-to-be-discardable/warning.png?raw=true) 

First of all, take the following function as an example for this article.

```swift
func example() -> String {
  let description = "This is an example"
  print(description)
  return description
}
```

In most scenarios, you would use '`_ = example()`' to silence the warning. While this is correct, adding '`_ =`' every single time would create a lot of boilerplate code and your public interface wouldn't seem well designed. Keep in mind that changing the function to `Void` isn't an option for this specific example because we might want to use `example()`'s return in some scenario.

## The Hero

Prior to Swift 2, this warning wouldn't appear unless you've marked your function with `@warn_unused_result`. In Swift 3, Apple turned on this warning by default and introduced `@discardableResult`. This mark is available since iOS 8.0.

## Ignore this, Ignore that, I want those

Previously you've used '`_ =`' to ignore a function result, but this time, you are going to do that by using `@discardableResult`. To do so, you'll `@discardableResult` to the previous function. Resulting in:

```swift
@discardableResult
func example() -> String {
  let description = "This is an example"
  print(description)
  return description
}
```

Now, invoke your function like this:

```swift
example()
```

Compile and you'll verify that Xcode didn't show any kind of warning this time. But what if you want to use the value returned? 

```swift
var value = example()
value.append(" with discardable")
print(value)
```

If you run the code above you'll see that "This is an example" is printed followed by "This is an example with discardable", meaning that you've successfully stored the result of `example()` in  `value`, appended " with discardable to it" and finally printed it.

## Real-world Examples

You don't have to look too far to find some real-world examples. Take a look at Apple's `NSLayoutAnchor` for example. If you notice when you apply a constraint with anchors, in case you need to save it locally to define a priority, you could easily do:

```swift
let a = UIView()
let b = UIView()

a.topAnchor.constraint(equalTo: b.topAnchor)

let aBottom = a.bottomAnchor.constraint(equalTo: b.bottomAnchor)
aBottom.priority = .defaultHigh
```

If you don't want use the `NSLayoutConstraint` returned, you're also allowed to ignore it without Xcode displaying any warning.

There are many other cases where `@discardableResult` can be useful, for example, it can also be handy for chaining functions and logging.

## Conclusion
So, should you use it every single time you have a return value?
The answer is no, absolutely not. Your interfaces should be as clear as possible and `@discardableResult` usually means your function has side-effects and adds a small implementation detail that doesn't have much visibility, therefore, it could lead to some readability problems and inconsistencies. Plus, it shouldn't be used when you are expecting to use the result of a function most of the times. 

And with this, you've now acknowledged `@discardableResult`. What's your opinion about it? Did you know it or is it something new to you? Let me hear it, alongside with your questions and feedback on [Twitter](https://twitter.com/pedrommcarrasco) or here.

Last but not least, I would like to praise [Ana Filipa Ferreira](https://twitter.com/anafpf3), [Tiago Silva](https://twitter.com/tiagomssilvaa), [Pedro Eusébio](https://www.linkedin.com/in/peusebio/), [José Figueiredo](https://twitter.com/ZeMiguelFig), [Warren Burton](https://twitter.com/TroutDev) and [João Pereira](https://twitter.com/NSMyself) for their outstanding support. ❤️

Thanks for reading. ✨
