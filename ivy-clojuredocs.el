;;; ivy-clojuredocs.el --- search for help in clojuredocs.org

;; Author: Wanderson Ferreira <iagwanderson@gmail.com>
;; URL: https://github.com/wandersoncferreira/ivy-clojuredocs
;; Package-Requires: ((edn "1.1.2") (ivy "0.12.0"))
;; Version: 0.1
;; Keywords: ivy, clojure

;; Copyright (C) 2019 Wanderson Ferreira <iagwanderson@gmail.com>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This work is heavily inspired by `helm-clojuredocs'.  Despite the completion
;; engine difference, there are minor implementation details and bug fixes in
;; this first version.

;;; Code:

(require 'ivy)
(require 'counsel)
(require 'edn)

(defgroup ivy-clojuredocs nil
  "Ivy applications"
  :group 'ivy)

(defcustom ivy-clojuredocs-url
  "http://clojuredocs.org/"
  "Url used for searching in ClojureDocs website."
  :type 'string
  :group 'ivy-clojuredocs)

(defcustom ivy-clojuredocs-min-chars-number
  2
  "Value for minimum input character before start searching on ClojureDocs website."
  :type 'integer
  :group 'ivy-clojuredocs)

(defvar ivy-clojuredocs-cache (make-hash-table :test 'equal))
(defvar ivy-clojuredocs-history nil)

(defun ivy-clojuredocs--parse-entries (entry)
  (let ((cd-namespace (or (gethash ':ns entry) ""))
        (cd-type (or (gethash ':type entry) ""))
        (cd-name (gethash ':name entry)))
    (format "%s %s %s" cd-namespace cd-name cd-type)))

(defun ivy-clojuredocs--parse-response (response)
  (cl-loop for i in (edn-read response)
           collect (ivy-clojuredocs--parse-entries i) into result
           finally return result))

(defun ivy-clojuredocs-fetch (entry)
  (let ((url (concat ivy-clojuredocs-url "ac-search?query=" entry)))
    (with-current-buffer (url-retrieve-synchronously url)
      (goto-char (point-min))
      (when (re-search-forward "\\(({.+})\\)" nil t)
        (puthash entry
                 (ivy-clojuredocs--parse-response (match-string 0))
                 ivy-clojuredocs-cache)))))

(defun ivy-clojuredocs-candidates (str &rest _u)
  (if (< (length str) ivy-clojuredocs-min-chars-number)
      (ivy-more-chars)
    (let ((candidates (or (gethash str ivy-clojuredocs-cache)
                          (ivy-clojuredocs-fetch str))))
      (if (member str candidates)
          candidates
        (append
         candidates
         (list (format "Search for '%s' on clojuredocs.org" str)))))))

(defun ivy-clojuredocs-fmt-web-entry (e)
  (if (string-match "on clojuredocs.org$" e)
      (format "search?q=%s" (cadr (split-string e "'")))
    (let* ((le (split-string entry " ")))
      (replace-regexp-in-string "?" "_q" (string-join (nbutlast le) "/")))))

(defun ivy-clojuredocs--clean-cache ()
  (clrhash ivy-clojuredocs-cache))

(defun ivy-clojuredocs-thing-at-point (thing)
  (when thing
    (first (last (split-string thing "/")))))

(defun ivy-clojuredocs-invoke (&optional initial-input)
  (ivy-read "ClojureDocs: " #'ivy-clojuredocs-candidates
            :initial-input initial-input
            :dynamic-collection t
            :history 'ivy-clojuredocs-history
            :action (lambda (entry)
                      (browse-url (concat ivy-clojuredocs-url (ivy-clojuredocs-fmt-web-entry entry))))
            :unwind #'ivy-clojuredocs--clean-cache
            :caller 'ivy-clojuredocs))

;;;###autoload
(defun ivy-clojuredocs ()
  (interactive)
  (ivy-clojuredocs-invoke))

;;;###autoload
(defun ivy-clojuredocs-at-point ()
  (interactive)
  (ivy-clojuredocs-invoke (ivy-clojuredocs-thing-at-point (thing-at-point 'symbol))))

(provide 'ivy-clojuredocs)

;; Local Variables:
;; coding: utf-8
;; End:

;;; ivy-clojuredocs.el ends here
