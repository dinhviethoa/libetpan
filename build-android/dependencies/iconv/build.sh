#!/bin/sh

version=1.15
build_version=1
package_name=iconv-android
current_dir="`pwd`"

if test "x$ANDROID_NDK" = x ; then
  echo should set ANDROID_NDK before running this script.
  exit 1
fi

if test ! -f $current_dir/build-android/$package-name-$build_version.zip; then
  if test ! -f $current_dir/build-android/libiconv-$version.tar.gz; then
    cd "$current_dir/build-android"
    curl -O http://ftp.gnu.org/gnu/libiconv/libiconv-$version.tar.gz
    cd ..
  fi
  rm -rf "$current_dir/build-android/obj"
  rm -rf "$current_dir/build-andnroid/libiconv"
  cd "$current_dir/build-android"
  tar xzf "$current_dir/build-android/libiconv-$version.tar.gz"
  mv -v "$current_dir/build-android/libiconv-$version" "$current_dir/build-android/libiconv"
  cd "$current_dir/build-android/libiconv"
  ./configure
  cd ../
fi 

mkdir -p "$current_dir/$package_name-$build_version/libs/$arch_dir_name"
cp -r "$current_dir/build-android/libiconv/include" "$current_dir/$package_name-$build_version"

function build {
  cd "$current_dir/build-android" 
  $ANDROID_NDK/ndk-build TARGET_PLATFORM=$ANDROID_PLATFORM TARGET_ARCH_ABI=$TARGET_ARCH_ABI
  mkdir -p "$current_dir/$package_name-$build_version/libs/$TARGET_ARCH_ABI"
  cp "$current_dir/build-android/obj/local/$TARGET_ARCH_ABI/libiconv.a" "$current_dir/$package_name-$build_version/libs/$TARGET_ARCH_ABI"
}

mkdir -p "$current_dir/$package_name-$build_version"

# Start building.
ANDROID_PLATFORM=android-16
archs="armeabi armeabi-v7a x86"
for arch in $archs ; do
  TARGET_ARCH_ABI=$arch
  build
done
ANDROID_PLATFORM=android-21
archs="arm64-v8a"
for arch in $archs ; do
  TARGET_ARCH_ABI=$arch
  build
done

cd "$current_dir"
zip -qry "$package_name-$build_version.zip" "$package_name-$build_version"
rm -rf "$package_name-$build_version"
