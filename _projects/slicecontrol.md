---
title: "SliceControl"
image: 
  path: /assets/projects/SliceControl/cover.jpg
  thumbnail: /assets/projects/SliceControl/logo.jpg
  caption: ""
actions:
  - label: "GitHub"
    icon: github
    url: "http://www.github.com/pedrommcarrasco/SliceControl"
comments: false
---

Simply a better & animated UISegmentedControl

> **Slice** *(/slɑɪs/)*, *noun*
>
> "A slice is any small part that has been separated from something larger"

[![CocoaPods](https://img.shields.io/cocoapods/v/SliceControl.svg)](https://cocoapods.org/pods/SliceControl)
[![apm](https://img.shields.io/apm/l/vim-mode.svg)](https://github.com/pedrommcarrasco/Fluky/blob/master/LICENSE)

# Usage Example ⌨️

After installing **SliceControl**, you should start by importing the framework:

```swift
import SliceControl
```

Once imported, you can start using **SliceControl** like follows:

```swift
sliceControl = SliceControl(with: ["All", "Liked", "Favourited"],
primaryColor: .darkGray,
secondaryColor: .white,
padding: 12)

// Implement SliceControlDelegate to intercept actions
sliceControl.delegate = self

view.addSubview(sliceControl)
// ... Constrain it
```
You can also set its `UIFont` and starting option.


# Instalation 📦

**SliceControl** is available through [CocoaPods](https://cocoapods.org/pods/SliceControl). In order to install, add the following line to your Podfile:

```swift
pod 'SliceControl'
```
And run the following command in terminal:

```swift
pod install
```

# Sample Project  📲

There's a sample project in this repository called [Example](https://github.com/pedrommcarrasco/SliceControl/tree/master/Example).
