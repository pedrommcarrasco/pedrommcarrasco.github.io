---
title: "Power-Up Your Anchors"
image: /assets/posts/power-up-your-anchors/banner.jpg
categories:
- Auto Layout
tags:
- UI
layout: post
---

Programmatically done Auto Layout is still the preferred way of implementing views by a lot of developers. While there amazing open-source frameworks, most of them differ from Apple’s anchor syntax. Therefore, by adding them to your project, you’ll raise the entry level complexity of your project and increase its learning curve. In this article, you’ll learn how to avoid adding an external dependency and create your own layer above `NSLayoutAnchor` to solve some of its issues.

### Introduction

`NSLayoutAnchor` was first introduced by Apple in iOS 9.0 and it is described as a *"factory class for creating layout constraint objects using a fluent API"*.  Apple's [documentation](https://developer.apple.com/documentation/uikit/nslayoutanchor)  also refers that `NSLayoutAnchor` usage is preferred when compared to `NSLayoutConstraint`: “use these constraints to programmatically define your layout using Auto Layout. Instead of creating `NSLayoutConstraint` …”. This is due to type checking and having a cleaner interface when compared to `NSLayoutConstraint`.

Improvements related to type checking are based in Apple’s decision to split `NSLayoutAnchor` into three different concepts, being:

* `NSLayoutXAxisAnchor` for horizontal constraints
* `NSLayoutYAxisAnchor` for vertical constraints
* `NSLayoutDimension` for width and height constraints

