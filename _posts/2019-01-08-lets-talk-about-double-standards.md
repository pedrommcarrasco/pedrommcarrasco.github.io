---
title: "Let's Talk About Double Standards"
image: /assets/posts/lets-talk-about-double-standards/banner.jpg
categories:
- Let's Talk About
tags:
- Testing
layout: post
---

Have you ever found yourself surrounded in a codebase where code guidelines seem to be ignored in its tests? It's time to talk about this with [José Figueiredo](https://twitter.com/ZeMiguelFig), [Paul Hudson](https://twitter.com/twostraws), [Rodrigo López-Romero](https://twitter.com/rlrg_6) and [Tiago Martinho](https://twitter.com/martinho_t).

> **"Let's talk about"** is a series where I discuss and showcase **my point of view** about specific topics. However, as most topics can be highly opinionated, I will also **bring other people's opinion**.
>
> tl;dr - Friendly Rant

## Introduction

Let's start with the definition of *guideline* according to the [Cambridge Dictionary](https://dictionary.cambridge.org/dictionary/english/guideline):

> **guideline** *(noun)*
>
> *information intended to advise people on how something should be done or what something should be*

We have lots of guidelines in our lives and people soon recognised we also needed them in programming. Otherwise, our codebases would be a combination of personal tastes embedded into an incoherent pile of computer instructions.

