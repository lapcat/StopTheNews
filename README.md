# StopTheNews

StopTheNews is an app for macOS 10.14 Mojave that automatically handles Apple News URLs instead of News app. If you open an Apple News URL in Safari, StopTheNews will then open the original article page in Safari instead of sending it to News app. StopTheNews also works with Safari Technology Preview, if that is your default web browser.

## Installing

1. Download the [latest release](https://github.com/lapcat/StopTheNews/releases/latest).
2. Unzip the downloaded `.zip` file.
3. Move `StopTheNews.app` to your Applications folder.
4. Open `StopTheNews.app`.
5. Quit `StopTheNews.app`.

## Uninstalling

1. Move `StopTheNews.app` to the Trash.

## Building

Building StopTheMadness from source requires Xcode 10.

Before building, you need to create a file named `DEVELOPMENT_TEAM.xcconfig` in the project folder (the same folder as `Shared.xcconfig`). This file is excluded from version control by the project's `.gitignore` file, and it's not referenced in the Xcode project either. The file specifies the build setting for your Development Team, which is needed by Xcode to code sign the app. The entire contents of the file should be of the following format:
```
DEVELOPMENT_TEAM = [Your TeamID]
```

## Author

[Jeff Johnson](https://lapcatsoftware.com/)

To support the author, please consider buying the Safari extension StopTheMadness in the [Mac App Store](https://itunes.apple.com/app/stopthemadness/id1376402589?mt=12).

## Copyright

StopTheNews is Copyright © 2019 Jeff Johnson. All rights reserved.

## License

See the [LICENSE.txt](LICENSE.txt) file for details.
