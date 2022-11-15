;;; org-fit.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2022 Uni Marx
;;
;; Author: Uni Marx <uniwuni@protonmail.com
;; Maintainer: Uni Marx <uniwuni@protonmail.com>
;; Created: November 14, 2022
;; Modified: November 14, 2022
;; Version: 0.0.1
;; Keywords: data outlines
;; Homepage: https://github.com/uniwuni
;; Package-Requires: ((emacs "27.1"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:
;;;

(require 'org-id)
(require 'ts)
(require 'org)
(defvar org-fit-id "FIT_DATA")

(defun org-fit-get-marker ()
  "Acquire the marker to the fitness data entry."
  (org-id-find org-fit-id t))

(defun org-fit-get-updated-date ()
  "Acquire the date the fitness data was last updated."
    (org-entry-get (org-fit-get-marker) "LAST_UPDATED"))

(defun org-fit-get-updated-utc ()
  "Acquire the date the fitness data was last updated as an UTC format string."
 (ts-format "%Y-%m-%d %H:%M:%S UTC" (ts-parse-org (org-fit-get-updated-date))))

(defun org-fit-get-current-time-inactive ()
  "Generate an inactive timestamp of the current time."
  (org-timestamp-translate (org-timestamp-from-time (current-time) t t)))

(defun org-fit-update-last-updated ()
  "Update the `:LAST_UPDATED' property for the fitness data."
  (org-entry-delete (org-fit-get-marker) "LAST_UPDATED")
  (org-entry-put (org-fit-get-marker) "LAST_UPDATED" (org-fit-get-current-time-inactive)))

(defun org-fit-insert-clock-entry (text)
  "Insert `TEXT' into the logbook of the fitness data entry."
  (with-current-buffer (marker-buffer (org-fit-get-marker))
    (save-excursion
    (goto-char (org-fit-get-marker))
    (search-forward-regexp ":LOGBOOK:$")
    (org-fold-hide-drawer-toggle 'off)
    (dolist (line (split-string text "\n"))
      (newline)
      (insert line)
      (org-clock-update-time-maybe)
      (goto-char (org-fit-get-marker))
      (search-forward-regexp ":LOGBOOK:$")))))


;;;###autoload
(defun org-fit-update ()
  "Update the fitness data."
  (interactive)
  (let ((output (shell-command-to-string
               (concat "get-fit " "\"" (org-fit-get-updated-utc) "\""))))
    (if (string= "" output)
        (message "No new data available.")
        (progn (org-fit-insert-clock-entry
                (substring output 0 -1))
               (org-fit-update-last-updated)
               (with-current-buffer (marker-buffer (org-fit-get-marker))
                 (save-buffer))))))


(provide 'org-fit)
;;; org-fit.el ends here
