(provide 'textUtils)
(defun textUtils-deleteCharOrRegion () "Delete char or region if active

If a region is active (use-region-p is t) it deletes the region
else it deletes char at point"
       (interactive) (if (use-region-p)
			 (delete-region (region-beginning) (region-end))
		       (delete-char 1)))

(defun textUtils-backwardDeleteCharOrRegion () "Delete char backward or region if active

If a region is active (use-region-p is t) it deletes the region
else it deletes char before point"
       (interactive) (if (use-region-p)
			 (delete-region (region-beginning) (region-end))
		       (backward-delete-char 1)))

(defun textUtils-commentOrUncommentRegion () "comment-or-uncomment-region on either current region or current line"
  (interactive)
  (apply 'comment-or-uncomment-region (if (use-region-p)
                                          (list (save-excursion
                                                  (goto-char (region-beginning))
                                                  (beginning-of-line)
                                                  (point))
                                                (save-excursion
                                                  (goto-char (region-end))
                                                  (end-of-line)
                                                  (point)))
                                        (list (line-beginning-position)(line-end-position)))))

(defun textUtils-uncommentLineOrRegion () "Uncomments current line or region if active

if a region is active (use-region-p is t) it uncomments the region
else it uncomments current line"
       (interactive) (if (use-region-p)
			 (uncomment-region (region-beginning) (region-end))
		       (uncomment-region (line-beginning-position) (line-end-position))))

(defun textUtils-SmartBeginningOfLine ()
  "Move point to first non-whitespace character or beginning-of-line.

Move point to the first non-whitespace character on this line.
If point was already at that position, move point to beginning of line."
  (interactive)
  (let ((oldpos (point)))
    (back-to-indentation)
    (and (= oldpos (point))
	 (beginning-of-line))))

(defun textUtils-bufferMode (buffer-or-string)
  "Returns the major mode associated with a buffer."
  (with-current-buffer buffer-or-string
    major-mode))

(defun textUtils-decideCase ()
  "Decide if auto-capitalize should upcase next word.

Exclude some acronyms and try to handle i in i.e."
  (not (looking-back
           "\\([Ee]\\.g\\|[Ii]\\.e\\)\\.[^.!?]*" (- (point) 20))))

(defun textUtils-titleCase (@begin @end)
  "Title case text between nearest brackets, or current line, or text selection.
If a word already contains cap letters such as HTTP, URL, they are left as is.

When called in a elisp program, *begin *end are region boundaries.
Based on
URL `http://ergoemacs.org/emacs/elisp_title_case_text.html'
"
  (interactive
   (if (use-region-p)
       (list (region-beginning) (region-end))
     (let (
           $p1
           $p2
           ($skipChars "^\"<>(){}[]“”‘’‹›«»「」『』【】〖〗《》〈〉〔〕"))
       (progn
         (skip-chars-backward $skipChars (line-beginning-position))
         (setq $p1 (point))
         (skip-chars-forward $skipChars (line-end-position))
         (setq $p2 (point)))
       (list $p1 $p2))))
  (let* (
         ($strPairs []))
    (save-excursion
      (save-restriction
        (narrow-to-region @begin @end)
        (upcase-initials-region (point-min) (point-max))
        (let ((case-fold-search nil))
          (mapc
           (lambda ($x)
             (goto-char (point-min))
             (while
                 (search-forward (aref $x 0) nil t)
               (replace-match (aref $x 1) "FIXEDCASE" "LITERAL")))
           $strPairs))))))
