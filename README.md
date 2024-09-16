# mkweb for Windows PowerShell

**mkweb for Windows PowerShell** is a script designed to streamline the process of initializing and configuring web projects on Windows. It's inspired by the amazing **mkweb** script created by [Manz](https://manz.dev) for Linux systems, and this version brings similar functionality to PowerShell for Windows users.

## Features

- Initializes a new web project using [Vite](https://vitejs.dev/).
- Automatically sets up a folder structure and basic files (`index.html`, `style.css`, `index.js`, etc.).
- Configures a local development environment with essential tools like ESLint, Stylelint, and Vite.
- Automatically installs necessary dependencies.
- Removes unnecessary default files created by Vite and replaces them with a clean project structure.
- Includes a script to clean up the `dist` folder before each build.
- Can be run via PowerShell or a **`.bat`** file for easy execution.

## Installation

### Installation via npm

To install **mkweb** globally via **npm**, run the following command:

```bash
npm install -g https://github.com/CarlosMtnez/mkweb
```

### Installation manually

You can also install **mkweb** manually by downloading or cloning the project from the repository:

```bash
git clone https://github.com/CarlosMtnez/mkweb
```

After cloning the repository, you can make the script available globally by running the `install.bat` file. This will add the current directory to your system's `PATH`, allowing you to run `mkweb` from any location.

1. Run the `install.bat` file:

```batch
   install.bat
```

Once the installation is complete, you can execute mkweb globally from any directory on your system to start a vanilla website with vite and WebComponents.

## Usage

There are two ways to run the script:

1. **Using PowerShell**:
   - Open PowerShell and run the following command:

     ```powershell
     .\mkweb.ps1 <project-name>
     ```

2. **Using the `.bat` file**:
   - From the command line, run the following:

     ```batch
     mkweb.bat <project-name>
     ```

In both cases, if no project name is provided, the script will prompt you to enter one interactively.

### Start developing

Once the project is created, the script automatically installs the necessary dependencies. You can immediately start the development server with the following commands:

1. Navigate to the newly created project folder and run development server:

   ```bash
   cd <project-name>
   npm run dev
   ```
   
## Requirements

- Windows OS
- PowerShell
- Node.js (v18.3.0 or higher)

## Inspired By

This script is heavily inspired by the **mkweb** project by [Manz](https://manz.dev), which is designed for Linux environments. **mkweb for Windows PowerShell** brings the same simplicity and power to Windows, tailored for web development using PowerShell.

## Author

**Created by Carlos Martínez**  
Email: [carlos@mtnez.com](mailto:carlos@mtnez.com)  
Website: [mtnez.com](https://mtnez.com)

## License

This project is licensed under the ISC License.
