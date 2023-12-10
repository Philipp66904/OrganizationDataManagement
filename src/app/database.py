from pathlib import Path, PurePath
import os
import sqlite3
from sqlite3 import Error

class Database:
    """
    Handles the database operations like the in-memory db, or loading and saving to external files.
    """
    
    def __init__(self):
        """
        Initialises the in-memory database with the values from the template db.
        """
        
        self.con = sqlite3.connect(":memory:")
        self.path_template_db = Path(__file__).parent / "res" / "template.db"
        print("template path:", self.path_template_db)
        
        self.readTemplateDB()
    
    
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
            
            # Copy data over
            with con_external:
                with self.con:
                    self.con.backup(con_external)
            
            # Close source db
            con_external.close()
        except Error as e:
            raise e
