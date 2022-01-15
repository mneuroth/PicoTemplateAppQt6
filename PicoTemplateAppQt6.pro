QT += quick

SOURCES += \
        main.cpp

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

resources11.files = images/floppy-disk.svg
resources11.prefix = /$${TARGET}
resources12.files = images/open-folder-with-document.svg
resources12.prefix = /$${TARGET}


RESOURCES += resources resources1 resources2 resources3 resources4 resources5 resources6 resources7 resources8 resources9 resources10 resources11 resources12

RESOURCES += qml.qrc

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
