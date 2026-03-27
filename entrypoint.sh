#!/bin/bash
# entrypoint.sh

# Start Emacs daemon in the background with our init file
# Pass ORG_FILES_DIRS and ORG_FILE_IGNORE environment variables to Emacs
ORG_FILES_DIRS="$ORG_FILES_DIRS" ORG_FILE_IGNORE="$ORG_FILE_IGNORE" emacs --daemon -l /home/user/.emacs.d/init_allowed_org_files.el > /tmp/emacs-daemon.log 2>&1

# Wait for daemon to be ready
sleep 3

# Check if daemon is running
if ! emacsclient -e "(+ 1 1)" >/dev/null 2>&1; then
    echo "ERROR: Emacs daemon not responding"
    exit 1
fi

# Initialize org-mcp
emacsclient -e "(require 'org-mcp)"
emacsclient -e "(require 'mcp-server-lib)"
emacsclient -e "(org-mcp 1)"
emacsclient -e "(mcp-server-lib-start)"

# Run socat in the foreground
exec socat TCP-LISTEN:3000,reuseaddr,fork,keepalive EXEC:"/home/user/.emacs.d/emacs-mcp-stdio.sh --init-function=org-mcp-enable --server-id=org-mcp"
