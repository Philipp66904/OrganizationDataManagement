import sys
import os
from pathlib import Path
from sqlite3 import Error

from PySide6.QtCore import QTranslator, QLocale, QCoreApplication
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterType
from PySide6.QtGui import QIcon

from app.database import Database
from app.settings import Settings
from app.tablemodel import TableModel

from app.win.registry import WinRegistry


if __name__ == '__main__':    
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()
    
    app.setOrganizationName("Philipp Grueber")
    app.setApplicationName(QCoreApplication.translate("Main", "Organization Data Management"))
    app.setWindowIcon(QIcon(os.path.abspath(Path(__file__).parent / "ui" / "res" / "svg" / "window_icon.svg")))
    
    translations_path = Path(__file__).parent / "lang" / "build"
    settings = Settings(Path(__file__).parent / "settings.json", translations_path)
    
    # Load translations
    translator = QTranslator(app)
    selected_language = settings.getActiveLanguage()
    locale = QLocale.system()
    if selected_language == "Follow System":
        if translator.load(locale, '', '', os.path.abspath(translations_path)):
            app.installTranslator(translator)
    elif selected_language != "English Development (Fallback)":
        if translator.load(settings.getActiveLanguage(), os.path.abspath(translations_path)):
            app.installTranslator(translator)
            locale = QLocale(settings.getActiveLanguage())

    # Handle registry entries
    winregistry = WinRegistry()
    if settings.getFileTypeAssociation():
        winregistry.add_registry_entries()
    else:
        winregistry.remove_registry_entries()
    
    # Handle file opening at startup
    load_on_startup_path = None
    if len(sys.argv) >= 2 and sys.argv[1].endswith(('.odmdb', '.db')):  # automatically open path if provided
        load_on_startup_path = sys.argv[1]
    
    # Make classes available for use in QML
    db = Database(settings, locale, load_on_startup_path)
    engine.rootContext().setContextProperty("settings", settings)
    engine.rootContext().setContextProperty("database", db)
    engine.rootContext().setContextProperty("winregistry", winregistry)
    
    qmlRegisterType(TableModel, 'tablemodule', 1, 0, 'TableModel')
    
    # Start QML
    qml_file = Path(__file__).parent / "ui" / 'main.qml'
    engine.load(qml_file)
    
    if not engine.rootObjects():
        sys.exit(-1)
    
    sys.exit(app.exec())