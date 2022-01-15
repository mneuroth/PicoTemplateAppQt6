QT += quick svg printsupport

SOURCES += \
        main.cpp \
        applicationdata.cpp

HEADERS += \
        applicationdata.h

resources.files = main.qml 
resources.prefix = /$${TARGET}
resources1.files = AboutDialog.qml
resources1.prefix = /$${TARGET}
resources2.files = AboutDialogForm.ui.qml
resources2.prefix = /$${TARGET}
resources3.files = MobileFileDialog.qml
resources3.prefix = /$${TARGET}
resources4.files = MobileFileDialogForm.ui.qml
resources4.prefix = /$${TARGET}
resources5.files = pico.png
resources5.prefix = /$${TARGET}
resources6.files = HomeForm.ui.qml
resources6.prefix = /$${TARGET}
resources7.files = SettingsDialog.qml
resources7.prefix = /$${TARGET}
resources8.files = SettingsDialogForm.ui.qml
resources8.prefix = /$${TARGET}
resources9.files = Page1Form.ui.qml
resources9.prefix = /$${TARGET}
resources10.files = Page2Form.ui.qml
resources10.prefix = /$${TARGET}

resources21.files = images/floppy-disk.svg
resources21.prefix = /
resources22.files = images/open-folder-with-document.svg
resources22.prefix = /
resources23.files = images/menu.svg
resources23.prefix = /
resources24.files = images/menu_bars.svg
resources24.prefix = /
resources25.files = images/back.svg
resources25.prefix = /
resources26.files = images/share.svg
resources26.prefix = /
resources27.files = images/search.svg
resources27.prefix = /
resources28.files = images/replace.svg
resources28.prefix = /
resources29.files = images/settings.svg
resources29.prefix = /
resources30.files = images/close.svg
resources30.prefix = /
resources31.files = images/left-arrow.svg
resources31.prefix = /
resources32.files = images/right-arrow.svg
resources32.prefix = /
resources33.files = images/back-arrow.svg
resources33.prefix = /
resources34.files = images/redo-arrow.svg
resources34.prefix = /
resources35.files = images/file96.svg
resources35.prefix = /
resources36.files = images/new104.svg
resources36.prefix = /

RESOURCES += resources resources1 resources2 resources3 resources4 resources5 resources6 resources7 resources8 resources9 resources10 #resources11 resources12
RESOURCES += resources21 resources22 resources23 resources24 resources25 resources26 resources27 resources28 resources29 resources30 resources31 resources32 resources33 resources34 resources35 resources36

#RESOURCES += qml.qrc

TRANSLATIONS += \
    PicoTemplateAppQt6_de_DE.ts
CONFIG += lrelease
CONFIG += embed_translations

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    android/AndroidManifest.xml \
    android/build.gradle \
    android/gradle.properties \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew \
    android/gradlew.bat \
    android/res/values/libs.xml

contains(ANDROID_TARGET_ARCH,arm64-v8a) {
    ANDROID_PACKAGE_SOURCE_DIR = \
        $$PWD/android
}
