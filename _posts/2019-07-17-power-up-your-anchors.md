---
title: "Power-up your anchors"
categories:
- User Interface
tags:
- Auto Layout
- Constraint
- Anchor
layout: post
image: /assets/posts/power-up-your-anchors/banner.jpg
---

NSLayoutAnchor was first introduced by Apple in iOS 9.0 and it's described as a *"factory class for creating layout constraint objects using a fluent API"*.  Apple's documentation also refers that `NSLayoutAnchor` usage is preferred when compared to `NSLayoutConstraint`, *"use these constraints to programmatically define your layout using Auto Layout. Instead of creating `NSLayoutConstraint` ..."*, due to type checking and having a simple and cleaner interface when compared to NSLayoutConstraint.

`NSLayoutAnchor`'s type checking comes from Apple's three concepts of anchors:

* `NSLayoutXAxisAnchor` for horizontal constraints
* `NSLayoutYAxisAnchor` for vertical constraints
* `NSLayoutDimension` for width and height constraints

"*You never use the `NSLayoutAnchor` class directly. Instead, use one of its subclasses, based on the type of constraint you wish to create*". 

This means you can never constrain anchors between the different types shown above. But, you can still mess it up, as Apple states:

*"While the `NSLayoutAnchor` class provides additional type checking, it is still possible to create invalid constraints. For example, the compiler allows you to constrain one view's `leadingAnchor` with another view's `leftAnchor`, since they are both `NSLayoutXAxisAnchor` instances. However, Auto Layout does not allow constraints that mix leading and trailing attributes with left or right attributes"*

## Current State

It is time to take a look at an Auto Layout implementation with `NSLayoutAnchor` to see if we can spot some of its problems.

```swift
// Subviews
let logoImageView = UIImageView()
let welcomeLabel = UILabel()
let dismissButton = UIButton()

// Add Subviews
self.addSubview(logoImageView)
self.addSubview(welcomeLabel)
self.addSubview(dismissButton)

// Set view's translatesAutoresizingMaskIntoConstraints to false
[logoImageView, welcomeLabel, dismissButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

// Set Constraints
logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
logoImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
logoImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true

dismissButton.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 12).isActive = true
dismissButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12).isActive = true
dismissButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
let dismissButtonWidth = dismissButton.widthAnchor.constraint(equalToConstant: 320)
dismissButtonWidth.priority = UILayoutPriority(UILayoutPriority.defaultHigh.rawValue + 1)
dismissButtonWidth.isActive = true

welcomeLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 12).isActive = true
welcomeLabel.bottomAnchor.constraint(greaterThanOrEqualTo: dismissButton.topAnchor, constant: 12).isActive = true
welcomeLabel.leadingAnchor.constraint(equalTo: dismissButton.leadingAnchor).isActive = true
welcomeLabel.trailingAnchor.constraint(equalTo: dismissButton.trailingAnchor).isActive = true
```

Just by looking at this example, we're able to identify the following constraints:

* Having to set `translatesAutoresizingMaskIntoConstraints` to false for every view that isn't loaded from a NIB
* Activating constraints by setting its property `isActive` to true, or using `NSLayoutConstraint.activate()`
* Setting `UILayoutPriority` via parameter is not supported and requires you to create a variable.
* Interoperability is a major problem of `NSLayoutAnchor` because it doesn't allow it to take advantage of some Swift's features.

Also, setting multipliers is disabled, except for `NSLayoutDimension`'s anchors and in Interface Builder. Due to these limitations and some others, I've created my own Auto Layout µFramework called Constrictor, but this article isn't about convincing you to use a whole new DSL or external dependency for Auto Layout but instead help you power-up your anchors so you can reduce the amount of code you have to write, because the best code is the code you don't have to write, so let's get our hands dirty!

Keep in mind that the following improvements will only work with Swift, so in case you have interoperability in your project, while the same logic can be applied, it would required changes.

## TranslatesAutor... Yes, that long property you always set to false

