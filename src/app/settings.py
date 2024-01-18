import json
import re
import os
from pathlib import Path
from PySide6.QtCore import QObject, Slot, Signal, QUrl, QCoreApplication
from PySide6.QtGui import QColor


class Settings(QObject):
    """
    Class used for handling the settings json file with all nonvolatile settings.
    """
    
    def __init__(self, file_path: Path, translations_path: Path) -> None:
        """
        file_path: Path to the settings file that should be used
        """
        
        super().__init__()
        self.file_path = file_path
        self.settings = {}
        self.default_file_path = Path(__file__).parent / "res" / "default_settings.json"
        self.translations_path = translations_path
        
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
        Loads the default settings file and initilizes self.settings with the contents.
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
    
    
    @Slot(str, QColor)
    def slot_setThemeColor(self, color_name: str, new_color: QColor) -> None:
        """
        Wrapper slot for setThemeColor.
        """
        
        self.setThemeColor(color_name, new_color)
    
    
    @settings_autosave
    def setThemeColor(self, color_name: str, new_color: QColor) -> None:
        """
        Set a theme color to a new value.
        color_name: Name of the color that will be changed
        new_color: New Color value
        """
        
        for i, color in enumerate(self.settings["colors"]):
            color_name_settings = list(color.keys())[0]
            
            if color_name_settings == color_name:
                self.settings["colors"][i] = {color_name: new_color.name()}
    
    
    @Slot()
    def slot_resetThemeColors(self) -> None:
        """
        Wrapper slot for resetThemeColors.
        """
        
        self.resetThemeColors()
    
    
    @settings_autosave
    def resetThemeColors(self) -> None:
        """
        Resets all custom set theme colors by overriding color settings with default settings.
        """
        
        default_file = None
        try:
            default_file = open(self.default_file_path, 'r')
            default_settings = json.loads(default_file.read())
        except FileNotFoundError as e:
            raise RuntimeError("Settings::resetThemeColors: Default settings file missing. Try reinstalling the program.")
        finally:
            if default_file:
                default_file.close()
        
        self.settings["colors"] = default_settings["colors"]
    
    
    @Slot(result=list)
    def getThemeColors(self) -> list:
        """
        returns: A list of lists containing all the theme colors: list[[color_name: str, color: str]]
        """
        
        res = []
        for color in self.settings["colors"]:
            color_name = list(color.keys())[0]
            color_value = list(color.values())[0]
            
            if type(color_name) != str or type(color_value) != str or len(color_name) <= 0 \
               or not re.match("^#[A-Fa-f0-9]{6}$", color_value):
                continue
            
            res.append([color_name, color_value])
        
        return res
    
    
    @Slot(result=str)
    def getActiveLanguage(self) -> str:
        return self.settings["language"]
    
    
    @Slot(str)
    def slot_setActiveLanguage(self, new_language: str):
        self.setActiveLanguage(new_language)
    
    
    @settings_autosave
    def setActiveLanguage(self, new_language: str):
        self.settings["language"] = new_language
    
    
    @Slot(result=list)
    def getAvailableLanguages(self) -> list:
        """
        Returns a list of available languages for selection:
        returns: list[str]
        """
        
        res = ["Follow System","English Development (Fallback)"]
        res.extend(os.listdir(self.translations_path))
        
        return res
    
    
    @Slot(result=str)
    def resetSettings(self) -> str:
        """
        Overwrites the current settings with the default settings file.
        returns: Error msg as string; Empty string if no error
        """
        
        try:
            self.__load_default_settings__()
        except RuntimeError as e:
            return "Settings::resetSettings: " + str(e)
        
        return ""
    
    
    @Slot(bool)
    def slot_setFileTypeAssociation(self, new_file_type_association: bool) -> None:
        """
        Slot for setFileTypeAssociation.
        """
        
        self.setFileTypeAssociation(new_file_type_association)
    
    
    @settings_autosave
    def setFileTypeAssociation(self, new_file_type_association: bool) -> None:
        """
        Sets the file type association to a new value.
        new_file_type_association: New value to be set.
        """
        
        self.settings["file_type_association"] = new_file_type_association
    
    
    @Slot(result=bool)
    def getFileTypeAssociation(self) -> bool:
        """
        Returns the file type association value:
        returns: True if association should exist, otherwise False
        """
        
        return self.settings["file_type_association"]