Apple’s [documentation](https://developer.apple.com/documentation/uikit/nslayoutanchor) also mentions that "*you never use the `NSLayoutAnchor` class directly. Instead, use one of its subclasses, based on the type of constraint you wish to create*". In short, you can never constrain anchors between the different subclasses shown above. But, you can still mess it up, as Apple states:

> *"While the `NSLayoutAnchor` class provides additional type checking, it is still possible to create invalid constraints, For example, the compiler allows you to constrain one view's `leadingAnchor` with another view's `leftAnchor`, since they are both `NSLayoutXAxisAnchor` instances. However, Auto Layout does not allow constraints that mix leading and trailing attributes with left or right attributes"*

First of all, take a look at the following code and try to identify some of `NSLayoutAnchor`’s boilerplate code.

```swift
// Subviews
let logoImageView = UIImageView()
let welcomeLabel = UILabel()
let dismissButton = UIButton()

// Add Subviews & Set view's translatesAutoresizingMaskIntoConstraints to false
[logoImageView, welcomeLabel, dismissButton].forEach {
    self.addSubview($0)
    $0.translatesAutoresizingMaskIntoConstraints = false 
}

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

According to this implementation, you should have found the following requirements:

* You must set `translatesAutoresizingMaskIntoConstraints` to `false` for every view;
* You must activate constraints by setting its property `isActive` to `true` or by using `NSLayoutConstraint.activate()`;
* You cannot set `UILayoutPriority` via a parameter and must instead create a variable.

Within this article, you will learn how to address these issues. However, keep in mind that this only applies to Swift.

### TranslatesAutor... Yes, that long property you always set to false

Here lies the first identified issue, and Apple is clear on why you always have to set it as false:

> "*If this property’s value is `true`, the system creates a set of constraints that duplicate the behavior specified by the view’s autoresizing mask. This also lets you modify the view’s size and location using the view’s `frame`, `bounds`, or `center` properties*.

> *If you want to use Auto Layout to dynamically calculate the size and position of your view, you must set this property to `false`*"

This describes exactly what you want: use Auto Layout to dynamically calculate the size and position of your views. However you don’t want to write this huge property for every single view, not even inside a `forEach`.

There are multiple approaches to solve this, but for now you will be improving `addSubview` and adding a side-effect to it. To do so, create an `UIView` extension with the following code:

```swift
extension UIView {

  func addSubviewsUsingAutoLayout(_ views: UIView ...) {

    views.forEach {
      self.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }
  }
}
```

With this code, you will be able to send multiple views, set them all as subviews and set each one’s `translatesAutoresizingMaskIntoConstraints` to false all at once.

Now, instead of doing the following:

```swift
[logoImageView, welcomeLabel, dismissButton].forEach {
    self.addSubview($0)
    $0.translatesAutoresizingMaskIntoConstraints = false 
}
```

You will now have:

```swift
addSubviewsUsingAutoLayout(logoImageView, welcomeLabel, dismissButton)
```

### What about the remaining issues?

Start by extending `NSLayoutAnchor` as follows:

```swift
extension NSLayoutAnchor {

  func test() {}

}
```

This will generate an error:

![ObjcGenericError](https://github.com/pedrommcarrasco/pedrommcarrasco.github.io/blob/master/assets/posts/power-up-your-anchors/objcerror.png?raw=true)

Prior to Swift 4, you were forced to extend each of `NSLayoutAnchor’`s subclasses, or constrain it, because it is a generic class. But now you can simply expose your extension to Objective-C.

```swift
@objc extension NSLayoutAnchor
```

If you try to compile this, you will notice that the error disappears. Your extension is now ready to use your own code, and that is exactly what you’re going to do.

### Activate your constraints!

Setting `isActive` in every single anchor is excruciating. Even though `NSLayoutConstraint.activate()` might be considered a better option, according to Apple’s [documentation](https://developer.apple.com/documentation/uikit/nslayoutconstraint/1526955-activate), it still adds a lot of indentation.

One way of solving this would be to set `isActive` to true by `default`. You can achieve this with the following:

```swift
@objc extension NSLayoutAnchor {

  @discardableResult 
  func constrain(equalTo anchor: NSLayoutAnchor, 
                 with constant: CGFloat = 0.0, 
                 isActive: Bool = true) -> NSLayoutConstraint {

    let constraint = self.constraint(equalTo: anchor, constant: constant)
    constraint.isActive = isActive
    return constraint
  }
}
```

This function uses a Swift capability called default argument. It allows `isActive` to be called as an optional argument. By default, it will always be set to `true`. But in case you don’t want it active, you can set it to `false`.

By using `@discardableResult`, you will be returning an `NSLayoutConstraint` that you can safely ignore if you don’t need it. In case you never heard about this keyword, I’ve written an article titled “[I Want to be Discardable](https://pedrommcarrasco.github.io/posts/i-want-to-be-discardable/)” that addresses this.

### Too many functions!

Currently, you only support a relation of `equalTo` when you should also support `greaterThanOrEqualTo` and `lessThanOrEqualTo`.

According to Apple's [documentation](https://developer.apple.com/documentation/uikit/nslayoutanchor), `NSLayoutAnchor` exposes 6 different functions. These are as follows:

* `func constraint(equalTo: NSLayoutAnchor) -> NSLayoutConstraint`
* `func constraint(equalTo: NSLayoutAnchor, constant: CGFloat) -> NSLayoutConstraint`
* `func constraint(greaterThanOrEqualTo: NSLayoutAnchor) -> NSLayoutConstraint`
* `func constraint(greaterThanOrEqualTo: NSLayoutAnchor, constant: CGFloat) -> NSLayoutConstraint`
* `func constraint(lessThanOrEqualTo: NSLayoutAnchor) -> NSLayoutConstraint`
* `func constraint(lessThanOrEqualTo: NSLayoutAnchor, constant: CGFloat) -> NSLayoutConstraint`

While Apple's approach works, you can reduce the amount of functions in your interface with an enumeration approach for `NSLayoutConstraint.Relation` as in the following code:

```swift
@objc extension NSLayoutAnchor {

  @discardableResult 
  func constrain(_ relation: NSLayoutConstraint.Relation = .equal, 
                 to anchor: NSLayoutAnchor, 
                 with constant: CGFloat = 0.0, 
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

    constraint.isActive = isActive
      
    return constraint
  }
}
```
If you try to use it:

```swift
let a = UIView()
let b = UIView()

a.addSubviewsUsingAutoLayout(b)

// Constraint set as equal to a.topAnchor
b.topAnchor.constrain(a.topAnchor)

// Constraint set as greater than or equal to a.bottomAnchor
b.bottomAnchor.constrain(.greaterThanOrEqual, to: a.bottomAnchor)

// Constraint set as less than or equal to a.bottomAnchor
b.leadingAnchor.constrain(.lessThanOrEqual, to: a.leadingAnchor)

```

Everything seems to be working well. But what if you try to apply a width constraint based on a constant? Add the following line of code to the previous example and rebuild:

```swift
b.widthAnchor.constrain(to: 50.0)
```

Oh no, you trigger another error:

![MissingFunction](https://github.com/pedrommcarrasco/pedrommcarrasco.github.io/blob/master/assets/posts/power-up-your-anchors/missingfunction.png?raw=true)

But this time it is pretty easy to understand what’s happening. Currently, your function is expecting you to send a `NSLayoutAnchor`.

To solve this, the following are the two most obvious solutions:

* Set the expecting anchor as an optional, `NSLayoutAnchor?`.
* Provide a default parameter.

But none of these are optimal, because:

* It would lead to some edge cases that aren’t supposed to be possible and wouldn’t even work. Therefore your interface would allow inconsistencies that didn’t exist before.
* It isn't possible to provide a valid default parameter to `NSLayoutAnchor`.

According to Apple’s documentation, you are only allowed to set a constraint without any relation to another anchor for `NSLayoutDimension`’s anchors.

To avoid missing cases that already exist, you should also have the option to apply a constraint between two `NSLayouDimension` anchors with a constant & multiplier.

In order to address this, you must enable this feature only for `NSLayoutDimension`’s anchors. Therefore, you are going to extend `NSLayoutDimension` with the following code:

```swift
extension NSLayoutDimension {

  @discardableResult
  func constrain(_ relation: NSLayoutConstraint.Relation = .equal,
                 to anchor: NSLayoutDimension
                 with constant: CGFloat = 0.0,
                 multiplyBy multiplier: CGFloat = 1.0,
                 isActive: Bool = true) -> NSLayoutConstraint {

    let constraint: NSLayoutConstraint

    switch relation {
      case .equal:
        constraint = self.constraint(equalTo: anchor, multiplier: multiplier, constant: constant)
            
      case .greaterThanOrEqual:
        constraint = self.constraint(greaterThanOrEqualTo: anchor, multiplier: multiplier, constant: constant)
            
      case .lessThanOrEqual:
        constraint = self.constraint(lessThanOrEqualTo: anchor, multiplier: multiplier, constant: constant)
        }

    constraint.isActive = isActive

    return constraint
  }
    
  @discardableResult
  func constrain(_ relation: NSLayoutConstraint.Relation = .equal,
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

You’ll now able to apply width and height constraints without any kind of relation to another anchor.

### Priorities

Now, you're going to simplify setting priorities. To set a constraint’s priority in the current model, with anchors, you would need to do the following:

```swift
let bWidth = b.widthAnchor.constraint(equalToConstant: 50.0)
bWidth.priority = .defaultHigh
// or if you want between .defaultHigh and .required 👇 🤮
bWidth.priority = UILayoutPriority(UILayoutPriority.defaultHigh.rawValue + 1)
```

A good way to avoid being forced to assign the constraint to a property is adding this option to your functions. Also, with a default value of `.required`, you don’t need to type it in most scenarios.

Replace your functions with the following:

```swift
@objc extension NSLayoutAnchor {

  @discardableResult
  func constrain(_ relation: NSLayoutConstraint.Relation = .equal,
                 to anchor: NSLayoutAnchor,
                 with constant: CGFloat = 0.0,
                 prioritizeAs priority: UILayoutPriority = .required,
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
  func constrain(_ relation: NSLayoutConstraint.Relation = .equal,
                 to anchor: NSLayoutDimension
                 with constant: CGFloat = 0.0,
                 multiplyBy multiplier: CGFloat = 1.0,
                 prioritizeAs priority: UILayoutPriority = .required,
                 isActive: Bool = true) -> NSLayoutConstraint {

    let constraint: NSLayoutConstraint

    switch relation {
      case .equal:
        constraint = self.constraint(equalTo: anchor, multiplier: multiplier, constant: constant)
            
      case .greaterThanOrEqual:
        constraint = self.constraint(greaterThanOrEqualTo: anchor, multiplier: multiplier, constant: constant)
            
      case .lessThanOrEqual:
        constraint = self.constraint(lessThanOrEqualTo: anchor, multiplier: multiplier, constant: constant)
        }
	
    constraint.priority = priority
    constraint.isActive = isActive

    return constraint
  }

  @discardableResult
  func constrain(_ relation: NSLayoutConstraint.Relation = .equal,
                 to constant: CGFloat = 0.0,
                 prioritizeAs priority: UILayoutPriority = .required,
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

However, what if you wanted a priority between `.defaultHigh` and `.required`? The current way doesn’t look very clean. In order to improve it, you are going to extend `NSLayoutPriority` with the following:

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

And now you’ll be able to do the following:

```swift
bWidth.priority = .defaultHigh + 1 // 😍
```

### DRY

DRY stands for “[Don’t Repeat Yourself](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself)”, and it is often seen as a golden rule in software development.

You are currently repeating yourself when setting `isActive` and `priority`. In order to follow this pattern, you will move this to a `NSLayoutConstraint` extension.

Start by adding the following function to your extension:

```swift
func set(priority: UILayoutPriority, isActive: Bool) {
	
    self.priority = priority
    self.isActive = isActive
}
```

And now update your `constrain` functions with the following:

```swift
@objc extension NSLayoutAnchor {

  @discardableResult
  func constrain(_ relation: NSLayoutConstraint.Relation = .equal,
                 to anchor: NSLayoutAnchor,
                 with constant: CGFloat = 0.0,
                 prioritizeAs priority: UILayoutPriority = .required,
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
      
    constraint.set(priority: priority, isActive: isActive)

    return constraint
  }
}

extension NSLayoutDimension {
    
  @discardableResult
  func constrain(_ relation: NSLayoutConstraint.Relation = .equal,
                 to anchor: NSLayoutDimension
                 with constant: CGFloat = 0.0,
                 multiplyBy multiplier: CGFloat = 1.0,
                 prioritizeAs priority: UILayoutPriority = .required,
                 isActive: Bool = true) -> NSLayoutConstraint {

    let constraint: NSLayoutConstraint

    switch relation {
      case .equal:
        constraint = self.constraint(equalTo: anchor, multiplier: multiplier, constant: constant)
            
      case .greaterThanOrEqual:
        constraint = self.constraint(greaterThanOrEqualTo: anchor, multiplier: multiplier, constant: constant)
            
      case .lessThanOrEqual:
        constraint = self.constraint(lessThanOrEqualTo: anchor, multiplier: multiplier, constant: constant)
        }
	
    constraint.set(priority: priority, isActive: isActive)

    return constraint
  }

  @discardableResult
  func constrain(_ relation: NSLayoutRelation = .equal,
                 to constant: CGFloat = 0.0,
                 prioritizeAs priority: UILayoutPriority = .required,
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
      
    constraint.set(priority: priority, isActive: isActive)

	return constraint	
  }
}
```

### What have you done?

At the beginning of this article, you spotted some problems related to anchors. Now you can proudly check that you’ve developed solutions to each of them.

- Having to set `translatesAutoresizingMaskIntoConstraints` to `false` for every view that isn’t loaded from a NIB
  - **You've created a new `addSubviewsUsingAutoLayout` function that supports sending multiple `UIView`**
- Activating constraints by setting its property `isActive` to `true`, or using `NSLayoutConstraint.activate()`
- Setting `UILayoutPriority` via parameter is not supported and requires you to create a variable.
  - **`NSLayoutAnchor` extensions work together to solve these two problems**
- Interoperability has its costs to `NSLayoutAnchor` because it doesn't allow it to take advantage of some Swift capabilities.
  - **You've reduced the number of functions needed with an enum based approach and adopted default parameters in your interface.**

Everything is looking good on paper. However, how does it look in practice?

### How does it look?

Before showcasing your new and fresh powered-up anchors, take another look at the initial example shown in this article:

```swift
// Subviews
let logoImageView = UIImageView()
let welcomeLabel = UILabel()
let dismissButton = UIButton()

// Add Subviews & Set view's translatesAutoresizingMaskIntoConstraints to false
[logoImageView, welcomeLabel, dismissButton].forEach { 
  self.addSubview($0)
  $0.translatesAutoresizingMaskIntoConstraints = false 
}

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

Now you can achieve the same result in a much cleaner way with your extensions:

```swift
// Subviews
let logoImageView = UIImageView()
let welcomeLabel = UILabel()
let dismissButton = UIButton()
        
// Add Subviews & Set view's translatesAutoresizingMaskIntoConstraints to false
addSubviewsUsingAutoLayout(logoImageView, welcomeLabel, dismissButton)
        
// Set Constraints
logoImageView.topAnchor.constrain(to: topAnchor, with: 12)
logoImageView.centerXAnchor.constrain(to: centerXAnchor)
logoImageView.widthAnchor.constrain(to: 50)
logoImageView.heightAnchor.constrain(to: 50)
        
dismissButton.leadingAnchor.constrain(.greaterThanOrEqual, to: leadingAnchor, with: 12)
dismissButton.trailingAnchor.constrain(.lessThanOrEqual, to: trailingAnchor, with: -12)
dismissButton.bottomAnchor.constrain(to: bottomAnchor)
dismissButton.widthAnchor.constrain(to: 320, prioritizeAs: .defaultHigh + 1)
        
welcomeLabel.topAnchor.constrain(to: logoImageView.bottomAnchor, with: 12)
welcomeLabel.bottomAnchor.constrain(.greaterThanOrEqual, to: dismissButton.topAnchor, with: 12)
welcomeLabel.leadingAnchor.constrain(to: dismissButton.leadingAnchor)
welcomeLabel.trailingAnchor.constrain(to: dismissButton.trailingAnchor)
 
```

As you can see, it is a lot easier to read and understand what each anchor is doing. You were also able to decrease the amount of code you needed to write.

### Future Improvements

While this will simplify the usage of Auto Layout programmatically, there are some details missing. The following functions aren’t covered:

  * `constraintEqualToSystemSpacingBelow(NSLayoutYAxisAnchor, multiplier: CGFloat) `
  * `constraintGreaterThanOrEqualToSystemSpacingBelow(NSLayoutYAxisAnchor, multiplier: CGFloat) `
  * `constraintLessThanOrEqualToSystemSpacingBelow(NSLayoutYAxisAnchor, multiplier: CGFloat) `
  * `constraintEqualToSystemSpacingAfter(NSLayoutXAxisAnchor, multiplier: CGFloat)`
  * `constraintGreaterThanOrEqualToSystemSpacingAfter(NSLayoutXAxisAnchor, multiplier: CGFloat)`
  * `constraintLessThanOrEqualToSystemSpacingAfter(NSLayoutXAxisAnchor, multiplier: CGFloat)`

If requested, we can review this in a follow-up article.

### The End

If you’ve managed to fully read this and reach the end, congratulations on powering your anchors!
In the end, what’s your opinion of it? Did you know it already, or was it something new to you? Let me know, alongside with your questions, by sending feedback on [Twitter](https://twitter.com/pedrommcarrasco) or here.

Last but not least, I would like to praise [Ana Filipa Ferreira](https://twitter.com/anafpf3), [João Pereira](https://twitter.com/NSMyself), [José Figueiredo](https://twitter.com/ZeMiguelFig), [Pedro Eusébio](https://www.linkedin.com/in/peusebio/), [Tiago Silva](https://twitter.com/tiagomssilvaa) and [Farfetch](https://twitter.com/farfetch) for their outstanding support. ❤️

Thanks for reading. ✨
