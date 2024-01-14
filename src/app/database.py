from pathlib import Path
import os
import sqlite3
from PySide6.QtCore import QObject, Slot, Signal, QUrl, QCoreApplication, QLocale, QDateTime
import datetime
from copy import deepcopy
import re
import timeit

from app.settings import Settings

class Database(QObject):
    """
    Handles the database operations like the in-memory db, or loading and saving to external files.
    """
    
    # Signals
    databaseLoaded = Signal(str)  # signals the new database name when a new database was loaded
    dataChanged = Signal()  # signals any database change
    
    
    def __init__(self, settings: Settings, locale: QLocale):
        """
        Initialises the in-memory database with the values from the template db.
        """
        
        super().__init__()
        
        self.con = sqlite3.connect(":memory:")
        self.path_template_db = Path(__file__).parent / "res" / "template.odmdb"
        self.settings = settings
        self.supported_db_version = "1.0"
        self.locale = locale
        
        self._search_data_cache = {}  # Caching last search results from database per table
        
        self.readTemplateDB()
        
    
    @Slot()
    def init_db(self) -> None:
        """
        Call this function whenever loading a new database including the template db.
        It sets the foreign key support to ON and emits the dataChanged signal.
        """
        
        with self.con:
            self.con.execute("""PRAGMA foreign_keys = ON;""")
        
        self.dataChanged.emit()
        
    
    @Slot()
    def clear_cache(self) -> None:
        """
        Deletes all data from the search case.
        Call this function whenever the database data was changed.
        """
        
        self._search_data_cache = {}
    
    
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
    
    
    @Slot(str, result=list)
    def getNonPrimaryKeyColumnNames(self, table_name: str) -> list:
        """
        Returns a list of column names for a specific table name that are not part of the primary key.
        table_name: Table name where the caller wants the non primary key column names from
        returns: List of strings
        """
        
        with self.con:
            res = self.con.execute(f"PRAGMA table_info({table_name});")
            column_names = res.fetchall()
        
        non_primary_key_column_names = []
        for column in column_names:
            if column[5] == 0:
                non_primary_key_column_names.append(column[1])
        
        return non_primary_key_column_names
    
    
    @Slot(str, result=list)
    def getNonPrimaryKeyNonForeignKeyColumnNames(self, table_name: str) -> list:
        """
        Returns a list of column names for a specific table name that are not part of the primary key and not a foreign key.
        table_name: Table name where the caller wants the non primary key and non foreign key column names from
        returns: List of strings
        """
        
        with self.con:
            res = self.con.execute(f"PRAGMA table_info({table_name});")
            column_names = res.fetchall()
            
            res = self.con.execute(f"PRAGMA foreign_key_list({table_name});")
            foreign_key_column_names_tmp = res.fetchall()
            foreign_key_column_names = [f[3] for f in foreign_key_column_names_tmp]
        
        non_primary_key_column_names = []
        for column in column_names:
            if column[5] == 0 and column[1] not in foreign_key_column_names:
                non_primary_key_column_names.append(column[1])
        
        return non_primary_key_column_names
    
    
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
        
        self.init_db()


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
            return "Database::slot_readDB: " + str(e)
        
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
            self.settings.removeRecentFile(db_path)
            raise RuntimeError("Database::readDB: file doesn't exist")
        
        try:
            # Open source database path
            con_external = sqlite3.connect(db_path)
            
            # Check db version
            with con_external:
                res = con_external.execute("""SELECT content FROM __meta__ WHERE name = 'db_version';""")
                res_tmp = res.fetchone()
                if res_tmp is None:
                    raise RuntimeError("Database::readDB: No db_version was found")
                
                db_version = res_tmp[0]
            
            if not (db_version == self.supported_db_version):
                raise RuntimeError(f"Database::readDB: Incorrect db_version: {db_version} (supported: {self.supported_db_version})")
            
            # Copy data over
            with con_external:
                with self.con:
                    con_external.backup(self.con)
            
            # Close source db
            con_external.close()
        except Exception as e:
            raise e
        
        self.init_db()
        emitted_db_path = db_path if db_path != str(self.path_template_db) else ""
        self.clear_cache()
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
            return "Database::slot_saveDB: " + str(e)
        
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
        except Exception as e:
            raise e
    
        self.clear_cache()
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
        date_indexes = (res[0].index("modified"), res[0].index("created"))
        for data in organization_data:
            row = []
            for i, row_data in enumerate(data):
                val = row_data
                if i in date_indexes:
                    val = self.adaptDateTimeToLocale(val)
                
                row.append(val)
            
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
        date_indexes = (res[0].index("modified"), res[0].index("created"))
        for data_tmp in data:
            row = []
            for i, row_data in enumerate(data_tmp):
                val = row_data
                if i in date_indexes:
                    val = self.adaptDateTimeToLocale(val)
                
                row.append(val)
            
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
        date_indexes = (res[0].index("modified"), res[0].index("created"))
        for data in address_data:
            row = []
            for i, row_data in enumerate(data):
                val = row_data
                if i in date_indexes:
                    val = self.adaptDateTimeToLocale(val)
                
                row.append(val)
            
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
            for i, row_data in enumerate(data):
                val = row_data
                if i in (res[0].index("modified"), res[0].index("created")):
                    val = self.adaptDateTimeToLocale(val)
                
                row.append(val)
            
            res.append(row)
        
        return res
    
    
    @Slot(int, str, str, str, str, result=list)
    def getDataOther(self, pk_id: int, pk_column_name: str, table_name: str, fk_column_name: str, other_table_name: str) -> list:
        """
        Returns the 'other' data for a specific table sorted by 'other_index'.
        pk_id: Address id which entries should be filtered for
        pk_column_name: Name of the primary key column name in the base table
        table_name: Base table name
        fk_column_name: Name of the foreign key column in the 'other' table
        other_table_name: Other table name
        returns: list[list[other_id: int, other_index: int, content: str, derivate_flag: bool]]
        """
        
        if pk_id < 0:
            return []
        
        res = {}
        
        def getOther(primary_key: int) -> list:
            """Returns a list with tuples with the following format for a specific address_id:
               list[other_id: int, other_index: int, content: str]"""
            
            res = self.con.execute(f"""SELECT o.id, o.other_index, o.content
                                       FROM {table_name} t, {other_table_name} o
                                       WHERE o.{fk_column_name} = ? AND o.{fk_column_name} = t.{pk_column_name}
                                       ORDER BY o.other_index ASC;""",
                                   (primary_key,))
            
            result = res.fetchall()
            if result is None:
                result = []
            
            return result
        
        def getParentId(primary_key: int) -> int | None:
            """Returns the parent id for a specific address_id"""
            
            res = self.con.execute(f"""SELECT parent_id FROM {table_name} WHERE {pk_column_name} = ? LIMIT 1;""",
                                   (primary_key,))
            
            parent_id_res = res.fetchone()
            
            if parent_id_res is None:
                return None
            else:
                return parent_id_res[0]
        
        with self.con:
            original_other_data = getOther(pk_id)
            
            for other_data_row in original_other_data:
                res[other_data_row[1]] = [other_data_row[0], other_data_row[1], other_data_row[2], False]
            
            parent_id = getParentId(pk_id)
            
            while parent_id is not None:                
                other_data = getOther(parent_id)
                
                for other_data_row in other_data:
                    if other_data_row[1] not in res:
                        res[other_data_row[1]] = [other_data_row[0], other_data_row[1], other_data_row[2], True]
                
                parent_id = getParentId(parent_id)
        
        if len(res) <= 0:
            return []
        
        # Sort res dict and convert into list
        sorted_keys = sorted(res.keys())
        sorted_values = [res[key] for key in sorted_keys]
        
        return sorted_values
    
    
    @Slot(int, result=list)
    def getConnections(self, organization_id: int) -> list:
        """
        Returns all relations for a specific organization.
        organization_id: Organization id which relations shall be returned
        returns: List of lists with all the rows. The first list is always reserved for the column names.
        """
        
        res_list = [["id",
                     QCoreApplication.translate("Database", "person_name"),
                     QCoreApplication.translate("Database", "person_note"),
                     QCoreApplication.translate("Database", "address_name"),
                     QCoreApplication.translate("Database", "address_note")]]
        
        with self.con:
            res = self.con.execute("""SELECT t.id, d.name, d.note
                                   FROM description d,
                                   (
                                       SELECT c.id, p.description_id
                                       FROM connection c, person p, address a
                                       WHERE c.organization_id = ? AND c.person_id = p.id AND c.address_id = a.id
                                   ) t
                                   WHERE t.description_id = d.id;""",
                                   (organization_id,))
            
            person_data_res = res.fetchall()
            
            res = self.con.execute("""SELECT t.id, d.name, d.note
                                   FROM description d,
                                   (
                                       SELECT c.id, a.description_id
                                       FROM connection c, person p, address a
                                       WHERE c.organization_id = ? AND c.person_id = p.id AND c.address_id = a.id
                                   ) t
                                   WHERE t.description_id = d.id;""",
                                   (organization_id,))
            
            address_data_res = res.fetchall()
        
        for i in range(len(person_data_res)):
            person_data = person_data_res[i]
            address_data = address_data_res[i]
            
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
        returns: List with 3 string entries for organization, person, and address.
                 The id, name, and note for person and address get combined into one string.
        """
        
        if connection_id < 0:
            return ["", "", ""]
        
        with self.con:
            res = self.con.execute("""SELECT d.name
                                      FROM connection c, organization o, description d
                                      WHERE c.id = ? AND c.organization_id = o.id AND o.description_id = d.id;""",
                                      (connection_id,))
            
            organization_res = res.fetchone()
            
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
        
        return [organization_res[0], person_combination, address_combination]
    
    
    @Slot(int, result=list)
    def getOrganizationConnection(self, connection_id: int) -> list:
        """
        Returns a list with all organizations that exist ordered by name, note and id.
        connection_id: Currently edited connection_id. Set to < 0 if a connection is added.
        returns: A list containing a list with the following specification: list[[organization_id, name, note], ...].
                 If the connection_id is >= 0, the currently selected organization will be at the top of the list.
        """
        
        
        selected_organization_id = None
        
        with self.con:
            if connection_id >= 0:
                res = self.con.execute("""SELECT organization_id FROM connection WHERE id = ?;""", (connection_id,))
                selected_organization_id = res.fetchone()[0]
            
            res = self.con.execute("""SELECT o.id, d.name, d.note
                                      FROM organization o, description d
                                      WHERE o.description_id = d.id
                                      ORDER BY d.name ASC, d.note ASC, o.id ASC;""")
            all_organizations = res.fetchall()
        
        avail_organizations = []
        for organization in all_organizations:
            if selected_organization_id is not None and organization[0] == selected_organization_id:
                avail_organizations.insert(0, [organization[0], organization[1], organization[2]])
            else:
                avail_organizations.append([organization[0], organization[1], organization[2]])
        
        return avail_organizations
    
    
    @Slot(int, result=list)
    def getPersonConnection(self, connection_id: int) -> list:
        """
        Returns a list with all persons that exist ordered by name, note and id.
        connection_id: Currently edited connection_id. Set to < 0 if a connection is added.
        returns: A list containing a list with the following specification: list[[person_id, name, note], ...].
                 If the connection_id is >= 0, the currently selected person will be at the top of the list.
        """
        
        selected_person_id = None
        
        with self.con:
            if connection_id >= 0:
                res = self.con.execute("""SELECT person_id FROM connection WHERE id = ?;""", (connection_id,))
                selected_person_id = res.fetchone()[0]
            
            res = self.con.execute("""SELECT p.id, d.name, d.note
                                      FROM person p, description d
                                      WHERE p.description_id = d.id
                                      ORDER BY d.name ASC, d.note ASC, p.id ASC;""")
            all_persons = res.fetchall()
        
        avail_persons = []
        for person in all_persons:
            if selected_person_id is not None and person[0] == selected_person_id:
                avail_persons.insert(0, [person[0], person[1], person[2]])
            else:
                avail_persons.append([person[0], person[1], person[2]])
        
        return avail_persons
    
    
    @Slot(int, result=list)
    def getAddressConnection(self, connection_id: int) -> list:
        """
        Returns a list with all addresses that exist ordered by name, note and id.
        connection_id: Currently edited connection_id. Set to < 0 if a connection is added.
        returns: A list containing a list with the following specification: list[[address_id, name, note], ...].
                 If the connection_id is >= 0, the currently selected person will be at the top of the list.
        """
        
        selected_address_id = None
        
        with self.con:
            if connection_id >= 0:
                res = self.con.execute("""SELECT address_id FROM connection WHERE id = ?;""", (connection_id,))
                selected_address_id = res.fetchone()[0]
            
            res = self.con.execute("""SELECT a.id, d.name, d.note
                                      FROM address a, description d
                                      WHERE a.description_id = d.id
                                      ORDER BY d.name ASC, d.note ASC, a.id ASC;""")
            all_addresses = res.fetchall()
        
        avail_addresses = []
        for address in all_addresses:            
            if selected_address_id is not None and address[0] == selected_address_id:
                avail_addresses.insert(0, [address[0], address[1], address[2]])
            else:
                avail_addresses.append([address[0], address[1], address[2]])
        
        return avail_addresses
    
    
    @Slot(str, int, str, result=int)
    def getParentId(self, table_name: str, pk: int, pk_column_name: str) -> int:
        """
        Returns the parent id for a specific id in a specific table.
        table_name: Name of the table where pk_column_name and the parent id are located.
        pk: Primary key for the specific row
        pk_column_name: Primary key column name
        returns: Parent_id if it is defined, otherwise -1
        """
        
        with self.con:
            res = self.con.execute(f"""SELECT parent_id FROM {table_name} WHERE {pk_column_name} = ? LIMIT 1;""",
                                   (pk,))
            
            parent_id = res.fetchone()
            
        if parent_id is None:
            return -1
        
        return parent_id

    
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
    
    
    @Slot(int, int, int, int, result=bool)
    def checkConnection(self, connection_id: int, organization_id: int, person_id: int, address_id: int) -> bool:
        """
        Checks if a connection based on the person_id and address_id already exist.
        The own connection_id is ignored in this search.
        connection_id: Connection id if editing an existing connection, otherwise -1
        organization_id: Organization id that should be checked
        person_id: Person id that should be checked
        address_id: Address id that should be checked
        returns: True if the connection doesn't exist yet (ignoring the own connection), otherwise False
        """
        
        found_connection = None
        
        with self.con:    
            if connection_id >= 0:
                res = self.con.execute("""SELECT id
                                          FROM connection
                                          WHERE (NOT id = ?) AND organization_id = ? AND person_id = ? AND address_id = ?
                                          LIMIT 1;""",
                                       (connection_id, organization_id, person_id, address_id))
                
                found_connection = res.fetchone()
            else:
                res = self.con.execute("""SELECT id
                                          FROM connection
                                          WHERE organization_id = ? AND person_id = ? AND address_id = ? LIMIT 1;""",
                                       (organization_id, person_id, address_id))
                
                found_connection = res.fetchone()
        
        if found_connection is None:
            return True
        else:
            return False
    
    
    def setModified_CreatedTimestamps(self, metadata_id: int) -> None:
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
        """
        Sets the name and note for a specific table to the given values.
        Additionaly, it also updates the modified and created timestamps in the metadata table.
        name: New name that shall be set; len(name.strip()) must be > 0
        note: New note that shall be set
        pk: Primary key
        pk_column_name: Name of the column where the primary key is located
        table_name: Name of the table where the pk_column_name is located
        returns: Error message as string; Empty string if no error
        """
        
        metadata_id = None
        
        try:
            if pk < 0:
                raise ValueError("Primary key is <0")
            
            if len(name.strip()) <= 0:
                raise ValueError("Name must be set")
            
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
            return "Database::setName_Note_byPk: " + str(e)
        
        self.clear_cache()
        self.setModified_CreatedTimestamps(metadata_id)
        self.dataChanged.emit()
        return ""
    
    
    @Slot(str, int, str, str, None, result=str)
    @Slot(str, int, str, str, str, result=str)
    def setValue_Str(self, column_name: str, pk_id: int, pk_column_name: str, table_name: str, value: str | None = None) -> str:
        """
        Set a value in a column to a specific value.
        column_name: Column name where the value should be set
        pk_id: Primary key which specifies the row's value which shall be changed
        pk_column_name: Column name of the primary key
        table_name: Name of the table, where column_name and pk_column_name are located
        value: New value that should be set
        returns: Error message as string; Empty string if no error
        """
        
        try:
            if pk_id < 0:
                raise ValueError("Primary key < 0")
            
            with self.con:
                self.con.execute(f"""UPDATE {table_name}
                                    SET {column_name} = ?
                                    WHERE {pk_column_name} = ?;""",
                                    (value, pk_id))
        except Exception as e:
            return "Database::setValue_Str: " + str(e)
        
        self.clear_cache()
        self.dataChanged.emit()
        return ""
    
    
    @Slot(int, str, str, list, result=str)
    def setOther(self, fk_id: int, fk_column_name: str, table_name: str, new_other: list) -> str:
        """
        Saves the 'other' entries for a specific entry.
        fk_id: Identifier of the base entry
        fk_column_name: Name of the foreign key column in the 'other' table
        table_name: 'other' table name
        new_other: List of new values to be set:
                   list[dict['other_index': int, 'property_derivate_flag': bool, 'property_value': str]]
        returns: Error message as string; Empty string if no error
        """
        
        try:
            if fk_id < 0:
                raise ValueError("Primary key is not set")
            
            with self.con:
                self.con.execute(f"""DELETE FROM {table_name} WHERE {fk_column_name} = ?;""",
                                (fk_id,))
                
                for other in new_other:
                    other_index = other["other_index"]
                    value = other["property_value"]
                    
                    if other["property_derivate_flag"] == True or value is None:
                        continue
                    
                    self.con.execute(f"""INSERT INTO {table_name} ({fk_column_name}, other_index, content)
                                         VALUES (?, ?, ?);""",
                                    (fk_id, other_index, value))
        except Exception as e:
            return "Database::setOther: " + str(e)
        
        self.clear_cache()
        self.dataChanged.emit()
        return ""
    
    
    @Slot(int, str, str, result=str)
    @Slot(int, str, str, str, str, result=str)
    def duplicateEntry(self, pk: int, pk_column_name: str, table_name: str, other_fk_column_name: str | None = None, other_table_name: str | None = None) -> str:
        """
        Shallow duplicate a specific entry with metadata and description (and optional 'other' table).
        pk: Primary key of the entry that shall be duplicated
        pk_column_name: Column name of the primary key
        table_name: Name of the table where the primary key column is located
        other_fk_column_name [optional]: Foreign key column name for a 'other' table. Must be specified if other_table_name is set.
        other_table_name [optional]: Table name of the 'other' table. Must be specified if other_fk_column_name is set.
        returns: Error message as string; Empty string if no error
        """
        
        new_metadata_id = None
        
        try:
            if pk < 0:
                raise ValueError("Primary key < 0")
            
            column_names_non_pk = ", ".join(self.getNonPrimaryKeyColumnNames(table_name))
            description_column_names_non_pk = ", ".join(self.getNonPrimaryKeyColumnNames("description"))
            metadata_column_names_non_pk = ", ".join(self.getNonPrimaryKeyColumnNames("metadata"))
            other_column_names_non_pk = None
            if other_fk_column_name is not None and other_table_name is not None:
                res_list = self.getNonPrimaryKeyColumnNames(other_table_name)
                res_list.remove(other_fk_column_name)
                other_column_names_non_pk = ", ".join(res_list)
            
            with self.con:
                # Duplicate description & metadata
                res = self.con.execute(f"""SELECT description_id, metadata_id FROM {table_name} WHERE {pk_column_name} = ?""",
                                       (pk,))
                description_id, metadata_id = res.fetchone()
                
                self.con.execute(f"""INSERT INTO description ({description_column_names_non_pk})
                                     SELECT {description_column_names_non_pk} FROM description WHERE id = ? LIMIT 1;""",
                                 (description_id,))
                res = self.con.execute("""SELECT last_insert_rowid() AS id;""")
                new_description_id = res.fetchone()[0]
                
                self.con.execute(f"""INSERT INTO metadata ({metadata_column_names_non_pk})
                                     SELECT {metadata_column_names_non_pk} FROM metadata WHERE id = ? LIMIT 1;""",
                                 (metadata_id,))
                res = self.con.execute("""SELECT last_insert_rowid() AS id;""")
                new_metadata_id = res.fetchone()[0]
                self.con.execute("""UPDATE metadata SET date_created = '' WHERE id = ?""",
                                 (new_metadata_id,))
                
                # Duplicate entry
                self.con.execute(f"""INSERT INTO {table_name} ({column_names_non_pk})
                                     SELECT {column_names_non_pk} FROM {table_name} WHERE id = ? LIMIT 1;""",
                                 (pk,))
                res = self.con.execute("""SELECT last_insert_rowid() AS id;""")
                new_pk = res.fetchone()[0]
                
                # Insert new description id and metadata id
                self.con.execute(f"""UPDATE {table_name}
                                     SET description_id = ?, metadata_id = ?
                                     WHERE id = ?;""",
                                 (new_description_id, new_metadata_id, new_pk))
                
                # Duplicate other table
                if other_fk_column_name is not None and other_table_name is not None and other_column_names_non_pk is not None:
                    self.con.execute(f"""INSERT INTO {other_table_name} ({other_fk_column_name}, {other_column_names_non_pk})
                                         SELECT {new_pk} AS {other_fk_column_name}, {other_column_names_non_pk}
                                             FROM {other_table_name}
                                             WHERE {other_fk_column_name} = ?;""",
                                     (pk,))
        except Exception as e:
            return "Database::duplicateEntry: " + str(e)
        
        self.clear_cache()
        self.setModified_CreatedTimestamps(new_metadata_id)
        self.dataChanged.emit()
        return ""
    
    
    @Slot(str, str, int, None, result=str)
    @Slot(str, str, int, str, result=str)
    def createOrganization(self, name: str, note: str, parent_id: int, website: str | None = None) -> str:
        """
        Creates a new organization in the db.
        name: Name of the new organization; len(name.strip()) must be > 0
        note: Note of the new organization
        parent_id: Parent id of the new organization; set to <0 if no parent exists
        website: Website of the new organization; set to None if no website is set
        returns: Error message as string; Empty string if no error message
        """
        
        metadata_id = None
        description_id = None
        
        if parent_id < 0:
            parent_id = None
        
        try:
            if len(name.strip()) <= 0:
                raise ValueError("Name must be set")
            
            with self.con:
                res = self.con.execute("""INSERT INTO metadata (date_created, date_modified)
                                          VALUES ('', '') RETURNING id;""")
                metadata_id = res.fetchone()[0]
                
                res = self.con.execute("""INSERT INTO description (name, note)
                                          VALUES (?, ?) RETURNING id;""",
                                    (name, note))
                description_id = res.fetchone()[0]
                
                self.con.execute("""INSERT INTO organization (parent_id, description_id, metadata_id, website)
                                    VALUES (?, ?, ?, ?);""",
                                 (parent_id, description_id, metadata_id, website))
        
            self.setModified_CreatedTimestamps(metadata_id)
        except Exception as e:
            return "Database::createOrganization: " + str(e)
        
        self.clear_cache()
        self.dataChanged.emit()
        return ""
    
    
    @Slot(str, str, int, list, result=str)
    def createPerson(self, name: str, note: str, parent_id: int, values: list) -> str:
        """
        Creates a new person in the db.
        name: Description name of the new person; len(name.strip()) must be > 0
        note: Note of the new person
        parent_id: Parent id of the new person; set to <0 if no parent exists
        values: List of values for the new person:
                list[title: str | None, gender: str | None, firstname: str | None, middlename: str | None, surname: str | None]
        returns: Error message as string; Empty string if no error message
        """
        
        metadata_id = None
        description_id = None
        
        if parent_id < 0:
            parent_id = None
        
        try:
            if len(name.strip()) <= 0:
                raise ValueError("Name must be set")
            
            with self.con:
                res = self.con.execute("""INSERT INTO metadata (date_created, date_modified)
                                          VALUES ('', '') RETURNING id;""")
                metadata_id = res.fetchone()[0]
                
                res = self.con.execute("""INSERT INTO description (name, note)
                                          VALUES (?, ?) RETURNING id;""",
                                       (name, note))
                description_id = res.fetchone()[0]
                
                self.con.execute("""INSERT INTO person (parent_id, description_id, metadata_id, title, gender, firstname, middlename, surname)
                                    VALUES (?, ?, ?, ?, ?, ?, ?, ?);""",
                                 (parent_id, description_id, metadata_id, values[0], values[1], values[2], values[3], values[4]))
        
            self.setModified_CreatedTimestamps(metadata_id)
        except Exception as e:
            return "Database::createPerson: " + str(e)
        
        self.clear_cache()
        self.dataChanged.emit()
        return ""
    
    
    @Slot(str, str, int, list, list, result=str)
    def createAddress(self, name: str, note: str, parent_id: int, values: list, other: list) -> str:
        """
        Creates a new address in the db.
        name: Description name of the new address; len(name.strip()) must be > 0
        note: Note of the new address
        parent_id: Parent id of the new address; set to <0 if no parent exists
        values: List of values for the new address:
                list[street: str | None, number: str | None, postalcode: str | None, city: str | None, country: str | None]
        other: List of 'other' values to be set:
               list[dict['other_index': int, 'property_derivate_flag': bool, 'property_value': str]]
        returns: Error message as string; Empty string if no error message
        """
        
        metadata_id = None
        description_id = None
        
        if parent_id < 0:
            parent_id = None
        
        try:
            if len(name.strip()) <= 0:
                raise ValueError("Name must be set")
            
            with self.con:
                res = self.con.execute("""INSERT INTO metadata (date_created, date_modified)
                                          VALUES ('', '') RETURNING id;""")
                metadata_id = res.fetchone()[0]
                
                res = self.con.execute("""INSERT INTO description (name, note)
                                          VALUES (?, ?) RETURNING id;""",
                                       (name, note))
                description_id = res.fetchone()[0]
                
                res = self.con.execute("""INSERT INTO address (parent_id, description_id, metadata_id, street, number, postalcode, city, country)
                                          VALUES (?, ?, ?, ?, ?, ?, ?, ?) RETURNING id;""",
                                       (parent_id, description_id, metadata_id, values[0], values[1], values[2], values[3], values[4]))
        
                pk_id = res.fetchone()[0]
            
            self.setOther(pk_id, "address_id", "address_other", other)
            self.setModified_CreatedTimestamps(metadata_id)
        except Exception as e:
            return "Database::createAddress: " + str(e)
        
        self.clear_cache()
        self.dataChanged.emit()
        return ""
    
    
    @Slot(int, int, int, int, result=str)
    def saveConnection(self, connection_id: int, organization_id: int, person_id: int, address_id: int) -> str:
        """
        Edits an existing connection or creates a new one after checking if new connection already exists.
        connection_id: Connection id that should be edited; -1 if a new connection shall be created
        organization_id: Organization id in the new connection
        person_id: Person id in the new connection
        address_id: Address id in the new connection
        returns: Empty string if no error, otherwise error message as string
        """
        
        if organization_id < 0 or person_id < 0 or address_id < 0:
            return "Database::saveConnection: " + "Not all ids for a connection defined."
        
        if not self.checkConnection(connection_id, organization_id, person_id, address_id):
            return "Database::saveConnection: " + "Connection is not unique."
        
        try:
            with self.con:
                if connection_id >= 0:
                    # Edit existing connection
                    self.con.execute("""UPDATE connection
                                        SET person_id = ?, address_id = ?
                                        WHERE id = ?;""",
                                     (person_id, address_id, connection_id))
                else:
                    # Create new entry
                    self.con.execute("""INSERT INTO connection (organization_id, person_id, address_id)
                                        VALUES (?, ?, ?);""",
                                     (organization_id, person_id, address_id))
        except Exception as e:
            return "Database::saveConnection: " + str(e)
        
        self.clear_cache()
        self.dataChanged.emit()
        return ""
    
    
    @Slot(int, result=bool)
    def deleteConnection(self, connection_id: int) -> bool:
        """
        Deletes a defined connection.
        connection_id: Connection id that shall be deleted
        returns: True if successfull, else False
        """
        
        if connection_id < 0:
            return False
        
        with self.con:
            self.con.execute("""DELETE FROM connection WHERE id = ?;""",
                             (connection_id,))
        
        self.clear_cache()
        self.dataChanged.emit()
        return True
    
    
    @Slot(int, str, str, result=str)
    def deleteEntry(self, pk: int, pk_column_name: str, table_name: str) -> str:
        """
        Deletes a specified entry and all non referenced descriptions and metadata.
        pk: Primary key of the entry that shall be deleted
        pk_column_name: Primary key's column name
        table_name: Table name, where the pk_column is located
        returns: Error message as string; Empty string if no error
        """
        
        try:
            if pk < 0:
                raise ValueError("Primary key < 0")
            
            with self.con:
                # Delete entry
                self.con.execute(f"""DELETE FROM {table_name} WHERE {pk_column_name} = ?;""",
                                 (pk,))
            
            with self.con:
                # Delete all descriptions that are no longer referenced
                self.con.execute("""DELETE FROM description
                                    WHERE id NOT IN (SELECT DISTINCT description_id FROM organization)
                                          AND id NOT IN (SELECT DISTINCT description_id FROM person)
                                          AND id NOT IN (SELECT DISTINCT description_id FROM address);""")
                
                # Delete all metadata that are no longer referenced
                self.con.execute("""DELETE FROM metadata
                                    WHERE id NOT IN (SELECT DISTINCT metadata_id FROM organization)
                                          AND id NOT IN (SELECT DISTINCT metadata_id FROM person)
                                          AND id NOT IN (SELECT DISTINCT metadata_id FROM address);""")
        except Exception as e:
            return "Database::deleteEntry: " + str(e)
        
        self.clear_cache()
        self.dataChanged.emit()
        return ""


    @Slot(int, str, str, str, result=list)
    def getData(self, pk_id: int, pk_column_name: str, column_name: str, table_name: str) -> list:
        """
        Returns the column value for a specific table.
        If the tables's column value is Null and it has a parent, the parent's column value is returned (and so on).
        pk_id: Primary key id whose website shall be returned
        pk_column_name: Column name of the primary key's column
        column_name: Column name whose value shall be returned
        table_name: Name of the table where the column_name and pk_column_name are located
        returns: list[column_value: str | None, derivate_flag: bool].
                 The derivate_flag is True if the column value from one of the parents is returned, otherwise False.
        """
        
        if pk_id < 0:
            return ["", False]
        
        result = None
        parent_id = pk_id
        derivate = False
        
        with self.con:
            while parent_id is not None and result is None:
                res = self.con.execute(f"""SELECT {column_name}, parent_id
                                           FROM {table_name}
                                           WHERE {pk_column_name} = ?""",
                                       (parent_id,))
                
                tmp_res = res.fetchone()
                result = tmp_res[0]
                
                if result == None and parent_id == pk_id and tmp_res[1] is not None:
                    derivate = True
                
                parent_id = tmp_res[1]
        
        return [result, derivate]
    
    
    @Slot(int, str, str, str, result=list)
    def getDataDerivate(self, pk_id: int, pk_column_name: str, column_name: str, table_name: str) -> list:
        """
        Returns the parent's column value. If the row has no parent, [None] is returned.
        If the parent's column valule is Null, searching for the column value at parent's parent and so on.
        pk_id: Primary key id whose derivate column value shall be returned
        pk_column_name: Column name of the primary key's column
        column_name: Column name whose value shall be returned
        table_name: Name of the table where the column_name and pk_column_name are located
        returns: list[column_value: str] if one exists, otherwise list[None]
        """
        
        if pk_id < 0:
            return [None]
        
        result = None
        parent_id = pk_id
        
        with self.con:
            res = self.con.execute(f"""SELECT parent_id FROM {table_name} WHERE {pk_column_name} = ?""",
                                   (parent_id,))
            
            res_first = res.fetchone()
            parent_id = res_first[0]
            if parent_id is None:
                # Row is already root
                return [None]
            
            while parent_id is not None and result is None:
                res = self.con.execute(f"""SELECT {column_name}, parent_id FROM {table_name} WHERE {pk_column_name} = ?""",
                                       (parent_id,))
                
                result_res = res.fetchone()
                result = result_res[0]
                parent_id = result_res[1]
        
        return [result]
    
    
    @Slot(int, str, str, result=list)
    def getMetadata(self, pk: int, pk_column_name: str, table_name: str) -> list:
        """
        Returns the metadata for a given primary key, primary key column name and table name.
        pk: Primary key of the entry
        pk_column_name: Primary key's column name
        table_name: Name of the table, where the primary key and pk_column are located
        returns: list[date_modified: str, date_created: str]
        """
        
        if pk < 0:
            return ["", ""]
        
        with self.con:
            res = self.con.execute(f"""SELECT datetime(m.date_modified, 'localtime'), datetime(m.date_created, 'localtime')
                                FROM {table_name} t, metadata m
                                WHERE t.{pk_column_name} = ? AND t.metadata_id = m.id;""",
                                (pk,))
            
            dates = res.fetchone()
        
        return [self.adaptDateTimeToLocale(dates[0]), self.adaptDateTimeToLocale(dates[1])]
    
    
    @Slot(result=list)
    def getDBMetadata(self) -> list:
        """
        Returns the database metadata.
        returns: list[db_version: str, date_modified: str, date_created: str]
        """
        
        with self.con:
            res = self.con.execute(f"""SELECT content
                                FROM __meta__
                                WHERE name = ?
                                LIMIT 1;""",
                                ("db_version",))
            
            db_version = res.fetchone()[0]
            
            res = self.con.execute(f"""SELECT datetime(content, 'localtime')
                                FROM __meta__
                                WHERE name = ?
                                LIMIT 1;""",
                                ("date_saved",))
            
            date_saved = self.adaptDateTimeToLocale(res.fetchone()[0])
            
            res = self.con.execute(f"""SELECT datetime(content, 'localtime')
                                FROM __meta__
                                WHERE name = ?
                                LIMIT 1;""",
                                ("date_created",))
            
            date_created = self.adaptDateTimeToLocale(res.fetchone()[0])
        
        return [db_version, date_saved, date_created]
    
    
    def _getSearchResultCompleteColumnNames(self, table_name: str | None = None, column_names: list | None = None) -> list:
        """
        Returns a list of column names used for the search result tables.
        Note: Either table_name or column_names (or both) must be defined!
        table_name [optional]: Name of the table whose column names shall be returned
        column_names [optional]: Predefined column names that will be used instead of querying the db for better performance
        returns: List of strings with all the column names used for the search tables
        """
        
        if table_name is None and column_names is None:
            raise ValueError("Database::_getSearchResultCompleteColumnNames: Either table_name or column_names must be defined")
        
        if column_names is None:
            column_names = self.getNonPrimaryKeyNonForeignKeyColumnNames(table_name)
        
        complete_column_names = ["id", "name", "note"]
        complete_column_names.extend(column_names)
        complete_column_names.extend(["modified", "created"])
        
        return complete_column_names
    
    
    def _updateSearchCache(self, table_name) -> None:
        """
        Checks if the data for a specific table name is already cached or adds it for faster search responses.
        If yes, the function simply returns.
        If no, the function adds the data to the self._search_data_cache dictionary.
        table_name: Table name that should be cached
        """
        
        if table_name in self._search_data_cache.keys():
            # Data already cached -> nothing to do
            return
        
        # Data is not cached: Read newest data and store in dict
        with self.con:
            column_names = self.getNonPrimaryKeyNonForeignKeyColumnNames(table_name)
            column_names_str = ""
            for column_name in column_names:
                column_names_str += f", t.{column_name}"
            
            res = self.con.execute(f"""SELECT c.organization_id, c.person_id, c.address_id, t.id, d.name, d.note {column_names_str}, datetime(m.date_modified, 'localtime'), datetime(m.date_created, 'localtime')
                                       FROM {table_name} t
                                       LEFT JOIN connection c
                                       ON t.id = c.{table_name}_id
                                       LEFT JOIN description d
                                       ON t.description_id = d.id
                                       LEFT JOIN metadata m
                                       ON t.metadata_id = m.id
                                       ORDER BY d.name ASC;""")
            
            data_list = res.fetchall()
        
        # Convert list[tupel] to list[dict]
        complete_column_names = ["organization_id", "person_id", "address_id"]
        complete_column_names.extend(self._getSearchResultCompleteColumnNames(table_name, column_names))
        
        data = []
        for row in data_list:
            row_dict = {}
            for i, column_name in enumerate(complete_column_names):
                val = row[i]
                if column_name in ["modified", "created"]:
                    val = self.adaptDateTimeToLocale(val)
                row_dict[column_name] = val
            data.append(row_dict)
        
        self._search_data_cache[table_name] = data
    
    
    @Slot(str, str, int, int, int, list, result=list)
    def search(self, table_name: str, search_term: str, organization_id: int, person_id: int, address_id: int,
               search_properties: list) -> list:
        """
        Performs a search for the given parameters on a specific table.
        First, it looks for the search_term (if not empty string) in all specified search_properties.
            It must be present in at least one specified column.
            If all search_properties are deactivated, all values will be returned.
        Next, it will filter for the organization_id, person_id and address_id.
            Only entries that have a connection with all the specified ids will be returned.
            Furthermore, the selected organization_id, person_id and address_id itself will always be returned.
        table_name: Table name who's values shall be returned
        search_term: Search string that it should filter for in the specified search_properties
                     (pass empty string if no search_term shall be used)
        organization_id: An organization_id who's connections (and itself) will be returned
        person_id: An person_id who's connections (and itself) will be returned
        address_id: An address_id who's connections (and itself) will be returned
        search_properties: List defining which columns should be used for the search_term
                           Format: list[{"column_name": str, "button_checked": true}]
                           button_checked is True if the column is part of the search, otherwise False
        returns: List of lists with all the rows. The first list is always reserved for the column names.
        """
        
        # Update cache
        self._updateSearchCache(table_name)

        # Get current data from cache
        row_data = self._search_data_cache[table_name]
        
        def filter_function(var) -> bool:
            """
            Function used for filtering the data.
            returns: True if value shall remain in result, False if value shall be removed from the result list
            """
            
            if search_term != "":
                found_cnt = 0
                search_cnt = 0
                for search_property in search_properties:
                    if search_property["button_checked"] == True:
                        search_cnt += 1
                        
                        if var[search_property["column_name"]] is None:
                            continue
                        
                        search_res = re.search(search_term, var[search_property["column_name"]])
                        
                        if search_res is not None:
                            found_cnt += 1
                            break
                
                if found_cnt == 0 and search_cnt > 0:
                    return False
            
            if organization_id >= 0:
                if var["organization_id"] != organization_id and not (table_name == "organization" and var["id"] == organization_id):
                    return False
            
            if person_id >= 0:
                if var["person_id"] != person_id and not (table_name == "person" and var["id"] == person_id):
                    return False
            
            if address_id >= 0:
                if var["address_id"] != address_id and not (table_name == "address" and var["id"] == address_id):
                    return False
            
            return True
        
        # Filter rows
        filtered_row_data = list(filter(filter_function, row_data))
        
        # Convert data to list format
        res = []
        res_ids = []  # list of all ids already added to avoid duplicate ids
        for i, row in enumerate(filtered_row_data):
            if i == 0:  # At first and only at first, the header names shall be added to the list
                header_list = []
                
                for column_name in row.keys():
                    if column_name not in ["organization_id", "person_id", "address_id"]:
                        header_list.append(column_name)
                        
                res.append(header_list)
            
            row_list = []
            for column_name, cell in row.items():
                if column_name in ["organization_id", "person_id", "address_id"]:
                    continue
                
                row_list.append(cell)
            
            if row["id"] in res_ids:
                continue
            
            res_ids.append(row["id"])
            res.append(row_list)
        
        if len(res) == 0:
            res.append(self._getSearchResultCompleteColumnNames(table_name))

        return res
    
    
    @Slot(list, result=list)
    def translateColumnNames(self, column_names: list) -> list:
        """
        Translates a list of strings which represent the column names to the correct language.
        If no translation for a column name was found, the original English developer version will be returned.
        column_names: list[str] with all the column names that should be translated
        returns: list[str] with the translations
        """
        
        res = []
        for column_name in column_names:
            match column_name:
                case "id":
                    res.append(column_name)
                case "name":
                    res.append(QCoreApplication.translate("Database", "name"))
                case "note":
                    res.append(QCoreApplication.translate("Database", "note"))
                case "modified":
                    res.append(QCoreApplication.translate("Database", "modified"))
                case "created":
                    res.append(QCoreApplication.translate("Database", "created"))
                case "website":
                    res.append(QCoreApplication.translate("Database", "website"))
                case "title":
                    res.append(QCoreApplication.translate("Database", "title"))
                case "gender":
                    res.append(QCoreApplication.translate("Database", "gender"))
                case "firstname":
                    res.append(QCoreApplication.translate("Database", "firstname"))
                case "middlename":
                    res.append(QCoreApplication.translate("Database", "middlename"))
                case "surname":
                    res.append(QCoreApplication.translate("Database", "surname"))
                case "street":
                    res.append(QCoreApplication.translate("Database", "street"))
                case "number":
                    res.append(QCoreApplication.translate("Database", "number"))
                case "postalcode":
                    res.append(QCoreApplication.translate("Database", "postalcode"))
                case "city":
                    res.append(QCoreApplication.translate("Database", "city"))
                case "country":
                    res.append(QCoreApplication.translate("Database", "country"))
                case _:
                    print("Database::translateColumnNames: Missing translation for:", column_name)
                    res.append(column_name)
        
        return res
    
    
    def adaptDateTimeToLocale(self, datetime_str: str) -> str:
        """
        Converts a time string to the format of self.locale, beginning with the time followed by the date.
        datetime_str: Datetime string in the format "yyyy-MM-dd HH:mm:ss"
        returns: Datetime string based on self.locale; first time than date
        """
        
        datetime = QDateTime.fromString(datetime_str, "yyyy-MM-dd HH:mm:ss")
        
        local_time = self.locale.toString(datetime, "HH:mm:ss")
        local_date = self.locale.toString(datetime, self.locale.dateFormat(QLocale.ShortFormat))

        return local_time + ' ' + local_date
    