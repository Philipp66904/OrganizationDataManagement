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
                        raise ValueError("Database::saveDB: date_created is not a string")
                    
                    date_created = datetime.datetime.strptime(date_created, "%Y-%m-%d %H:%M:%S")
                except ValueError as e:
                    date_created = None
                
                if date_created == None:
                    date_created = datetime.datetime.utcnow()
                
                date_saved = datetime.datetime.utcnow()
                self.con.execute("UPDATE __meta__ SET content = ? WHERE name = 'date_created'", (date_created.strftime("%Y-%m-%d %H:%M:%S"),))
                self.con.execute("UPDATE __meta__ SET content = ? WHERE name = 'date_saved'", (date_saved.strftime("%Y-%m-%d %H:%M:%S"),))
            
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
            res = self.con.execute("""SELECT t.id, d.name, d.note, t.website, datetime(m.date_modified, 'localtime'), datetime(m.date_created, 'localtime')
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
    
    
    @Slot(int, str, str, result=list)
    def getDataDerivates(self, parent_id: int, parent_column_name: str, table_name: str) -> list:
        """
        Returns all derivates for a given primary key.
        parent_id: Id of the parent whose derivates shall be returned
        parent_column_name: Name of the column where the parent_ids are defined
        table_name: Name of the table whose derivates shall be returned
        returns: List of lists with all the rows. The first list is always reserved for the column names.
        """
        
        with self.con:
            res = self.con.execute(f"""SELECT t.id, d.name, d.note, datetime(m.date_modified, 'localtime'), datetime(m.date_created, 'localtime')
                             FROM {table_name} t, description d, metadata m
                             WHERE t.{parent_column_name} = {parent_id} AND t.description_id = d.id AND t.metadata_id = m.id
                             ORDER BY d.name ASC;""")
            
            data = res.fetchall()
        
        res = [["id", "name", "note", "modified", "created"]]
        for data_tmp in data:
            row = []
            for row_data in data_tmp:
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
            res = self.con.execute("""SELECT t.id, d.name, d.note, t.street, t.number, t.postalcode, t.city, t.country, datetime(m.date_modified, 'localtime'), datetime(m.date_created, 'localtime')
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
            res = self.con.execute("""SELECT t.id, d.name, d.note, t.title, t.gender, t.firstname, t.middlename, t.surname, datetime(m.date_modified, 'localtime'), datetime(m.date_created, 'localtime')
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
    
    
    @Slot(int, result=list)
    def getConnections(self, organization_id: int) -> list:
        """
        Returns all relations for a specific organization.
        organization_id: Organization id which relations shall be returned
        returns: List of lists with all the rows. The first list is always reserved for the column names.
        """
        
        res_list = [["id", "person_name", "person_note", "address_name", "address_note"]]
        
        with self.con:
            res = self.con.execute("""SELECT t.id, d.name, d.note
                                   FROM description d,
                                   (
                                       SELECT c.id, p.description_id
                                       FROM connection c, person p, address a
                                       WHERE c.id = ? AND c.person_id = p.id AND c.address_id  = a.id
                                   ) t
                                   WHERE t.description_id = d.id;""",
                                   (organization_id,))
            
            person_data = res.fetchone()
            
            res = self.con.execute("""SELECT t.id, d.name, d.note
                                   FROM description d,
                                   (
                                       SELECT c.id, a.description_id
                                       FROM connection c, person p, address a
                                       WHERE c.id = ? AND c.person_id = p.id AND c.address_id  = a.id
                                   ) t
                                   WHERE t.description_id = d.id;""",
                                   (organization_id,))
            
            address_data = res.fetchone()
            
            if person_data == None or len(person_data) != 3 or address_data == None or len(address_data) != 3:
                return res_list
            
            if person_data[0] != address_data[0]:
                raise ValueError("Database::getRelations: Organization ids don't match")
        
        res_list.append([person_data[0], person_data[1], person_data[2], address_data[1], address_data[2]])
        return res_list
    
    
    @Slot(int, result=list)
    def getConnection(self, connection_id: int) -> list:
        """
        Returns the name and note for the associated person_id and address_id of the connection.
        connection_id: Connection primary key
        returns: List with 2 string entries for person and address. The name and note get combined into one string.
        """
        
        if connection_id < 0:
            return ["", ""]
        
        with self.con:
            res = self.con.execute("""SELECT c.person_id, d.name, d.note
                                      FROM connection c, person p, description d
                                      WHERE c.id = ? AND c.person_id = p.id AND p.description_id = d.id;""",
                                      (connection_id,))
            
            person_res = res.fetchone()
            
            res = self.con.execute("""SELECT c.address_id, d.name, d.note
                                      FROM connection c, address a, description d
                                      WHERE c.id = ? AND c.address_id = a.id AND a.description_id = d.id;""",
                                      (connection_id,))
            
            address_res = res.fetchone()
        
        person_combination = str(person_res[0]) + " ・ " + person_res[1]
        if len(person_res[2].strip()) > 0:
            person_combination += " ・ " + person_res[2]
        
        address_combination = str(address_res[0]) + " ・ " + address_res[1]
        if len(address_res[2].strip()) > 0:
            address_combination +=  " ・ " + address_res[2]
        
        return [person_combination, address_combination]
    
    
    @Slot(int, result=list)
    def getAvailPersonConnection(self, connection_id: int) -> list:
        """
        Returns a list with all persons available for a connection for the specified organization_id
        connection_id: Connection identifier. Set to < 0 if a new connection is created.
        returns: A list containing a list with the following specification: list[[person_id, name, note], ...]
        """
        
        with self.con:
            res = self.con.execute("""SELECT p.id, d.name, d.note FROM person p, description d WHERE p.description_id = d.id;""")
            all_persons = res.fetchall()
            
            if connection_id >= 0:
                res = self.con.execute("""SELECT person_id FROM connection WHERE id = ?;""",
                                    (connection_id,))
                selected_person_id = res.fetchone()[0]
            
                res = self.con.execute("""SELECT person_id FROM connection WHERE organization_id = ? AND NOT person_id = ?;""",
                                    (connection_id, selected_person_id))
                unavail_persons = res.fetchall()
            else:
                res = self.con.execute("""SELECT person_id FROM connection WHERE organization_id = ?;""",
                                    (connection_id,))
                unavail_persons = res.fetchall()
            
        avail_persons = []
        for person in all_persons:
            if (person[0],) in unavail_persons:
                continue
            
            avail_persons.append([person[0], person[1], person[2]])
            
        return avail_persons
    
    
    @Slot(int, result=list)
    def getAvailAddressConnection(self, connection_id: int) -> list:
        """
        Returns a list with all addresses available for a connection for the specified organization_id
        connection_id: Connection identifier. Set to < 0 if a new connection is created.
        returns: A list containing a list with the following specification: list[[address_id, name, note], ...]
        """
        
        with self.con:
            res = self.con.execute("""SELECT a.id, d.name, d.note FROM address a, description d WHERE a.description_id = d.id;""")
            all_addresses = res.fetchall()
            
            if connection_id >= 0:
                res = self.con.execute("""SELECT address_id FROM connection WHERE id = ?;""",
                                    (connection_id,))
                selected_address_id = res.fetchone()[0]
                
                res = self.con.execute("""SELECT address_id FROM connection WHERE organization_id = ? AND NOT address_id = ?;""",
                                    (connection_id, selected_address_id))
                unavail_addresses = res.fetchall()
            else:
                res = self.con.execute("""SELECT address_id FROM connection WHERE organization_id = ?;""",
                                    (connection_id,))
                unavail_addresses = res.fetchall()
        
        avail_addresses = []
        for address in all_addresses:
            if (address[0],) in unavail_addresses:
                continue
            
            avail_addresses.append([address[0], address[1], address[2]])
            
        return avail_addresses

    
    @Slot(int, str, str, str, result=int)
    def getValueInt_byPk(self, pk: int, pk_column_name: str, column_name: str, table_name: str) -> int:
        """
        Get a specific column's integer value from a specified primary key.
        pk: Primary key of the row to be selected
        pk_column_name: Primary key's column name
        column_name: Column which value shall be returned
        table_name: The table name where the values are located
        returns: Value as integer
        raises ValueError: In case the returned value has an incorrect type
        """
        
        if pk < 0:
            return 0
        
        with self.con:
            res = self.con.execute(f"""SELECT {column_name} FROM {table_name} WHERE {pk_column_name} = ? LIMIT 1;""",
                                   (pk,))
            
            val = res.fetchone()[0]
        
        if val is None:
            val = -1
        if type(val) != int:
            raise ValueError("Database::getValueInt_byPk: Returned value is not of type 'int'")
        
        return val
    
    
    @Slot(int, str, str, str, result=str)
    def getValueStr_byPk(self, pk: int, pk_column_name: str, column_name: str, table_name: str) -> str:
        """
        Get a specific column's String value from a specified primary key.
        pk: Primary key of the row to be selected
        pk_column_name: Primary key's column name
        column_name: Column which value shall be returned
        table_name: The table name where the values are located
        returns: Value as String
        raises ValueError: In case the returned value has an incorrect type
        """
        
        if pk < 0:
            return ""
        
        with self.con:
            res = self.con.execute(f"""SELECT {column_name} FROM {table_name} WHERE {pk_column_name} = ? LIMIT 1;""",
                                   (pk,))
            
            val = res.fetchone()[0]
        
        if type(val) != str:
            raise ValueError("Database::getValueStr_byPk: Returned value is not of type 'str'")
        
        return val
    
    
    @Slot(int, str, str, result=str)
    def getName_byPk(self, pk: int, pk_column_name: str, table_name: str) -> str:
        """
        Returns the name of an entry specified by the primary key.
        pk: Primary key
        pk_column_name: Name of the primary key column
        table_name: Name of the table, where the row is located
        returns: The name of the entry
        """
        
        if pk < 0:
            return ""
        
        with self.con:
            res = self.con.execute(f"""SELECT d.name FROM {table_name} t, description d WHERE t.{pk_column_name} = ? AND t.description_id = d.id LIMIT 1;""",
                                   (pk,))
            
            val = res.fetchone()[0]
            
        if val == None:
            raise ValueError("Database::getName_byPk: Primary key not found")
        
        return val
    
    
    @Slot(int, str, str, result=str)
    def getNote_byPk(self, pk: int, pk_column_name: str, table_name: str) -> str:
        """
        Returns the note of an entry specified by the primary key.
        pk: Primary key
        pk_column_name: Name of the primary key column
        table_name: Name of the table, where the row is located
        returns: The note of the entry
        """
        
        if pk < 0:
            return ""
        
        with self.con:
            res = self.con.execute(f"""SELECT d.note FROM {table_name} t, description d WHERE t.{pk_column_name} = ? AND t.description_id = d.id LIMIT 1;""",
                                   (pk,))
            
            val = res.fetchone()[0]
            
        if val == None:
            raise ValueError("Database::getNote_byPk: Primary key not found")
        
        return val
    
    
    def setModified_CreatedTimestamps(self, metadata_id: int):
        """
        Reads the saved created_time for a specific metadata entry.
        If a valid timestamp is found, only the modified_time will be updated,
        otherwise created_time and modified_time will be set to the current time.
        metadata_id: Metadata id
        raises ValueError: In case the metadata_id is not an integer or <0 
        """
        
        if type(metadata_id) != int or metadata_id < 0:
            raise ValueError("Database::setModified_CreatedTimestamps: metadata_id is not an int or <0")
        
        with self.con:
            # Get created time
            res = self.con.execute(f"""SELECT date_created FROM metadata WHERE id = ?;""", (metadata_id,))
            date_created = res.fetchone()[0]
            
            try:
                if type(date_created) != str:
                    raise ValueError("Database::setModified_CreatedTimestamps: date_created is not a string")
                
                date_created = datetime.datetime.strptime(date_created, "%Y-%m-%d %H:%M:%S")
            except ValueError as e:
                date_created = None
            
            if date_created == None:
                date_created = datetime.datetime.utcnow()
            
            date_modified = datetime.datetime.utcnow()
            
            self.con.execute("UPDATE metadata SET date_created = ?, date_modified = ? WHERE id = ?;",
                             (date_created.strftime("%Y-%m-%d %H:%M:%S"),
                              date_modified.strftime("%Y-%m-%d %H:%M:%S"),
                              metadata_id))
    
    
    @Slot(str, str, int, str, str, result=str)
    def setName_Note_byPk(self, name: str, note: str, pk: int, pk_column_name: str, table_name: str) -> str:        
        metadata_id = None
        
        try:
            if pk < 0:
                raise ValueError("Database::setNote_byPk: Primary key is <0")
            
            with self.con:
                # Get description_id
                res = self.con.execute(f"""SELECT d.id FROM {table_name} t, description d WHERE t.{pk_column_name} = {pk} AND t.description_id = d.id;""")
                description_id = res.fetchone()[0]
                
                # Get metadata_id
                res = self.con.execute(f"""SELECT metadata_id FROM {table_name} WHERE {pk_column_name} = {pk};""")
                metadata_id = res.fetchone()[0]
                
                self.con.execute(f"""UPDATE description
                                 SET name = ?, note = ?
                                 WHERE id = {description_id};""",
                                 (name, note))
        except Exception as e:
            return str(e)
        
        self.setModified_CreatedTimestamps(metadata_id)
        self.dataChanged.emit()
        return ""