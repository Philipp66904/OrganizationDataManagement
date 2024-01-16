from PySide6.QtCore import QObject, Slot, Signal, QAbstractTableModel, QModelIndex, Qt, QLocale
from app.database import Database
import datetime

class TableModel(QAbstractTableModel):
    updateView = Signal()
    sortingChanged = Signal(str, bool)  # signals a change of the sorting: column_name and reverse_flag
    
    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self.table_name = ""
        self.column_names = []
        self.row_data = []
        
        # Current sorting
        self.sorted_column_name = None
        self.sorted_reverse = False
        self.sorted_locale = None
    
    
    @Slot(str, list, list)
    def loadData(self, table_name: str, column_names: list, row_data: list) -> None:
        self.layoutAboutToBeChanged.emit()
        self.table_name = table_name
        
        init_sorting = False
        if len(self.column_names) <= 0:
            init_sorting = True
        
        self.column_names = column_names
        self.row_data = row_data
        
        if len(self.column_names) >= 2 and init_sorting:
            self.sorted_column_name = self.getColumnName(1)
        
        self.updateSort()
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
                self.updateSort()
                return
        
        # Primary key was not found in table -> do nothing
    
    
    @Slot(int, list)
    def addRowData(self, pos: int, row_data: list) -> None:
        """
        Adds a row with the row_data at position pos.
        pos: Position where the data should be inserted; if < 0 the row will be added at the end
        row_data: List with column values for the row
        """
        
        if pos < 0:
            pos = len(self.row_data)
        
        self.beginInsertRows(QModelIndex(), pos, pos)
        self.row_data.insert(pos, row_data)
        self.endInsertRows()
        self.layoutChanged.emit()
        self.updateView.emit()
        self.updateSort()
    
    
    @Slot(int, str)
    def removeRowData(self, pk_id: int, pk_column_name: str) -> None:
        """
        Removes the row with the specified primary key from the data.
        If the primary key doesn't exist in the data, nothing happens.
        pk_id: Primary key of the row that shall be deleted
        pk_column_name: Primary key column name
        """
        
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
                self.updateSort()
                return
        
        # Primary key was not found in table -> do nothing
    
    
    @Slot(result=int)
    def getSortedColumnName(self) -> int:
        return self.sorted_column_name
    
    
    @Slot(result=bool)
    def getSortedReverse(self) -> bool:
        return self.sorted_reverse
    
    
    def updateSort(self) -> None:
        """
        Reapplies the last saved sorting.
        """
        
        self.sort(self.sorted_column_name, self.sorted_reverse, self.sorted_locale)
    
    
    @Slot(str, bool, QLocale)
    def sort(self, column_name: str, reverse: bool, locale: QLocale | None) -> None:
        """
        Sorts the table view by the specified column in the specified order.
        If two rows have the same value, the modified date (if the column exists) will be used for sorting.
        If both modified dates match, too, the ids will be used for sorting.
        column_name: Column that should be used for sorting
        reverse: False for ascending order; True for descending order
        locale: Current QLocale object, set to None as fallback to ignore date and time differences
        raises ValueError: In case the column_name or id column were not found
        """
        
        if len(self.column_names) <= 0 or column_name is None:
            return
        
        column_id = -1
        id_column_id = -1
        modified_column_id = -1
        modified_column_name = (Database.translateColumnNames(["modified"]))[0]
        created_column_id = -1
        created_column_name = (Database.translateColumnNames(["created"]))[0]
        
        for i, column_name_tmp in enumerate(self.column_names):
            if column_name_tmp == column_name:
                column_id = i
            if column_name_tmp == "id":
                id_column_id = i
            if column_name_tmp == modified_column_name:
                modified_column_id = i
            if column_name_tmp == created_column_name:
                created_column_id = i
            
            if column_id > 0 and id_column_id >= 0 and modified_column_id >= 0 and created_column_id >= 0:
                break
        
        if column_id < 0 or id_column_id < 0:
            raise ValueError("TableModel::sort: The column_name or id column were not found")
        
        def convertDateTimeFromLocale(datetime_str) -> datetime.datetime:
            if locale is None:
                return datetime.datetime.now()
            
            qdate_obj = locale.toDate(datetime_str.split(' ')[1], locale.dateFormat(QLocale.ShortFormat))
            date_obj = datetime.date(qdate_obj.year(), qdate_obj.month(), qdate_obj.day())
            time_obj = datetime.datetime.strptime(datetime_str.split(' ')[0], "%H:%M:%S").time()
            
            datetime_obj = datetime.datetime.combine(date_obj, time_obj)
            return datetime_obj
        
        def sorting_func(row) -> tuple:
            val = row[column_id]
            if column_id in (modified_column_id, created_column_id):
                val = convertDateTimeFromLocale(val)
            
            modified_date = convertDateTimeFromLocale(row[modified_column_id]) if modified_column_id >= 0 else ""
            id = row[id_column_id]
            
            if val is None:
                val = ""
            if modified_date is None:
                modified_date = datetime.datetime.now()
            if id is None:
                id = 0
            
            if locale is None:
                return (val, id)
            else:
                return (val, modified_date, id)
        
        self.layoutAboutToBeChanged.emit()
        self.row_data.sort(key=sorting_func, reverse=reverse)
        self.sorted_column_name = column_name
        self.sorted_reverse = reverse
        self.sorted_locale = locale
        self.sortingChanged.emit(self.sorted_column_name, self.sorted_reverse)
        self.layoutChanged.emit()


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
        """
        Returns the longest text for a specific column.
        column_index: Column index
        returns: Longest text as string
        """
        
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
    
    
    @Slot(int, result=str)
    def getColumnName(self, column_id: int) -> str:
        """
        Returns the column name for a specific column index:
        returns: String of the column name
        raises ValueError: If column_id doesn't exist
        """
        
        if column_id < 0 or column_id >= len(self.column_names):
            raise ValueError("TableModel::getColumnName: column_id doesn't exist")
        
        return self.column_names[column_id]
    
    
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
