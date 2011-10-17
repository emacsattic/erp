;;; erp.el --- ERP(Enterprise Ressource Planning) in plain text. 

;; Filename: erp.el
;; Description: ERP(Enterprise Ressource Planning) in plain text. 
;; Author: Thorsten <tj at data-driven dot de>
;; Maintainer: Thorsten <tj at data-driven dot de>
;; Copyright (C) 2011, Thorsten, all rights reserved.
;; Created: 2011-06-25 14:28:48
;; Version: 0.1
;; Last-Updated: 2011-06-25 14:28:48
;;           By: Thorsten
;; URL: http://www.emacswiki.org/emacs/download/erp.el
;;
;; Keywords: CRM (Customer Relationship Management), Accounting (acc),
;; Operations Management (op), Stock & Manufactering (stm), Sales &
;; Purchases (sp), Process- & Documentmanagement (pd),Human Ressource
;; Management (hrm), ERP (Enterprise Ressource Planning)
;;
;; Compatibility: GNU Emacs 23.2.1
;;
;; Features that might be required by this library:
;;
;; (require 'org)
;; (require 'ledger)
;; (require 'calc)
;; (require 'bbdb)
;; (require 'gnus)
;; (require 'gnus)
;; (require 'taskjuggler)



;;; This file is NOT part of GNU Emacs

;;; License
;;
v;; This program is free software; you can redistribute it and/or modify
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
;; ERP-mode for Emacs (Enterprise Ressource Planning) 
;; 
;; Emacs has been used by programmers, scientists, freelancers and
;; other users as a feature-rich personnal ressource planning tool for
;; many years now. In fact, the facilities provided for communication
;; (e.g. Gnus), organisation (e.g. Org), writing, reporting and
;; presentations (e.g. LaTex, Org-babel), calculations (e.g. Calc,
;; Org-tables) as well as accounting (e.g. Ledger) are often
;; incredibly powerfull and efficient to use. In combination with a
;; version control system like e.g. GIT, this text-based ressource
;; planning environment can be easily turned into a sophisticated
;; collaborative system for groups of users that keeps track of every
;; single change of the shared text-files in a distributed fast
;; database (thats what GIT is). 
;; 
;; ERP-software has long been one of the last big market segments
;; entirely dominated by proprietary software of leading software
;; companies. This changed in the last years with the appearance of
;; several Open-Source ERP-Software projects. Often, there is a huge
;; gap between marketing and real software-quality in these projects,
;; and the Open-Source philosophy is quickly abandoned once the
;; intensive marketing resulted in commercial success for the company
;; backing the project.
;;
;; The aim of erp-mode is to make the power of Emacs ressource
;; planning tools more accessible to average users of ERP-software,
;; enabling the Emacs power-users and programmers to use Emacs as a
;; license free and highly customizable software in
;; ERP-consulting. Therefore, erp-mode is more concerned with hiding
;; already available functionality (and the resulting complexity)
;; rather than with adding new functionality. It should be an
;; extremely simple yet efficient frontend for the uninitialized
;; ERP-User, while at the same time providing all the Emacs power for
;; the ERP-Integrator and -Programmer (under the hood).


;;; Installation:
;;
;; Put erp.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'erp-mode)
;;
;; No need more.

;;; Customize:
;;
;; 
;;
;; All of the above can customize by:
;;      M-x customize-group RET erp-mode RET
;;

;;; Change log:
;;	
;; 2011/06/25
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
(require 'easymenu)

;;; Code:

;;;; Customization variables

;;; Version

(defconst erp-version "0.01x"
  "The version number of the file erp.el.")

;;; Compatibility constants

;;; The custom variables

(defgroup erp nil
  "ERP(Enterprise Ressource Planning) in plain text."
  :tag "ERP")

(defcustom erp-mode-hook nil
  "Mode hook for erp-mode, run after the mode was turned on."
  :group 'erp
  :type 'hook)

(defcustom erp-load-hook nil
  "Hook that is run after erp.el has been loaded."
  :group 'erp
  :type 'hook)

(defvar erp-modules)  ; defined below
(defvar erp-modules-loaded nil
  "Have the modules been loaded already?")

(defun erp-load-modules-maybe (&optional force)
  "Load all extensions listed in `erp-modules'."
  (when (or force (not erp-modules-loaded))
    (mapc (lambda (ext)
            (condition-case nil (require ext)
              (error (message "Problems while trying to load feature `%s'" ext))))
          erp-modules)
    (setq erp-modules-loaded t)))

(defun erp-set-modules (var value)
  "Set VAR to VALUE and call `erp-load-modules-maybe' with the force flag."
  (set var value)
  (when (featurep 'erp)
    (erp-load-modules-maybe 'force)))

;; (when (erp-bound-and-true-p erp-modules)
;;   (let ((a (member 'erp-infojs erp-modules)))
;;     (and a (setcar a 'erp-jsinfo))))

(defcustom erp-modules '(erp-crm erp-acc erp-op erp-stm erp-sp erp-pd erp-hrm)
  "Modules that should always be loaded together with erp.el.
If a description starts with <C>, the file is not part of Emacs
and loading it will require that you have downloaded and properly installed
the erp-mode distribution.

You can also use this system to load external packages (i.e. neither ERP
core modules, nor modules from the CONTRIB directory).  Just add symbols
to the end of the list.  If the package is called erp-xyz.el, then you need
to add the symbol `xyz', and the package must have a call to

   (provide 'erp-xyz)"
  :group 'erp
  :set 'erp-set-modules
  :type
  '(set :greedy t
        (const :tag "   crm:              Customer Relationship Management" erp-crm)
        (const :tag "   acc:            Accounting" erp-acc)
        (const :tag "   op:             Operations Management" erp-op)
        (const :tag "   stm:              Stock & Manufactoring" erp-stm)
        (const :tag "   sp:             Sales & Purchases" erp-sp)
        (const :tag "   pd:            Process- & Documentmanagement" erp-pd)
        (const :tag "   hrm:            Human Ressource Management" erp-pd)
))

(defgroup erp-startup nil
  "Options concerning startup of erp-mode."
  :tag "ERP Startup"
  :group 'erp)

(defcustom erp-insert-mode-line-in-empty-file nil
  "Non-nil means insert the first line setting erp-mode in empty files.
When the function `erp-mode' is called interactively in an empty file, this
normally means that the file name does not automatically trigger erp-mode.
To ensure that the file will always be in erp-mode in the future, a
line enforcing erp-mode will be inserted into the buffer, if this option
has been set."
  :group 'erp-startup
  :type 'boolean)


;;; Functions and variables from their packages
;;  Declared here to avoid compiler warnings

;; ...

;; ;; Various packages
;; (declare-function calendar-absolute-from-iso    "cal-iso"    (date))
;; (declare-function calendar-forward-day          "cal-move"   (arg))
;; (declare-function calendar-goto-date            "cal-move"   (date))
;; (declare-function calendar-goto-today           "cal-move"   ())
;; (declare-function calendar-iso-from-absolute    "cal-iso"    (date))
;; (defvar calc-embedded-close-formula)
;; (defvar calc-embedded-open-formula)

;;; Autoload and prepare some erp modules

;; ...

;; Autoload the functions in erp-xyz.el that are needed by functions here.

;; ...

;; (eval-and-compile
;;   (org-autoload "org-table"
;;                 '(org-table-align org-table-begin org-table-blank-field
;;                                   org-table-convert org-table-convert-region org-table-copy-down
;;                                   org-table-copy-region org-table-create
;;                                   org-table-create-or-convert-from-region
;;                                   org-table-create-with-table.el org-table-current-dline
;;                                   org-table-cut-region org-table-delete-column org-table-edit-field
;;                                   org-table-edit-formulas org-table-end org-table-eval-formula
;;                                   org-table-export org-table-field-info
;;                                   org-table-get-stored-formulas org-table-goto-column
;;                                   org-table-hline-and-move org-table-import org-table-insert-column
;;                                   org-table-insert-hline org-table-insert-row org-table-iterate
;;                                   org-table-justify-field-maybe org-table-kill-row
;;                                   org-table-maybe-eval-formula org-table-maybe-recalculate-line
;;                                   org-table-move-column org-table-move-column-left
;;                                   org-table-move-column-right org-table-move-row
;;                                   org-table-move-row-down org-table-move-row-up
;;                                   org-table-next-field org-table-next-row org-table-paste-rectangle
;;                                   org-table-previous-field org-table-recalculate
;;                                   org-table-rotate-recalc-marks org-table-sort-lines org-table-sum
;;                                   org-table-toggle-coordinate-overlays
;;                                   org-table-toggle-formula-debugger org-table-wrap-region
;;                                   orgtbl-mode turn-on-orgtbl org-table-to-lisp)))



;; (defun erp-at-input-p (&optional table-type)
;;   "Return t if the cursor is inside an erp-type inputfield."
;;   (if org-enable-table-editor
;;       (save-excursion
;;         (beginning-of-line 1)
;;         (looking-at (if table-type org-table-any-line-regexp
;;                       org-table-line-regexp)))
;;     nil))
;; (defsubst erp-input-p () (erp-at-input-p))




;; (defun erp-recognize-input.el ()
;;   "If there is a table.el table nearby, recognize it and move into it."
;;   (if org-table-tab-recognizes-table.el
;;       (if (org-at-table.el-p)
;;           (progn
;;             (beginning-of-line 1)
;;             (if (looking-at org-table-dataline-regexp)
;;                 nil
;;               (if (looking-at org-table1-hline-regexp)
;;                   (progn
;;                     (beginning-of-line 2)
;;                     (if (looking-at org-table-any-border-regexp)
;;                         (beginning-of-line -1)))))
;;             (if (re-search-forward "|" (org-table-end t) t)
;;                 (progn
;;                   (require 'table)
;;                   (if (table--at-cell-p (point))
;;                       t
;;                     (message "recognizing table.el table...")
;;                     (table-recognize-table)
;;                     (message "recognizing table.el table...done")))
;;               (error "This should not happen..."))
;;             t)
;;         nil)
;;     nil)) 


;; ;;; Variables for pre-computed regular expressions, all buffer local

;; (defvar org-drawer-regexp nil
;;   "Matches first line of a hidden block.")
;; (make-variable-buffer-local 'org-drawer-regexp)
;; (defvar org-todo-regexp nil
;;   "Matches any of the TODO state keywords.")
;; (make-variable-buffer-local 'org-todo-regexp)



;; (defun org-set-regexps-and-options ()
;;   "Precompute regular expressions for current buffer.")


;;;; Define the Org-mode

;; ;;;###autoload
;; (define-derived-mode org-mode outline-mode "Org"
;;   "Outline-based notes management and organizer, alias
;; \"Carsten's outline-mode for keeping track of everything.\"

;; Org-mode develops organizational tasks around a NOTES file which
;; contains information about projects as plain text.  Org-mode is
;; implemented on top of outline-mode, which is ideal to keep the content
;; of large files well structured.  It supports ToDo items, deadlines and
;; time stamps, which magically appear in the diary listing of the Emacs
;; calendar.  Tables are easily created with a built-in table editor.
;; Plain text URL-like links connect to websites, emails (VM), Usenet
;; messages (Gnus), BBDB entries, and any files related to the project.
;; For printing and sharing of notes, an Org-mode file (or a part of it)
;; can be exported as a structured ASCII or HTML file.

;; The following commands are available:

;; \\{org-mode-map}"

(erp-load-modules-maybe)
(easy-menu-add erp-erp-menu)
(easy-menu-add erp-tbl-menu)

(define-derived-mode erp-mode special-mode "ERP"
  "ERP(Enterprise Ressource Planning) in plain text")


;;;; Font-Lock stuff, including the activators

;; ...


;; ;;;; Files

;; (defun org-save-all-org-buffers ()
;;   "Save all Org-mode buffers without user confirmation."
;;   (interactive)
;;   (message "Saving all Org-mode buffers...")
;;   (save-some-buffers t 'org-mode-p)
;;   (when (featurep 'org-id) (org-id-locations-save))
;;   (message "Saving all Org-mode buffers... done"))

;; (defun org-revert-all-org-buffers ()
;;   "Revert all Org-mode buffers.
;; Prompt for confirmation when there are unsaved changes.
;; Be sure you know what you are doing before letting this function
;; overwrite your changes.

;; This function is useful in a setup where one tracks org files
;; with a version control system, to revert on one machine after pulling
;; changes from another.  I believe the procedure must be like this:

;; 1. M-x org-save-all-org-buffers
;; 2. Pull changes from the other machine, resolve conflicts
;; 3. M-x org-revert-all-org-buffers"
;;   (interactive)
;;   (unless (yes-or-no-p "Revert all Org buffers from their files? ")
;;     (error "Abort"))
;;   (save-excursion
;;     (save-window-excursion
;;       (mapc
;;        (lambda (b)
;;          (when (and (with-current-buffer b (org-mode-p))
;;                     (with-current-buffer b buffer-file-name))
;;            (switch-to-buffer b)
;;            (revert-buffer t 'no-confirm)))
;;        (buffer-list))
;;       (when (and (featurep 'org-id) org-id-track-globally)
;;         (org-id-locations-load)))))

;; erp mode key bindings and initialization
;; ORG
;; ;;;; Key bindings

;; ;; Make `C-c C-x' a prefix key
;; (org-defkey org-mode-map "\C-c\C-x" (make-sparse-keymap))

;; ;; TAB key with modifiers
;; (org-defkey org-mode-map "\C-i"       'org-cycle)
;; (org-defkey org-mode-map [(tab)]      'org-cycle)
;; (org-defkey org-mode-map [(control tab)] 'org-force-cycle-archived)
;; (org-defkey org-mode-map [(meta tab)] 'org-complete)
;; (org-defkey org-mode-map "\M-\t" 'org-complete)
;; (org-defkey org-mode-map "\M-\C-i"      'org-complete)
;; ;; The following line is necessary under Suse GNU/Linux
;; (unless (featurep 'xemacs)
;;   (org-defkey org-mode-map [S-iso-lefttab]  'org-shifttab))
;; (org-defkey org-mode-map [(shift tab)]    'org-shifttab)
;; (define-key org-mode-map [backtab] 'org-shifttab)

;; (org-defkey org-mode-map [(shift return)]   'org-table-copy-down)
;; (org-defkey org-mode-map [(meta shift return)] 'org-insert-todo-heading)
;; (org-defkey org-mode-map [(meta return)]       'org-meta-return)

;; ;; Cursor keys with modifiers
;; (org-defkey org-mode-map [(meta left)]  'org-metaleft)
;; (org-defkey org-mode-map [(meta right)] 'org-metaright)
;; (org-defkey org-mode-map [(meta up)]    'org-metaup)
;; (org-defkey org-mode-map [(meta down)]  'org-metadown)

;; (org-defkey org-mode-map [(meta shift left)]   'org-shiftmetaleft)
;; (org-defkey org-mode-map [(meta shift right)]  'org-shiftmetaright)
;; (org-defkey org-mode-map [(meta shift up)]     'org-shiftmetaup)
;; (org-defkey org-mode-map [(meta shift down)]   'org-shiftmetadown)

;; (org-defkey org-mode-map [(shift up)]          'org-shiftup)
;; (org-defkey org-mode-map [(shift down)]        'org-shiftdown)
;; (org-defkey org-mode-map [(shift left)]        'org-shiftleft)
;; (org-defkey org-mode-map [(shift right)]       'org-shiftright)

;; (org-defkey org-mode-map [(control shift right)] 'org-shiftcontrolright)
;; (org-defkey org-mode-map [(control shift left)]  'org-shiftcontrolleft)

;; ;;; Extra keys for tty access.
;; ;;  We only set them when really needed because otherwise the
;; ;;  menus don't show the simple keys

;; (when (or org-use-extra-keys
;;           (featurep 'xemacs)   ;; because XEmacs supports multi-device stuff
;;           (not window-system))
;;   (org-defkey org-mode-map "\C-c\C-xc"    'org-table-copy-down)
;;   (org-defkey org-mode-map "\C-c\C-xM"    'org-insert-todo-heading)
;;   (org-defkey org-mode-map "\C-c\C-xm"    'org-meta-return)
;;   (org-defkey org-mode-map [?\e (return)] 'org-meta-return)
;;   (org-defkey org-mode-map [?\e (left)]   'org-metaleft)
;;   (org-defkey org-mode-map "\C-c\C-xl"    'org-metaleft)
;;   (org-defkey org-mode-map [?\e (right)]  'org-metaright)
;;   (org-defkey org-mode-map "\C-c\C-xr"    'org-metaright)
;;   (org-defkey org-mode-map [?\e (up)]     'org-metaup)
;;   (org-defkey org-mode-map "\C-c\C-xu"    'org-metaup)
;;   (org-defkey org-mode-map [?\e (down)]   'org-metadown)
;;   (org-defkey org-mode-map "\C-c\C-xd"    'org-metadown)
;;   (org-defkey org-mode-map "\C-c\C-xL"    'org-shiftmetaleft)
;;   (org-defkey org-mode-map "\C-c\C-xR"    'org-shiftmetaright)
;;   (org-defkey org-mode-map "\C-c\C-xU"    'org-shiftmetaup)
;;   (org-defkey org-mode-map "\C-c\C-xD"    'org-shiftmetadown)
;;   (org-defkey org-mode-map [?\C-c (up)]    'org-shiftup)
;;   (org-defkey org-mode-map [?\C-c (down)]  'org-shiftdown)
;;   (org-defkey org-mode-map [?\C-c (left)]  'org-shiftleft)
;;   (org-defkey org-mode-map [?\C-c (right)] 'org-shiftright)
;;   (org-defkey org-mode-map [?\C-c ?\C-x (right)] 'org-shiftcontrolright)
;;   (org-defkey org-mode-map [?\C-c ?\C-x (left)] 'org-shiftcontrolleft)
;;   (org-defkey org-mode-map [?\e (tab)] 'org-complete)
;;   (org-defkey org-mode-map [?\e (shift return)] 'org-insert-todo-heading)
;;   (org-defkey org-mode-map [?\e (shift left)]   'org-shiftmetaleft)
;;   (org-defkey org-mode-map [?\e (shift right)]  'org-shiftmetaright)
;;   (org-defkey org-mode-map [?\e (shift up)]     'org-shiftmetaup)
;;   (org-defkey org-mode-map [?\e (shift down)]   'org-shiftmetadown))

;; ;; All the other keys

;; (org-defkey org-mode-map "\C-c\C-a" 'show-all)  ; in case allout messed up.
;; (org-defkey org-mode-map "\C-c\C-r" 'org-reveal)
;; (if (boundp 'narrow-map)
;;     (org-defkey narrow-map "s" 'org-narrow-to-subtree)
;;   (org-defkey org-mode-map "\C-xns" 'org-narrow-to-subtree))
;; (org-defkey org-mode-map "\C-c\C-f"    'org-forward-same-level)
;; (org-defkey org-mode-map "\C-c\C-b"    'org-backward-same-level)
;; (org-defkey org-mode-map "\C-c$"    'org-archive-subtree)
;; (org-defkey org-mode-map "\C-c\C-x\C-s" 'org-advertized-archive-subtree)
;; (org-defkey org-mode-map "\C-c\C-x\C-a" 'org-archive-subtree-default)
;; (org-defkey org-mode-map "\C-c\C-xa" 'org-toggle-archive-tag)
;; (org-defkey org-mode-map "\C-c\C-xA" 'org-archive-to-archive-sibling)
;; (org-defkey org-mode-map "\C-c\C-xb" 'org-tree-to-indirect-buffer)
;; (org-defkey org-mode-map "\C-c\C-j" 'org-goto)
;; (org-defkey org-mode-map "\C-c\C-t" 'org-todo)
;; (org-defkey org-mode-map "\C-c\C-q" 'org-set-tags-command)
;; (org-defkey org-mode-map "\C-c\C-s" 'org-schedule)
;; (org-defkey org-mode-map "\C-c\C-d" 'org-deadline)
;; (org-defkey org-mode-map "\C-c;"    'org-toggle-comment)
;; (org-defkey org-mode-map "\C-c\C-v" 'org-show-todo-tree)
;; (org-defkey org-mode-map "\C-c\C-w" 'org-refile)
;; (org-defkey org-mode-map "\C-c/"    'org-sparse-tree)   ; Minor-mode reserved
;; (org-defkey org-mode-map "\C-c\\"   'org-match-sparse-tree) ; Minor-mode res.



;; dired
(defvar erp-erp-map
  ;; This looks ugly when substitute-command-keys uses C-d instead d:
  ;;  (define-key erp "\C-d" 'erp-flag-file-deletion)
  (let ((map (make-keymap)))
    (suppress-keymap map)
    ;; Commands to mark or flag certain categories of files
    (define-key map "#" 'erp-flag-auto-save-files)
    (define-key map "." 'erp-clean-directory)
    (define-key map "~" 'erp-flag-backup-files)
    ;; Upper case keys (except !) for operating on the marked entries
    (define-key map "A" 'erp-do-search)
    (define-key map "C" 'erp-do-copy)
    (define-key map "B" 'erp-do-byte-compile)
    (define-key map "D" 'erp-do-delete)
    (define-key map "G" 'erp-do-chgrp)
    (define-key map "H" 'erp-do-hardlink)
    (define-key map "L" 'erp-do-load)
    (define-key map "M" 'erp-do-chmod)
    (define-key map "O" 'erp-do-chown)
    (define-key map "P" 'erp-do-print)
    (define-key map "Q" 'erp-do-query-replace-regexp)
    (define-key map "R" 'erp-do-rename)
    (define-key map "S" 'erp-do-symlink)
    (define-key map "T" 'erp-do-touch)
    (define-key map "X" 'erp-do-shell-command)
    (define-key map "Z" 'erp-do-compress)
    (define-key map "!" 'erp-do-shell-command)
    (define-key map "&" 'erp-do-async-shell-command)
    ;; Comparison commands
    (define-key map "=" 'erp-diff)
    (define-key map "\M-=" 'erp-backup-diff)
    ;; Tree Dired commands
    (define-key map "\M-\C-?" 'erp-unmark-all-files)
    (define-key map "\M-\C-d" 'erp-tree-down)
    (define-key map "\M-\C-u" 'erp-tree-up)
    (define-key map "\M-\C-n" 'erp-next-subdir)
    (define-key map "\M-\C-p" 'erp-prev-subdir)
    ;; move to marked files
    (define-key map "\M-{" 'erp-prev-marked-file)
    (define-key map "\M-}" 'erp-next-marked-file)
    ;; Make all regexp commands share a `%' prefix:
    ;; We used to get to the submap via a symbol erp-regexp-prefix,
    ;; but that seems to serve little purpose, and copy-keymap
    ;; does a better job without it.
    (define-key map "%" nil)
    (define-key map "%u" 'erp-upcase)
    (define-key map "%l" 'erp-downcase)
    (define-key map "%d" 'erp-flag-files-regexp)
    (define-key map "%g" 'erp-mark-files-containing-regexp)
    (define-key map "%m" 'erp-mark-files-regexp)
    (define-key map "%r" 'erp-do-rename-regexp)
    (define-key map "%C" 'erp-do-copy-regexp)
    (define-key map "%H" 'erp-do-hardlink-regexp)
    (define-key map "%R" 'erp-do-rename-regexp)
    (define-key map "%S" 'erp-do-symlink-regexp)
    (define-key map "%&" 'erp-flag-garbage-files)
    ;; Commands for marking and unmarking.
    (define-key map "*" nil)
    (define-key map "**" 'erp-mark-executables)
    (define-key map "*/" 'erp-mark-directories)
    (define-key map "*@" 'erp-mark-symlinks)
    (define-key map "*%" 'erp-mark-files-regexp)
    (define-key map "*c" 'erp-change-marks)
    (define-key map "*s" 'erp-mark-subdir-files)
    (define-key map "*m" 'erp-mark)
    (define-key map "*u" 'erp-unmark)
    (define-key map "*?" 'erp-unmark-all-files)
    (define-key map "*!" 'erp-unmark-all-marks)
    (define-key map "U" 'erp-unmark-all-marks)
    (define-key map "*\177" 'erp-unmark-backward)
    (define-key map "*\C-n" 'erp-next-marked-file)
    (define-key map "*\C-p" 'erp-prev-marked-file)
    (define-key map "*t" 'erp-toggle-marks)
    ;; Lower keys for commands not operating on all the marked files
    (define-key map "a" 'erp-find-alternate-file)
    (define-key map "d" 'erp-flag-file-deletion)
    (define-key map "e" 'erp-find-file)
    (define-key map "f" 'erp-find-file)
    (define-key map "\C-m" 'erp-find-file)
    (put 'erp-find-file :advertised-binding "\C-m")
    (define-key map "g" 'revert-buffer)
    (define-key map "h" 'describe-mode)
    (define-key map "i" 'erp-maybe-insert-subdir)
    (define-key map "j" 'erp-goto-file)
    (define-key map "k" 'erp-do-kill-lines)
    (define-key map "l" 'erp-do-redisplay)
    (define-key map "m" 'erp-mark)
    (define-key map "n" 'erp-next-line)
    (define-key map "o" 'erp-find-file-other-window)
    (define-key map "\C-o" 'erp-display-file)
    (define-key map "p" 'erp-previous-line)
    (define-key map "q" 'quit-window)
    (define-key map "s" 'erp-sort-toggle-or-edit)
    (define-key map "t" 'erp-toggle-marks)
    (define-key map "u" 'erp-unmark)
    (define-key map "v" 'erp-view-file)
    (define-key map "w" 'erp-copy-filename-as-kill)
    (define-key map "x" 'erp-do-flagged-delete)
    (define-key map "y" 'erp-show-file-type)
    (define-key map "+" 'erp-create-directory)
    ;; moving
    (define-key map "<" 'erp-prev-dirline)
    (define-key map ">" 'erp-next-dirline)
    (define-key map "^" 'erp-up-directory)
    (define-key map " "  'erp-next-line)
    (define-key map "\C-n" 'erp-next-line)
    (define-key map "\C-p" 'erp-previous-line)
    (define-key map [down] 'erp-next-line)
    (define-key map [up] 'erp-previous-line)
    ;; hiding
    (define-key map "$" 'erp-hide-subdir)
    (define-key map "\M-$" 'erp-hide-all)
    ;; isearch
    (define-key map (kbd "M-s a C-s")   'erp-do-isearch)
    (define-key map (kbd "M-s a M-C-s") 'erp-do-isearch-regexp)
    (define-key map (kbd "M-s f C-s")   'erp-isearch-filenames)
    (define-key map (kbd "M-s f M-C-s") 'erp-isearch-filenames-regexp)
    ;; misc
    (define-key map "\C-x\C-q" 'erp-toggle-read-only)
    (define-key map "?" 'erp-summary)
    (define-key map "\177" 'erp-unmark-backward)
    (define-key map [remap undo] 'erp-undo)
    (define-key map [remap advertised-undo] 'erp-undo)
    ;; thumbnail manipulation (image-erp)
    (define-key map "\C-td" 'image-erp-display-thumbs)
    (define-key map "\C-tt" 'image-erp-tag-files)
    (define-key map "\C-tr" 'image-erp-delete-tag)
    (define-key map "\C-tj" 'image-erp-jump-thumbnail-buffer)
    (define-key map "\C-ti" 'image-erp-dired-display-image)
    (define-key map "\C-tx" 'image-erp-dired-display-external)
    (define-key map "\C-ta" 'image-erp-display-thumbs-append)
    (define-key map "\C-t." 'image-erp-display-thumb)
    (define-key map "\C-tc" 'image-erp-dired-comment-files)
    (define-key map "\C-tf" 'image-erp-mark-tagged-files)
    (define-key map "\C-t\C-t" 'image-erp-dired-insert-marked-thumbs)
    (define-key map "\C-te" 'image-erp-dired-edit-comment-and-tags)
    ;; encryption and decryption (epa-erp)
    (define-key map ":d" 'epa-erp-do-decrypt)
    (define-key map ":v" 'epa-erp-do-verify)
    (define-key map ":s" 'epa-erp-do-sign)
    (define-key map ":e" 'epa-erp-do-encrypt)

;;; Menu entries

    ;; Define the erp-mode menus
    (easy-menu-define erp-tbl-menu erp-mode-map "Tbl menu"
      '("Tbl"
        ["Align" erp-ctrl-c-ctrl-c :active (erp-at-table-p)]
        ["Next Field" erp-cycle (erp-at-table-p)]
        ["Previous Field" erp-shifttab (erp-at-table-p)]
        ["Next Row" erp-return (erp-at-table-p)]
        "--"
        ["Blank Field" erp-table-blank-field (erp-at-table-p)]
        ["Edit Field" erp-table-edit-field (erp-at-table-p)]
        ["Copy Field from Above" erp-table-copy-down (erp-at-table-p)]
        "--"
        ("Column"
         ["Move Column Left" erp-metaleft (erp-at-table-p)]
         ["Move Column Right" erp-metaright (erp-at-table-p)]
         ["Delete Column" erp-shiftmetaleft (erp-at-table-p)]
         ["Insert Column" erp-shiftmetaright (erp-at-table-p)])
        ("Row"
         ["Move Row Up" erp-metaup (erp-at-table-p)]
         ["Move Row Down" erp-metadown (erp-at-table-p)]
         ["Delete Row" erp-shiftmetaup (erp-at-table-p)]
         ["Insert Row" erp-shiftmetadown (erp-at-table-p)]
         ["Sort lines in region" erp-table-sort-lines (erp-at-table-p)]
         "--"
         ["Insert Hline" erp-ctrl-c-minus (erp-at-table-p)])
        ("Rectangle"
         ["Copy Rectangle" erp-copy-special (erp-at-table-p)]
         ["Cut Rectangle" erp-cut-special (erp-at-table-p)]
         ["Paste Rectangle" erp-paste-special (erp-at-table-p)]
         ["Fill Rectangle" erp-table-wrap-region (erp-at-table-p)])
        "--"
        ("Calculate"
         ["Set Column Formula" erp-table-eval-formula (erp-at-table-p)]
         ["Set Field Formula" (erp-table-eval-formula '(4)) :active (erp-at-table-p) :keys "C-u C-c ="]
         ["Edit Formulas" erp-edit-special (erp-at-table-p)]
         "--"
         ["Recalculate line" erp-table-recalculate (erp-at-table-p)]
         ["Recalculate all" (lambda () (interactive) (erp-table-recalculate '(4))) :active (erp-at-table-p) :keys "C-u C-c *"]
         ["Iterate all" (lambda () (interactive) (erp-table-recalculate '(16))) :active (erp-at-table-p) :keys "C-u C-u C-c *"]
         "--"
         ["Toggle Recalculate Mark" erp-table-rotate-recalc-marks (erp-at-table-p)]
         "--"
         ["Sum Column/Rectangle" erp-table-sum
          (or (erp-at-table-p) (erp-region-active-p))]
         ["Which Column?" erp-table-current-column (erp-at-table-p)])
        ["Debug Formulas"
         erp-table-toggle-formula-debugger
         :style toggle :selected (erp-bound-and-true-p erp-table-formula-debug)]
        ["Show Col/Row Numbers"
         erp-table-toggle-coordinate-overlays
         :style toggle
         :selected (erp-bound-and-true-p erp-table-overlay-coordinates)]
        "--"
        ["Create" erp-table-create (and (not (erp-at-table-p))
                                        erp-enable-table-editor)]
        ["Convert Region" erp-table-convert-region (not (erp-at-table-p 'any))]
        ["Import from File" erp-table-import (not (erp-at-table-p))]
        ["Export to File" erp-table-export (erp-at-table-p)]
        "--"
        ["Create/Convert from/to table.el" erp-table-create-with-table.el t]))

    (easy-menu-define erp-erp-menu erp-mode-map "ERP menu"
      '("ERP"
        ("Show/Hide"
         ["Cycle Visibility" erp-cycle :active (or (bobp) (outline-on-heading-p))]
         ["Cycle Global Visibility" erp-shifttab :active (not (erp-at-table-p))]
         ["Sparse Tree..." erp-sparse-tree t]
         ["Reveal Context" erp-reveal t]
         ["Show All" show-all t]
         "--"
         ["Subtree to indirect buffer" erp-tree-to-indirect-buffer t])
        "--"
        ["New Heading" erp-insert-heading t]
        ("Navigate Headings"
         ["Up" outline-up-heading t]
         ["Next" outline-next-visible-heading t]
         ["Previous" outline-previous-visible-heading t]
         ["Next Same Level" outline-forward-same-level t]
         ["Previous Same Level" outline-backward-same-level t]
         "--"
         ["Jump" erp-goto t])
        ("Edit Structure"
         ["Move Subtree Up" erp-shiftmetaup (not (erp-at-table-p))]
         ["Move Subtree Down" erp-shiftmetadown (not (erp-at-table-p))]
         "--"
         ["Copy Subtree"  erp-copy-special (not (erp-at-table-p))]
         ["Cut Subtree"  erp-cut-special (not (erp-at-table-p))]
         ["Paste Subtree"  erp-paste-special (not (erp-at-table-p))]
         "--"
         ["Clone subtree, shift time" erp-clone-subtree-with-time-shift t]
         "--"
         ["Promote Heading" erp-metaleft (not (erp-at-table-p))]
         ["Promote Subtree" erp-shiftmetaleft (not (erp-at-table-p))]
         ["Demote Heading"  erp-metaright (not (erp-at-table-p))]
         ["Demote Subtree"  erp-shiftmetaright (not (erp-at-table-p))]
         "--"
         ["Sort Region/Children" erp-sort  (not (erp-at-table-p))]
         "--"
         ["Convert to odd levels" erp-convert-to-odd-levels t]
         ["Convert to odd/even levels" erp-convert-to-oddeven-levels t])
        ("Editing"
         ["Emphasis..." erp-emphasize t]
         ["Edit Source Example" erp-edit-special t]
         "--"
         ["Footnote new/jump" erp-footnote-action t]
         ["Footnote extra" (erp-footnote-action t) :active t :keys "C-u C-c C-x f"])
        ("Archive"
         ["Archive (default method)" erp-archive-subtree-default t]
         "--"
         ["Move Subtree to Archive file" erp-advertized-archive-subtree t]
         ["Toggle ARCHIVE tag" erp-toggle-archive-tag t]
         ["Move subtree to Archive sibling" erp-archive-to-archive-sibling t]
         )
        "--"
        ("Hyperlinks"
         ["Store Link (Global)" erp-store-link t]
         ["Find existing link to here" erp-occur-link-in-agenda-files t]
         ["Insert Link" erp-insert-link t]
         ["Follow Link" erp-open-at-point t]
         "--"
         ["Next link" erp-next-link t]
         ["Previous link" erp-previous-link t]
         "--"
         ["Descriptive Links"
          (progn (erp-add-to-invisibility-spec '(erp-link)) (erp-restart-font-lock))
          :style radio
          :selected (member '(erp-link) buffer-invisibility-spec)]
         ["Literal Links"
          (progn
            (erp-remove-from-invisibility-spec '(erp-link)) (erp-restart-font-lock))
          :style radio
          :selected (not (member '(erp-link) buffer-invisibility-spec))])
        "--"
        ("TODO Lists"
         ["TODO/DONE/-" erp-todo t]
         ("Select keyword"
          ["Next keyword" erp-shiftright (erp-on-heading-p)]
          ["Previous keyword" erp-shiftleft (erp-on-heading-p)]
          ["Complete Keyword" erp-complete (assq :todo-keyword (erp-context))]
          ["Next keyword set" erp-shiftcontrolright (and (> (length erp-todo-sets) 1) (erp-on-heading-p))]
          ["Previous keyword set" erp-shiftcontrolright (and (> (length erp-todo-sets) 1) (erp-on-heading-p))])
         ["Show TODO Tree" erp-show-todo-tree t]
         ["Global TODO list" erp-todo-list t]
         "--"
         ["Enforce dependencies" (customize-variable 'erp-enforce-todo-dependencies)
          :selected erp-enforce-todo-dependencies :style toggle :active t]
         "Settings for tree at point"
         ["Do Children sequentially" erp-toggle-ordered-property :style radio
          :selected (ignore-errors (erp-entry-get nil "ORDERED"))
          :active erp-enforce-todo-dependencies :keys "C-c C-x o"]
         ["Do Children parallel" erp-toggle-ordered-property :style radio
          :selected (ignore-errors (not (erp-entry-get nil "ORDERED")))
          :active erp-enforce-todo-dependencies :keys "C-c C-x o"]
         "--"
         ["Set Priority" erp-priority t]
         ["Priority Up" erp-shiftup t]
         ["Priority Down" erp-shiftdown t]
         "--"
         ["Get news from all feeds" erp-feed-update-all t]
         ["Go to the inbox of a feed..." erp-feed-goto-inbox t]
         ["Customize feeds" (customize-variable 'erp-feed-alist) t])
        ("TAGS and Properties"
         ["Set Tags" erp-set-tags-command t]
         ["Change tag in region" erp-change-tag-in-region (erp-region-active-p)]
         "--"
         ["Set property" erp-set-property t]
         ["Column view of properties" erp-columns t]
         ["Insert Column View DBlock" erp-insert-columns-dblock t])
        ("Dates and Scheduling"
         ["Timestamp" erp-time-stamp t]
         ["Timestamp (inactive)" erp-time-stamp-inactive t]
         ("Change Date"
          ["1 Day Later" erp-shiftright t]
          ["1 Day Earlier" erp-shiftleft t]
          ["1 ... Later" erp-shiftup t]
          ["1 ... Earlier" erp-shiftdown t])
         ["Compute Time Range" erp-evaluate-time-range t]
         ["Schedule Item" erp-schedule t]
         ["Deadline" erp-deadline t]
         "--"
         ["Custom time format" erp-toggle-time-stamp-overlays
          :style radio :selected erp-display-custom-times]
         "--"
         ["Goto Calendar" erp-goto-calendar t]
         ["Date from Calendar" erp-date-from-calendar t]
         "--"
         ["Start/Restart Timer" erp-timer-start t]
         ["Pause/Continue Timer" erp-timer-pause-or-continue t]
         ["Stop Timer" erp-timer-pause-or-continue :active t :keys "C-u C-c C-x ,"]
         ["Insert Timer String" erp-timer t]
         ["Insert Timer Item" erp-timer-item t])
        ("Logging work"
         ["Clock in" erp-clock-in :active t :keys "C-c C-x C-i"]
         ["Switch task" (lambda () (interactive) (erp-clock-in '(4))) :active t :keys "C-u C-c C-x C-i"]
         ["Clock out" erp-clock-out t]
         ["Clock cancel" erp-clock-cancel t]
         "--"
         ["Mark as default task" erp-clock-mark-default-task t]
         ["Clock in, mark as default" (lambda () (interactive) (erp-clock-in '(16))) :active t :keys "C-u C-u C-c C-x C-i"]
         ["Goto running clock" erp-clock-goto t]
         "--"
         ["Display times" erp-clock-display t]
         ["Create clock table" erp-clock-report t]
         "--"
         ["Record DONE time"
          (progn (setq erp-log-done (not erp-log-done))
                 (message "Switching to %s will %s record a timestamp"
                          (car erp-done-keywords)
                          (if erp-log-done "automatically" "not")))
          :style toggle :selected erp-log-done])
        "--"
        ["Agenda Command..." erp-agenda t]
        ["Set Restriction Lock" erp-agenda-set-restriction-lock t]
        ("File List for Agenda")
        ("Special views current file"
         ["TODO Tree"  erp-show-todo-tree t]
         ["Check Deadlines" erp-check-deadlines t]
         ["Timeline" erp-timeline t]
         ["Tags/Property tree" erp-match-sparse-tree t])
        "--"
        ["Export/Publish..." erp-export t]
        ("LaTeX"
         ["ERP CDLaTeX mode" erp-cdlatex-mode :style toggle
          :selected erp-cdlatex-mode]
         ["Insert Environment" cdlatex-environment (fboundp 'cdlatex-environment)]
         ["Insert math symbol" cdlatex-math-symbol (fboundp 'cdlatex-math-symbol)]
         ["Modify math symbol" erp-cdlatex-math-modify
          (erp-inside-LaTeX-fragment-p)]
         ["Insert citation" erp-reftex-citation t]
         "--"
         ["Export LaTeX fragments as images"
          (if (featurep 'erp-exp)
              (setq erp-export-with-LaTeX-fragments
                    (not erp-export-with-LaTeX-fragments))
            (require 'erp-exp))
          :style toggle :selected (and (boundp 'erp-export-with-LaTeX-fragments)
                                       erp-export-with-LaTeX-fragments)])
        "--"
        ("MobileERP"
         ["Push Files and Views" erp-mobile-push t]
         ["Get Captured and Flagged" erp-mobile-pull t]
         ["Find FLAGGED Tasks" (erp-agenda nil "?") :active t :keys "C-c a ?"]
         "--"
         ["Setup" (progn (require 'erp-mobile) (customize-group 'erp-mobile)) t])
        "--"
        ("Documentation"
         ["Show Version" erp-version t]
         ["Info Documentation" erp-info t])
        ("Customize"
         ["Browse ERP Group" erp-customize t]
         "--"
         ["Expand This Menu" erp-create-customize-menu
          (fboundp 'customize-menu-create)])
        ["Send bug report" erp-submit-bug-report t]
        "--"
        ("Refresh/Reload"
         ["Refresh setup current buffer" erp-mode-restart t]
         ["Reload ERP (after update)" erp-reload t]
         ["Reload ERP uncompiled" (erp-reload t) :active t :keys "C-u C-c C-x r"])
        ))


;;;; Documentation

;;;; Miscellaneous stuff
;;; Generally useful functions

;;;; Integration with and fixes for other packages

;;;; Experimental code

(provide 'erp-mode)

(run-hooks 'erp-load-hook)

;;; erp.el ends here
