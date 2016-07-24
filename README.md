# PDX-Cocoaheads.com

This is the source code behind [pdxcocoaheads.com](http://pdxcocoaheads.com).

# Contributing

If you'd like to add features, fix typos on the site or implement one of our [issues](https://github.com/pdx-cocoaheads/pdxcocoaheads.com/issues); Pull requests are welcome! Read on for how to get the project set up to build locally.

## Building the app

The site is built using [Vapor](https://github.com/qutheory/vapor), head there for documentation on how to do things within the framework.

### Command Line

If you have the [Vapor Toolbox](https://github.com/qutheory/vapor-toolbox) installed, run `vapor build` and `vapor run`.

Otherwise, run `swift build` to compile the application, then run `.build/debug/App`.

Once the app is running open a browser and head to [http://localhost:8080](http://localhost:8080)!

### Xcode 8

If you want to use Xcode you'll need to create and maintain your own Xcode Project file (it is in the .gitignore). [Vapor Toolbox](https://github.com/qutheory/vapor-toolbox) has a handy command to generate one for you: `vapor xcode`. Once you've done that, you can open the project in Xcode and choose the "App" target and build/run/debug from Xcode.

Open a browser and head to [http://localhost:8080](http://localhost:8080)!
