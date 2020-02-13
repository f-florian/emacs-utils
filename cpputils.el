(provide 'cpputils)
(defun cpputils-hideBlock () "Use vimish-fold to fold the current block

Block are detected using hs"
       (interactive)
       (if (vimish-fold--folds-in (point)(point))
           (vimish-fold-toggle)
         (hs-find-block-beginning)
         (setq cpputils-regionStart (point))
         (forward-sexp)
         (vimish-fold cpputils-regionStart (point))))

(setq cpputilsTypeRegex "\\=\\([a-zA-Z_][a-zA-Z0-9_:<>]*[&\\*]?\\) ")
(setq cpputilsIdentifierRegex "\\=\\([a-zA-Z_][a-zA-Z0-9_]*\\)\\([(,)]\\)")

(defun cpputils-parseReturn(className) "Parse return value of the function definition starting on this line"
       (interactive "sClass name") (let ((point0 (re-search-forward "^ *")))
                                     (while (and
                                             (re-search-forward cpputilsTypeRegex (line-end-position) t 1)
                                             (or
                                              (equal (match-string-no-properties 1) "static")
                                              (equal (match-string-no-properties 1) "virtual")))
                                       (replace-match ""))
                                     (when (and
                                            (not (and
                                                  (equal (match-string-no-properties 1) className)
                                                  (goto-char point0)))
                                            (not (equal (match-string-no-properties 1) "void")))
                                       (match-string-no-properties 1))))

(defun cpputils-parseType() "Parse return value of the function definition starting on this line"
       (interactive) (if (re-search-forward cpputilsTypeRegex (line-end-position) t 1)
                         (if (equal (match-string-no-properties 1) "void") nil (match-string-no-properties 1)) nil))

(defun cpputils-getIdentifier () "Return the identifier name starting at point"
       (interactive) (when (re-search-forward cpputilsIdentifierRegex (line-end-position) t 1)
                       (match-string-no-properties 1)))

(defun cpputils-replaceFollowingDocstring () "clear the `';' and the doygen documentation after a function declaration; replace with an empty function body"
       (interactive) (when (re-search-forward "; *//!< .*" (line-end-position) t 1)
                       (replace-match "")
                       (indent-according-to-mode)
                       (newline)
                       (insert "{")
                       (indent-according-to-mode)
                       (newline)
                       (indent-according-to-mode)
                       (insert "}")
                       (forward-line -2)))

(defun cpputils-addDoxygen (returnVal params)
  (forward-line -1)
  (end-of-line)
  (newline-and-indent)
  (insert "/**")
  (newline-and-indent)
  (insert " */")
  (when returnVal
    (forward-line -1)
    (end-of-line)
    (newline-and-indent)
    (insert " * \\return "))
  (cpputils-printParams params)
  (forward-line -1))

(defun cpputils-printParams (params)
  (when params
    (when (car params)
      (forward-line -1)
      (end-of-line)
      (newline-and-indent)
      (insert (concat " * \\param " (car params))))
    (cpputils-printParams (cdr params))))

(defun cpputils-setupClassHeader2Cpp (className) "Add Class:: scope before function definitions, doxygen long docs and function body {}

if a region is active (use-region is t) it only applies to functions in the region, else operates from point to the end of buffer"
       (interactive "sClass name") (let ((returnValue t) params startPos classBegin)
                                     (if (use-region-p)
                                         (progn
                                           (setq startPos (region-beginning))
                                           (goto-char (region-end)))
                                       (goto-char (point-max))
                                       (setq startPos (point-min)))
                                     (beginning-of-line)
                                     (while (< startPos (point))
                                       (let (point0 point1)
                                         (when (or
                                                (setq returnValue (cpputils-parseReturn className))
                                                (not (setq point0 (point)))
                                                (when (cpputils-getIdentifier)
                                                  (goto-char point0)))
                                         (insert (concat className) "::")
                                         (cpputils-getIdentifier)
                                         (setq params nil)
                                         (while (cpputils-parseType)
                                           (setq params (append params (list (cpputils-getIdentifier)))))
                                         (cpputils-replaceFollowingDocstring)
                                         (cpputils-addDoxygen returnValue params))
                                         (forward-line -1)
                                         (beginning-of-line)))))
