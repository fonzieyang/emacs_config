;;; emacs-rc-cedet.el ---

;; Copyright (C) 2003 Alex Ott
;;
;; Author: alexott@gmail.com
;; Keywords:
;; Requirements:
;; Status: not intended to be distributed yet

(add-to-list 'load-path "~/.emacs.d/cedet-1.1/common/")
(load-file "~/.emacs.d/cedet-1.1/common/cedet.el")

(semantic-load-enable-excessive-code-helpers)
;(semantic-load-enable-minimum-features)
;(semantic-load-enable-code-helpers)
;(semantic-load-enable-guady-code-helpers)
;(semantic-load-enable-excessive-code-helpers)
;(semantic-load-enable-semantic-debugging-helpers)


(custom-set-variables
 '(semantic-idle-scheduler-idle-time 3)
 '(semantic-self-insert-show-completion-function (lambda nil (semantic-ia-complete-symbol-menu (point))))
 '(global-semantic-tag-folding-mode t nil (semantic-util-modes)))

(setq senator-minor-mode-name "SN")
(setq semantic-imenu-auto-rebuild-directory-indexes nil)
(global-srecode-minor-mode 1)
(global-semantic-mru-bookmark-mode 1)
;(global-semantic-folding-mode 1)


(require 'semantic-decorate-include)

;; gcc setup
(require 'semantic-gcc)

;; smart complitions
(require 'semantic-ia)

(setq-mode-local c-mode semanticdb-find-default-throttle
                 '(project unloaded system recursive))
(setq-mode-local c++-mode semanticdb-find-default-throttle
                 '(project unloaded system recursive))
(setq-mode-local erlang-mode semanticdb-find-default-throttle
                 '(project unloaded system recursive))

(require 'eassist)

;; customisation of modes
(defun alexott/cedet-hook ()
  (local-set-key [(control return)] 'semantic-ia-complete-symbol-menu)
  (local-set-key "\C-c?" 'semantic-ia-complete-symbol)
  ;;
  (local-set-key "\C-c>" 'semantic-complete-analyze-inline)
  (local-set-key "\C-c=" 'semantic-decoration-include-visit)

  (local-set-key "\C-cj" 'semantic-ia-fast-jump)
  (local-set-key "\C-cq" 'semantic-ia-show-doc)
  (local-set-key "\C-cs" 'semantic-ia-show-summary)
  (local-set-key "\C-cp" 'semantic-analyze-proto-impl-toggle)
  (local-set-key (kbd "C-c <left>") 'semantic-tag-folding-fold-block)
  (local-set-key (kbd "C-c <right>") 'semantic-tag-folding-show-block)
  )

(global-set-key "\C-cf" 'semantic-ia-fast-jump)
(global-set-key "\C-cb"
                (lambda ()
                  (interactive)
                  (if (ring-empty-p (oref semantic-mru-bookmark-ring ring))
                      (error "Semantic Bookmark ring is currently empty"))
                  (let* ((ring (oref semantic-mru-bookmark-ring ring))
                         (alist (semantic-mrub-ring-to-assoc-list ring))
                         (first (cdr (car alist))))
                    (if (semantic-equivalent-tag-p (oref first tag)
                                                   (semantic-current-tag))
                        (setq first (cdr (car (cdr alist)))))
                    (semantic-mrub-switch-tags first))))

(global-set-key (kbd "C-x C-b") 'ibuffer)
(autoload 'ibuffer "ibuffer" "List buffers." t)


;; (add-hook 'semantic-init-hooks 'alexott/cedet-hook)
(add-hook 'c-mode-common-hook 'alexott/cedet-hook)
(add-hook 'lisp-mode-hook 'alexott/cedet-hook)
(add-hook 'scheme-mode-hook 'alexott/cedet-hook)
(add-hook 'emacs-lisp-mode-hook 'alexott/cedet-hook)
(add-hook 'erlang-mode-hook 'alexott/cedet-hook)

(defun alexott/c-mode-cedet-hook ()
 ;; (local-set-key "." 'semantic-complete-self-insert)
 ;; (local-set-key ">" 'semantic-complete-self-insert)
  (local-set-key "\C-ct" 'eassist-switch-h-cpp)
  (local-set-key "\C-xt" 'eassist-switch-h-cpp)
  (local-set-key "\C-ce" 'eassist-list-methods)
  (local-set-key "\C-c\C-r" 'semantic-symref)
  )
(add-hook 'c-mode-common-hook 'alexott/c-mode-cedet-hook)

;; hooks, specific for semantic
(defun alexott/semantic-hook ()
;; (semantic-tag-folding-mode 1)
  (imenu-add-to-menubar "TAGS")
 )
(add-hook 'semantic-init-hooks 'alexott/semantic-hook)

;; gnu global support
(when (cedet-gnu-global-version-check t)
  (require 'semanticdb-global)
  (semanticdb-enable-gnu-global-databases 'c-mode)
  (semanticdb-enable-gnu-global-databases 'c++-mode))

;; ctags
(when (cedet-ectag-version-check t)
  (require 'semanticdb-ectag)
  (semantic-load-enable-primary-exuberent-ctags-support))

;;
(semantic-add-system-include "~/exp/include" 'c++-mode)
(semantic-add-system-include "~/exp/include" 'c-mode)

(defun recur-list-files (dir re)
  "Returns list of files in directory matching to given regex"
  (when (file-accessible-directory-p dir)
    (let ((files (directory-files dir t))
          matched)
      (dolist (file files matched)
        (let ((fname (file-name-nondirectory file)))
          (cond
           ((or (string= fname ".")
                (string= fname "..")) nil)
           ((and (file-regular-p file)
                 (string-match re fname))
            (setq matched (cons file matched)))
           ((file-directory-p file)
            (let ((tfiles (recur-list-files file re)))
              (when tfiles (setq matched (append matched tfiles)))))))))))

(defun c++-setup-boost (boost-root)
  (when (file-accessible-directory-p boost-root)
    (let ((cfiles (recur-list-files boost-root "\\(config\\|user\\)\\.hpp")))
      (dolist (file cfiles)
        (add-to-list 'semantic-lex-c-preprocessor-symbol-file file)))))


;;
;;(global-semantic-idle-tag-highlight-mode 1)

;;; ede customization
(require 'semantic-lex-spp)
(global-ede-mode t)
(ede-enable-generic-projects)

;; maven-based projects
;;(ede-maven2-project "clojure-hadoop" :file "~/projects/clojure-hadoop/pom.xml")

;; cpp-tests project definition
(when (file-exists-p "~/projects/lang-exp/cpp/CMakeLists.txt")
  (setq cpp-tests-project
    (ede-cpp-root-project "cpp-tests"
                  :file "~/projects/lang-exp/cpp/CMakeLists.txt"
                  :system-include-path '("/home/ott/exp/include"
                             boost-base-directory)
                  :local-variables (list
                        (cons 'compile-command 'alexott/gen-cmake-debug-compile-string)
                        )
                  )))

(when (file-exists-p "~/projects/squid-gsb/README")
  (setq squid-gsb-project
    (ede-cpp-root-project "squid-gsb"
                  :file "~/projects/squid-gsb/README"
                  :system-include-path '("/home/ott/exp/include"
                             boost-base-directory)
                  :local-variables (list
                        (cons 'compile-command 'alexott/gen-cmake-debug-compile-string)
                        )
                  )))

(when (file-exists-p "~/work/emacs-head/README")
  (setq emacs-project
    (ede-emacs-project "emacs-head"
               :file "~/work/emacs-head/README")))

;; (setq arabica-project
;;       (ede-cpp-root-project "arabica"
;;                             :file "~/projects/arabica-devel/README"
;;                             :system-include-path '("/home/ott/exp/include"
;;                                                    boost-base-directory)
;;                             :local-variables (list
;;                                               (cons 'compile-command 'alexott/gen-std-compile-string)
;;                                               )
;;                             ))

;; my functions for EDE
(defun alexott/ede-get-local-var (fname var)
  "fetch given variable var from :local-variables of project of file fname"
  (let* ((current-dir (file-name-directory fname))
         (prj (ede-current-project current-dir)))
    (when prj
      (let* ((ov (oref prj local-variables))
            (lst (assoc var ov)))
        (when lst
          (cdr lst))))))

;; setup compile package
;; TODO: allow to specify function as compile-command
(require 'compile)
(setq compilation-disable-input nil)
(setq compilation-scroll-output t)
(setq mode-compile-always-save-buffer-p t)

(defun alexott/compile ()
  "Saves all unsaved buffers, and runs 'compile'."
  (interactive)
  (save-some-buffers t)
  (let* ((r (alexott/ede-get-local-var
             (or (buffer-file-name (current-buffer)) default-directory)
             'compile-command))
         (cmd (if (functionp r) (funcall r) r)))
;;    (message "AA: %s" cmd)
    (set (make-local-variable 'compile-command) (or cmd compile-command))
    (compile compile-command)))

(global-set-key [f9] 'alexott/compile)

;;
(defun alexott/gen-std-compile-string ()
  "Generates compile string for compiling CMake project in debug mode"
  (let* ((current-dir (file-name-directory
                       (or (buffer-file-name (current-buffer)) default-directory)))
         (prj (ede-current-project current-dir))
         (root-dir (ede-project-root-directory prj))
         )
    (concat "cd " root-dir "; make -j2")))

;;
(defun alexott/gen-cmake-debug-compile-string ()
  "Generates compile string for compiling CMake project in debug mode"
  (let* ((current-dir (file-name-directory
                       (or (buffer-file-name (current-buffer)) default-directory)))
         (prj (ede-current-project current-dir))
         (root-dir (ede-project-root-directory prj))
         (subdir "")
         )
    (when (string-match root-dir current-dir)
      (setf subdir (substring current-dir (match-end 0))))
    (concat "cd " root-dir "Debug/" "; make -j3")))

(defun alexott/gen-cmake-debug/release-compile-string ()
  "Generates compile string for compiling CMake project in debug & release modes"
  (let* ((current-dir (file-name-directory
                       (or (buffer-file-name (current-buffer)) default-directory)))
         (prj (ede-current-project current-dir))
         (root-dir (ede-project-root-directory prj))
         (subdir "")
         )
    (when (string-match root-dir current-dir)
      (setf subdir (substring current-dir (match-end 0))))
    (concat "cd " root-dir "Debug/ && make -j3 && cd " root-dir "Release/ && make -j3" )))

;; clang setup
(require 'semantic-clang)

;;; emacs-rc-cedet.el ends here
(provide 'mycedet)
