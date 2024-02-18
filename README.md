## **DumpRecoverSh - Database Dump Recovery Tool**

DumpRecoverSh is a bash script designed to facilitate the process of creating, dump importing, and dropping PostgreSQL database dumps using Docker containers.

### **Usage**

### **`createdumpinstance`**

Creates a new Docker container, imports a PostgreSQL database dump, and optionally cleans up the container afterward.

```bash
bashCopy code
./dumpRecover.sh createdumpinstance [options] -f dump_file_path.sql

```

**Options:**

- **`n`**: Name of the Docker container (optional, default: postgres).
- **`d`**: Name of the database (optional, default: postgres).
- **`f`**: SQL dump file path (required).
- **`s`**: Show import log (optional, default: false).
- **`e`**: Exit from the container after the "\q" command in PostgreSQL (optional, default: true).

### **`dropdumpinstance`**

Removes an existing Docker container.

```bash
bashCopy code
./dumpRecover.sh dropdumpinstance [options]

```

**Options:**

- **`n`**: Name of the Docker container (optional, default: postgres).

### **Examples**

### Creating a Database Dump Instance

```bash
bashCopy code
./dumpRecover.sh createdumpinstance -n mycontainer -d mydatabase -f /path/to/dump.sql -s

```

- Creates a Docker container named "mycontainer" with a PostgreSQL database named "mydatabase."
- Imports the database dump located at "/path/to/dump.sql" with import log displayed.
- Accesses the PostgreSQL shell inside the container.

### Dropping a Database Dump Instance

```bash
bashCopy code
./dumpRecover.sh dropdumpinstance -n mycontainer

```

- Removes the Docker container named "mycontainer."

### **Additional Information**

- Ensure that Docker is installed and accessible in your environment.
- The script utilizes the official PostgreSQL Docker image.

### **Options Details**

- **`n` (Name of Docker container):** Specifies the name of the Docker container. If not provided, the default name is "postgres."
- **`d` (Name of the database):** Specifies the name of the PostgreSQL database. If not provided, the default name is "postgres."
- **`f` (Dump file path):** Specifies the path to the PostgreSQL database dump file. This option is required.
- **`s` (Show import log):** If specified, the import log will be displayed. If not, the log will be suppressed. Default is false.
- **`e` (Exit from container after "\q" command):** If specified, the container will exit after executing the "\q" command in PostgreSQL. If not, it will remain running. Default is true.

### **Notes**

- The script checks for valid dump file extensions, requiring the file to have a ".sql" extension.
- PostgreSQL password is set to "postgres" within the Docker container.

### **Author**

DumpRecoverSh is developed by RUDYAN.
 Discord: rudy_an
