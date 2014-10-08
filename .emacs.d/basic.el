;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;basic config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(set-default-font "-apple-Monaco-medium-normal-normal-*-12-*-*-*-m-0-iso10646-1")


(global-set-key "\C-c\C-n" 'other-window)

(defun other-window-backward (&optional n) 
  "Select Nth previous window." 
  (interactive "P") 
  (other-window (- (prefix-numeric-value n)))) 

(global-set-key "\C-c\C-p" 'other-window-backward)

(defun read-only-if-symlink ()
  "make file real-only if symlink"
  (if (file-symlink-p buffer-file-name)
      (progn
	(setq buffer-read-only t)
	(message "File is a symlink"))))

(add-hook 'find-file-hook 'read-only-if-symlink)

(add-hook 'org-mode-hook (lambda () (setq truncate-lines nil)))

(defun count-unicode-words-region (start end) 
   "" 
   (interactive "r") 
   (let (count) 
     (save-excursion 
       (save-restriction 
         (narrow-to-region start end) 
         (setq count (count-unicode-words start end)))) 
     (message (mapconcat #'(lambda (x) (format "%s: %s" (car x) 
                                               (propertize 
                                                (number-to-string 
                                                 (cdr x)) 
                                                'face '((t (:foreground "#729fcf" :bold t)))))) 
                         count " ")))) 
  
(defun count-unicode-words-buffer () 
   "" 
   (interactive) 
   (let (count) 
         (save-excursion 
           (setq count (count-unicode-words (point-min) (point-max)))) 
         (message (mapconcat #'(lambda (x) (format "%s: %s" 
                                                   (car x) 
                                                   (propertize (number-to-string (cdr x)) 
                                                               'face 
                                                               '((t (:foreground "#729fcf" :bold t)))))) 
                             count " ")))) 
  
(defun count-unicode-words (start end) 
   "count unicode words" 
   (let ((latin 0) (chinese 0) 
         (semiangle 0) (fullangle 0) 
         (others 0) (total 0) 
         count class (iter 0)) 
     (goto-char start) 
     (while (< start end) 
           (skip-chars-forward "[\000-\037\177-\377]") 
           (skip-chars-forward "[[:space:]]") 
           (setq start (point)) 
           (cond 
            ((looking-at "[[:punct:]]") 
           (cond ((looking-at "[\x00-\xff]") 
                  (setq semiangle (1+ semiangle))) 
                 ((looking-at "[\\(\xff00-\xffef\\|\\x3000-\x303f\\)]") 
                  (setq fullangle (1+ fullangle))) 
                 (t (setq others (1+ others)))) 
           (forward-char) 
           (setq start (point))) 
          ((looking-at "[\x00-xff]+?") 
           (setq latin (1+ latin)) 
           (forward-word) 
           (setq start (point))) 
          ((looking-at "[\x4e00-\x9fa5]") 
           (setq chinese (1+ chinese)) 
           (forward-char) 
           (setq start (point))) 
          (t (unless (= start end) 
               (forward-char) 
               (setq others (1+ others)) 
               (setq start (point)))))) 
     (setq count '(("Chinese" . 0) ("Latin" . 0) ("Semiangle" . 0) ("Fullangle" . 0)  
("Others" . 0))) 
     (setq numl (list chinese latin semiangle fullangle others)) 
     (dolist (item numl iter) 
       (setq total (+ total item)) 
       (setcdr (nth iter count) item) 
       (setq iter (1+ iter))) 
     (push (cons "Total" total) count) 
     count)) 

(global-set-key "\C-c\C-w" 'count-unicode-words-buffer)
;;��ʾ�к�
(column-number-mode t)
;;������ʾƥ�������
(show-paren-mode t)
;;�ı�emacsҪ��ش�yes����Ϊ
(fset 'yes-or-no-p 'y-or-n-p) 
;;�رճ���ʱ����ʾ��
(setq visiable-bell t) 
;;���еı����ļ���������~/backupsĿ¼��
(setq backup-directory-alist (quote (("." . "~/backups"))))
(setq version-control t)
(setq kept-old-versions 2)
(setq kept-new-versions 5)
(setq delete-old-versions t)
(setq backup-directory-alist '(("." . "~/backups")))
(setq backup-by-copying t)
;;��tab�������Ʊ���滻Ϊ�ȳ��ȵĿո�
(setq-default indent-tabs-mode nil)
;;����tab�ĳ���Ϊ4���ַ�
(setq-default tab-width 4)

;����
(add-to-list 'load-path "~/.emacs.d/color-theme-6.6.0")
(require 'color-theme)
;(color-theme-initialize)
;(color-theme-arjen)

(require 'org-docbook) ;; 
(setq org-export-docbook-xsl-fo-proc-command "/usr/local/bin/fop \"%i\" \"%o\"")
(setq org-export-docbook-xslt-proc-command "/usr/local/bin/saxon -o:\"%o\" -s:\"%i\" -xsl:\"%s\"") 
(setq org-export-docbook-xslt-stylesheet "/usr/local/Cellar/docbook/5.0/docbook/xsl-ns/1.77.1/fo/docbook.xsl")

(if (eq window-system 'mac)
   (add-to-list 'exec-path "/usr/local/texlive/2013basic/bin/universal-darwin")
)

(provide 'basic)
