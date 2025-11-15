@echo off
cls
echo ========================================
echo  Dynamos POS - Microsoft Store Builder
echo  Kaluba Technologies
echo ========================================
echo.

:menu
echo Please select an option:
echo.
echo [1] Build for Local Testing
echo [2] Build for Microsoft Store
echo [3] Clean Build Environment
echo [4] View Package Info
echo [5] Install Package Locally
echo [6] Uninstall Test Package
echo [7] Exit
echo.
set /p choice="Enter your choice (1-7): "

if "%choice%"=="1" goto local_build
if "%choice%"=="2" goto store_build
if "%choice%"=="3" goto clean
if "%choice%"=="4" goto info
if "%choice%"=="5" goto install
if "%choice%"=="6" goto uninstall
if "%choice%"=="7" goto exit
echo Invalid choice. Please try again.
echo.
goto menu

:local_build
echo.
echo ========================================
echo Building for LOCAL TESTING
echo ========================================
echo.
echo [1/4] Cleaning previous builds...
call flutter clean
if %errorlevel% neq 0 goto error

echo.
echo [2/4] Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 goto error

echo.
echo [3/4] Building Windows release...
call flutter build windows --release
if %errorlevel% neq 0 goto error

echo.
echo [4/4] Creating MSIX package...
call dart run msix:create
if %errorlevel% neq 0 goto error

echo.
echo ========================================
echo SUCCESS! Package created for testing
echo ========================================
echo Location: build\windows\x64\runner\Release\pos_software.msix
echo.
echo You can now:
echo - Double-click the MSIX file to install
echo - Or select option 5 to install via command
echo.
pause
goto menu

:store_build
echo.
echo ========================================
echo Building for MICROSOFT STORE
echo ========================================
echo.
echo WARNING: Make sure you have updated pubspec.yaml
echo with your actual Partner Center identity values!
echo.
pause

echo [1/4] Cleaning previous builds...
call flutter clean
if %errorlevel% neq 0 goto error

echo.
echo [2/4] Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 goto error

echo.
echo [3/4] Building Windows release...
call flutter build windows --release
if %errorlevel% neq 0 goto error

echo.
echo [4/4] Creating MSIX package for Store...
call dart run msix:create --store
if %errorlevel% neq 0 goto error

echo.
echo ========================================
echo SUCCESS! Package ready for Store
echo ========================================
echo Location: build\windows\x64\runner\Release\pos_software.msix
echo.
echo Next steps:
echo 1. Go to Microsoft Partner Center
echo 2. Navigate to your app
echo 3. Go to Packages section
echo 4. Upload pos_software.msix
echo 5. Complete Store listing
echo 6. Submit for certification
echo.
pause
goto menu

:clean
echo.
echo ========================================
echo Cleaning Build Environment
echo ========================================
echo.
echo Removing build artifacts...
call flutter clean
echo.
echo Cleaning Dart tool cache...
rd /s /q .dart_tool 2>nul
echo.
echo Getting fresh dependencies...
call flutter pub get
echo.
echo ========================================
echo Clean complete!
echo ========================================
echo.
pause
goto menu

:info
echo.
echo ========================================
echo Package Information
echo ========================================
echo.

if exist "build\windows\x64\runner\Release\pos_software.msix" (
    echo Package: build\windows\x64\runner\Release\pos_software.msix
    echo.
    
    for %%F in ("build\windows\x64\runner\Release\pos_software.msix") do (
        set size=%%~zF
    )
    set /a size_mb=!size! / 1048576
    echo Size: !size_mb! MB
    echo.
    
    echo Checking installed version...
    powershell -Command "Get-AppxPackage | Where-Object {$_.Name -like '*dynamospos*'} | Select-Object Name, Version, Architecture" 2>nul
    
    if %errorlevel% neq 0 (
        echo Package not currently installed.
    )
) else (
    echo No MSIX package found.
    echo Build the package first (option 1 or 2).
)

echo.
echo ========================================
echo.
pause
goto menu

:install
echo.
echo ========================================
echo Installing Package Locally
echo ========================================
echo.

if not exist "build\windows\x64\runner\Release\pos_software.msix" (
    echo ERROR: Package not found!
    echo Please build the package first (option 1).
    echo.
    pause
    goto menu
)

echo Installing pos_software.msix...
echo.
echo NOTE: If you get an error about Developer Mode,
echo go to: Settings ^> Update ^& Security ^> For developers
echo and enable Developer Mode.
echo.

powershell -Command "Add-AppxPackage -Path 'build\windows\x64\runner\Release\pos_software.msix'"

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo Installation successful!
    echo ========================================
    echo.
    echo You can now find "Dynamos POS" in your Start Menu.
    echo.
) else (
    echo.
    echo ========================================
    echo Installation failed!
    echo ========================================
    echo.
    echo Possible reasons:
    echo - Developer Mode not enabled
    echo - Package is not signed (expected for test builds)
    echo - Previous version not uninstalled
    echo.
    echo Try:
    echo 1. Enable Developer Mode in Windows Settings
    echo 2. Uninstall previous version (option 6)
    echo 3. Try installing again
    echo.
)

pause
goto menu

:uninstall
echo.
echo ========================================
echo Uninstalling Test Package
echo ========================================
echo.

echo Searching for installed package...
powershell -Command "Get-AppxPackage | Where-Object {$_.Name -like '*dynamospos*'}" 2>nul

if %errorlevel% neq 0 (
    echo No installed package found.
    echo.
    pause
    goto menu
)

echo.
echo Uninstalling...
powershell -Command "Get-AppxPackage *dynamospos* | Remove-AppxPackage"

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo Uninstallation successful!
    echo ========================================
    echo.
) else (
    echo.
    echo ========================================
    echo Uninstallation failed!
    echo ========================================
    echo.
)

pause
goto menu

:error
echo.
echo ========================================
echo ERROR: Build failed!
echo ========================================
echo.
echo Please check the error messages above.
echo.
echo Common solutions:
echo - Make sure Flutter is properly installed
echo - Run "flutter doctor" to check your environment
echo - Check for syntax errors in pubspec.yaml
echo - Try "flutter clean" and rebuild
echo.
pause
goto menu

:exit
echo.
echo Thank you for using Dynamos POS Builder!
echo.
exit /b 0
