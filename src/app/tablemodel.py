from PySide6.QtCore import QObject, Slot, Signal, QAbstractTableModel, QModelIndex, Qt

class TableModel(QAbstractTableModel):
    updateView = Signal()
    
    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self.column_names = []
        self.row_data = []
       
     
    @Slot(list, list)
    def loadData(self, column_names: list, row_data: list) -> None:
        self.column_names = column_names
        self.row_data = row_data
        
        self.updateView.emit()


    def rowCount(self, parent: QModelIndex = QModelIndex) -> int:
        return len(self.row_data)
    
    
    def columnCount(self, parent: QModelIndex = QModelIndex) -> int:
        return len(self.column_names)
    
    
    def headerData(self, section: int, orientation: Qt.Orientation | None = None, role: int = None) -> any:
        return self.column_names[section]
    
    
    def data(self, index: QModelIndex, role: int | None = None) -> any:
        return self.row_data[index.row()][index.column()]
    
    
    @Slot(int, result=str)
    def getLongestText(self, column_index: int) -> str:
        res = str(self.column_names[column_index])
        
        for row in self.row_data:
            if len(str(row[column_index])) > len(res):
                res = str(row[column_index])
                
        return res
    