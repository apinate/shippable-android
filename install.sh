#!/bin/bash -e

apt-get clean
mv /var/lib/apt/lists /tmp
mkdir -p /var/lib/apt/lists/partial
apt-get clean

# ------------------------------------------------------
# --- Base pre-installed tools
apt-get update -qq
# Common, useful
DEBIAN_FRONTEND=noninteractive apt-get -y install build-essential
DEBIAN_FRONTEND=noninteractive apt-get -y install zip unzip
DEBIAN_FRONTEND=noninteractive apt-get -y install tree
# For PPAs
DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common

# RUN gem install bundler --no-document

# # ------------------------------------------------------
# # --- Update Rubygems

# RUN gem update --system --no-document

echo "=============== Installing Node v. 6.x ============="
. /root/.nvm/nvm.sh && nvm install 6.9.1

echo "Dependencies to execute Android builds"
dpkg --add-architecture i386
apt-get update -qq

DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-8-jdk libc6:i386 libstdc++6:i386 libgcc1:i386 libncurses5:i386 libz1:i386

# ------------------------------------------------------
echo "--- Download Android SDK tools into $ANDROID_HOME"

cd /opt && wget -q https://dl.google.com/android/repository/tools_r25.2.5-linux.zip -O android-sdk-tools.zip
cd /opt && unzip -q android-sdk-tools.zip
mkdir -p ${ANDROID_HOME}
cd /opt && mv tools/ ${ANDROID_HOME}/tools/
cd /opt && rm -f android-sdk-tools.zip

echo "--- Install Android SDKs and other build packages"

# Other tools and resources of Android SDK
#  you should only install the packages you need!
# To get a full list of available options you can use:
#  sdkmanager --list

# Accept "android-sdk-license" before installing components, no need to echo y for each component
# License is valid for all the standard components in versions installed from this file
# Non-standard components: MIPS system images, preview versions, GDK (Google Glass) and Android Google TV require separate licenses, not accepted there
mkdir -p ${ANDROID_HOME}/licenses
echo 8933bad161af4178b1185d1a37fbf41ea5269c55 > ${ANDROID_HOME}/licenses/android-sdk-license

echo "Platform tools"
sdkmanager "platform-tools"

echo "SDKs"
# Please keep these in descending order!
sdkmanager "platforms;android-23"

echo "build tools"
# Please keep these in descending order!
sdkmanager "build-tools;23.0.1"

echo "Extras"
sdkmanager "extras;android;m2repository"
sdkmanager "extras;google;m2repository"
sdkmanager "extras;google;google_play_services"

echo "Constraint Layout"
# Please keep these in descending order!
sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2"
sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1"

echo "google apis"
# Please keep these in descending order!
sdkmanager "add-ons;addon-google_apis-google-23"
sdkmanager "add-ons;addon-google_apis-google-22"
sdkmanager "add-ons;addon-google_apis-google-21"

echo "--- Install Gradle from PPA"

# Gradle PPA
apt-get update
apt-get -y install gradle
gradle -v

echo "--- Install Maven 3 from PPA"

apt-get purge maven maven2
apt-get update
apt-get -y install maven
mvn --version

echo "Cleaning"
apt-get clean
