;;; snails-backend-rg.el --- Ripgrep backend for snails

;; Filename: snails-backend-rg.el
;; Description: Ripgrep backend for snails
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2019, Andy Stewart, all rights reserved.
;; Created: 2019-07-23 16:41:05
;; Version: 0.1
;; Last-Updated: 2019-07-23 16:41:05
;;           By: Andy Stewart
;; URL: http://www.emacswiki.org/emacs/download/snails-backend-rg.el
;; Keywords:
;; Compatibility: GNU Emacs 26.2
;;
;; Features that might be required by this library:
;;
;;
;;

;;; This file is NOT part of GNU Emacs

;;; License
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; Ripgrep backend for snails
;;

;;; Installation:
;;
;; Put snails-backend-rg.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'snails-backend-rg)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET snails-backend-rg RET
;;

;;; Change log:
;;
;; 2019/07/23
;;      * First released.
;;

;;; Acknowledgements:
;;
;;
;;

;;; TODO
;;
;;
;;

;;; Require
(require 'snails-core)
(when (featurep 'cocoa)
  (require 'exec-path-from-shell)
  (exec-path-from-shell-initialize))

;;; Code:

(snails-create-async-backend
 :name
 "RG"

 :build-command
 (lambda (input)
   (when (and (executable-find "rg")
              (> (length input) 5))
     (let ((project (project-current)))
       (when project
         (list "rg" "--no-heading" "--column" "--color" "never" "--max-columns" "300" input (expand-file-name (cdr project)))
         ))))

 :candidate-filter
 (lambda (candidate-list)
   (let (candidates)
     (dolist (candidate candidate-list)
       (let ((file-info (split-string candidate ":"))
             (project-dir (expand-file-name (cdr (project-current)))))
         (add-to-list 'candidates
                      (list
                       (snails-wrap-file-icon-with-candidate
                        (nth 0 file-info)
                        (format "PDIR/%s" (nth 1 (split-string candidate project-dir))))
                       candidate)
                      t)))
     candidates))

 :candiate-do
 (lambda (candidate)
   (let ((file-info (split-string candidate ":")))
     (when (> (length file-info) 3)
       ;; Open file and jump to position.
       (find-file (nth 0 file-info))
       (goto-line (string-to-number (nth 1 file-info)))
       (goto-column (max (- (string-to-number (nth 2 file-info)) 1) 0))

       ;; Flash match line.
       (let ((pulse-iterations 1)
             (pulse-delay 0.3))
         (pulse-momentary-highlight-one-line (point) 'highlight))
       ))))

(provide 'snails-backend-rg)

;;; snails-backend-rg.el ends here

