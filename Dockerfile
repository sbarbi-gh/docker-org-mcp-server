FROM alpine:3.19

RUN apk add --no-cache emacs-nox git socat curl bash

RUN adduser -D user
USER user
WORKDIR /home/user

# Create necessary directories
RUN mkdir -p /home/user/.emacs.d/lisp/

# Install packages in a single step
RUN emacs --batch \
    --eval "(require 'package)" \
    --eval "(add-to-list 'package-archives '(\"melpa\" . \"https://melpa.org/packages/\") t)" \
    --eval "(package-initialize)" \
    --eval "(package-refresh-contents)" \
    --eval "(unless (package-installed-p 'org-mcp) (package-install 'org-mcp))" \
    --eval "(unless (package-installed-p 'mcp-server-lib) (package-install 'mcp-server-lib))" \
    --eval "(when (fboundp 'mcp-server-lib-install) (mcp-server-lib-install))" 2>&1 | tee /tmp/emacs-install.log

# Find and copy the emacs-mcp-stdio.sh script from the installed package
# The script is likely in ~/.emacs.d/elpa/org-mcp-*/ or ~/.emacs.d/elpa/mcp-server-lib-*/
RUN find /home/user/.emacs.d/elpa -name "emacs-mcp-stdio.sh" -type f | head -1 | xargs -I {} cp {} /home/user/.emacs.d/emacs-mcp-stdio.sh && \
    chmod +x /home/user/.emacs.d/emacs-mcp-stdio.sh || \
    (echo "WARNING: Could not find emacs-mcp-stdio.sh, creating a fallback" && \
     echo '#!/bin/bash' > /home/user/.emacs.d/emacs-mcp-stdio.sh && \
     echo 'exec emacsclient --socket-name=org-mcp --eval "(org-mcp-enable)" "$@"' >> /home/user/.emacs.d/emacs-mcp-stdio.sh && \
     chmod +x /home/user/.emacs.d/emacs-mcp-stdio.sh)

COPY --chown=user:user init_allowed_org_files.el /home/user/.emacs.d/init_allowed_org_files.el

# Use the entrypoint script instead of direct socat command
COPY --chown=user:user entrypoint.sh /home/user/entrypoint.sh
RUN chmod +x /home/user/entrypoint.sh

ENTRYPOINT ["/home/user/entrypoint.sh"]

ENTRYPOINT ["/home/user/entrypoint.sh"]
