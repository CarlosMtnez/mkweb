param(
    [string]$projectName
)

# Define version variables
$NODE_MIN_VERSION = "18.3.0"
$MKWEB_VERSION = "0.1"

# Display MKWEB version
Write-Host "MKWEB script version: $MKWEB_VERSION" -ForegroundColor Green

# Check if Node.js is installed
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "Node.js is not installed. Please install Node.js first." -ForegroundColor Red
    exit
}

# If no project name was provided, ask for it
if (-not $projectName) {
    $projectName = Read-Host "Enter the project folder name"
}

# Check if the folder already exists
if (Test-Path $projectName) {
    Write-Host "The folder '$projectName' already exists. Please delete the folder or choose another name." -ForegroundColor Red
    exit
}

# Check the Node.js version
$nodeVersion = (node --version).TrimStart('v') # Remove the 'v' from the version string
if ([version]$nodeVersion -lt [version]$NODE_MIN_VERSION) {
    Write-Host "Node.js version $NODE_MIN_VERSION or higher is required. You have $nodeVersion." -ForegroundColor Yellow
    exit
}

# Run the command to create the Vite project
Write-Host "[$(Get-Date -Format HH:mm:ss)] Installing Vite..." -ForegroundColor Yellow
& npm init vite@latest $projectName -y -- --template vanilla

# Change to the project directory
Set-Location $projectName

# Initialize a GIT repository (if available)
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "Initializing GIT repository..." -ForegroundColor Yellow
    git init > $null
}

# Read the content of package.json and convert it to a hashtable
$packageJson = Get-Content "package.json" -Raw | ConvertFrom-Json

# Convert the JSON object to a hashtable for modification
$packageJsonHashtable = @{}

# Loop through all properties in the JSON object and add them to the hashtable
foreach ($property in $packageJson.PSObject.Properties) {
    $packageJsonHashtable[$property.Name] = $property.Value
}

# If the 'scripts' property doesn't exist, create it as a hashtable
if (-not $packageJsonHashtable.scripts) {
    $packageJsonHashtable.scripts = @{}
} else {
    # Convert 'scripts' into a hashtable if it already exists to allow modification
    $scriptsHashtable = @{}
    foreach ($property in $packageJsonHashtable.scripts.PSObject.Properties) {
        $scriptsHashtable[$property.Name] = $property.Value
    }
    $packageJsonHashtable.scripts = $scriptsHashtable
}

# Add or update necessary properties in package.json
$packageJsonHashtable.scripts.build = "node scripts/clean-dist.mjs && vite build"
$packageJsonHashtable.scripts.deploy = "gh-pages -d dist"

# Add keywords if they don't exist
if (-not $packageJsonHashtable.keywords) {
    $packageJsonHashtable.keywords = @()
}

# Set the license
if (-not $packageJsonHashtable.license) {
    $packageJsonHashtable.license = "ISC"
} else {
    $packageJsonHashtable.license = "ISC"
}

# Convert the hashtable back to JSON and save the changes in package.json
$packageJsonHashtable | ConvertTo-Json -Compress | Set-Content "package.json"

# Remove default files created by Vite
Write-Host "[$(Get-Date -Format HH:mm:ss)] Removing default files created by Vite..." -ForegroundColor Cyan
Remove-Item -Force -ErrorAction SilentlyContinue "index.html", "main.js", "style.css", "counter.js"
Remove-Item -Force -ErrorAction SilentlyContinue "public/vite.svg", "javascript.svg"

# Create additional folders if they don't exist: public, components, modules, assets
Write-Host "[$(Get-Date -Format HH:mm:ss)] Creating additional folder structure..." -ForegroundColor Cyan
if (-not (Test-Path "public")) {
    New-Item -ItemType Directory -Name "public" > $null
}
if (-not (Test-Path "assets")) {
    New-Item -ItemType Directory -Path "assets" -Force > $null
}
if (-not (Test-Path "components")) {
    New-Item -ItemType Directory -Path "components" -Force > $null
}
if (-not (Test-Path "modules")) {
    New-Item -ItemType Directory -Path "modules" -Force > $null
}

# Create additional files and VSCode configuration
New-Item -ItemType Directory -Name ".vscode" > $null
New-Item -ItemType File -Name ".vscode/settings.json" -Force -Value @"
{
  "typescript.suggest.completeJSDocs": true,
  "[javascript]": {
    "editor.defaultFormatter": "dbaeumer.vscode-eslint"
  },
  "[html]": {
    "editor.defaultFormatter": "vscode.html-language-features"
  },
  "[css]": {
    "editor.defaultFormatter": "stylelint.vscode-stylelint"
  },
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit",
    "source.fixAll.stylelint": "explicit"
  },
  "editor.formatOnSave": true,
  "eslint.enable": true,
  "stylelint.enable": true,
  "css.validate": false,
  "scss.validate": false,
  "less.validate": false,
  "javascript.validate.enable": false,
  "emmet.includeLanguages": {
    "jsx": "html",
    "vue": "html",
    "html": "html",
    "javascript": "html"
  }
}
"@ > $null

# Create index.html in the root directory with updated content
New-Item -ItemType File -Name "index.html" -Force -Value @"
<!DOCTYPE html>
<html lang='en'>