Subsequently, we developed multiple guidelines from styling to best practices. On top of that, we even automated the review process with tools such as [SwiftLint](https://github.com/realm/SwiftLint) but what about tests?

We follow a whole bunch of principles, patterns and guidelines but we often see tests ignoring them. Copy-pasting across multiple tests, response's stubs polluting test files, magic numbers everywhere and force-unwrapping because "it is just a unit test"? What about having double standards when it comes to code guidelines?

[Paul Hudson](https://twitter.com/twostraws), author of [Hacking with Swift](https://www.hackingwithswift.com) and [Testing Swift](https://www.hackingwithswift.com/store/testing-swift), agrees that tests are as important as application's code and we shouldn't have different standards between both: 

> *"The Swift language provides us with a dazzling array of language features and design patterns to help us create smart, safe, reusable code, but for some reason these get completely ignored when writing tests – we just write them the brute force way, with a thousand functions named `testXYZ()`.*
>
> *At WWDC17, Xcode engineer Greg Tracy said “Treat your test code with the same amount of care as your app code.” Simple, but straight to the point: all the coding principles we apply in our application's code should also be applied in our tests*
>
> *Many companies will talk proudly about their approach to code review – they might do pair programming, they might do GitHub reviews, they might have in-person code review sessions. But if you ask whether they do that same code review for their tests, you’ll find a problem: they usually don’t.*
>
> *The code you write is designed to solve a problem, and the tests you write are there to prove the code does what it says – the two are equally important, and should be treated as such."* - Paul

At this point, it should be clear how critical it is to acknowledge tests as part of the codebase and treat them as such. In this regard, [Tiago Martinho](https://twitter.com/martinho_t), the organiser of the [Swift Peer Lab in Barcelona](https://swiftpeerlab.github.io/), goes one step further and explains how culture and adaptability work together to eliminate double standards:

> *"Guidelines are important as a safety and communication mechanism, but the secret to maintaining a healthy codebase is having a healthy team culture. If we have guidelines for the production code but we are not following them for our tests, then there is a misalignment in the value these guidelines provide, and this should be tackled before adding more or changing existing guidelines.*
>
> *My personal opinion is that tests are part of the codebase, without them the cost of doing iterative development on the software greatly increases over time. On the other hand, if a test is not providing a safety net (that actually works) or is fragile with a high maintenance cost, then the best approach is to gradually migrate it to follow the team principles."* - Tiago

The following sections contain some examples in how you can improve your tests by giving them as much attention as you give to your application's code.

## Call It Magic

A magic number (or any other type) is a hard-coded value which meaning is hard to infer without context. Also, it might need to be updated at a later stage, therefore requiring you to change it in multiple places if it is all over your codebase.

Everyone tends to avoid it in their projects, but it isn't uncommon to see it in tests. 

Take a look at the following example:

<script src="https://gist.github.com/pedrommcarrasco/e65d46b7959b29ac0a09fd7ef56d5d52.js"></script>

While you might quickly notice the number 7, in order to understand it, you have to take a few seconds analyzing both functions. You might end realizing there is a business rule limiting the number of products an unauthenticated user will see. However, if instead of a magic number, you defined a constant with a proper name, both readability and understandability would have been improved. 

Still not convinced if it is worth the effort? What if months later, your company decides to update from 6 items for non-logged users to 9? In the previous example, you would *only* have to update two tests but what if you had more? That's right, using a magic number isn't scalable at all.

So instead, you could do as follows:

<script src="https://gist.github.com/pedrommcarrasco/2832fba065df686155401ac8ec22e172.js"></script>

Now, if there is an update, you just change one value in your tests. Besides, you can immediately see the reasons behind what you are asserting.

[José Figueiredo](https://twitter.com/ZeMiguelFig), a senior engineer at [Synchronoss Technologies](https://synchronoss.com), also disagrees with the use of magic numbers and double standards in general. According to him:

> *"In my honest opinion, magic values have no place in the middle of the code either if its production-grade or on a test target. Instead, they should be contextualised with variables, struct or enums with proper naming.*
>
> *After all, if you avoid the use of magic numbers in production code, you should be compelled to do it on the test target as well."* - José

## Hide yo' Data

It is uncommon to have data stubs in the application's code. However, it is very likely to have them in its tests. While data stubs aren't an issue by themselves, spreading them across your test case isn't a proper solution. Not only do they pollute it with extra lines but do also reduce its readability.

Take the following as an example:

<script src="https://gist.github.com/pedrommcarrasco/9cd12e99e90db69057893c7c7ee047ef.js"></script>

In two tests, a considerable amount of lines are for instantiating two `Product` and for what? In the end, you care about what these objects represent, not how they are instantiated. So instead, place them strategically into isolated containers, expose their meaning and reuse them if appropriate. Not only will this reduce the lines of code in your test file but also increase its readability - not to mention you now have two `Product` you can reuse across your tests.

As an example, create the following in a separate file:

<script src="https://gist.github.com/pedrommcarrasco/b76e3fe4dc50e3f8080e1711c00f92ff.js"></script>

Then, update your test as follows:

<script src="https://gist.github.com/pedrommcarrasco/08f17141a4e15289289e998a1a894ef9.js"></script>

Much shorter, easier to read, easier to understand and easier to maintain.

[Rodrigo López-Romero](https://twitter.com/rlrg_6), an engineer at [Adidas](https://adidas.github.io), added you should also have a well-defined folder structure, just like you would have in your application's code. According to him:

> *“I find very useful to have a separate project folder consisting of all test data. It helps to make the testing code clean and neat. When it comes to stubbing network requests, I think it is useful to have the JSON responses in separate files, although you need to update those JSON files whenever the server side changes.”* - Rodrigo 

Keep in mind you shouldn't overuse your test data! Distribute it by logic, context or any other criteria and avoid crossing it. Logic receives updates over time and with so you may need to update your test data. If it is too spread all over your tests, it may undesirably set some of them on fire! 🔥

## Copy-Pastability

On what do we spend most of our time as programmers? Scalability, replaceability, understandability, reusability and other fancy terms. All because we strive for quality.

If we have the same five lines of code in different places what do we do? Encapsulate it in a function. But what about tests?

Imagine a scenario in which your screens' structure is dynamically controlled by a back-end service and you want to validate that when receiving a new structure it updates accordingly. Take the following as an example:

<script src="https://gist.github.com/pedrommcarrasco/d8108a5519e9ee4fee1965d8cb0671f9.js"></script>

Notice the pattern? The code responsible for loading a JSON file doesn't add any value to these tests. After all, it isn't relevant how it loads it. It adds unnecessary complexity and extra lines for you to read. Instead, try doing as follows:

<script src="https://gist.github.com/pedrommcarrasco/db355b8285b5b4a2467a4d2b097679c7.js"></script>

These tests exist to validate how the `screenStructureManager` determines and updates the screen structure. Therefore, you can encapsulate any supplementary logic in functions with a well-defined interface. Subsequently, you'll reduce the lines of code in your test file and its readability. The DRY principle plays a big role both in your application's code and its tests in order to avoid repeating yourself.

Want to improve it even further? Decouple loading a JSON from this test case, make it as pure as possible and then you can freely reuse it across your tests' codebase.

In short, you can summarize this section with the following words from [Paul Hudson](https://twitter.com/twostraws):

> *"Take the time to clean up your tests so you isolate common setup, then add custom assertion functions to avoid repeating yourself. The end result will be shorter tests that are easier to read, easier to write, and easier to check when they fail."* - Paul

## Some or None?

Optionality as great as it is can sometimes be bothersome to tackle. However, why would you take care of it in your application's code but ignore it in its tests?

I could be writing about this, but instead, I will ask you to read John Sundell's [article](https://www.swiftbysundell.com/posts/avoiding-force-unwrapping-in-swift-unit-tests) about this subject. My opinion is quite the same as his so I think we should apply DRY here! 😂

## Conclusion

Tests' code quality must be as high as in your application as you'll be spending hours creating, maintaining and debugging them, so make sure you create a healthy environment around it. Also, be as coherent as possible and use all the tools in your belt, from design patterns to principles. Don't disregard your tests, they are an essential part of your codebase!

For further reading, [Paul](https://twitter.com/twostraws) recommends ["XUnit Test Patterns: Refactoring Test Code"](http://xunitpatterns.com/) by Gerard Meszaros.

 Huge shoutout to [José Figueiredo](https://twitter.com/ZeMiguelFig), [Paul Hudson](https://twitter.com/twostraws), [Rodrigo López-Romero](https://twitter.com/rlrg_6) and [Tiago Martinho](https://twitter.com/martinho_t) for joining me. I would also like to praise [Ana Filipa Ferreira](https://twitter.com/anafpf3), [Heitor Ferreira](https://www.linkedin.com/in/heitormpf) and [Tiago Silva](https://twitter.com/tiagomssilvaa) for their outstanding support and [João Pereira](https://twitter.com/NSMyself) for giving the "Let's Talk About" original idea. ❤️

Last but not least, if you have any subject you would like to see covered and/or discussed, let me know here or on [Twitter](https://twitter.com/pedrommcarrasco)! 👀

Thanks for reading. ✨
