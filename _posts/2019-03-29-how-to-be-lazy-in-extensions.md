---
title: "How To Be Lazy In Extensions?"
image: /assets/posts/how-to-be-lazy-in-extensions/banner.png

categories:
- how to
tags:
- language feature 
layout: post
---

How to extend an object with a lazy property? Recently, I needed this for [Constrictor](https://github.com/pedrommcarrasco/Constrictor) and, in this post, you'll learn how you can achieve it.

> **"How to …  ?"** is a collection of short posts where I'll share problems I've faced and how I ended up solving them.
>
> tl;dr - Question 👉 Answer

## Problem

Let's start with the obvious solution, which in this case, would be extending `UIView` with:

<script src="https://gist.github.com/pedrommcarrasco/d017bf6c192fc788ec739384fcd394a7.js"></script>

Clean and simple, but it doesn't work... If you give it a try, Xcode will fail to compile with "**Extensions must not contain stored properties**".

## Solution

While potentially dangerous, **Associated Objects** can still be very useful as they allow us to add new properties inside an extension of an existing object.

As an example, we are able to create a lazy property in an `UIView` extension as follows:

<script src="https://gist.github.com/pedrommcarrasco/34c6f225f9c0285351fdd41cd7a20dc1.js"></script>

In short, we have a lazy property by associating a `Constrictor`'s instance to a `UIView`'s instance in runtime. If there is one associated, it will retrieve it. If there isn't, it will create one and save its "address" in `AssociatedKey.constrictor` so it can be retrieved in future calls.

## Conclusion

As mentioned, **Associated Objects** can be dangerous if used improperly. To be fully aware of its capabilities and common pitfalls, I recommend reading Mattt's [article](https://nshipster.com/associated-objects/) from NSHipster.

Last but not least, if you have any subject you would like to see covered and/or discussed, let me know here or on [Twitter](https://twitter.com/pedrommcarrasco)! 👀

Thanks for reading. ✨
