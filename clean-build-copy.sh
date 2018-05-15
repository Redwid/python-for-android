#!/usr/bin/env bash
#enviroment set up
export PYTHONIOENCODING=UTF-8
export PYTHONUNBUFFERED=1
export VERSIONER_PYTHON_VERSION=2.7
export PYTHONPATH=$PWD

#script set up
p4a="$PWD/pythonforandroid/toolchain.py"
#pythonApp="~/Projects/git/youtube-dl/youtube_dl"
pythonApp="$(dirname "$PWD")/youtube-dl/youtube_dl"
pythonAppDistName="youtube_dl_wrapper"
pythonAppPackageName="org.youtube.dl"
pythonAppName="youtube_dl"
distFolder="$HOME/.python-for-android/dists/$pythonAppDistName"
ndkDir=~/Library/Android/sdk/ndk-bundle

clean() {
/usr/bin/python $p4a clean_builds
rm -rfv $distFolder
}

build() {
/usr/bin/python $p4a apk --private $pythonApp --dist_name=$pythonAppDistName --package=$pythonAppPackageName --name=$pythonAppName --version=1 --ndk_dir $ndkDir --ndk_version r16b --requirements=android,pyopenssl,pycrypto,openssl --android_api=23 --arch=$1 --java-build-tool gradle
}

copy_libs() {
mkdir $PWD/build
cp -rfv $distFolder/libs/ $PWD/build/libs/
}

copy_assets() {
cp -rfv $distFolder/src/main/assets/ $PWD/build/assets
rm $PWD/build/assets/.gitkeep
}

echo "[INFO]     Clean"
clean
rm -rfv $PWD/build
echo "[INFO]     Clean done"

echo "[INFO]     Build [arm64-v8a]"
build "arm64-v8a"
copy_libs
copy_assets
echo "[INFO]     Build [arm64-v8a] done"

echo "[INFO]     Build [armeabi-v7a]"
clean
build "armeabi-v7a"
copy_libs
echo "[INFO]     Build [armeabi-v7a] done"

echo "[INFO]     Build done"