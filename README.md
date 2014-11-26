# DemoNotes: Demonstration of iOS 8 "today" and "share" extensions.

This project is a sample of how to create iOS "today" and "share" extensions. The sequence of commits in the repository demonstrates various steps in the process.

The central app is a trivial text notes app. The UI is simply the standard master/detail layout created using one of Xcode's project templates. The master view displays a list of notes. Tapping on one displays a text view that can be used to edit the note content. The app is intentionally simplistic in order to keep this repository focused on the process of developing app extensions.

The basic text notes app is complete as of commit [a32cf84](https://github.com/atomicbird/iOS-Extension-Demo/commit/a32cf84c5f56aee3fe2d41b412669cecd75679a7). The commits then go through the process of adding a today extension which also displays notes and a share extension that can be used to create new notes from other iOS apps. When complete,

* The today extension displays data shared with the app
* The today extension communicates with the app via a custom URL scheme so that users can launch the app to edit selected text notes
* The share extension allows adding custom notes from other apps, e.g. Safari.

The project then goes through the following steps:

* [**Today extension template**](https://github.com/atomicbird/iOS-Extension-Demo/commit/15889ce01e46f4e605deb5fb3bb537340d3ed588). Add a today extension target in Xcode, but don't make any changes to it. This creates a working today extension with a default "Hello, World" UI.
* [**Fix today extension name**](https://github.com/atomicbird/iOS-Extension-Demo/commit/82727bea9da829021b57bad29fe38d8fb9876f98). Change the display name for the today extension to be more descriptive when it appears in the iOS notification center. The only significant change is to `Info.plist`.
* [**Build today extension UI**](https://github.com/atomicbird/iOS-Extension-Demo/commit/2d99aa61de1d0cc321f8847fcda50af831420094). Replace the default today extension UI with a table view UI to match the app. This UI is non-functional at this point, since there's no code to support it yet.
* [**Add a custom framework**](https://github.com/atomicbird/iOS-Extension-Demo/commit/2dc85b5f43e16751f694c84aee8b8dc7cbdb9f5d) to hold code that will be shared between the app and the extensions (in this case only the `DemoNote` model object). Change the app to `#import` the framework header instead of the shared code header.
* [**Enable app groups to share data**](https://github.com/atomicbird/iOS-Extension-Demo/commit/3f05d632729622c24b73d171a5a5db2bc14314b7). There are no code changes here, but there are a couple of news entitlements files and corresponding project file changes. These correspond with Xcode communicating with Apple's developer center to configure the app ID and generate custom provisioning profiles that include the new entitlements.
* [**Use the app group in the app**](https://github.com/atomicbird/iOS-Extension-Demo/commit/38c3efc95099044c752de6d98bfae9da5a36bfb5). Change the existing app code to read/write data via the new app group instead of using its private documents directory.
* [**Add today extension code**](https://github.com/atomicbird/iOS-Extension-Demo/commit/2cbde1da38dedcc9a620edbc25a086743d333e0f). This adds code similar to the app to load and display notes. It also adds the shared framework to the today extension and-- importantly-- tells Xcode that the framework should only use extension-safe APIs.
* [**Add a URL scheme so extensions can call back to the app**](https://github.com/atomicbird/iOS-Extension-Demo/commit/dc5e4eafefc66a0d9e4a3008a9c0ac20073065f0). The URL scheme is in the app, and can be used by app extensions. In this case it's used by the today extension to launch the app and to tell it which note the user tapped on. The app displays that note.
* [**Share extension template**](https://github.com/atomicbird/iOS-Extension-Demo/commit/e9a638cf098ce16c6c5332bf937307e2984c5ad1). Add a share extension target in Xcode, but don't make any changes to it. This creates a share extension which uses `SLComposeServiceViewController` to display a UI similar to the built-in share extensions for Twitter, Facebook, etc.
* [**Add share extension code**](https://github.com/atomicbird/iOS-Extension-Demo/commit/c7a7a8589cad98cfd39de98c4ddde6954c066ebe). This adds a JavaScript preprocessing file which is used when the share extension is invoked from Safari. The JS code extracts various items of interest, such as the selected text. The app extension code looks through this data to fill in the new note text. The default share extension UI is still in place.
* [**Keep data synchronized**](https://github.com/atomicbird/iOS-Extension-Demo/commit/0ea4e381426e04696dee37ba0972dac1ba6aa5a7). Update the app to make it more aware of the share extension. Since new notes can now be added from outside the app, the app needs to be sure to check for new notes when the app enters the foreground.
* [**Custom share extension UI**](https://github.com/atomicbird/iOS-Extension-Demo/commit/e95872ff45317e9877d98b3f2d2f629e46c99ba5). Replace the standard `SLComposeServiceViewController`-based UI with a custom UI. Partly because there's no API to change the text on the share UI's "Post" button, and partly just because I can. It's still a share extension, though it's not using the standard UI anymore.
* [**Better data synchronization**](https://github.com/atomicbird/iOS-Extension-Demo/commit/ef596032db004019bc9626b5d0db819c368aa234). Update file reading/writing to use coordinated reads and file presenters to keep app and extension data in sync. With this change the app doesn't check for changes when coming to the foreground. Instead it's notified that changes are available, thanks to `NSFilePresenter`.
* [**Convert to Core Data**](https://github.com/atomicbird/iOS-Extension-Demo/commit/04bd9d519d1b26096a55ce86fa5869d2a4eb812d). This commit replaces the simple file-based data model with Core Data. Data is still shared locally via the app group, and coordinated writes are used to notify the app of changes made in the share extension.

This isn't a comprehensive list of commits, see [the full list](https://github.com/atomicbird/iOS-Extension-Demo/commits/master) if you're interested.

# Credits

By Tom Harrington, @atomicbird on most social networks.
