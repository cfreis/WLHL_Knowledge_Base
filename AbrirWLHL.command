#!/bin/zsh

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR" || exit 1

clear
echo "Opening the WLHL Knowledge Base..."
echo ""

if curl -fsS --max-time 2 http://localhost:8501/ >/dev/null 2>&1; then
  open http://localhost:8501/
  echo "The application was already open."
  read -k 1 "?Press any key to close this window."
  exit 0
fi

if [[ ! -x ".venv/bin/python" ]]; then
  echo "First use: preparing the application..."
  if ! command -v python3 >/dev/null 2>&1; then
    echo "Install Python 3 from python.org and try again."
    read -k 1 "?Press any key to close this window."
    exit 1
  fi
  python3 -m venv .venv || exit 1
  .venv/bin/python -m pip install -r requirements.txt || exit 1
fi

(sleep 3; open http://localhost:8501/) &
echo "The application will open in your browser."
echo "Keep this window open while using WLHL."
echo "Press Control + C here to stop the app."
echo ""

exec .venv/bin/python -m streamlit run app.py --server.headless true --server.port 8501 --browser.gatherUsageStats false
