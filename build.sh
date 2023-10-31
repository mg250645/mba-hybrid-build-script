#!/bin/sh

prod_flag=false
unset -v platform

usage() {
  echo "build --platform (ios|android) [--production]"
  echo " "
  echo "options:"
  echo "-h, --help                show brief help"
  echo "--platform PLATFORM       (required) specify the platform to build"
  echo "-p, --production          creates a production-like build"
}

has_argument() {
    [[ ("$1" == *=* && -n ${1#*=}) || ( ! -z "$2" && "$2" != -*)  ]];
}

# TODO: Improve the android flow
function android_build () {
  if [ prod_flag = true ]
  then
    echo "Creating Android production bundle"
    nx bundle-android --dev=false --reset-cache
  else
    nx bundle-android # --dev=false --reset-cache
  fi

  cd ..

  if [ -e cma-android/BankingSolution/mobile/assets/main.jsbundle ]
  then
    echo "Removing previous bundle"
    rm cma-android/BankingSolution/mobile/assets/main.jsbundle
  else
    echo "Previous bundle didn't exists"
  fi

  cp mba-react-native/dist/apps/mobile/android/main.jsbundle cma-android/BankingSolution/mobile/assets/main.jsbundle

  if [ -e mba-ios/MobileBanking/Modules/ReactNative/main.jsbundle ]
  then
    echo "File copied successfully"
  fi

  cd ..

  # open android studio if it is not open
  open -a /Applications/Android\ Studio.app cma-android/BankingSolution
}

function ios_build () {
  if [ prod_flag = true ]
  then
    echo "Creating iOS production bundle"
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

  echo "Killing xcode..."
  kill $(ps aux | grep 'Xcode' | awk '{print $2}')

  echo "Deleting xcode cache..."
  rm -R ~/Library/Developer/Xcode/DerivedData/*
  xcrun simctl shutdown all

  echo "Opening xcode project again!"
  # open ~/Development/mba-ios/MobileBanking/MobileBanking.xcodeproj
  cd ~/Development/mba-ios/
  xed .
}

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --platform*)
      if ! has_argument $@; then
        echo "Please provide a platform" >&2
        echo " "
        usage
        exit 1
      fi
        
      platform=$2

      shift
      ;;
    -p|--production)
        prod_flag=true
      shift
      ;;
    *)
      break
      ;;
  esac
done

if [ -z "$platform" ]
then
  echo 'Missing --platform (ios|android)' >&2
  echo " "
  usage
  exit 1
fi

echo "Generating ${platform} bundle..."
cd mba-react-native

if [[ "$platform" == "ios" ]]; then
  ios_build
else
  android_build
fi

echo "Wrapping up the build script..."