(provide 'TeXUtils)
(defun TeXUtils-insertBraces (open close start end) "Insert autoscaling pairing braces in LaTeX

Open and close specify the opening and closing braces which can actually be any strings; this function does not attempt to check that they are valid LaTeX delimiters"
       (interactive)
       (goto-char end)
       (insert (concat " \\right" close))
       (goto-char start)
       (insert (concat " \\left" open " ")))