Here lies the first problem we've spotted and Apple is clear in why you have to do this.

"*If this property’s value is `true`, the system creates a set of constraints that duplicate the behavior specified by the view’s autoresizing mask. This also lets you modify the view’s size and location using the view’s `frame`, `bounds`, or `center` properties*

*If you want to use Auto Layout to dynamically calculate the size and position of your view, you must set this property to `false`*"

As you might notice, this describes exactly what we want, use Auto Layout to dynamically calculate the size and position of our views, except that we don't want to write this huge property for every single view, not even inside a `forEach`.

To solve this we're going to create a `UIView` extension with the following code.

```swift
extension UIView {

  func addSubviews(_ subviews: UIView ...) {
    subviews.forEach {
      self.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }
  }
}
```

This function is going to add all `UIView `as its subviews and set each one's  `translatesAutoresizingMaskIntoConstraints` to false. In the end, we'll reduce our code to add subviews and set `translatesAutoresizingMaskIntoConstraints` to the following.

```swift
// Add Subviews & Sets translatesAutoresizingMaskIntoConstraints to false
self.addSubviews(logoImageView, welcomeLabel, dismissButton)
```
There's a minor downside here, it introduces a side effect to the add subviews's process, one way to make this clearer would be changing the function's name to reflect it but that's up to you.

## What about the other problems?

We've now dealt with setting `translatesAutoresizingMaskIntoConstraints`to false and now we're going to start working in the remaining problems. To solve them, while there are hundreds of possible solutions, in this article we are going to extend `NSLayoutAnchor`. With this, we'll also leverage some Swift features and decrease how verbose and static the current functions are.

Now that we know what we want, let's start by extending `NSLayoutAnchor` as follows.

```swift
extension NSLayoutAnchor {

  func test() {}

}
```

Try to compile this and you will get the error shown in the image below.

