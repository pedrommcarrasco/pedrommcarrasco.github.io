---
title: "Constrictor"
image: 
  path: /assets/projects/constrictor/cover.jpg
  thumbnail: /assets/projects/constrictor/logo.png
  caption: ""
actions:
  - label: "GitHub"
    icon: github
    url: "http://www.github.com/pedrommcarrasco/Constrictor"
comments: false
---

Constrict your Auto Layout code with **Constrictor**, your chainable sugar.

> **Constrict** *(/ˈkənˈstrɪkt/)*, *verb*
>
> "... to make something become tighter and narrower:"

<p align="center">
<img src="https://github.com/pedrommcarrasco/Constrictor/blob/Revamp/presentation.gif?raw=true" alt="Presentation" width="100%"/>
</p>

[![Build Status](https://travis-ci.org/pedrommcarrasco/Constrictor.svg?branch=master)](https://travis-ci.org/pedrommcarrasco/Constrictor) 
[![codecov](https://codecov.io/gh/pedrommcarrasco/Constrictor/branch/master/graph/badge.svg)](https://codecov.io/gh/pedrommcarrasco/Constrictor)
[![CocoaPods](https://img.shields.io/cocoapods/v/Constrictor.svg)](https://cocoapods.org/pods/Constrictor)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![GitHub contributors](https://img.shields.io/github/contributors/pedrommcarrasco/constrictor.svg)
[![apm](https://img.shields.io/apm/l/vim-mode.svg)](https://github.com/pedrommcarrasco/Constrictor/blob/master/LICENSE)


- [x] Compatible with Auto Layout
- [x] Concise and chainable syntax
- [x] Automatically sets `translateAutoresizingMaskIntoConstraints`
- [x] Constraints are active by default
- [x] Easily update constraints
- [x] Allows setting priority upon creation


# Installation
## CocoaPods
Constrictor's available through [CocoaPods](https://cocoapods.org/pods/Constrictor). To do so, add the following line to your PodFile:

```swift
pod 'Constrictor'
```
And then run the following command in terminal:

```swift
pod install
```

## Carthage
Add this to your Cartfile:

```swift
github "pedrommcarrasco/Constrictor"
```

And then run the following command in terminal:

```swift
carthage update
```
