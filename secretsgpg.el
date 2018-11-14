(provide 'secretsgpg)

(defvar secretsgpg-defaultFilename "~/.emacs.d/secrets/secrets.gpg" "filename to look in to loads secrets hash table")
(defvar secretsgpg-hashTable (make-hash-table :test 'equal :rehash-size 2.5))

(defun secretsgpg-loadEncryptedPasswords (hashTable &optional filename) "read data from (encrypted) file filename and stores them in hashTable
Each entry correspond to a single file line of the form 'key data' (without quotes),
where: key is the hash key; data is the data associated to key, as a space separated list of elements which will be loaded to a lisp list
Requires transparent decryption configured to work on encrypted files, see e.g. https://www.emacswiki.org/emacs/EasyPG"
       (interactive "fFilename")
       (let ((passwds nil) (tmpval nil))
         (unless filename (setq filename secretsgpg-defaultFilename))
         (with-temp-buffer
           (insert-file-contents filename)
           (setq passwds (split-string (buffer-substring-no-properties (point-min) (point-max)) "\n" t)))
         (while passwds
           (setq tmpval (split-string (car passwds)))
           (setq passwds (cdr passwds))
           (unless (gethash (car tmpval) hashTable)
               (puthash (car tmpval) (cdr tmpval) hashTable)))))

(defun secretsgpg-getEncryptedPassword (name &optional hashTableObject) "Get password which is stored encrypted (but may alreay have been loaded)

Get the value associated to the key 'name' in the specified hash table (if it is an hash table, otherwise in SecretsgpgHashTable).
The returned vaule is a list"
       (let()
         (unless (hash-table-p hashTableObject)
           (setq hashTableObject secretsgpg-hashTable))
         (setq value (gethash name hashTableObject nil))
         (if value
             value
           (secretsgpg-load-encrypted-passwords hashTableObject secretsgpg-defaultFilename)
           (gethash name hashTableObject nil))))

(defun secretsgpg-addLineToFile (data &optional filename) "Append a line with given content to a given file

The file is assumed to end with a newline"
       (interactive "sLine fFilename")
       (with-temp-buffer
         (unless filename (setq filename secretsgpg-defaultFilename))
         (insert-file-contents filename)
         (insert (concat data "\n"))
         (save-buffer)))

