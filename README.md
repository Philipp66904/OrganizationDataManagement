# OrganizationDataManagement
OrganizationDataManagement (ODM) is a tool designed for effective **management and tracking of addresses and personal data shared with different organizations**.  
Boasting a **user-friendly interface** with **customizability**, ODM simplifies the process of **updating**, **connection**, and **searching data**, whilst ensuring optimal **data privacy** and **minimization of redundancy**.

## Use Case
The OrganizationDataManagement (ODM) program is a comprehensive tool designed to help manage and search through the various addresses you've shared with different companies.  
Whether you're relocating and need to alter all address details or simply intend to keep track of the companies possessing your information, ODM is all you need.

ODM achieves this by allowing you to add people, addresses and organizations independently and by creating a linkage accros these categories.  
Additionally, the search tab proves instrumental in the quick search of specific or connected entries.  

To avoid clutter and minimize redundant data entries, for instance, varied name spellings or minor variations, ODM provides the option of creating derivatives of entries.  
Importantly, on deletion of the parent entry, all derivatives are also removed, thereby maintaining an clean database.  

Furthermore, ODM's user interface is highly customizable, with options for independent color modifications and automatic adaptations to your timezone and language settings (subject to translation availability).

ODM allows effortless tracking of shared information, with the added assurance of your information remaining on your device.  
The choice of where to store files rests entirely with you, ensuring optimal user convenience and control.  

## Installation
### Using the `.exe` [Windows only]
1) Click on the newest release on the sidebar to your right.
1) Download the `.zip` file and unzip it.
1) Double click on the ```OrganizationDataManagement.exe``` file to start the application.
1) It will initialize itself automatically.

### Using the Git Repository
1) Clone the git repository to your PC
1) Install **Python 3** and **pip**
1) Install **PySide6**: ```pip install PySide6```
1) Install **pywin32**: ```pip install pywin32```
1) Use Python to execute `main.py` found in the `src` directory: ```python main.py```

#### Create .exe [Windows only]
1) Install **pyinstaller**: ```pip install pyinstaller```
1) Install **Pillow**: ```pip install Pillow```
1) Go into the `scripts` folder
1) Execute the ```compile_translations.bat``` script
1) Execute the ```create_executable.bat``` script
1) Execute the `OrganizationDataManagement.exe` found in ```build\exe\dist\OrganizationDataManagement``` to set up the file association for `.odmdb` files (can be configured in the program settings)

#### Required Programs and non-standard Dependencies
- Python - <kbd>3.11.0</kbd>  
- PySide6
- pywin32
- [pyinstaller (if you want to create your own .exe)]
- [Pillow (if you want to create your own .exe)]

## `.odmdb` file best practices
The `.odmdb` file includes personal information like the saved persons, addresses, and organization, their connections and some metadata.  

The information is <ins>not encrypted</ins> and therefore anyone with access to the stored location can access or modify the data.  
Therefore, it is **highly encouraged** to store the database in an **encrypted** way in a **safe location**.  

A good way to store your data is **in a Keepass database**.  
Keepass supports files as attachments and one can even open the file from within Keepass.  

## Bugs and Support
Please **open an issue** to get the problem fixed.

## How to contribute
Any contribution is welcome!  

If you have something in mind and are **able to do it yourself**, just create your own branch and open a PullRequest in the end.  
You can take a look at the documentation found in the Github Wiki to assist you with your idea.

**Otherwise**, you can always **create an issue**.  

If you want to **add or modify a language**, take a look at the Github Wiki for instructions.

> [!IMPORTANT]
> **Keep in mind to always stick to the main goals and rules of the project!**
## Main Goals and Rules
- **KISS**: *Keep it simple, stupid!* -> Don't overengineer the program
- **No highly personal data** or **passwords** may be stored in the database created by this program. *Highly personal data* includes, but is not limited to: Health, bank, religious, and ethnic data. See **EU-GDPR articel 9** for more categories.
- **No email-address** shall be stored in the database, as a password manager usually already takes care of this information.
- **Ease of use** and **speed** take precedence over maximum functionality.
- Support **Keyboard-Control** wherever easily possible.
- **Document** your changes.
- **All OS modifications** (e.g. registry entries) must be **removed on deinstall**.

## Documentation and User Manual
The documentation and user manual can be found in the **Github Wiki**.
