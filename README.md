# StopTheNews

StopTheNews is an app for macOS (10.14 Mojave or later) that automatically handles Apple News URLs instead of News app. If you allow Safari to open an Apple News URL in StopTheNews, the original article will then open in Safari instead of News app. StopTheNews also works with Safari Technology Preview, if that is your default web browser.

StopTheNews now also handles Mac App Store URLs instead of App Store app. If you allow Safari to open a Mac App Store URL in StopTheNews, the app's page will then open in App Store. This lets you stop App Store from automatically opening.

## Installing

1. On macOS Big Sur, download the [latest release](https://github.com/lapcat/StopTheNews/releases/latest). On macOS Catalina or Mojave, download [version 2.2](https://github.com/lapcat/StopTheNews/releases/tag/v2.2).
2. Unzip the downloaded `.zip` file.
3. Move `StopTheNews.app` to your Applications folder.
4. Open `StopTheNews.app`.
5. Quit `StopTheNews.app`.

## Uninstalling

1. Move `StopTheNews.app` to the Trash.

## Known Issues

- Some Apple News pages don't provide the original article URL. The articles are designed to be displayed inline on `apple.news`. In these cases, StopTheNews offers the option to open the article in News app.

## Building

Building StopTheMadness from source requires Xcode 10 or later.

Before building, you need to create a file named `DEVELOPMENT_TEAM.xcconfig` in the project folder (the same folder as `Shared.xcconfig`). This file is excluded from version control by the project's `.gitignore` file, and it's not referenced in the Xcode project either. The file specifies the build setting for your Development Team, which is needed by Xcode to code sign the app. The entire contents of the file should be of the following format:
```
DEVELOPMENT_TEAM = [Your TeamID]
```

## Author

[Jeff Johnson](https://lapcatsoftware.com/)

To support the author, you can [PayPal.Me](https://www.paypal.me/JeffJohnsonWI) or buy the Safari extension StopTheMadness in the [Mac App Store](https://apps.apple.com/app/stopthemadness/id1376402589?mt=12).

## Copyright

StopTheNews is Copyright © 2019 Jeff Johnson. All rights reserved.

## License

See the [LICENSE.txt](LICENSE.txt) file for details.
