// (c) 2017 Ekkehard Gentz (ekke) @ekkescorner
// my blog about Qt for mobile: http://j.mp/qt-x
// see also /COPYRIGHT and /LICENSE

#include "applicationui.hpp"

//#include <QtQml>
#include <QGuiApplication>
#include <QStandardPaths>

#include <QFile>
#include <QDir>

#if defined(Q_OS_ANDROID)
#if QT_VERSION < 0x060000
#include <QtAndroid>
#else
#include <QtCore/6.2.2/QtCore/private/qandroidextras_p.h>
#endif
#endif

const QString IMAGE_DATA_FILE = "/qt-logo.png";
const QString IMAGE_ASSETS_FILE_PATH = ":/data_assets/qt-logo.png";

const QString JPEG_DATA_FILE = "/crete.jpg";
const QString JPEG_ASSETS_FILE_PATH = ":/data_assets/crete.jpg";

const QString DOCX_DATA_FILE = "/test.docx";
const QString DOCX_ASSETS_FILE_PATH = ":/data_assets/test.docx";

const QString PDF_DATA_FILE = "/share_file.pdf";
const QString PDF_ASSETS_FILE_PATH = ":/data_assets/share_file.pdf";

const static int NO_RESPONSE_IMAGE = 0;
//const static int NO_RESPONSE_PDF = -1;
const static int NO_RESPONSE_JPEG = -2;
const static int NO_RESPONSE_DOCX = -3;

const static int EDIT_FILE_IMAGE = 42;
//const static int EDIT_FILE_PDF = 44;
const static int EDIT_FILE_JPEG = 45;
const static int EDIT_FILE_DOCX = 46;

const static int VIEW_FILE_IMAGE = 22;
//const static int VIEW_FILE_PDF = 21;
const static int VIEW_FILE_JPEG = 23;
const static int VIEW_FILE_DOCX = 24;

const static int SEND_FILE_IMAGE = 11;
//const static int SEND_FILE_PDF = 10;
const static int SEND_FILE_JPEG = 12;
const static int SEND_FILE_DOCX = 13;

ApplicationUI::ApplicationUI(QObject *parent)
    : QObject(parent),
      mShareUtils(new ShareUtils(this)),
      mPendingIntentsChecked(false)
{
    // this is a demo application where we deal with an Image and a PDF as example
    // Image and PDF are delivered as qrc:/ resources at /data_assets
    // to start the tests as first we must copy these 2 files from assets into APP DATA
    // so we can simulate HowTo view, edit or send files from inside your APP DATA to other APPs
    // in a real life app you'll have your own workflows
    // I made copyAssetsToAPPData() INVOKABLE to be able to reset to origin files
    copyAssetsToAPPData();
}

ApplicationUI::~ApplicationUI()
{
    delete mShareUtils;
}

void ApplicationUI::copyAssetsToAPPData() {
    // Android: HomeLocation works, iOS: not writable - so I'm using always QStandardPaths::AppDataLocation
    // Android: AppDataLocation works out of the box, iOS you must create the DIR first !!
    QString appDataRoot = QStandardPaths::standardLocations(QStandardPaths::AppDataLocation).value(0);
    // QString appDataRoot = QStandardPaths::standardLocations(QStandardPaths::DocumentsLocation).value(0);
#if defined (Q_OS_IOS)
    if (!QDir(appDataRoot).exists()) {
        if (QDir("").mkpath(appDataRoot)) {
        } else {
            return;
        }
    }
#endif
    // as next we create a /my_share_files subdirectory to store our example files from assets
    mAppDataFilesPath = appDataRoot.append("/picoapp_shared_files");
    if (!QDir(mAppDataFilesPath).exists()) {
        if (QDir("").mkpath(mAppDataFilesPath)) {
            //qDebug() << "Created app data /files directory. " << mAppDataFilesPath;
        } else {
            //qWarning() << "Failed to create app data /files directory. " << mAppDataFilesPath;
            return;
        }
    }

    // now create the working dir if not exists
#if defined (Q_OS_IOS)
    QString docLocationRoot = QStandardPaths::standardLocations(QStandardPaths::DocumentsLocation).value(0);
#endif
#if defined(Q_OS_ANDROID)
    QString docLocationRoot = QStandardPaths::standardLocations(QStandardPaths::AppDataLocation).value(0);
#endif
#if defined(Q_OS_WIN)
    QString docLocationRoot = QStandardPaths::standardLocations(QStandardPaths::AppDataLocation).value(0);
#endif
#if defined(Q_OS_MAC) && !defined(Q_OS_IOS)
    QString docLocationRoot = QStandardPaths::standardLocations(QStandardPaths::AppDataLocation).value(0);
#endif
#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    QString docLocationRoot = QStandardPaths::standardLocations(QStandardPaths::AppDataLocation).value(0);
#endif
#if defined(Q_OS_WASM)
    QString docLocationRoot = QStandardPaths::standardLocations(QStandardPaths::AppDataLocation).value(0);
#endif
    mDocumentsWorkPath = docLocationRoot.append("/picoapp_shared_files");
    if (!QDir(mDocumentsWorkPath).exists()) {
        if (QDir("").mkpath(mDocumentsWorkPath)) {
            //qDebug() << "Created Documents Location work directory. " << mDocumentsWorkPath;
        } else {
            //qWarning() << "Failed to create Documents Location work directory. " << mDocumentsWorkPath;
            return;
        }
    }
}

