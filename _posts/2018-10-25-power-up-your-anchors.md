---
title: "Power-Up Your Anchors"
image: /assets/posts/power-up-your-anchors/banner.jpg
categories:
- Guide
tags:
- Auto Layout
layout: post
---

Programmatically done Auto Layout is still the preferred way of implementing views by a lot of developers. While there are amazing open-source frameworks, most of them differ from Apple’s anchor syntax. Therefore, by adding them to your project, you’ll raise the entry level complexity of your project and increase its learning curve. In this article, you’ll learn how to avoid adding an external dependency and create your own layer above `NSLayoutAnchor` to solve some of its issues.

### Introduction

`NSLayoutAnchor` was first introduced by Apple in iOS 9.0 and it is described as a *"factory class for creating layout constraint objects using a fluent API"*.  Apple's [documentation](https://developer.apple.com/documentation/uikit/nslayoutanchor)  also refers that `NSLayoutAnchor` usage is preferred when compared to `NSLayoutConstraint`: “use these constraints to programmatically define your layout using Auto Layout. Instead of creating `NSLayoutConstraint` …”. This is due to type checking and having a cleaner interface when compared to `NSLayoutConstraint`.

Improvements related to type checking are based in Apple’s decision to split `NSLayoutAnchor` into three different concepts, being:

* `NSLayoutXAxisAnchor` for horizontal constraints
* `NSLayoutYAxisAnchor` for vertical constraints
* `NSLayoutDimension` for width and height constraints

Apple’s [documentation](https://developer.apple.com/documentation/uikit/nslayoutanchor) also mentions that "*you never use the `NSLayoutAnchor` class directly. Instead, use one of its subclasses, based on the type of constraint you wish to create*". In short, you can never constrain anchors between the different subclasses shown above. But, you can still mess it up, as Apple states:

> *"While the `NSLayoutAnchor` class provides additional type checking, it is still possible to create invalid constraints, For example, the compiler allows you to constrain one view's `leadingAnchor` with another view's `leftAnchor`, since they are both `NSLayoutXAxisAnchor` instances. However, Auto Layout does not allow constraints that mix leading and trailing attributes with left or right attributes"*

First of all, take a look at the following code and try to identify some of `NSLayoutAnchor`’s boilerplate code.

<script src="https://gist.github.com/pedrommcarrasco/c6957ba7fcd8519d82d73f9d1b8275c7.js"></script>

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

<script src="https://gist.github.com/pedrommcarrasco/be50ad4da9a743c791ee07fbd39ee970.js"></script>

With this code, you will be able to send multiple views, set them all as subviews and set each one’s `translatesAutoresizingMaskIntoConstraints` to false all at once.

Now, instead of doing the following:

<script src="https://gist.github.com/pedrommcarrasco/ea6052781799fcefc3ed2f2ca8bceea4.js"></script>

You will now have:

<script src="https://gist.github.com/pedrommcarrasco/fe03e548c9b916b11278188bc192a2e5.js"></script>

### What about the remaining issues?

Start by extending `NSLayoutAnchor` as follows:

<script src="https://gist.github.com/pedrommcarrasco/190b5a091917d1307c26f0ef0b64e85c.js"></script>

This will generate an error:

![ObjcGenericError](https://github.com/pedrommcarrasco/pedrommcarrasco.github.io/blob/master/assets/posts/power-up-your-anchors/objcerror.png?raw=true)

Prior to Swift 4, you were forced to extend each of `NSLayoutAnchor’`s subclasses, or constrain it, because it is a generic class. But now you can simply expose your extension to Objective-C.

<script src="https://gist.github.com/pedrommcarrasco/9655a5c2ccd468ad6ea6ae98e01d046b.js"></script>

If you try to compile this, you will notice that the error disappears. Your extension is now ready to use your own code, and that is exactly what you’re going to do.

### Activate your constraints!

Setting `isActive` in every single anchor is excruciating. Even though `NSLayoutConstraint.activate()` might be considered a better option, according to Apple’s [documentation](https://developer.apple.com/documentation/uikit/nslayoutconstraint/1526955-activate), it still adds a lot of indentation.

One way of solving this would be to set `isActive` to true by `default`. You can achieve this with the following:

<script src="https://gist.github.com/pedrommcarrasco/394200fedad867b63f504f149301afe4.js"></script>

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

<script src="https://gist.github.com/pedrommcarrasco/0d5d088b47c627b9509183503c745b51.js"></script>

If you try to use it:

<script src="https://gist.github.com/pedrommcarrasco/04d59262eea41b9ddc4430d029eedcab.js"></script>

Everything seems to be working well. But what if you try to apply a width constraint based on a constant? Add `b.widthAnchor.constrain(to: 50.0)` to the previous example and rebuild. Oh no, you trigger another error:

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

<script src="https://gist.github.com/pedrommcarrasco/550c1a0828d3245079382d318b298906.js"></script>

You’ll now able to apply width and height constraints without any kind of relation to another anchor.

### Priorities

Now, you're going to simplify setting priorities. To set a constraint’s priority in the current model, with anchors, you would need to do the following:

<script src="https://gist.github.com/pedrommcarrasco/1819ab318af946b29b0e5998b2d666a1.js"></script>

A good way to avoid being forced to assign the constraint to a property is adding this option to your functions. Also, with a default value of `.required`, you don’t need to type it in most scenarios.

Replace your functions with the following:

<script src="https://gist.github.com/pedrommcarrasco/b4dbb92ff435df63dfc5f8861ea3bff8.js"></script>

However, what if you wanted a priority between `.defaultHigh` and `.required`? The current way doesn’t look very clean. In order to improve it, you are going to extend `NSLayoutPriority` with the following:

<script src="https://gist.github.com/pedrommcarrasco/866dbdf718c28e7a94bad4fab68c3810.js"></script>

And now you’ll be able to do `bWidth.priority = .defaultHigh + 1` .

### DRY

DRY stands for “[Don’t Repeat Yourself](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself)”, and it is often seen as a golden rule in software development.

You are currently repeating yourself when setting `isActive` and `priority`. In order to follow this pattern, you will move this to a `NSLayoutConstraint` extension.

Start by adding the following function to your extension:

<script src="https://gist.github.com/pedrommcarrasco/222e09cc794f51c203e7262e654939c6.js"></script>

And now update your `constrain` functions with the following:

<script src="https://gist.github.com/pedrommcarrasco/0866f2260656c8690b5e4ec02a5261de.js"></script>

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

<script src="https://gist.github.com/pedrommcarrasco/c6957ba7fcd8519d82d73f9d1b8275c7.js"></script>

Now you can achieve the same result in a much cleaner way with your extensions:

<script src="https://gist.github.com/pedrommcarrasco/3329b41081d8798c837852e17d87a78e.js"></script>

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
