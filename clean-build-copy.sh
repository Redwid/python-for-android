#!/usr/bin/env bash
#enviroment set up
export PYTHONIOENCODING=UTF-8
export PYTHONUNBUFFERED=1
export VERSIONER_PYTHON_VERSION=2.7
export PYTHONPATH=$PWD

#script set up
p4a="$PWD/pythonforandroid/toolchain.py"
pythonApp="$(dirname "$PWD")/youtube-dl/youtube_dl"
pythonAppDistName="youtube_dl_wrapper"
pythonAppPackageName="org.youtube.dl"
pythonAppName="youtube_dl"
distFolder="$HOME/.python-for-android/dists/$pythonAppDistName"
ndkDir=~/Library/Android/sdk/ndk-bundle

#Link for android-youtube-dl project to where script will copy build artifacts
androidYoutubeDlProject="$(dirname "$PWD")/android-youtube-dl"

clean() {
echo "[INFO]     Clean"
/usr/bin/python $p4a clean_builds
rm -rfv $distFolder
rm -rfv $PWD/build
echo "[INFO]     Clean done"
}

build() {
echo "[INFO]     Build [$1]"
/usr/bin/python $p4a clean_builds
rm -rfv $distFolder
/usr/bin/python $p4a apk --private $pythonApp --dist_name=$pythonAppDistName --package=$pythonAppPackageName --name=$pythonAppName --version=1 --ndk_dir $ndkDir --ndk_version r16b --requirements=android,pyopenssl,pycrypto,openssl --android_api=23 --arch=$1 --java-build-tool gradle
copy_libs
copy_assets
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
delete_unused_assets "x86"
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

clean

build "armeabi-v7a"
build "x86"
build "arm64-v8a"

copy_assets_to_androidYoutubeDlProject
echo "[INFO]     Build done"