![](https://github.com/pedrommcarrasco/pedrommcarrasco.github.io/blob/master/assets/posts/power-up-your-anchors/objcerror.png?raw=true)

In the past, we would be forced to extend each of `NSLayoutAnchor`'s subclasses but since Swift 4 we are able to solve this by just adding `@objc` to our extension.

```swift
@objc extension NSLayoutAnchor
```

And now, if you try to compile, you'll notice that our error is gone for good and with this, our extension is now ready to have some code inside.

## Activate your constraints!

Setting `isActive` in every single anchor is painful and even though `NSLayoutConstraint.activate([NSLayoutConstraint])` might be considered a better option, it still adds a lot of indentation to our code. But, what if `isActive` would be set by default as true instead of false? Let's try to achieve that with the following code.

```swift
@objc extension NSLayoutAnchor {

  @discardableResult 
  func constrain(equalTo anchor: NSLayoutAnchor, 
                 constant: CGFloat = 0.0, 
                 isActive = true) -> NSLayoutConstraint {

    let constraint = self.constraint(equalTo: anchor, constant: constant)
    constraint.isActive = isActive
    return constraint
  }
}
```

We've decided to put up to use a Swift capability called default parameters. This means that we can call this function without providing a value for the `isActive`'s parameter and in this case, its value will always be true, but in case you need a constraint that's not immediately active, you can always send false to this parameter.

Then, while we tell our lovely machine that our function must return a `NSLayoutConstraint` we also say that this function's return is a `@discardableResult`. In case you never heard about it, here is a short sample that will allow you to understand what it does.

```swift
extension String {

  func test() {   
    self.discardable()
    self.nonDiscardable()
  }

  @discardableResult
  func discardable() -> String {
    return ""
  }

  func nonDiscardable() -> String {
    return ""
  }
}
```

Compile it and you'll notice that you've got a warning in your `nonDiscardable()` function call because you aren't using the value returned. Also, notice that the `discardable()` call surprisingly doesn't have any warning. That's exactly what  `@discardableResult` does, it tells the compiler that it shouldn't worry if we're discarding, by not using or storing the object returned. Now that you know everything about `@discardableResult`let's move back to our Auto Layout function.

So, if we wanted to use our function it would look like this.

```swift
let a = UIView()
let b = UIView()

a.addSubviews(b)

// Constant set by default as 0.0
// isActive set by default as true
// returned constraint discarded
b.topAnchor.constrain(equalTo: a.topAnchor)

// isActive set by default as true
// returned constraint discarded
b.bottomAnchor.constrain(equalTo: a.bottomAnchor, constant: 10.0)

// Constant set by default as 0.0
// returned constraint is stored in a local variable
let bLeading = b.leadingAnchor.constrain(equalTo: a.leadingAnchor, isActive = false)

```

It looks like we've solved our little constraint's activation problem but we're still missing an important aspect, our function only supports a relation of `equalTo` when it should also support `greaterThanOrEqualTo` and `lessThanOrEqualTo`.

## Too many functions!

To tackle this problem let's first take a look at how Apple solves it. According to Apple's documentation, `NSLayoutAnchor`exposes 6 different functions, being:

* `func constraint(equalTo: NSLayoutAnchor) -> NSLayoutConstraint`
* `func constraint(equalTo: NSLayoutAnchor, constant: CGFloat) -> NSLayoutConstraint`
* `func constraint(greaterThanOrEqualTo: NSLayoutAnchor) -> NSLayoutConstraint`
* `func constraint(greaterThanOrEqualTo: NSLayoutAnchor, constant: CGFloat) -> NSLayoutConstraint`
* `func constraint(lessThanOrEqualTo: NSLayoutAnchor) -> NSLayoutConstraint`
* `func constraint(lessThanOrEqualTo: NSLayoutAnchor, constant: CGFloat) -> NSLayoutConstraint`

While Apple solves the problem, it would require two more functions with almost the same logic as the one we've already created. So let's try an enumeration based approach with `NSLayoutRelation`.

```swift
@objc extension NSLayoutAnchor {

  @discardableResult 
  func constrain(_ relation: NSLayoutRelation = .equal, 
                 to anchor: NSLayoutAnchor, 
                 constant: CGFloat = 0.0, 
                 isActive = true) -> NSLayoutConstraint {

    let constraint: NSLayoutConstraint

    switch relation {
      case .equal:
        constraint = self.constraint(equalTo: anchor, constant: constant)

      case .greaterThanOrEqual:
        constraint = self.constraint(greaterThanOrEqualTo: anchor, constant: constant)

      case .lessThanOrEqual:
        constraint = self.constraint(lessThanOrEqualTo: anchor, constant: constant)
    }

    let constraint = self.constraint(equalTo: anchor, constant: constant)
    constraint.isActive = isActive
    return constraint
  }
}
```
If we now try to use our function, it would work like the following.

```swift
let a = UIView()
let b = UIView()

a.addSubviews(b)

// Constraint set as equal to a.topAnchor
b.topAnchor.constrain(a.topAnchor)

// Constraint set as greater than or equal to a.bottomAnchor
b.bottomAnchor.constrain(.greaterThanOrEqual, to: a.bottomAnchor)

// Constraint set as less than or equal to a.bottomAnchor
b.leadingAnchor.constrain(.lessThanOrEqual, to: a.leadingAnchor)

```

If you compile, it'll work but what if we try to apply a width constraint based on a constant. Add the next line of code to your test function and compile again.

```swift
b.widthAnchor.constrain(constant: 50.0)
```

Oh no, another error... 

![](https://github.com/pedrommcarrasco/pedrommcarrasco.github.io/blob/master/assets/posts/power-up-your-anchors/missingfunction.png?raw=true)

But this time it's pretty easy to understand what's happening. Currently, our function is always expecting us to send a `NSLayoutAnchor` and it doesn't have a default parameter. To solve this, these would be the two most obvious solutions:

* Set the expecting anchor as an optional, `NSLayoutAnchor?`
* Provide a default parameter

But none of them would work because:

* It would lead to edge cases that aren't supposed to be allowed and wouldn't even work, therefore our interface would allow inconsistencies that didn't exist before.
* It isn't possible to provide a default parameter to `NSLayoutAnchor`

With this in our hands, it looks like It is time to read Apple's documentation, and according to it, it is only allowed to set a constraint without any relation to another anchor for `NSLayoutDimension`'s anchors.

So, in order to tackle this, we must enable this feature for `NSLayoutDimension`'s anchors. Therefore, we're going to extend `NSLayoutDimension` with the following code.

```swift
extension NSLayoutDimension {

  @discardableResult
  func constrain(_ relation: NSLayoutRelation = .equal,
                 to constant: CGFloat = 0.0,
                 isActive: Bool = true) -> NSLayoutConstraint {

    let constraint: NSLayoutConstraint

    switch relation {
      case .equal:
        constraint = self.constraint(equalToConstant: constant)

      case .greaterThanOrEqual:
        constraint = self.constraint(greaterThanOrEqualToConstant: constant)

      case .lessThanOrEqual:
        constraint = self.constraint(lessThanOrEqualToConstant: constant)
      }
      
    constraint.isActive = isActive

    return constraint
  }
}
```

And now we're finally able to apply width and height constraints without any kind of relation to another anchor.  As you might also verify, this function is only available to `NSLayoutDimension`'s anchors as it should, because we extended `NSLayoutDimension`instead of `NSLayoutAnchor`.

## Priorities

We're now going to ease the use of priorities with anchors. In the current state, to set a constraint's priority you would need to do following.

```swift
let bWidth = b.widthAnchor.constraint(constant: 50.0)
bWidth.priority = .defaultHigh

// or if you want between .defaultHigh and .required
bWidth.priority = UILayoutPriority(UILayoutPriority.defaultHigh.rawValue + 1)
```

Now your brain might be engineering something like:

"What if we can send an `UILayoutPriority` to our functions but let it have a default value of `.required` so we don't actually need to type it in most of the time." 

Congratulations, you're absolutely right! But what if you want a priority between `.defaultHigh` and `.required`? As you can see, currently, it doesn't look very nice and so, we're going to extend `NSLayoutPriority` with the code below.

```swift
extension UILayoutPriority {

  static func +(lhs: UILayoutPriority, rhs: Float) -> UILayoutPriority {
    return UILayoutPriority(lhs.rawValue + rhs)
  }

  static func -(lhs: UILayoutPriority, rhs: Float) -> UILayoutPriority {
    return UILayoutPriority(lhs.rawValue - rhs)
  }
}
```

Now we're able to achieve the following line.

```swift
bWidth.priority = .defaultHigh + 1
```

It's looking great so far but let's update our functions with what we engineered before.

```swift
@objc extension NSLayoutAnchor {

  @discardableResult
  func constrain(_ relation: NSLayoutRelation = .equal,
                 to anchor: NSLayoutAnchor,
                 constant: CGFloat = 0.0,
                 priority: UILayoutPriority = .required,
                 isActive: Bool = true) -> NSLayoutConstraint {
                 
    let constraint: NSLayoutConstraint
    
    switch relation {
    case .equal:
      constraint = self.constraint(equalTo: anchor, constant: constant)
      
    case .greaterThanOrEqual:
      constraint = self.constraint(greaterThanOrEqualTo: anchor, constant: constant)

    case .lessThanOrEqual:
      constraint = self.constraint(lessThanOrEqualTo: anchor, constant: constant)
    }

    constraint.priority = priority
    constraint.isActive = isActive

    return constraint
  }
}

extension NSLayoutDimension {

  @discardableResult
  func constrain(_ relation: NSLayoutRelation = .equal,
                 to constant: CGFloat = 0.0,
                 priority: UILayoutPriority = .required,
                 isActive: Bool = true) -> NSLayoutConstraint {

    let constraint: NSLayoutConstraint

    switch relation {
    case .equal:
      constraint = self.constraint(equalToConstant: constant)

    case .greaterThanOrEqual:
      constraint = self.constraint(greaterThanOrEqualToConstant: constant)

    case .lessThanOrEqual:
      constraint = self.constraint(lessThanOrEqualToConstant: constant)
    }

    constraint.priority = priority
    constraint.isActive = isActive

    return constraint
  }
}
```

Looking even better now that it is updated, but it's time to move to another  `NSLayoutConstraint` 's property.

## Multipliers

Nowadays, apart from `NSLayoutDimension`'s anchors and "SystemSpecific"'s functions, anchors don't support setting a multiplier value, however, it is possible to do it in Interface Builder. Considering this and since we're powering up our anchor's interface, we'll also allow them to have their truly deserved multiplier!

As mentioned above, `NSLayoutConstraint` has a `multiplier` property, the bad news is, it's read-only, however, let's take a look at its initializer.

```swift
init(item: Any, attribute: NSLayoutAttribute, relatedBy: NSLayoutRelation, toItem: Any?, attribute: NSLayoutAttribute, multiplier: CGFloat, constant: CGFloat)
```

With `NSLayoutConstraint`'s initializer, it seems that we might be able to set a constraint's multiplier by "copying" most of its properties and settings its multiplier. To achieve this, we'll create the following `NSLayoutConstraint's` extension.

```swift
extension NSLayoutConstraint {

  func multiply(by multiplier: CGFloat) -> NSLayoutConstraint {
    
    guard let owner = self.firstItem else { return NSLayoutConstraint() }
    
    return NSLayoutConstraint(item: owner,
                              attribute: self.firstAttribute,
                              relatedBy: self.relation,
                              toItem: self.secondItem,
                              attribute: self.secondAttribute,
                              multiplier: multiplier,
                              constant: self.constant)
  }
}
```

It is now time to update our functions so they're able to receive a multiplier by parameter while still having a default value of 1.0.

```swift
@objc extension NSLayoutAnchor {

  @discardableResult
  func constrain(_ relation: NSLayoutRelation = .equal,
                 to anchor: NSLayoutAnchor,
                 constant: CGFloat = 0.0,
                 priority: UILayoutPriority = .required,
                 multiplier: CGFloat = 1.0,
                 isActive: Bool = true) -> NSLayoutConstraint {

    var constraint: NSLayoutConstraint

    switch relation {
    case .equal:
      constraint = self.constraint(equalTo: anchor, constant: constant)

    case .greaterThanOrEqual:
      constraint = self.constraint(greaterThanOrEqualTo: anchor, constant: constant)

    case .lessThanOrEqual:
      constraint = self.constraint(lessThanOrEqualTo: anchor, constant: constant)
    }

    constraint = constraint.multiply(by: multiplier)
    constraint.priority = priority
    constraint.isActive = isActive

    return constraint
  }
}

extension NSLayoutDimension {

  @discardableResult
  func constrain(_ relation: NSLayoutRelation = .equal,
                 to constant: CGFloat = 0.0,
                 priority: UILayoutPriority = .required,
                 multiplier: CGFloat = 1.0,
                 isActive: Bool = true) -> NSLayoutConstraint {

    var constraint: NSLayoutConstraint
    
    switch relation {
    case .equal:
      constraint = self.constraint(equalToConstant: constant)

    case .greaterThanOrEqual:
      constraint = self.constraint(greaterThanOrEqualToConstant: constant)

    case .lessThanOrEqual:
      constraint = self.constraint(lessThanOrEqualToConstant: constant)
    }

    constraint = constraint.multiply(by: multiplier)
    constraint.priority = priority
    constraint.isActive = isActive

    return constraint
  }
}
```

We're getting closer to the end, but if you take a closer look at our current solution you'll notice that we're setting constraint's `multiplier`, `priority` and `isActive` and its code is being repeated in both functions.

## DRY

DRY stands for "Don't repeat yourself" and it is often seen as a golden rule in programming. So what are we waiting for? 

To avoid repeating ourselves, we're going to move this logic to our `NSLayoutConstraint` extension and replace our multiply function with the following.

```swift
func set(multiplier: CGFloat, priority: UILayoutPriority, isActive: Bool) -> NSLayoutConstraint {

  guard let owner = self.firstItem else { return NSLayoutConstraint() }

  let constraint = NSLayoutConstraint(item: owner,
                                      attribute: self.firstAttribute,
                                      relatedBy: self.relation,
                                      toItem: self.secondItem,
                                      attribute: self.secondAttribute,
                                      multiplier: multiplier,
                                      constant: self.constant)
  constraint.priority = priority
  constraint.isActive = isActive

  return constraint
}
```
And now we invoke our new function instead of setting those properties.

```swift
@objc extension NSLayoutAnchor {

  @discardableResult
  func constrain(_ relation: NSLayoutRelation = .equal,
                 to anchor: NSLayoutAnchor,
                 constant: CGFloat = 0.0,
                 priority: UILayoutPriority = .required,
                 multiplier: CGFloat = 1.0,
                 isActive: Bool = true) -> NSLayoutConstraint {

    let constraint: NSLayoutConstraint
    
    switch relation {
    case .equal:
      constraint = self.constraint(equalTo: anchor, constant: constant)

    case .greaterThanOrEqual:
      constraint = self.constraint(greaterThanOrEqualTo: anchor, constant: constant)

    case .lessThanOrEqual:
      constraint = self.constraint(lessThanOrEqualTo: anchor, constant: constant)
    }

    return constraint.set(multiplier: multiplier, priority: priority, isActive: isActive)
  }
}

extension NSLayoutDimension {

  @discardableResult
  func constrain(_ relation: NSLayoutRelation = .equal,
                 to constant: CGFloat = 0.0,
                 priority: UILayoutPriority = .required,
                 multiplier: CGFloat = 1.0,
                 isActive: Bool = true) -> NSLayoutConstraint {
                 
    let constraint: NSLayoutConstraint
    
    switch relation {
    case .equal:
      constraint = self.constraint(equalToConstant: constant)

    case .greaterThanOrEqual:
      constraint = self.constraint(greaterThanOrEqualToConstant: constant)

    case .lessThanOrEqual:
      constraint = self.constraint(lessThanOrEqualToConstant: constant)
    }

    return constraint.set(multiplier: multiplier, priority: priority, isActive: isActive)
   }
}
```

## What have we done?

Right at the start of this article, we've spotted some problems related to anchors and we can proudly check that we've developed solutions to each one of them.

- Having to set `translatesAutoresizingMaskIntoConstraints` to false for every view that isn't loaded from a NIB
  - We've created a new addSubviews function that supports sending multiple `UIView`.
- Activating constraints by setting its property `isActive` to true, or using `NSLayoutConstraint.activate()`
- Setting `UILayoutPriority` via parameter is not supported and requires you to create a variable.
- Setting multipliers is disabled except for `NSLayoutDimension`'s anchors and in Interface Builder.'
  - Our extensions work together to solve these three problems.
- Interoperability is a major problem of `NSLayoutAnchor` because it doesn't allow it to take advantage of some Swift's features.
  - We've reduced the number of functions needed with an enum based approach and we've adopted default parameters in our functions.

Everything is looking good on paper, however, we still need to try out our work.

## How does it look?

To showcase our powered-up anchors, let's take a look at the first example we saw right at the start of this article.

```swift
// Subviews
let logoImageView = UIImageView()
let welcomeLabel = UILabel()
let dismissButton = UIButton()

// Add Subviews
self.addSubview(logoImageView)
self.addSubview(welcomeLabel)
self.addSubview(dismissButton)

// Set view's translatesAutoresizingMaskIntoConstraints to false
[logoImageView, welcomeLabel, dismissButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

// Set Constraints
logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
logoImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
logoImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true

dismissButton.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 12).isActive = true
dismissButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12).isActive = true
dismissButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
let dismissButtonWidth = dismissButton.widthAnchor.constraint(equalToConstant: 320)
dismissButtonWidth.priority = UILayoutPriority(UILayoutPriority.defaultHigh.rawValue + 1)
dismissButtonWidth.isActive = true

welcomeLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 12).isActive = true
welcomeLabel.bottomAnchor.constraint(greaterThanOrEqualTo: dismissButton.topAnchor, constant: 12).isActive = true
welcomeLabel.leadingAnchor.constraint(equalTo: dismissButton.leadingAnchor).isActive = true
welcomeLabel.trailingAnchor.constraint(equalTo: dismissButton.trailingAnchor).isActive = true
```

And now, let's see how we can achieve the same result, however, this time, we'll be using our extensions.

```swift
// Subviews
let logoImageView = UIImageView()
let welcomeLabel = UILabel()
let dismissButton = UIButton()
        
