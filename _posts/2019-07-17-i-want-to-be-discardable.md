---
title: "I want to be discardable"
categories:
- tips and tricks
tags:
- Chaining
- Discard
layout: post
image: /assets/posts/i-want-to-be-discardable/banner.jpg
---

Ever wanted to ignore a value returned from a function but if you do so you'll end up with the following warning? 

![](https://github.com/pedrommcarrasco/pedrommcarrasco.github.io/blob/master/assets/posts/i-want-to-be-discardable/warning.png?raw=true) 

Let's take the following function as an example for this article.

```swift
func example() -> String {
  let description = "This is an example"
  print(description)
  return description
}
```

In most case scenarios, you would probably do `_ = example()`to silence the warning. Although, while this is correct, in case you want to ignore the result of a function most of the times, but still have the possibility to use it, this solution wouldn't look very clean because adding `_ =` every single time would create a lot of boilerplate code and your public interface wouldn't seem well designed.

## Our hero

Fear not dear reader because there's a solution to this problem!
Previous to Swift 2, this warning wouldn't appear unless you've marked your function with `@warn_unused_result`. But in Swift 3, Apple turned on this warning by default and introduced our hero `@discardableResult`. This mark is available since iOS 8.0.

## Ignore this, ignore that, I want those

Previously you've used `_` to ignore a function result, but this time, we are going to do that by using `@discardableResult`. To do so, we'll replace our function with the following code.

```swift
@discardableResult
func example() -> String {
  let description = "This is an example"
  print(description)
  return description
}
```

Now it's time to invoke it.

```swift
example()
```

Compile and you'll confirm that Xcode didn't show any kind of warning this time. But what if we want to use the value returned? 

```swift
var value = example()
value.append(" with discardable")
print(value)
```

If we run the code above you'll see that "This is an example" is printed followed by "This is an example with discardable", meaning that we've successfully stored the result of `example()` in  `value`, appended " with discardable to it" and finally printed it.

## Real-world examples

You don't have to look too far to find some real-world examples. Take a look at Apple's `NSLayoutAnchor` for example. If you notice when you apply a constraint with anchors, in case you need to save it locally to define a priority, you could easily do:

```swift
let a = UIView()
let b = UIView()

a.topAnchor.constraint(equalTo: b.topAnchor)

let aBottom = a.bottomAnchor.constraint(equalTo: b.bottomAnchor)
aBottom.priority = .defaultHigh
```

But if you don't want use the `NSLayoutConstraint` returned, you're also allowed to ignore it without Xcode displaying any warning.

There are many other cases where `@discardableResult` can be useful, for example, it can also be handy for chaining functions.

## Conclusion
So, should you use it every single time you have a return value?
The answer is no, absolutely not. Your interfaces should be as clear as possible and `@discardableResult` adds a small implementation detail that doesn't have much visibility, therefore, it could lead to some readability problems. Plus, it shouldn't be used when you are expecting to use the result of a function most of the times. 

And with this, you've now acknowledged `@discardableResult` and what's your opinion about it? Did you know it or is it something new to you? Let me hear it, alongside with questions and feedback on [Twitter](https://twitter.com/pedrommcarrasco) or here with Disqus.

Thanks for your time. ✨