bool ApplicationUI::copyAssetFile(const QString sourceFilePath, const QString destinationFilePath) {
    if (QFile::exists(destinationFilePath))
    {
        bool removed = QFile::remove(destinationFilePath);
        if(!removed) {
            return false;
        }
    }
    bool copied = QFile::copy(sourceFilePath, destinationFilePath);
    if(!copied) {
        return false;
    }
    // because files are copied from assets it's a good idea to set r/w permissions
    bool permissionsSet = QFile(destinationFilePath).setPermissions(QFileDevice::ReadUser | QFileDevice::WriteUser);
    if(!permissionsSet) {
        return false;
    }
    return true;
}

// the old workflow (SDK 23, FilePath):
// Data files in AppDataLocation cannot shared with other APPs
// so we copy them into our working directory inside USERS DOCUMENTS location

// the new workflow:
// now with FileProvider our working directory is inside AppDataLocation
QString ApplicationUI::filePathDocumentsLocation(const int requestId) {
    QString sourceFilePath;
    QString destinationFilePath;
    switch (requestId) {
    case SEND_FILE_IMAGE:
    case VIEW_FILE_IMAGE:
    case EDIT_FILE_IMAGE:
    case NO_RESPONSE_IMAGE:
        sourceFilePath = mAppDataFilesPath+IMAGE_DATA_FILE;
        destinationFilePath = mDocumentsWorkPath+IMAGE_DATA_FILE;
        break;
    case SEND_FILE_JPEG:
    case VIEW_FILE_JPEG:
    case EDIT_FILE_JPEG:
    case NO_RESPONSE_JPEG:
        sourceFilePath = mAppDataFilesPath+JPEG_DATA_FILE;
        destinationFilePath = mDocumentsWorkPath+JPEG_DATA_FILE;
        break;
    case SEND_FILE_DOCX:
    case VIEW_FILE_DOCX:
    case EDIT_FILE_DOCX:
    case NO_RESPONSE_DOCX:
        sourceFilePath = mAppDataFilesPath+DOCX_DATA_FILE;
        destinationFilePath = mDocumentsWorkPath+DOCX_DATA_FILE;
        break;
    default:
        sourceFilePath = mAppDataFilesPath+PDF_DATA_FILE;
        destinationFilePath = mDocumentsWorkPath+PDF_DATA_FILE;
        break;
    }
//    if(requestId == SEND_FILE_IMAGE || requestId == VIEW_FILE_IMAGE || requestId == EDIT_FILE_IMAGE || requestId == NO_RESPONSE_IMAGE) {
    if (QFile::exists(destinationFilePath))
    {
        bool removed = QFile::remove(destinationFilePath);
        if(!removed) {
            //qWarning() << "Failed to remove " << destinationFilePath;
            return destinationFilePath;
        }
    }
    bool copied = QFile::copy(sourceFilePath, destinationFilePath);
    if(!copied) {
//#if defined(Q_OS_ANDROID)
//        emit noDocumentsWorkLocation();
//#endif
    }
    return destinationFilePath;
}

bool ApplicationUI::deleteFromDocumentsLocation(const int requestId) {
    QString filePath;
    switch (requestId) {
    case SEND_FILE_IMAGE:
    case VIEW_FILE_IMAGE:
    case EDIT_FILE_IMAGE:
    case NO_RESPONSE_IMAGE:
        filePath = mDocumentsWorkPath+IMAGE_DATA_FILE;
        break;
    case SEND_FILE_JPEG:
    case VIEW_FILE_JPEG:
    case EDIT_FILE_JPEG:
    case NO_RESPONSE_JPEG:
        filePath = mDocumentsWorkPath+JPEG_DATA_FILE;
        break;
    case SEND_FILE_DOCX:
    case VIEW_FILE_DOCX:
    case EDIT_FILE_DOCX:
    case NO_RESPONSE_DOCX:
        filePath = mDocumentsWorkPath+DOCX_DATA_FILE;
        break;
    default:
        filePath = mDocumentsWorkPath+PDF_DATA_FILE;
        break;
    }
    if (QFile::exists(filePath)) {
        bool removed = QFile::remove(filePath);
        if(!removed) {
            return false;
        }
    } else {
        return false;
    }
    return true;
}

