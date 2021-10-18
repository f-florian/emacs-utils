(provide 'cpputils)
;; (defun cpputils-hideBlock () "Use vimish-fold to fold the current block

;; Block are detected using hs"
;;        (interactive)
;;        (if (vimish-fold--folds-in (point)(point))
;;            (vimish-fold-toggle)
;;          (hs-find-block-beginning)
;;          (setq cpputils-regionStart (point))
;;          (forward-sexp)
;;          (vimish-fold cpputils-regionStart (point))))

(setq cpputilsTypeRegex "\\=\\([a-zA-Z_][a-zA-Z0-9_:<>]*[&\\*]?\\) ")
(setq cpputilsIdentifierRegex "\\=\\([a-zA-Z_][a-zA-Z0-9_]*\\)\\([(,)]\\)")

;; (defun cpputils-printFunction () (interactive)
;;        (setq tmpdebugtags (rtags-symbol-info-internal)))
;; (global-set-key (kbd "<f9>") 'cpputils-printFunction)

;; (setq info tmpdebugtags)

;; ((alignment . 4) (arguments ((context .     void drop(ShogiServer::Piece::Type const piece_type)) (cursor . /home/f/Documents/dev/shogiserver/clients/qt/display.h:48:15:) (cursorContext .     void drop(ShogiServer::Piece::Type const piece_type)) (length . 41) (location . /home/f/Documents/dev/shogiserver/clients/qt/display.h:48:15:))) (cf . class Display) (cfl . /home/f/Documents/dev/shogiserver/clients/qt/display.h:35:9:) (cflcontext .   class Display) (container . t) (context .     void drop(ShogiServer::Piece::Type const piece_type)) (endColumn . 57) (endLine . 48) (kind . CXXMethod) (linkage . External) (location . /home/f/Documents/dev/shogiserver/clients/qt/display.h:48:10:) (sizeof . 1) (startColumn . 5) (startLine . 48) (symbolLength . 4) (symbolName . void Display::drop(const ShogiServer::Piece::Type)) (type . void (const ShogiServer::Piece::Type)) (usr . c:@N@QShogi@S@Display@F@drop#1$@N@ShogiServer@S@Piece@E@Type#))

(defun cpputils-unindentUntilLineComputeLength (firstLine) "Unindent up to firstLine and return final line length."
       (let (length)
         (newline-and-indent)
         (forward-line -1)
         (while (< firstLine (line-number-at-pos (point) t))
           (delete-indentation))
         (setq length (- (line-end-position) (line-beginning-position)))
         (forward-line 1)
         length))

(defun cpputils-newFunctionDoxygenAfter () "Try to insert documenting comments about function, paratemers and return type.
This will insert comments after each parameter and after the function definition, and will break the function definition into multiple lines to do so."
  (interactive)
  (let* ((info (rtags-symbol-info-internal))
        (returnType (car (split-string (cdr (assoc 'type info)) " *(")))
        (maxColumn 0)
        (firstLine (cdr (assoc 'startLine info)))
        (currentLine firstLine))
    ;; afaik rtags doesn't know about narrowing: move to start
    (goto-char 1)
    (forward-line (- firstLine 1))
    (move-to-column (cdr (assoc 'startColumn info)))
    ;; split/join lines appropriately and compute maximal length
    (while (search-forward "," (point-max) t)
      (goto-char (match-end 0))
      (setq maxColumn (max maxColumn (cpputils-unindentUntilLineComputeLength currentLine)))
      (forward-line 1)
      (setq currentLine (+ currentLine 1))
      (beginning-of-line))
    (search-forward ")")
    (goto-char (match-beginning 0))
    (setq maxColumn (max maxColumn (cpputils-unindentUntilLineComputeLength currentLine)))
    (setq maxColumn (+ maxColumn (- tab-width (% (- maxColumn 1) tab-width))))
    (move-to-column maxColumn t)
    (insert "//!< ")
    (unless (equal returnType "void")
      (insert "\\return "))
    (while (>= currentLine firstLine)
      (forward-line -1)
      (setq currentLine (- currentLine 1))
      (move-to-column maxColumn t)
      (insert "//!< "))))

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

;; (defun cpputils-makeClass  (className) "Create header and source file for a class"
;;        (interactive "sClass name")
       
;;   )
