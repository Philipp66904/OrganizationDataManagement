import sys
import platform
import threading
import winreg
from PySide6.QtCore import QObject, Slot


class WinRegistry(QObject):
    def __init__(self):
        super().__init__()
        
        self.file_type = ".odmdb"
        self.file_type_name = "OrganizationDataManagement-Database"
    
    
    @Slot()
    def add_registry_entries(self):
        if self.getRegistrySupported():
            thread = threading.Thread(None, self.__worker_add_registry_entries__)
            thread.start()
    
    
    def __worker_add_registry_entries__(self):
        path_to_exe = sys.executable
        
        key_path = fr"Software\Classes\{self.file_type}"
        file_type_key_path = fr"Software\Classes\{self.file_type_name}"
        open_command_key_path = fr"Software\Classes\{self.file_type_name}\shell\open\command"

        with winreg.CreateKey(winreg.HKEY_CURRENT_USER, key_path) as key:
            winreg.SetValueEx(key, "", 0, winreg.REG_SZ, self.file_type_name)

        with winreg.CreateKey(winreg.HKEY_CURRENT_USER, file_type_key_path) as key:
            winreg.SetValueEx(key, "", 0, winreg.REG_SZ, self.file_type_name)

        with winreg.CreateKey(winreg.HKEY_CURRENT_USER, open_command_key_path) as key:
            winreg.SetValueEx(key, "", 0, winreg.REG_SZ, f"\"{path_to_exe}\" \"%1\"")
    
    
    @Slot()
    def remove_registry_entries(self):
        if self.getRegistrySupported():
            thread = threading.Thread(None, self.__worker_remove_registry_entries__)
            thread.start()
    
    
    def __worker_remove_registry_entries__(self):
        key_path = fr"Software\Classes\{self.file_type}"
        file_type_key_path = fr"Software\Classes\{self.file_type_name}"
        open_command_key_path = fr"Software\Classes\{self.file_type_name}"
        
        try:
            winreg.DeleteKey(winreg.HKEY_CURRENT_USER, open_command_key_path + r"\shell\open\command")
            winreg.DeleteKey(winreg.HKEY_CURRENT_USER, open_command_key_path + r"\shell\open")
            winreg.DeleteKey(winreg.HKEY_CURRENT_USER, open_command_key_path + r"\shell")
            winreg.DeleteKey(winreg.HKEY_CURRENT_USER, file_type_key_path)
            winreg.DeleteKey(winreg.HKEY_CURRENT_USER, key_path)
        except FileNotFoundError:
            pass
    
    
    @Slot(result=bool)
    def getRegistrySupported(self) -> bool:
        return (getattr(sys, 'frozen', False) and platform.system() == "Windows")
