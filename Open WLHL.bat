@echo off
cd /d "%~dp0"

if not exist ".venv\Scripts\python.exe" (
  echo First use: preparing the WLHL Knowledge Base...
  py -m venv .venv 2>nul || python -m venv .venv
  if errorlevel 1 goto python_missing
  .venv\Scripts\python.exe -m pip install -r requirements.txt
  if errorlevel 1 goto install_failed
)

start "" http://localhost:8501
.venv\Scripts\python.exe -m streamlit run app.py --server.headless true --server.port 8501 --browser.gatherUsageStats false
goto end

:python_missing
echo Install Python 3 from python.org, then double-click this file again.
pause
goto end

:install_failed
echo Streamlit could not be installed. Check the internet connection and try again.
pause

:end
