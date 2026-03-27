;; Read ORG_FILES_DIRS environment variable
(let ((dirs-str (getenv "ORG_FILES_DIRS"))
      (ignore-regex (getenv "ORG_FILE_IGNORE")))
  (when dirs-str
    (setq org-mcp-allowed-files nil)
    (dolist (dir (split-string dirs-str ":" t))
      (when (and (file-directory-p dir) (file-exists-p dir))
        (let ((found-files (directory-files-recursively dir "\\.org$")))
          ;; Filter out files matching the ignore regex if provided
          (when ignore-regex
            (setq found-files
                  (seq-filter (lambda (file)
                                (not (string-match-p ignore-regex file)))
                              found-files)))
          (setq org-mcp-allowed-files
                (append org-mcp-allowed-files found-files)))))))