bool ApplicationUI::updateFileFromDocumentsLocation(const int requestId) {
    QString docLocationFilePath;
    QString appDataFilePath;
    switch (requestId) {
    case SEND_FILE_IMAGE:
    case VIEW_FILE_IMAGE:
    case EDIT_FILE_IMAGE:
    case NO_RESPONSE_IMAGE:
        docLocationFilePath = mDocumentsWorkPath+IMAGE_DATA_FILE;
        appDataFilePath = mAppDataFilesPath+IMAGE_DATA_FILE;
        break;
    case SEND_FILE_JPEG:
    case VIEW_FILE_JPEG:
    case EDIT_FILE_JPEG:
    case NO_RESPONSE_JPEG:
        docLocationFilePath = mDocumentsWorkPath+JPEG_DATA_FILE;
        appDataFilePath = mAppDataFilesPath+JPEG_DATA_FILE;
        break;
    case SEND_FILE_DOCX:
    case VIEW_FILE_DOCX:
    case EDIT_FILE_DOCX:
    case NO_RESPONSE_DOCX:
        docLocationFilePath = mDocumentsWorkPath+DOCX_DATA_FILE;
        appDataFilePath = mAppDataFilesPath+DOCX_DATA_FILE;
        break;
    default:
        docLocationFilePath = mDocumentsWorkPath+PDF_DATA_FILE;
        appDataFilePath = mAppDataFilesPath+PDF_DATA_FILE;
        break;
    }
    if (QFile::exists(docLocationFilePath)) {
        // delete appDataFilePath should exist
        if(QFile::exists(appDataFilePath)) {
            bool removed = QFile::remove(appDataFilePath);
            if(!removed) {
                //qWarning() << "Failed to remove " << appDataFilePath;
                // go on
            } else {
                //qDebug() << "old file removed: " << appDataFilePath;
            }
        }
        // now copy the file from doc location to app data location
        bool copied = QFile::copy(docLocationFilePath, appDataFilePath);
        if(!copied) {
            return false;
        } else {
            // now delete from Documents location
            bool removed = QFile::remove(docLocationFilePath);
            if(!removed) {
                //qWarning() << "Failed to remove " << docLocationFilePath;
                // go on
            } else {
                //qDebug() << "doc file removed: " << docLocationFilePath;
            }
        }
    } else {
        return false;
    }
    return true;
}

#if defined(Q_OS_ANDROID)
void ApplicationUI::onApplicationStateChanged(Qt::ApplicationState applicationState)
{
    if(applicationState == Qt::ApplicationState::ApplicationSuspended) {
        // nothing to do

        // 31.5.2020 --> always exit application in suspend mode --> fixes problem whith sharing data from other application if this application is still running !
        //QCoreApplication::quit();
        //emit requestApplicationQuit();
        // ==> nicht gut, verhindert nach O Button ein erneutes starten !!!

        return;
    }
    if(applicationState == Qt::ApplicationState::ApplicationActive) {
        // if App was launched from VIEW or SEND Intent
        // there's a race collision: the event will be lost,
        // because App and UI wasn't completely initialized
        // workaround: QShareActivity remembers that an Intent is pending
        if(!mPendingIntentsChecked) {
            mPendingIntentsChecked = true;
            mShareUtils->checkPendingIntents(mAppDataFilesPath);
        }
    }
}

void ApplicationUI::onSaveStateRequest(QSessionManager & sessionManager)
{
}

// we don't need permissions if we only share files to other apps using FileProvider
// but we need permissions if other apps share their files with out app and we must access those files
bool ApplicationUI::checkPermission() {
#if QT_VERSION < 0x060000
    QtAndroid::PermissionResult r = QtAndroid::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
    if(r == QtAndroid::PermissionResult::Denied) {
        QtAndroid::requestPermissionsSync( QStringList() << "android.permission.WRITE_EXTERNAL_STORAGE" );
        r = QtAndroid::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
        if(r == QtAndroid::PermissionResult::Denied) {
            emit noDocumentsWorkLocation();
            return false;
        }
   }
#else
    QFuture<QtAndroidPrivate::PermissionResult> result = QtAndroidPrivate::checkPermission(QtAndroidPrivate::PermissionType::Storage);
    if( result.result() == QtAndroidPrivate::PermissionResult::Denied )
    {
        QFuture<QtAndroidPrivate::PermissionResult> result2 = QtAndroidPrivate::requestPermission(QtAndroidPrivate::PermissionType::Storage);
        if( result2.result() == QtAndroidPrivate::PermissionResult::Denied )
        {
            //qDebug() << "Permission denied";
            emit noDocumentsWorkLocation();
            return false;
        }
    }
#endif
   return true;
}
#endif
