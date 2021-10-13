(provide 'TeXUtils)
(require 'textUtils)

(defun TeXUtils-insertBraces (open close start end) "Insert autoscaling pairing braces in LaTeX

Open and close specify the opening and closing braces which can actually be any strings; this function does not attempt to check that they are valid LaTeX delimiters"
       (interactive)
       (goto-char end)
       (insert (concat " \\right" close))
       (goto-char start)
       (insert (concat "\\left" open " ")))

(defun TeXUtils-mkAutobraces () "Make normal braces \left-\right type blaces

Todo: make the list of braces customizable or match something existing
TODO: point must be on open bracet"
  (interactive)
  (insert "\\left")
  (forward-sexp 1)
  (backward-char 1)
  (insert "\\right"))

(defun TeXUtils-rmAutobraces () "Make normal braces \left-\right type blaces

Todo: make the list of braces customizable or match something existing
TODO: point must be on open bracet"
  (interactive)
  (delete-region (point) (- (point) 5))
  (forward-sexp 1)
  (delete-region (- (point) 1) (- (point) 7)))

(defun TeXUtils-toggleAutobraces () "Toggle between normal braces and \left-\right type blaces

TODO: call make or remove as appropriate"
  (interactive)
  (TeXUtils-mkAutobraces))

(defun TeXUtils-decideCase ()
  "Decide if auto-capitalize should upcase next word in TeX mode.

Exclude math, but looks for points in math mode."
  (or (not (save-match-data (texmathp)))
      (not (looking-back
        "[.!?]\\( \\|	\\|
\\|\\\\end{[a-zA-Z\\*]*}\\)*" (- (point) 50)))))

;; (global-set-key (kbd "<f5> <f5>") (lambda () (interactive)
;;                       (if (not (looking-back
;;                                 "[.!?]\\( \\|	\\|
;; \\|\\\\end{[a-zA-Z\\*]*}\\)*" (- (point) 50)))(insert "t")(insert "f"))))
