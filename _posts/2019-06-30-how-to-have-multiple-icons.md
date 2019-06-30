---
title: "How To Have Multiple Icons?"
image: /assets/posts/how-to-have-multiple-icons/banner.jpg

categories:
- how to
tags:
layout: post
---

There are multiple ways to make your application feel more personal to your users or even reward the most loyal ones. However, there aren't many as simple as having multiple application icons available and, in this post, you'll learn how you can do it.

> **"How to …  ?"** is a collection of short posts where I'll share problems I've faced and how I ended up solving them.
>
> tl;dr - Question 👉 Answer

## Problem

While adding your main application icon is as simple as adding some image to an asset catalogue (`.xcassets`), adding an alternative application icon won't be anything like that. 

**⚠️ Spoiler:** You won't even add it to an asset catalog 😱

## Solution

Assuming you have already designed a beautiful default icon and some alternatives, export them using the @2x and @3x naming convention and place them somewhere in your project inside a group (outside of any asset catalogue). 

In the end, you should have something as follows:

![](https://github.com/pedrommcarrasco/pedrommcarrasco.github.io/blob/master/assets/posts/how-to-have-multiple-icons/folderExample.png?raw=true)

Now, open your `Info.plist` as [source code](https://github.com/pedrommcarrasco/pedrommcarrasco.github.io/blob/master/assets/posts/how-to-have-multiple-icons/openAsSource.jpg?raw=true). At the end of your file, you should see `</dict>` and `</plist>`. Paste the following before them:

<script src="https://gist.github.com/pedrommcarrasco/7ea615cf3755d3d42df4357a5e44721a.js"></script>

In case you didn't notice, you must omit the file extension and the scaling suffix (@2x and @3x) from each entry. 

Once you're done, you can freely change your application's icon by calling `[setAlternateIconName(_:completionHandler:)](https://developer.apple.com/reference/uikit/uiapplication/2806818-setalternateiconname)` like follows:

<script src="https://gist.github.com/pedrommcarrasco/dabebe009c6738a6cb6c0ae774a6ef13.js"></script>

Before ending, if your application also supports **iPad**, you'll need to add another dictionary to your `Info.plist`. This dictionary should be a copy of the previously added one but with the `~ipad` suffix. Considering the previous dictionary, it would result in:

<script src="https://gist.github.com/pedrommcarrasco/19ade32e54e8870ac9988e827099fcbc.js"></script>

## Conclusion

Alternate application icons were introduced in iOS 10.3 and can help you make your application feel more personal to your users. While providing this feature isn't difficult, it isn't as easy as it could and should be and tools like [AlternativeIcons](https://github.com/alexaubry/alternate-icons) can improve your experience with it.

Last but not least, if you have any subject you would like to see covered and/or discussed, let me know here or on [Twitter](https://twitter.com/pedrommcarrasco)! 👀

Thanks for reading. ✨
