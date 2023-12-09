import sys
from pathlib import Path

from PySide6.QtCore import QObject, Slot
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine, QmlElement
from PySide6.QtQuickControls2 import QQuickStyle

if __name__ == '__main__':
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    qml_file = Path(__file__).parent / "ui" / 'main.qml'
    engine.load(qml_file)

    if not engine.rootObjects():
        sys.exit(-1)
    
    sys.exit(app.exec())