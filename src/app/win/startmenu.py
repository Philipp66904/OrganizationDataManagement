import os
import sys
import platform
import threading
if os.name == 'nt':  # Only for Windows
    import pythoncom
    from win32com.shell import shell, shellcon
from PySide6.QtCore import QObject, Slot


class Startmenu(QObject):
    def __init__(self, application_name: str):
        super().__init__()

        self.application_name = application_name
    

    @Slot(bool)
    def add_to_startmenu(self, wait_for_worker_finished: bool):
        if self.getStartmenuSupported():
            thread = threading.Thread(None, self.__worker_add_to_startmenu__)
            thread.start()
            
            if wait_for_worker_finished:
                thread.join()
    
    
    def __worker_add_to_startmenu__(self):
        path_to_exe = sys.executable
        lnk_name = f'{self.application_name}.lnk'

        startmenu_path = shell.SHGetFolderPath(0, shellcon.CSIDL_PROGRAMS, None, 0)

        shortcut = pythoncom.CoCreateInstance(shell.CLSID_ShellLink, None, pythoncom.CLSCTX_INPROC_SERVER, shell.IID_IShellLink)

        shortcut.SetPath(path_to_exe)
        shortcut.SetDescription(f"Link for {self.application_name}")

        persist_file = shortcut.QueryInterface(pythoncom.IID_IPersistFile)
        persist_file.Save(os.path.join(startmenu_path, lnk_name), 0)
    
    
    @Slot(bool)
    def remove_from_startmenu(self, wait_for_worker_finished: bool):
        if self.getStartmenuSupported():
            thread = threading.Thread(None, self.__worker_remove_from_startmenu__)
            thread.start()
            
            if wait_for_worker_finished:
                thread.join()
    
    
    def __worker_remove_from_startmenu__(self):
        lnk_name = f'{self.application_name}.lnk'
        lnk_path = os.path.join(shell.SHGetFolderPath(0, shellcon.CSIDL_PROGRAMS, None, 0), lnk_name)

        if os.path.exists(lnk_path):
            os.remove(lnk_path)
    
    
    @Slot(result=bool)
    def getStartmenuSupported(self) -> bool:
        return (getattr(sys, 'frozen', False) and platform.system() == "Windows")