<head>
  <meta charset='UTF-8'>
  <meta name='viewport' content='width=device-width, initial-scale=1.0'>
  <title>Vite Project</title>
  <link rel='stylesheet' href='./style.css'>
  <script type='module' src='./index.js'></script>
</head>

<body>
  <h1>Your awesome website!</h1>
  <say-hello name='Mate'>
    This is a sample WebComponent...
  </say-hello>
</body>

</html>
"@ > $null

# Create index.js in the root directory
New-Item -ItemType File -Name "index.js" -Force -Value @"
import './components/SayHello.js';

console.log('Welcome to Vite!');
"@ > $null

# Create SayHello.js in the components folder
New-Item -ItemType File -Name "components/SayHello.js" -Force -Value @"
class SayHello extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
  }

  static get styles() {
    return /*css*/ ``
    :host {
      display: block;
      border: 10px solid #0004;
      border-radius: 10px;
      padding: 20px;
      margin: 20px;
      background: linear-gradient(45deg, cyan, magenta, lime);
      color: white;
      text-align: center;
    }

    .container {
      padding: 1rem;
    }

    .greeting {
      font-size: 2rem;
      font-weight: bold;
      color: #000; /* Contrast color */
      margin-top: 0;
    }

    ::slotted(*) {
      color: #fff;
    }
    ``;
  }

  /* Children */
  connectedCallback() {
    this.render();
  }

  render() {
    const name = this.getAttribute('name') || 'Friend'; // Default value 'Friend'
    this.shadowRoot.innerHTML = /*html*/ ``
    <style>`${SayHello.styles}</style>
    <div class="container">
      <p class="greeting">Hi, `${name}!</p>
      <slot></slot> 
    </div>
    ``;
  }
}

customElements.define('say-hello', SayHello);
"@ > $null

# Create the style.css file in the root directory
New-Item -ItemType File -Name "style.css" -Force -Value @"
/* Basic reset styles */
html {
  box-sizing: border-box;
  font-size: 16px;
  font-family: system-ui, -apple-system, sans-serif;
}

*, *:before, *:after {
  box-sizing: inherit;
}

body, h1, h2, h3, h4, h5, h6, p, ol, ul {
  margin: 0;
  padding: 0;
  font-weight: normal;
}

ol, ul {
  list-style: none;
}

img {
  max-width: 100%;
  height: auto;
}
"@ > $null



# Create the clean-dist.mjs script (ESM)
Write-Host "[$(Get-Date -Format HH:mm:ss)] Creating clean-dist.mjs script (ESM)..." -ForegroundColor Cyan
New-Item -ItemType Directory -Name "scripts" > $null
New-Item -ItemType File -Name "scripts/clean-dist.mjs" -Force -Value @"
import { rmSync, existsSync } from 'fs';
import { join } from 'path';

const distPath = join(new URL('.', import.meta.url).pathname, '..', 'dist');

// Remove the dist directory if it exists
if (existsSync(distPath)) {
  rmSync(distPath, { recursive: true, force: true });
  console.log('dist directory deleted.');
} else {
  console.log('dist directory not found.');
}
"@ > $null

# Create the jsconfig.json file without escape characters
Write-Host "[$(Get-Date -Format HH:mm:ss)] Creating jsconfig.json file..." -ForegroundColor Cyan
New-Item -ItemType File -Name "jsconfig.json" -Force -Value @"
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./*"] # Adjusted paths since src is removed
    }
  }
}
"@ > $null

# Create the .vscode/extensions.json file
Write-Host "[$(Get-Date -Format HH:mm:ss)] Creating .vscode/extensions.json file..." -ForegroundColor Cyan
New-Item -ItemType File -Name ".vscode/extensions.json" -Force -Value @"
{
  "recommendations": [
    "dbaeumer.vscode-eslint",
    "stylelint.vscode-stylelint",
    "esbenp.prettier-vscode",
    "Tobermory.es6-string-html",
    "wix.vscode-import-cost",
    "oderwat.indent-rainbow"
  ]
}
"@ > $null

# Create the .eslintrc.json file
Write-Host "[$(Get-Date -Format HH:mm:ss)] Creating .eslintrc.json file..." -ForegroundColor Cyan
New-Item -ItemType File -Name ".eslintrc.json" -Force -Value @"
{
  "env": {
    "browser": true,
    "es2021": true
  },
  "extends": "eslint:recommended",
  "parserOptions": {
    "ecmaVersion": 12,
    "sourceType": "module"
  },
  "rules": {
  }
}
"@ > $null

# Install development dependencies
Write-Host "[$(Get-Date -Format HH:mm:ss)] Installing development dependencies (stylelint, eslint, gh-pages, vite-tsconfig-paths)..." -ForegroundColor Magenta
npm install stylelint eslint eslint-config-standard gh-pages vite-tsconfig-paths --save-dev

# Install project dependencies
Write-Host "[$(Get-Date -Format HH:mm:ss)] Installing project dependencies..." -ForegroundColor Magenta
npm install

Write-Host "`nProject successfully configured!" -ForegroundColor Green
Write-Host "`nRun the following commands to start:"
Write-Host "cd $projectName"
Write-Host "npm run dev"
