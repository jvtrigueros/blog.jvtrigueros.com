---
layout: post
title: 'Java Localization: Indonesia'
---

Recently, I went through the exercise of externalizing the strings on a Discord bot, [pawa](https://pawa.im), so that
I can provide different translations. Since this is a JVM code base, the preferred path is to use a
[`ResourceBundle`](https://docs.oracle.com/javase/tutorial/i18n/resbundle/concept.html). This would allow me to have
different Properties files for each of the languages that the application would support, and as long as these Properties
files are located in the classpath, the `getBundle` method will find the correct one to load.

In a contrived example, this is how it would work:
```kotlin
fun main() {
  // Default Bundle
  var bundle = ResourceBundle.getBundle("strings")
  var greeting = bundle.getString("greeting")

  println("greeting = $greeting")
  //=> greeting = hello

  // Spanish Bundle
  bundle = ResourceBundle.getBundle("strings", Locale("es"))
  greeting = bundle.getString("greeting")

  println("greeting = $greeting")
  //=> greeting = hola
}
```

You can use built in locales such as `Locale.CHINESE` or you can specify your own as I did in the example above. The only
requirement is that you stick to the [ISO-639](https://en.wikipedia.org/wiki/List_of_ISO_639-2_codes) language codes. While
the Locale constructor will accept 2-letter codes, it's best to use the 3-letter code as it's less ambiguous.

### Incorrect Indonesian Language Code

When I was adding support for the Indonesian language, I made the mistake of using the language code `id` code. I structured
my resources as follows:

```
❯ exa -T src/main/resources
src/main/resources
├── strings.properties
├── strings_es.properties
└── strings_id.properties
```

> I did that because if you go to the [Indonesian language](https://en.wikipedia.org/wiki/Indonesian_language) wikipedia page, it that the code is `id`.

And this is the code snippet with the result:

```kotlin
  // Indonesian Bundle
  bundle = ResourceBundle.getBundle("strings", Locale("id"))
  greeting = bundle.getString("greeting")

  println("greeting = $greeting")
  //=> greeting = hello
```

🤔 hmmm, the result should've been `greeting = halo`, however that's not what I was seeing here.

This was confusing because, the locale object was correctly printing out the right language:

```kotlin
Locale("id").displayName //=> Indonesian
```

So what was going on?

### Read the Docs

In the [`Locale`](https://docs.oracle.com/javase/8/docs/api/java/util/Locale.html) documentation there's a line that talks about deprecated ISO codes:

> Deprecated ISO language codes "iw", "ji", and "in" are converted to "he", "yi", and "id", respectively. 

Which appears in the private static method `Locale.convertOldISOCodes`

```java
private static String convertOldISOCodes(String language) {
    // we accept both the old and the new ISO codes for the languages whose ISO
    // codes have changed, but we always store the OLD code, for backward compatibility
    language = LocaleUtils.toLowerString(language).intern();
    if (language == "he") {
        return "iw";
    } else if (language == "yi") {
        return "ji";
    } else if (language == "id") {
        return "in";
    } else {
        return language;
    }
}
```

The confusing part was that I wasn't specifying `in` but rather `id`. So something somewhere was over correcting for me, as we can see in the function
above, `id` is converted to `in`.

So...could I rename the resource `strings_id.properties` to `strings_in.properties` and call it a day? Let's try it!

```
❯ exa -T src/main/resources
src/main/resources
├── strings.properties
├── strings_es.properties
└── strings_in.properties
```

```kotlin
  // Indonesian Bundle
  bundle = ResourceBundle.getBundle("strings", Locale("id"))
  greeting = bundle.getString("greeting")

  println("greeting = $greeting")
  //=> greeting = halo
```

**AHA!**

### Solution

So while that works, it's misleading and may cause errors if...when I forget why I did that in the first place, so my final solution is to use the 3-letter
code as specified in the ISO-639-2 Standard. Finally landing on this:

```
❯ exa -T src/main/resources
src/main/resources
├── strings.properties
├── strings_es.properties
└── strings_ind.properties
```

```kotlin  // Indonesian Bundle
  bundle = ResourceBundle.getBundle("strings", Locale("ind"))
  greeting = bundle.getString("greeting")

  println("greeting = $greeting")
  //=> greeting = halo
```
