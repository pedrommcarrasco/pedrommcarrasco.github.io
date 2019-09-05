---
title: "How To Display Your Dependencies?"
image: /assets/posts/how-to-display-your-dependencies/banner.jpg

categories:
- how to
tags:
layout: post
---

Ever wanted to show your users which dependencies your application has? I needed this for an application I'll launch soon and, in this post, you'll learn how you can achieve it.

> **"How to …  ?"** is a collection of short posts where I'll share problems I've faced and how I ended up solving them.
>
> tl;dr - Question 👉 Answer

## Problem

Since I was using [CocoaPods]([https://cocoapods.org](https://cocoapods.org/)) to manage my dependencies, there was only one requirement: **the data must be synchronized with the `podfile`**.

## Solution

While I've never heard of it before, there was a clear and "official" solution. It was the plugin [`cocoapods-acknowledgements`](https://github.com/CocoaPods/cocoapods-acknowledgements).

This plugin generates a property list (`.plist`) with the metadata of your dependencies. In order to use it, follow the next steps:

1. Install it via ruby with  `gem install cocoapods-acknowledgements`
2. Add `plugin 'cocoapods-acknowledgements'` to your `podfile`.
3. You'll now find `Pods-YOUR_TARGET-metadata.plist` inside `Pods/`

With this property list you can either decode it with the following code and map/transform to your own user interface:

<script src="https://gist.github.com/pedrommcarrasco/cbe1665e7c921c107e7bd74306691289.js"></script>

Or, if you rather have it in your application's settings, you can also embed it in your `Settings.bundle`. To do so, you just need to add  `plugin 'cocoapods-acknowledgements', :settings_bundle => true` to your `podfile`.

## Conclusion

You're now able to display your dependendencies to your users and keep in mind that CocoaPods Acknowledgements is well documented and offers other features, such as excluding dependencies or even adding non-CocoaPods dependencies to your property list. You can find it all [here](https://github.com/CocoaPods/cocoapods-acknowledgements/blob/master/README.md).

Last but not least, if you have any subject you would like to see covered and/or discussed, let me know here or on [Twitter](https://twitter.com/pedrommcarrasco)! 👀

Thanks for reading. ✨
