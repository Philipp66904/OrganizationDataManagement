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
        self.supported_settings_json_major_version = "1"
        
        self.__load_settings_file__()


    def __check_settings_versions__(self) -> None:
        """
        Checks if the version in the self.settings dictionary is supported by the program.
        The major version must match the one stored in self.supported_settings_json_major_version, while the minor version is ignored.
        raises RuntimeError: If version is incompatible
        """

        if self.settings["version"].split('.')[0] != self.supported_settings_json_major_version:
            raise RuntimeError("Settings::__load_settings_file__: Settings file version unsupported")
        

    @Slot(result=str)
    def getSupportedSettingsVersion(self) -> str:
        """
        Returns the supported settings version by the program.
        returns: Version as string
        """

        return self.supported_settings_json_major_version + ".x"
    

    @Slot(result=str)
    def getLoadedSettingsVersion(self) -> str:
        """
        Returns the currently loaded settings version by the program.
        returns: Version as string
        """

        version = ""

        try:
            version = self.settings["version"]
        except KeyError as e:
            version = "n/a"

        return version
    
    
    def __load_settings_file__(self) -> None:
        """
        Loads the settings file into the self.settings dictionary.
        If the settings file doesn't exist or has an incompatible version, a new one will be created based on the default settings file.
        """
        
        file = None
        try:
            file = open(self.file_path, 'r')
            self.settings = json.loads(file.read())

            self.__check_settings_versions__()
        except FileNotFoundError as e:
            self.__load_default_settings__()
        except KeyError as e:
            self.__load_default_settings__()
        except RuntimeError as e:
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
            self.__check_settings_versions__()
        except FileNotFoundError as e:
            raise RuntimeError(QCoreApplication.translate("Settings", "Settings::__load_default_settings__: Default settings file missing. Try reinstalling the program."))
        except RuntimeError as e:
            raise RuntimeError(QCoreApplication.translate("Settings", "Settings::__load_default_settings__: Default settings file is incompatible. Try reinstalling the program."))
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
    
    
    @staticmethod
    def _adapt_file_paths_(file_path: str) -> str:
        """
        Adapts file paths to be the same in different scenarios ('\' will be replaced with '/').
        file_path: File path that should be adapted
        returns: The adapted file_path
        """
        
        return file_path.replace("\\", "/")
    
    
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
        
        file_path = self._adapt_file_paths_(file_path)
        
        if file_path in self.settings["recent_files"]:
            self.settings["recent_files"].remove(file_path)
        
        self.settings["recent_files"].insert(0, file_path)
        
        while len(self.settings["recent_files"]) > 10:
            self.settings["recent_files"].pop()
            
    
    @Slot(str)
    def slot_removeRecentFile(self, file_path: str) -> None:
        """
        Wrapper slot for removeRecentFile.
        """
        
        file_path = self._adapt_file_paths_(file_path)

        return self.removeRecentFile(file_path)


    @settings_autosave
    def removeRecentFile(self, file_path: str) -> None:
        """
        Remove a file path from the recent file list.
        If the file path doesn't exist in the recent files list, nothing happens.
        """
        
        file_path = self._adapt_file_paths_(file_path)
        
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
            raise RuntimeError(QCoreApplication.translate("Settings", "Settings::resetThemeColors: Default settings file missing. Try reinstalling the program."))
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
    

    @Slot(bool)
    def slot_setStartmenuState(self, new_startmenu_state: bool) -> None:
        """
        Slot for setStartmenuState.
        """
        
        self.setStartmenuState(new_startmenu_state)
    
    
    @settings_autosave
    def setStartmenuState(self, new_startmenu_state: bool) -> None:
        """
        Sets the startmenu state to a new value.
        new_startmenu_state: New value to be set.
        """
        
        self.settings["startmenu_state"] = new_startmenu_state
    
    
    @Slot(result=bool)
    def getStartmenuState(self) -> bool:
        """
        Returns the startmenu state value:
        returns: True if startmenu entry should exist, otherwise False
        """
        
        return self.settings["startmenu_state"]


    @Slot(str, str, float)
    def slot_setFont(self, font_name: str, font_family: str, font_size: float) -> None:
        """
        Wrapper slot for setFont.
        """
        
        self.setFont(font_name, font_family, font_size)
    
    
    @settings_autosave
    def setFont(self, font_name: str, font_family: str, font_size: float) -> None:
        """
        Set a font to a new value.
        font_name: Name of the font that will be changed
        font_size: New font size
        """
        
        try:
            self.settings["fonts"][font_name]["font_family"] = font_family
            self.settings["fonts"][font_name]["font_size"] = font_size
        except KeyError:
            raise RuntimeError(f"Settings::setFont: font_name not found: {font_name}")
    
    
    @Slot()
    def slot_resetFonts(self) -> None:
        """
        Wrapper slot for resetFonts.
        """
        
        self.resetFonts()
    
    
    @settings_autosave
    def resetFonts(self) -> None:
        """
        Resets all custom set fonts by overriding color settings with default settings.
        """
        
        default_file = None
        try:
            default_file = open(self.default_file_path, 'r')
            default_settings = json.loads(default_file.read())
        except FileNotFoundError as e:
            raise RuntimeError(QCoreApplication.translate("Settings", "Settings::resetThemeColors: Default settings file missing. Try reinstalling the program."))
        finally:
            if default_file:
                default_file.close()
        
        self.settings["fonts"] = default_settings["fonts"]
    
    
    @Slot(result=list)
    def getFonts(self) -> list:
        """
        returns: A list of lists containing all the fonts: list[[font_name: str, font_family: str, font_size: int]]
        """
        
        res = []
        for font_name, font in self.settings["fonts"].items():
            font_family = font["font_family"]
            font_size = font["font_size"]
            
            if type(font_name) != str or type(font_family) != str or type(font_size) != float or len(font_name) <= 0 or len(font_family) <= 0 or font_size <= 0.0:
                continue
            
            res.append([font_name, font_family, font_size])
        
        return res
