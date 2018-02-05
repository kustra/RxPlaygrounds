RxPlaygrounds
=============

Xcode playgrounds on iOS, with Cocoapods integrated.

You can use this workspace to quickly try out any RxSwift-based code of unclear behavior. The fastest way to use it:
1. Open RxPlaygrounds.xcworkspace in Xcode >= 9.
1. Select MyPlayground from the Project navigator.
1. Start scetching some ideas!

If you see the `No such module 'RxSwift'` error, just build the project once (⌘B) and the error should disappear.

In order to add a new playground to the project:
1. Create a new playground using _File > New > Playground..._
1. Place it in the repository root, next to `MyPlayground.playground`.
1. Xcode will open the new playground in a new window and won't add it to the RxPlaygrounds project. Close the window with the new playground, as we need to open it as part of the project.
1. Right Click on the RxPlaygrounds project in the Project navigator in Xcode, then click _Add files to "RxPlaygrounds"_.
1. Select the new playground in the dialog that pops up.
1. It should show up in the Project navigator, next to the other playgrounds in the project. Select it and you're good to go.

In order to add a new pod to the project:
1. Edit the `Podfile`.
1. Run `pod install`
1. Import any new modules that you'd like to use in `frameworks.swift` in the project.
1. Build the project once. (⌘B)
1. Use the new modules in any playground in the project.