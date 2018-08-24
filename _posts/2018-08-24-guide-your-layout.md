---
title: "Guide Your Layout"
image: /assets/posts/guide-your-layout/banner.jpg
categories:
- Auto Layout
tags:
- UI
- Tips & Tricks
- Performance
layout: post
actions:
- label: "Source Code"
  icon: github
  url: "https://github.com/pedrommcarrasco/pedrommcarrasco.github.io/tree/master/Articles-Source-Code/Guide%20your%20layout/GuideYourLayout.playground"
---

How would you achieve the following screen? 

![](https://github.com/pedrommcarrasco/pedrommcarrasco.github.io/blob/master/assets/posts/guide-your-layout/goal.jpg?raw=true)

You can easily spot an `UIImageView` and an `UILabel` centered together. 

There are multiple approaches to this problem and the most obvious would be to insert these two elements in a `UIStackView`. But what if, in a more complex layout, you weren´t able to use it? The most common approach, although not the best, would be encapsulating the `UIImageView` and the `UILabel` inside a `UIView`.

In this article, you'll learn how to approach this problem in this scenario.

## I'm Here to Guide You!
In iOS 9.0, Apple introduced major changes to its frameworks and added new ones. One of them was `UILayoutGuide`.

 `UILayoutGuide` is a *“rectangular area that can interact with Auto Layout”* and it should be used to replace any `UIView` used for *"inter-view spaces or encapsulation"* (dummy view).

It also improved efficiency and safety since you avoid the following issues regarding dummy views:

* Creating and maintaining a `UIView` impacts performance
* Each member of the view hierarchy adds overhead to every task the hierarchy performs
* A `dummyView` will be able to intercept messages that are intended for other views

It's also important to notice that, similar to `UIStackView`, `UILayoutGuide` cannot have a background color, among other properties.

## World’s Most Famous Guide

Alongside with iOS 11, Apple introduced the Safe Area Layout Guide while deprecating the top and bottom layout guides.

According to its [documentation](https://developer.apple.com/documentation/uikit/uiview/2891102-safearealayoutguide), `safeAreaLayoutGuide` is *"the layout guide representing the portion of your view that is unobscured by bars and other content"*. It can also be confirmed in its declaration below, that `safeAreaLayoutGuide` truly is an `UILayoutGuide`:

![](https://github.com/pedrommcarrasco/pedrommcarrasco.github.io/blob/master/assets/posts/guide-your-layout/safeAreaDeclaration.png?raw=true)

## Time to Solve Problems

With all the knowledge acquired, you are now able to solve the initial problem using `UILayoutGuide` instead of a *dummy view*.

To start off, if you were using an `UIView` for encapsulation, you would start by creating it and adding it to the hierarchy:

```swift
let containerView = UIView()
view.addSubview(containerView)
```

This time, since you're using `UILayoutGuide`, you'll need to create an instance of it. Then, instead of adding it by calling `addSubview(UIView)`, you'll be using `addLayoutGuide(UILayoutGuide)`.

```swift
let layoutGuide = UILayoutGuide()
view.addLayoutGuide(layoutGuide)
```

Notice that, since `UILayoutGuide` isn't a member of the view hierarchy you'll be adding your views to `view` instead of `layoutGuide`.

```swift
[photoImageView, introLabel].forEach { self.view.addSubview($0) }
```

You're now done with the `UILayoutGuide`'s initial setup and with so, it's time to move to constraints. In the end, it is similar to what you would do with an `UIView`.

```swift
NSLayoutConstraint.activate(
  [
    layoutGuide.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    layoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    layoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
    photoImageView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),     
    photoImageView.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),
    photoImageView.widthAnchor.constraint(equalTo: photoImageView.heightAnchor),
    photoImageView.heightAnchor.constraint(equalToConstant: 250),
                
    introLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 16),
    introLabel.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
    introLabel.leadingAnchor.constraint(equalTo: photoImageView.leadingAnchor),
    introLabel.trailingAnchor.constraint(equalTo: photoImageView.trailingAnchor)
  ]
)
```

Keep in mind that `photoImageView` and `introLabel` setup isn't in the scope of this article. Still, if you're interested in it, take a look [here](https://github.com/pedrommcarrasco/pedrommcarrasco.github.io/tree/master/Articles-Source-Code/Guide%20your%20layout/GuideYourLayout.playground).

## Conclusion

Most of the times, you'll end up using a `UIStackView` to solve problems alike but there are cases where `UILayoutGuide` shines. The presented problem isn't the case and it was just used for a matter of presentation.

Unfortunately, in case you prefer working with Interface Builder, `UILayoutGuide` isn't available there.

In the end, what's your opinion of it? Did you know it or is it something new to you? Let me know it, alongside with your questions and feedback on [Twitter](https://twitter.com/) or here.

Last but not least, I would like to praise [Ana Filipa Ferreira](https://twitter.com/anafpf3), [Tiago Silva](https://twitter.com/tiagomssilvaa), [José Figueiredo](https://twitter.com/ZeMiguelFig) and [João Pereira](https://twitter.com/NSMyself) for their outstanding support. ❤️

Thanks for reading. ✨
