
;;config for basic func
(add-to-list 'load-path "~/.emacs.d")

(defun open-basic()
  "open my basic config"
  (interactive)
  (require 'basic))


;;config for cedet
(defun open-cedet() 
  "open my cedet"
  (interactive) 
  (require 'mycedet)) 

;el-get
(defun open-mgr()
  "open my mgr"
  (interactive)
  (require 'pkgmgr))

;lua
(defun open-lua()
  "open my lua"
  (interactive)
  (require 'lua-config))

;all
(defun open-all()
  "open all func"
  (interactive)
  (open-basic)
  (open-cedet)
;  (open-mgr)
  (open-lua)
  )

(open-all)
