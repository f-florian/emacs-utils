(provide 'utils)
(defun delete-char-or-region () "delete char or region if active

if a region is active (use-region-p is t) it deletes the region
else it deletes one char"
       (interactive) (if (use-region-p)
			 (delete-region (region-beginning) (region-end))
		       (delete-char 1)))

(defun backward-delete-char-or-region () "delete char backward or region if active

if a region is active (use-region-p is t) it deletes the region
else it deletes one char back"
       (interactive) (if (use-region-p)
			 (delete-region (region-beginning) (region-end))
		       (backward-delete-char 1)))

(defun comment-eclipse ()
  (interactive)
  (let ((start (line-beginning-position))
	(end (line-end-position)))
    (when (or (not transient-mark-mode) (region-active-p))
      (setq start (save-excursion
		    (goto-char (region-beginning))
		    (beginning-of-line)
		    (point))
	    end (save-excursion
		  (goto-char (region-end))
		  (end-of-line)
		  (point))))
    (comment-or-uncomment-region start end)))

(defun uncomment-line-region () "uncomments current line or region if active

if a region is active (use-region-p is t) it uncomments the region
else it uncomments current line"
       (interactive) (if (use-region-p)
			 (uncomment-region (region-beginning) (region-end))
		       (uncomment-region (line-beginning-position) (line-end-position))))

(defun smart-beginning-of-line ()
  "Move point to first non-whitespace character or beginning-of-line.

Move point to the first non-whitespace character on this line.
If point was already at that position, move point to beginning of line."
  (interactive) ; Use (interactive "^") in Emacs 23 to make shift-select work
  (let ((oldpos (point)))
    (back-to-indentation)
    (and (= oldpos (point))
	 (beginning-of-line))))

(defun buffer-mode (buffer-or-string)
  "Returns the major mode associated with a buffer."
  (with-current-buffer buffer-or-string
    major-mode))
