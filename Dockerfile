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

COPY --chown=user:user init_allowed_org_files.el /home/user/.emacs.d/init_allowed_org_files.el

# Use the entrypoint script instead of direct socat command
COPY --chown=user:user entrypoint.sh /home/user/entrypoint.sh
RUN chmod +x /home/user/entrypoint.sh

# Ensure the emacs-mcp-stdio.sh script is executable
RUN chmod +x /home/user/.emacs.d/emacs-mcp-stdio.sh

ENTRYPOINT ["/home/user/entrypoint.sh"]
