(provide 'genaralUtils)

(defun genaralUtils-killBuffersMatchingRegex (regex)
    (interactive "sRegex")
  (let ((buffers (buffer-list))
        zombies)
    (while buffers
      (when (string-match regex (buffer-name (car buffers)))
        (setq zombies (append zombies (list (car buffers)))))
      (setq buffers (cdr buffers)))
    (while zombies
      (kill-buffer (car zombies))
      (setq zombies (cdr zombies)))))
