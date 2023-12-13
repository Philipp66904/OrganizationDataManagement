import sys
from pathlib import Path

from PySide6.QtCore import QObject, Slot
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterType
from PySide6.QtQuickControls2 import QQuickStyle

from app.database import Database
from app.settings import Settings
from app.tablemodel import TableModel


if __name__ == '__main__':
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()
    
    # Make classes available for use in QML
    settings = Settings(Path(__file__).parent / "settings.json")
    db = Database(settings)
    engine.rootContext().setContextProperty("settings", settings)
    engine.rootContext().setContextProperty("database", db)
    
    qmlRegisterType(TableModel, 'tablemodule', 1, 0, 'TableModel')

    # Start QML
    qml_file = Path(__file__).parent / "ui" / 'main.qml'
    engine.load(qml_file)
    
    if not engine.rootObjects():
        sys.exit(-1)
    
    sys.exit(app.exec())