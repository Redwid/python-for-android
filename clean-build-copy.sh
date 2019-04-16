#!/usr/bin/env bash
#
# Set up instructions for MacOS (10.14)
#  1. Set up your ANDROID_HOME directory:
#         export ANDROID_HOME=/Users/{your_user_name_here}/Library/Android/sdk
#         source ~/.bash_profile
# 2. Install gcc:
#         brew install gcc
# 3. Install the macOS_SDK_headers_for_macOS_10.14.pkg: https://github.com/frida/frida/issues/338#issuecomment-424595668
#         cd /Library/Developer/CommandLineTools/Packages/
#         open macOS_SDK_headers_for_macOS_10.14.pkg
# 4. Install llvm:
#         brew install llvm
# 5. Install XCode
# 6. Download NDK r16b: https://developer.android.com/ndk/downloads/older_releases?hl=zh-tw
#         set $ANDROID_NDK_HOME value below pointed to unpacked NDK r16b folder
#


#enviroment set up
export PYTHONIOENCODING=UTF-8
export PYTHONUNBUFFERED=1
export VERSIONER_PYTHON_VERSION=2.7
export PYTHONPATH=$PWD
export ANDROIDAPI="23"
export NDKAPI="23"

if [ -z "$ANDROID_NDK_HOME" ]
then
    export ANDROID_NDK_HOME=~/Downloads/android-ndk-r16b
fi

#script set up
p4a="$PWD/pythonforandroid/toolchain.py"
pythonApp="$(dirname "$PWD")/youtube-dl/youtube_dl"
pythonAppDistName="youtube_dl_wrapper"
pythonAppPackageName="org.youtube.dl"
pythonAppName="youtube_dl"

#Check if we are running on travis
if [ -z "$TRAVIS" ]
then
    distFolder="$HOME/.python-for-android/dists/$pythonAppDistName"
else
    distFolder="$HOME/.local/share/python-for-android/dists/$pythonAppDistName"
fi

echo "pythonApp: ${pythonApp}"
echo "distFolder: ${distFolder}"

#Link for android-youtube-dl project to where script will copy build artifacts
androidYoutubeDlProject="$(dirname "$PWD")/android-youtube-dl"


clean() {
    echo "[INFO]     Clean"
    python $p4a clean_builds
    rm -rf $distFolder
    rm -rf $PWD/build
    echo "[INFO]     Clean done"
}


build() {
    echo "[INFO]     Build [$1]"
    python $p4a clean_builds
    rm -rf $distFolder
    python $p4a apk --private $pythonApp --dist_name=$pythonAppDistName --package=$pythonAppPackageName --name=$pythonAppName --version=1 --ndk_dir $ANDROID_NDK_HOME --ndk_version r16b --requirements=android,pyopenssl,pycrypto,openssl --android_api=23 --arch=$1 --java-build-tool gradle
#    if [ -z "$TRAVIS" ]
#    then
#        copy_libs
#        copy_assets
#    else
        copy_assets_and_make_aar $1
#    fi
    echo "[INFO]     Build [$1] done"
}


copy_libs() {
    mkdir $PWD/build
    cp -rfv $distFolder/libs/ $PWD/build/libs/
}


copy_assets() {
    cp -rfv $distFolder/src/main/assets/ $PWD/build/assets
    rm $PWD/build/assets/.gitkeep

    delete_unused_assets "armeabi-v7a"
    #delete_unused_assets "x86"
    delete_unused_assets "arm64-v8a"
}


delete_unused_assets() {
    rm $PWD/build/libs/$1/libSDL2.so
    rm $PWD/build/libs/$1/libSDL2_image.so
    rm $PWD/build/libs/$1/libSDL2_mixer.so
    rm $PWD/build/libs/$1/libSDL2_ttf.so
}


copy_assets_to_androidYoutubeDlProject() {
    cp -rfv $PWD/build/assets/ $androidYoutubeDlProject/lib/src/main/assets
    cp -rfv $PWD/build/libs/   $androidYoutubeDlProject/lib/src/main/jniLibs
}


copy_assets_and_make_aar() {
    echo "[INFO]     Copy assets [$1]"
    #Copy *.so files
    mkdir $PWD/build
    mkdir $PWD/build/$1
    mkdir $PWD/build/$1/jni
    mkdir $PWD/build/$1/jni/$1
    cp -rfv $distFolder/libs/$1 $PWD/build/$1/jni
    rm $PWD/build/$1/jni/$1/libSDL2.so
    rm $PWD/build/$1/jni/$1/libSDL2_image.so
    rm $PWD/build/$1/jni/$1/libSDL2_mixer.so
    rm $PWD/build/$1/jni/$1/libSDL2_ttf.so

    #Copy *.mp3 file
    mkdir $PWD/build/$1/assets
    cp -rfv $distFolder/src/main/assets/private.mp3 $PWD/build/$1/assets/private-$1.mp3
    echo "[INFO]     Copy assets [$1] done"

    echo "[INFO]     Make aar [$1]"
    #Create aar file
    root=$PWD
    cd $root/build/$1
    zip $root/build/$1.aar -r ./*
    cd $root
    echo "[INFO]     Make aar [$1] done"
}


clean

build "armeabi-v7a"
#build "x86"
build "arm64-v8a"

#copy_assets_to_androidYoutubeDlProject
echo "[INFO]     Build done"
