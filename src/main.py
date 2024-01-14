import sys
import os
from pathlib import Path

from PySide6.QtCore import QTranslator, QLocale
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterType

from app.database import Database
from app.settings import Settings
from app.tablemodel import TableModel


if __name__ == '__main__':
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()
    
    translations_path = Path(__file__).parent.parent / "build" / "translations"
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

    # Make classes available for use in QML
    db = Database(settings, locale)
    engine.rootContext().setContextProperty("settings", settings)
    engine.rootContext().setContextProperty("database", db)
    
    qmlRegisterType(TableModel, 'tablemodule', 1, 0, 'TableModel')
    
    # Start QML
    qml_file = Path(__file__).parent / "ui" / 'main.qml'
    engine.load(qml_file)
    
    if not engine.rootObjects():
        sys.exit(-1)
    
    sys.exit(app.exec())