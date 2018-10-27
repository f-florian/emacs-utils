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

(defun smart-beginning-of-line ()
  "Move point to first non-whitespace character or beginning-of-line.

Move point to the first non-whitespace character on this line.
If point was already at that position, move point to beginning of line."
  (interactive)
  (let ((oldpos (point)))
    (back-to-indentation)
    (and (= oldpos (point))
	 (beginning-of-line))))

(defun buffer-mode (buffer-or-string)
  "Returns the major mode associated with a buffer."
  (with-current-buffer buffer-or-string
    major-mode))
