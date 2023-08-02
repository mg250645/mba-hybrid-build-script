#!/bin/sh

# 0. Tell the script to run with a production or dev environment
prod_flag=false

while test $# -gt 0; do
  case "$1" in
    --production*)
      echo "Running a production build"
      prod_flag=true
      break
      ;;
    *)
      echo "Running a development build"
      break
      ;;
  esac
done

# 1. Generate the bundle and move it to the mba-ios project
echo "Generating bundle..."
cd mba-react-native
if [ prd_flag == 'true' ]
then
  nx bundle-ios --dev=false --reset-cache
else
  nx bundle-ios
fi

cd ..

if [ -e mba-ios/MobileBanking/Modules/ReactNative/main.jsbundle ]
then
  echo "Removing previous bundle"
  rm mba-ios/MobileBanking/Modules/ReactNative/main.jsbundle
else
  echo "Previous bundle didn't exists"
fi

cp mba-react-native/dist/apps/mobile/ios/main.jsbundle mba-ios/MobileBanking/Modules/ReactNative/main.jsbundle

if [ -e mba-ios/MobileBanking/Modules/ReactNative/main.jsbundle ]
then
  echo "File copied successfully"
fi

cd ..

# 2. Stop the project in Xcode
echo "Killing xcode..."
kill $(ps aux | grep 'Xcode' | awk '{print $2}')

# 3. Clean the build folder and restart simulator
echo "Deleting xcode cache..."
rm -R ~/Library/Developer/Xcode/DerivedData/*
xcrun simctl shutdown all

# 4. Rebuild the project
echo "Opening xcode project again!"
# open ~/Development/mba-ios/MobileBanking/MobileBanking.xcodeproj
cd ~/Development/mba-ios/
xed .
