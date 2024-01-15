from PySide6.QtCore import QObject, Slot, Signal, QAbstractTableModel, QModelIndex, Qt

class TableModel(QAbstractTableModel):
    updateView = Signal()
    
    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self.table_name = ""
        self.column_names = []
        self.row_data = []
       
     
    @Slot(str, list, list)
    def loadData(self, table_name: str, column_names: list, row_data: list) -> None:
        self.layoutAboutToBeChanged.emit()
        self.table_name = table_name
        self.column_names = column_names
        self.row_data = row_data
        
        self.layoutChanged.emit()
        self.updateView.emit()
        
    
    @Slot(int, str, list)
    def changeRowData(self, pk_id: int, pk_column_name: str, row_data: list) -> None:
        """
        Update the data for a specific row
        pk_id: Primary key of the row whose values shall be updated
        pk_column_name: Column name where the pk_id is located
        row_data: New column data as a list
        raises ValueError: In case the pk_column_name or pk_id couldn't be found in the table
        """
        
        column_id = -1
        for i, column_name in enumerate(self.column_names):
            if column_name == pk_column_name:
                column_id = i
                break
                
        if column_id < 0:
            raise ValueError("TableModel::changeRowData: pk_column_name not found")
        
        for row_id, row in enumerate(self.row_data):
            if row[column_id] == pk_id:
                self.row_data[row_id] = row_data
                start_index = self.index(row_id, 0)
                end_index = self.index(row_id, self.columnCount() - 1)
                self.dataChanged.emit(start_index, end_index, [])
                self.layoutChanged.emit()
                self.updateView.emit()
                return
        
        # Primary key was not found in table -> do nothing
    
    
    @Slot(int, list)
    def addRowData(self, pos: int, row_data: list) -> None:
        if pos < 0:
            pos = len(self.row_data)
        
        self.beginInsertRows(QModelIndex(), pos, pos)
        self.row_data.insert(pos, row_data)
        self.endInsertRows()
        self.layoutChanged.emit()
        self.updateView.emit()
    
    
    @Slot(int, str)
    def removeRowData(self, pk_id: int, pk_column_name: str) -> None:
        column_id = -1
        for i, column_name in enumerate(self.column_names):
            if column_name == pk_column_name:
                column_id = i
                break
                
        if column_id < 0:
            raise ValueError("TableModel::removeRowData: pk_column_name not found")
        
        for row_id, row in enumerate(self.row_data):
            if row[column_id] == pk_id:
                self.beginRemoveRows(QModelIndex(), row_id, row_id)
                self.row_data.pop(row_id)
                self.endRemoveRows()
                self.layoutChanged.emit()
                self.updateView.emit()
                return
        
        # Primary key was not found in table -> do nothing


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
    
    
    @Slot(result=str)
    def getTableName(self) -> str:
        return self.table_name
    
    
    @Slot(str, result=int)
    def getColumnIndex(self, column_name: str) -> int:
        """
        Returns the column index for a specific column name:
        returns: Index of the column name
        raises ValueError: If column_name doesn't exist
        """
        
        if column_name not in self.column_names:
            raise ValueError("TableModel::getColumnIndex: column_name doesn't exist")
        
        for i, name in enumerate(self.column_names):
            if name == column_name:
                return i
    
    
    @Slot(int, int, result=str)
    def getValueType(self, column_index: int, row_index: int) -> str:
        """
        Return the value type at the specified location.
        Only String, int and float are supported.
        returns: String defining the value type: "str", "int", and "float"
        """
        
        val_type = (type(self.row_data[row_index][column_index]))
        
        if val_type == str:
            return "str"
        elif val_type == int:
            return "int"
        elif val_type == float:
            return "float"
        else:
            raise ValueError("TableModel::getValueType: Value is not a standard type")
    
    
    @Slot(int, int, result=int)
    def getValueInt(self, column_index: int, row_index: int) -> int:
        val = self.row_data[row_index][column_index]
        if type(val) != int:
            raise ValueError("TableModel::getValueInt: The requested value is not of type 'int'")
        
        return self.row_data[row_index][column_index]
    
    
    @Slot(int, int, result=str)
    def getValueStr(self, column_index: int, row_index: int) -> str:
        val = self.row_data[row_index][column_index]
        if type(val) != str:
            raise ValueError("TableModel::getValueStr: The requested value is not of type 'String'")
        
        return self.row_data[row_index][column_index]
    
    
    @Slot(int, int, result=float)
    def getValueFloat(self, column_index: int, row_index: int) -> str:
        val = self.row_data[row_index][column_index]
        if type(val) != str:
            raise ValueError("TableModel::getValueFloat: The requested value is not of type 'float'")
        
        return self.row_data[row_index][column_index]  
    