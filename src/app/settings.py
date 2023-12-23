import json
from pathlib import Path
from PySide6.QtCore import QObject, Slot, Signal, QUrl


class Settings(QObject):
    """
    Class used for handling the settings json file with all nonvolatile settings.
    """
    
    def __init__(self, file_path: Path) -> None:
        """
        file_path: Path to the settings file that should be used
        """
        
        super().__init__()
        self.file_path = file_path
        self.settings = {}
        self.default_file_path = Path(__file__).parent / "res" / "default_settings.json"
        
        self.__load_settings_file__()
    
    
    def __load_settings_file__(self) -> None:
        """
        Loads the settings file into the self.settings dictionary.
        If the settings file doesn't exist, a new one will be created based on the default settings file.
        """
        
        file = None
        try:
            file = open(self.file_path, 'r')
            self.settings = json.loads(file.read())
        except FileNotFoundError as e:
            self.__load_default_settings__()
        finally:
            if file:
                file.close()
            
            
    def __load_default_settings__(self) -> None:
        """
        Loads the default settings file and initialzes self.settings with the contents.
        With these values, a new settings file is created.
        raises RuntimeError: In case the default settings file is missing
        """
        
        default_file = None
        try:
            default_file = open(self.default_file_path, 'r')
            self.settings = json.loads(default_file.read())
        except FileNotFoundError as e:
            raise RuntimeError("Settings::__load_default_settings__: Default settings file missing. Try reinstalling the program.")
        finally:
            if default_file:
                default_file.close()
        
        self.__save_settings_file__()
        
        
    def __save_settings_file__(self) -> None:
        """
        Saves the contents of self.settings in a file.
        """
        
        try:
            file = open(self.file_path, 'w')
            file.write(json.dumps(self.settings, indent=4))
        finally:
            if file:
                file.close()
                
    
    def settings_autosave(func):
        """
        Decorator for autosaving the settings file after the decorated function was executed.
        Additionally, it is checked if the settings are initialized:
        raises RuntimeError: If seetings are not initialized.
        """
        
        def inner(*args, **kwargs):
            
            # Check if settings are initialized
            if len(args[0].settings) <= 0:
                raise RuntimeError("Settings::settings_save_decorator: Settings are not initalized.")
            
            # Execute the function
            returned_value = func(*args, **kwargs)
            
            # Save settings file
            args[0].__save_settings_file__()
            
            # return the function's value
            return returned_value
            
        return inner
               
    
    @Slot(str)
    @settings_autosave
    def addRecentFile(self, file_path: str) -> None:
        """
        Add a file path to the list of recent files.
        If the file path already exists, the old file path will be deleted and a new one will be created on top.
        Maximum 10 recent files are stored.
        If there are more than 10 files, the oldest gets deleted.
        file_path: File path that should be added to the list of recent files
        """
        
        if file_path in self.settings["recent_files"]:
            self.settings["recent_files"].remove(file_path)
        
        self.settings["recent_files"].insert(0, file_path)
        
        while len(self.settings["recent_files"]) > 10:
            self.settings["recent_files"].pop()
            
    
    @settings_autosave
    def removeRecentFile(self, file_path: str) -> None:
        """
        Remove a file path from the recent file list.
        If the file path doesn't exist in the recent files list, nothing changes.
        """
        
        if file_path in self.settings["recent_files"]:
            self.settings["recent_files"].remove(file_path)
    
    
    @Slot(result=list)
    def getRecentFiles(self) -> list[str]:
        """
        returns: A list containing all recent files.
        """
        
        return self.settings["recent_files"]