// Add Subviews
addSubviews(logoImageView, welcomeLabel, dismissButton)
        
// Set Constraints
logoImageView.topAnchor.constrain(to: topAnchor, constant: 12)
logoImageView.centerXAnchor.constrain(to: centerXAnchor)
logoImageView.widthAnchor.constrain(to: 50)
logoImageView.heightAnchor.constrain(to: 50)
        
dismissButton.leadingAnchor.constrain(.greaterThanOrEqual, to: leadingAnchor, constant: 12)
dismissButton.trailingAnchor.constrain(.lessThanOrEqual, to: trailingAnchor, constant: -12)
dismissButton.bottomAnchor.constrain(to: bottomAnchor)
dismissButton.widthAnchor.constrain(to: 320, priority: .defaultHigh + 1)
        
welcomeLabel.topAnchor.constrain(to: logoImageView.bottomAnchor, constant: 12)
welcomeLabel.bottomAnchor.constrain(.greaterThanOrEqual, to: dismissButton.topAnchor, constant: 12)
welcomeLabel.leadingAnchor.constrain(to: dismissButton.leadingAnchor)
welcomeLabel.trailingAnchor.constrain(to: dismissButton.trailingAnchor)
        
// Plus, we're able to set multipliers if we want :)
```

Since we've removed most of `NSLayoutAnchor`'s boilerplate it is actually looking pretty good. With this syntax, it is a lot easier to read and understand what each anchor is doing and we were also able to decrease the amount of code we've to write. 

## Future Improvements

While this works in most scenarios we are still missing some details:

* We don't support `UILayoutGuide`
* We don't abstract the following functions
  * `constraintEqualToSystemSpacingBelow(NSLayoutYAxisAnchor, multiplier: CGFloat) `
  * `constraintGreaterThanOrEqualToSystemSpacingBelow(NSLayoutYAxisAnchor, multiplier: CGFloat) `
  * `constraintLessThanOrEqualToSystemSpacingBelow(NSLayoutYAxisAnchor, multiplier: CGFloat) `
  * `constraintEqualToSystemSpacingAfter(NSLayoutXAxisAnchor, multiplier: CGFloat)`
  * `constraintGreaterThanOrEqualToSystemSpacingAfter(NSLayoutXAxisAnchor, multiplier: CGFloat)`
  * `constraintLessThanOrEqualToSystemSpacingAfter(NSLayoutXAxisAnchor, multiplier: CGFloat)`

And this is going to be your homework, or in case it is requested, it might be covered in a second part.

## The End

If you've managed to fully read this and reach this ending chapter, I would like to thank you for being with me on this journey through anchors! 

This is my first article so feel free to give me feedback on [Twitter](https://twitter.com/pedrommcarrasco) or here with Disqus. If you find this article helpful feel free to share.

The source code is available at Github [here](https://github.com/pedrommcarrasco).
