# MBA Hybrid build script

## How it works?

I created this script to make the build process faster for the hybrid app. It is a simple script that do the following 
steps:

### How to run hybrid app

- Build bundle from mba-react-native project
    - to build bundle use: `nx bundle-ios`
    - The bundle is generated at `dist/apps/mobile/ios/main.jsbundle`
- Copy bundle to `mba-ios/MobileBanking/Modules/ReactNative`
- Search for AppNavigation.swift file
    - Inside it search for `CustomRCTViewController`
    - Change it to this code:
```swift
  case .accounts, .myAccountsWidget:
  controller = CustomRCTViewController(feature: "accounts", useFSG: true)
```
* _Remove all the switch case (the if-else)_

### How to build and test the hybrid code

1. Update `mba-react-native` (work as normal in the react native code)
2. Generate the bundle and move it to the project (check How to run hybrid app step 1 and 2)
3. Stop the project in Xcode
4. Clean the build folder
    1. Sometimes you may need to close the simulator and Xcode to run it. Do this if when trying to rebuild the project it 
keeps hanging in the splash screen
5. Rebuild the project (hit play button on Xcode)

So, the script simplifies the steps. It do everything in the _"How to build and test the hybrid code"_ automatically. It will 
open up a clean xcode without cache so you just need to hit **Play**.

# Important Notes

- The script is built in mind that it will run in the root folder where both repositories are (`mba-react-native` and 
`mba-ios`). For example, you will have the following structure:

```
  - User/
    | - Development/
        | - build.sh
        | - mba-react-native/
        | - mba-ios/
```

- You need to update the script with the paths if needed. Again, this was thought for a specific structure and folders may 
vary.
- It always delete the cache and reopen the xcode due to a bug I found when building the hybrid app. If you want to save 
some time and avoid these steps, the code is commented so you can do it.
