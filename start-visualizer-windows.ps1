
# Delete configuration files in the viewer folder
Remove-Item -Path "$PSScriptRoot\sdlb-viewer\config" -Recurse -Force

# Copy the contents of the 'config' directory to 'sdlb-viewer\config'
Copy-Item -Path "$PSScriptRoot\config" -Destination "$PSScriptRoot\sdlb-viewer\config" -Recurse

# Copy the file 'sdlbViewer.conf' to 'sdlb-viewer\config'
Copy-Item -Path "$PSScriptRoot\envConfig\sdlbViewer.conf" -Destination "$PSScriptRoot\sdlb-viewer\config"

# Change the working directory to 'sdlb-viewer' (same as cd)
Set-Location -Path "$PSScriptRoot\sdlb-viewer"

# PYTHON INDEX BUILDER (see that you switch to Python3 if you don't have python installed)
try {
    python3 -m venv .venv
    .\.venv\Scripts\Activate
    pip install -r .\requirements.txt
    python3 .\build_index.py state
} finally {
    .\.venv\Scripts\Deactivate
}

.\lighttpd\lighttpd.exe -D -f .\lighttpd.conf
