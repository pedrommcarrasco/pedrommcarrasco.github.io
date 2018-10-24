---
title: "Splashy"
image: 
  path: /assets/projects/fluky/cover.png
  thumbnail: /assets/projects/fluky/logo.png
  caption: ""
actions:
  - label: "GitHub"
    icon: github
    url: "http://www.github.com/pedrommcarrasco/Fluky"
comments: false
---

> **Fluky** *(/ˈfluːki/)*, *adjective*
>
> "obtained or achieved more by chance than skill"

Make every loading screen different with Fluky, your random loading screen inspired by PlayStation.

[![CocoaPods](https://img.shields.io/cocoapods/v/Fluky.svg)](https://cocoapods.org/pods/Fluky)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![apm](https://img.shields.io/apm/l/vim-mode.svg)](https://github.com/pedrommcarrasco/Fluky/blob/master/LICENSE)

## Instalation 📦

### Cocoapods

Fluky is available through [CocoaPods](https://cocoapods.org/pods/Fluky). To do so, add the following line to your PodFile:

```swift
pod 'Fluky'
```
And then run the following command in terminal:

```swift
pod install
```

### Carthage
Add this to your Cartfile:

```swift
github "pedrommcarrasco/Fluky"
```

And then run the following command in terminal:

```swift
carthage update
```

##  Styles 💅

| Single                                                       | Linear                                                       | Box                                                          |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| ![](https://github.com/pedrommcarrasco/Fluky/blob/master/Design/single.gif?raw=true) | ![](https://github.com/pedrommcarrasco/Fluky/blob/master/Design/linear.gif?raw=true) | ![](https://github.com/pedrommcarrasco/Fluky/blob/master/Design/box.gif?raw=true) |

* ☝️ *This background is not part of Fluky*

## Usage Example ⌨️

After installing Fluky, you should start by importing the framework:

```swift
import Fluky
```

Once imported, you can start using Fluky to create randomized icon based loading sceens. Bellow, you'll be able to see a working example. First, we start by creating a `FlukyView`:

```swift
let flukyView = Fluky.view(as: .single, with: images) // images -> array of icons you want to display
// size has a default parameter of 30.0
```

Once you apply your constraints, to start animating you just need to do:

```swift
flukyView.start()
```

In order to stop you just do:

```swift
flukyView.stop()
```

With the goal of being as customizable as possible, Fluky only creates a `FlukyView` responsible for managing the icons and its animations. With this in mind, it should be added to your view hierarchy where you can customize `backgroundColor`, add a `UILabel` & others.

## Sample Project  📲

There's a sample project in this repository called [Example](https://github.com/pedrommcarrasco/Fluky/tree/master/Example) with some examples.
