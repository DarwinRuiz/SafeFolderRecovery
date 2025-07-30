# SafeFolderRecovery

**SafeFolderRecovery** is a lightweight, administrator-friendly Windows batch tool for **securely backing up a single folder** from any location (internal drive, corrupted OS partition, etc.) to an external drive or safe destination — even when the original Windows system cannot boot.

> Created by **Darwin Orlando Ruiz Mateo**, Software Architect  
> Version: `1.0.0`

---

## 🧭 Features

- ✅ Copy any single folder (not limited to user folders like Documents/Desktop).
- ✅ Supports **paths with spaces** and **arbitrary origin/destination**.
- ✅ Automatically requests **administrator privileges**.
- ✅ Supports both **interactive** and **parameter-based** modes.
- ✅ Optional features:
  - `--zip=true` to create a compressed archive
  - `--loglevel=verbose` for detailed output
- ✅ Generates:
  - 📁 a `README.txt` in the destination folder
  - 📄 a timestamped log file of the operation

---

## 🚀 How to Use

### 🔧 Option 1: Interactive mode (no parameters)

Just double-click the script or run from recovery CMD:

```cmd
SafeFolderRecovery.bat
```

You will be prompted to enter:

- Source folder path (e.g. `D:\\Important\\Invoices`)
- Destination folder path (e.g. `E:\\Recovered\\July2025`)

---

### ⚙️ Option 2: Named parameters mode

```cmd
SafeFolderRecovery.bat --source="D:\\Work2025" --dest="E:\\Backup_Work2025" --zip=true --loglevel=verbose
```

✅ Parameter order does **not matter**.

---

## 🗂️ Output Example

```
E:\\
 └── Backup_Work2025\\
     ├── [your files...]
     ├── README.txt
     ├── backup_log_2025-07-30.txt
     └── Backup_Work2025_backup_2025-07-30.zip (if --zip=true)
```

---

## 💡 Use Cases

- 💻 Recover user folders from a PC that **won’t boot** using Windows Recovery or WinPE.
- 🛠️ Backup specific folders during **incident response or forensics**.
- 🧳 Extract targeted data from temporary environments.

---

## ⚙️ Compatibility

| Environment       | Supported | Notes                                       |
|-------------------|-----------|---------------------------------------------|
| CMD (cmd.exe)     | ✅        | Fully supported                             |
| PowerShell launch | ✅        | Fully supported (invokes \`cmd.exe\`)        |
| PowerShell script | ⚠️        | **Do not** run line by line in PowerShell   |

To run from PowerShell, simply call:

```powershell
.\SafeFolderRecovery.bat --source="D:\\Data" --dest="E:\\Backup"
```

---

## 🔐 Permissions

The script checks for administrator rights and **self-elevates** if not already running with them. This is required to access protected folders or external volumes.

---

## 📄 License

MIT License — feel free to use, adapt, or integrate into your recovery toolkits.

---

## 🧑‍💻 Author

**Darwin Orlando Ruiz Mateo**  
Software Architect & Cybersecurity Enthusiast
