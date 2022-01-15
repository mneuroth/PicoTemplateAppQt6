#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include <QLocale>
#include <QTranslator>
#include <QIcon>
#include <QtGlobal>
#include <QDir>
#include <QFile>
#include <QDateTime>

#include "applicationdata.h"

#define _WITH_QDEBUG_REDIRECT
#define _WITH_ADD_TO_LOG

static qint64 g_iLastTimeStamp = 0;

void AddToLog(const QString & msg)
{
#ifdef _WITH_ADD_TO_LOG
    QString sFileName("/sdcard/Texte/picoapptpl_qdebug.log");
    if( !QDir("/sdcard/Texte").exists() )
    {
        sFileName = "D:\\Users\\micha\\Documents\\git_projects\\build-pico-Desktop_Qt_6_2_2_MinGW_64_bit-Debug\\picoapp_qdebug.log";
        sFileName = "picoapptpl_qdebug.log";
    }
    QFile outFile(sFileName);
    bool ok = outFile.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Unbuffered);
    QTextStream ts(&outFile);
    qint64 now = QDateTime::currentMSecsSinceEpoch();
    qint64 delta = now - g_iLastTimeStamp;
    g_iLastTimeStamp = now;
    ts << delta << " ";
    ts << msg << Qt::endl;
    //qDebug() << delta << " " << msg << Qt::endl;
    outFile.close();
#else
    Q_UNUSED(msg)
#endif
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("mneuroth.de");     // Computer/HKEY_CURRENT_USER/Software/mneuroth.de
    app.setOrganizationDomain("mneuroth.de");
    app.setApplicationName("PicoTemplateApp");
    app.setWindowIcon(QIcon(":/pico.png"));

    QTranslator translator;
    const QStringList uiLanguages = QLocale::system().uiLanguages();
    for (const QString &locale : uiLanguages) {
        const QString baseName = "PicoTemplateAppQt6_" + QLocale(locale).name();
        if (translator.load(":/i18n/" + baseName)) {
            app.installTranslator(&translator);
            break;
        }
    }

    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/PicoTemplateAppQt6/main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

#if defined(Q_OS_ANDROID)
//    ApplicationData data(0, appui.GetShareUtils(), aStorageAccess, engine);
    StorageAccess aStorageAccess;
    ApplicationData data(0, new ShareUtils(), aStorageAccess, engine);
    QObject::connect(&app, SIGNAL(applicationStateChanged(Qt::ApplicationState)), &data, SLOT(sltApplicationStateChanged(Qt::ApplicationState)));
#else
    StorageAccess aStorageAccess;
    ApplicationData data(0, new ShareUtils(), aStorageAccess, engine);
#endif

    engine.rootContext()->setContextProperty("applicationData", &data);
#ifdef _WITH_STORAGE_ACCESS
    engine.rootContext()->setContextProperty("storageAccess", &aStorageAccess);
#endif


    engine.load(url);

    return app.exec();
}
