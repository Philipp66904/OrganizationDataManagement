from pathlib import Path
import os
import sqlite3
from sqlite3 import Error
from PySide6.QtCore import QObject, Slot, Signal, QUrl
import datetime

from app.settings import Settings

class Database(QObject):
    """
    Handles the database operations like the in-memory db, or loading and saving to external files.
    """
    
    # Signals
    databaseLoaded = Signal(str)  # signals the new database name when a new database was loaded
    dataChanged = Signal()  # signals any database change
    
    
    def __init__(self, settings: Settings):
        """
        Initialises the in-memory database with the values from the template db.
        """
        
        super().__init__()
        
        self.con = sqlite3.connect(":memory:")
        self.path_template_db = Path(__file__).parent / "res" / "template.db"
        self.settings = settings
        
        self.readTemplateDB()
        
    
    @Slot(str, result=list)
    def getPrimaryKeyColumnNames(self, table_name: str) -> list:
        """
        Returns a list of column names for a specific table name that are part of the primary key.
        table_name: Table name where the caller wants the primary key column names from
        returns: List of strings
        """
        
        with self.con:
            res = self.con.execute(f"PRAGMA table_info({table_name});")
            column_names = res.fetchall()
        
        primary_key_column_names = []
        for column in column_names:
            if column[5] >= 1:
                primary_key_column_names.append(column[1])
        
        return primary_key_column_names
            
    
    @Slot(result=str)
    def slot_readTemplateDB(self) -> str:
        """
        Wrapper slot for readTemplateDB.
        All exeptions will be returned as a string.
        If string is empty, no exeption happened.
        """
        
        try:
            self.readTemplateDB()
        except Exception as e:
            return str(e)
        
        return ""
    
    def readTemplateDB(self) -> None:
        """
        Read the template database from disk and stores it in the in-memory db.
        raises RuntimeError: In case an error occured and therefore the db couldn't be read
        raises Error: In case a database command failed
        """
        
        try:
            self.readDB(str(self.path_template_db))
        except RuntimeError as e:
            raise e


    @Slot(str, result=str)
    @Slot(QUrl, result=str)
    def slot_readDB(self, db_path: str | QUrl) -> str:
        """
        Wrapper slot for readDB.
        All exeptions will be returned as a string.
        If string is empty, no exeption happened.
        """
        
        try:
            path_str = db_path.toLocalFile() if type(db_path) == QUrl else db_path
            self.settings.addRecentFile(path_str)
            self.readDB(path_str)
        except Exception as e:
            return str(e)
        
        return ""
    
    def readDB(self, db_path: str) -> None:
        """
        Reads a database from the disk and stores it in the in-memory db.
        db_path: Path to the file on disk
        raises RuntimeError: In case an invalid parameter is given
        raises Error: In case a database command failed
        """
        
        # Catch empty db_path or wrong type
        if type(db_path) not in {str} or len(db_path.strip()) <= 0:
            raise RuntimeError("Database::readDB: invalid path provided")
        
        # Check if path exists
        if not os.path.isfile(db_path):
            raise RuntimeError("Database::readDB: file doesn't exist")
        
        try:
            # Open source database path
            con_external = sqlite3.connect(db_path)
            
            # Copy data over
            with con_external:
                with self.con:
                    con_external.backup(self.con)
            
            # Close source db
            con_external.close()
        except Error as e:
            raise e
        
        emitted_db_path = db_path if db_path != str(self.path_template_db) else ""
        self.databaseLoaded.emit(emitted_db_path)
        self.dataChanged.emit()
    
    
    @Slot(QUrl, result=str)
    @Slot(str, result=str)
    def slot_saveDB(self, db_path: QUrl | str) -> str:
        """
        Wrapper slot for saveDB.
        All exeptions will be returned as a string.
        If string is empty, no exeption happened.
        """
        
        try:
            db_path_tmp = db_path.toLocalFile() if type(db_path) == QUrl else db_path
            self.settings.addRecentFile(db_path_tmp)
            self.saveDB(db_path_tmp)
        except Exception as e:
            return str(e)
        
        return ""
    
    def saveDB(self, db_path: str) -> None:
        """
        Saves the in-memory db to a .db file.
        If the .db file already exists, it'll be overriden.
        raises RuntimeError: In case an invalid parameter is given
        raises Error: In case a database command failed
        """
        
        # Catch empty db_path or wrong type
        if type(db_path) not in {str} or len(db_path.strip()) <= 0:
            raise RuntimeError("Database::saveDB: invalid path provided")
        
        try:
            # Open target database path
            con_external = sqlite3.connect(db_path)
            
            # Update modified and created dates
            with self.con:
                res = self.con.execute("SELECT content FROM __meta__ WHERE name = 'date_created';")
                date_created = res.fetchone()[0]
                
                try:
                    if type(date_created) != str:
                        raise ValueError("date_created is not a string")
                    
                    date_created = datetime.datetime.strptime(date_created, "%Y-%m-%d %H:%M:%S.%f")
                except ValueError as e:
                    date_created = None
                
                if date_created == None:
                    date_created = datetime.datetime.now()
                
                date_saved = datetime.datetime.now()
                self.con.execute("UPDATE __meta__ SET content = ? WHERE name = 'date_created'", (date_created.strftime("%Y-%m-%d %H:%M:%S.%f"),))
                self.con.execute("UPDATE __meta__ SET content = ? WHERE name = 'date_saved'", (date_saved.strftime("%Y-%m-%d %H:%M:%S.%f"),))
            
            # Copy data over
            with con_external:
                with self.con:
                    self.con.backup(con_external)
            
            # Close source db
            con_external.close()
        except Error as e:
            raise e
    
        self.databaseLoaded.emit(db_path)
        self.dataChanged.emit()


    @Slot(result=list)
    def getDataOrganization(self) -> list:
        """
        Returns all values that should be shown in the organization view.
        returns: List of lists with all the rows. The first list is always reserved for the column names.
        """
        
        with self.con:
            res = self.con.execute("""SELECT t.id, d.name, d.note, t.website, m.date_modified, m.date_created
                             FROM organization t, description d, metadata m
                             WHERE t.parent_id is NULL AND t.description_id = d.id AND t.metadata_id = m.id
                             ORDER BY d.name ASC;""")
            
            organization_data = res.fetchall()
        
        res = [["id", "name", "note", "website", "modified", "created"]]
        for data in organization_data:
            row = []
            for row_data in data:
                row.append(row_data)
            
            res.append(row)
        
        return res
    
    
    @Slot(result=list)
    def getDataAddress(self) -> list:
        """
        Returns all values that should be shown in the address view.
        returns: List of lists with all the rows. The first list is always reserved for the column names.
        """
        
        with self.con:
            res = self.con.execute("""SELECT t.id, d.name, d.note, t.street, t.number, t.postalcode, t.city, t.country, m.date_modified, m.date_created
                             FROM address t, description d, metadata m
                             WHERE t.parent_id is NULL AND t.description_id = d.id AND t.metadata_id = m.id
                             ORDER BY d.name ASC;""")
            
            address_data = res.fetchall()
        
        res = [["id", "name", "note", "street", "number", "postalcode", "city", "country", "modified", "created"]]
        for data in address_data:
            row = []
            for row_data in data:
                row.append(row_data)
            
            res.append(row)
        
        return res
    
    
    @Slot(result=list)
    def getDataPerson(self) -> list:
        """
        Returns all values that should be shown in the person view.
        returns: List of lists with all the rows. The first list is always reserved for the column names.
        """
        
        with self.con:
            res = self.con.execute("""SELECT t.id, d.name, d.note, t.title, t.gender, t.firstname, t.middlename, t.surname, m.date_modified, m.date_created
                             FROM person t, description d, metadata m
                             WHERE t.parent_id is NULL AND t.description_id = d.id AND t.metadata_id = m.id
                             ORDER BY d.name ASC;""")
            
            person_data = res.fetchall()
        
        res = [["id", "name", "note", "title", "gender", "firstname", "middlename", "surname", "modified", "created"]]
        for data in person_data:
            row = []
            for row_data in data:
                row.append(row_data)
            
            res.append(row)
        
        return res
