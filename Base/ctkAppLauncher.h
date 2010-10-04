#ifndef __ctkAppLauncher_h
#define __ctkAppLauncher_h

// Qt includes
#include <QString>
#include <QStringList>
#include <QSettings>
#include <QCoreApplication>

// STD includes
#include <iostream>

class ctkAppLauncherInternal;

// --------------------------------------------------------------------------
class ctkAppLauncher : public QObject
{
  Q_OBJECT
public:
  typedef ctkAppLauncher Self;
  typedef QObject Superclass;
  ctkAppLauncher(const QCoreApplication& application, QObject* parentObject = 0);
  ~ctkAppLauncher();
  
  enum ProcessArgumentsStatus
    {
    ExitWithError = 0, 
    ExitWithSuccess, 
    Continue
    };
  
  /// Display help string on standard output
  void displayHelp(std::ostream &output = std::cout);
  
  /// Initialize
  bool initialize();
  
  /// Parse arguments
  /// Return ProcessArgumentsStatus::ExitWithError in case of parse error 
  /// or if the object is NOT initialized
  int processArguments();
  
  /// Return associated settingsFileName
  /// Will return an empty string if the object is NOT initialized
  QString settingsFileName()const;
  
  /// Read/Write settings
  /// Will return False if the object is NOT initialized
  bool readSettings(const QString& fileName);
  bool writeSettings(const QString& outputFilePath);
  
  /// Set/Get list of library paths 
  const QStringList& libraryPaths()const; 
  void setLibraryPaths(const QStringList& listOfLibraryPaths);
  
  /// Set/Get list of paths
  const QStringList& paths()const;
  void setPaths(const QStringList& listOfPaths);
  
  /// Get applicationToLaunch
  QString applicationToLaunch()const;
  
  /// Start the ApplicationToLaunch as a child process
  /// Will return False if the object is NOT initialized
  void startApplication();
  
  /// Return the associated splash screen image path
  QString splashImagePath()const;

  /// \brief Return the delay in ms before the launcher hide the splashscreen.
  /// The delay is applied after the application finishes to start.
  int splashScreenHideDelayMs()const;

  /// Get verbose flag
  /// If True, print to standard output information associated with the parameters
  /// passed to the launcher, launcher settings, etc ...
  bool verbose()const;
  
  void generateTemplate();
  
public slots:
  
  /// Slot called just after the application event loop is started
  void startLauncher();
  
private:
  friend class ctkAppLauncherInternal;
  ctkAppLauncherInternal* Internal;

};

#endif
