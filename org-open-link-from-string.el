;;;;-------------------------------
;; great post!
;; thanks for the help, tincman.
;; Many thanks for putting this post.
;;;;-------------------------------
;; url: https://tincman.wordpress.com/2011/01/04/research-paper-management-with-emacs-org-mode-and-reftex/
;; Research Paper Management with Emacs, org-mode and RefTeX
;; January 4, 2011
;; 
;; Update 3-11-14:  Nuno Salgueiro in the comments led me to a RefTeX change that broke the “jump to this entry in notes.org” behavior (it seems “reftex-citation” returns a list now, regardless if there is only one entry). This can be fixed by changing (reftex-citation t) to (first (reftex-citation t)).
;; 
;; Update 1-19-11: I’ve added a screencast of me demonstrating how I use this setup to work with my papers, I’ve also re-written the “Workflow” section (due to the fact it was kind of confusing…) Hope this all helps :]
;; 
;; Update 4-27-12:  olberger (in the comments section) has added, what I consider, an incredibly clever and useful function to help when writing papers. I’ve just finished tweaking it slightly for my purposes, but please check out his post, here. I’ll be adding what I did to this post… when I get around to it.
;; 
;; My labmates and I have been searching for a while now for methods to organize the mountain of research papers we collect as graduate students. I’ve tried a handful of approaches, and was happy using zim-wiki for a while, but entering info became a choir, and finding a paper could sometimes be a hassle.
;; 
;; My recent attempts at working with lisp have led me to switch to emacs, and in what seems to be a common occurrence, I wanted to do everything in emacs. As silly as that sounds, I believe I’ve found my solution to organize my papers through emacs.
;; 
;; Managing papers and references in emacs is nothing new, and I actually followed a few guides on how other people used org-mode and reftex to do so. Specifically this post, and this email. My hope with this initial post is to pull the bits together, show what I built on top of them, and how I setup my org files to facilitate my workflow. If you don’t know how to use or don’t know what emacs and org-mode are, give a quick search–there is plenty of info out there.
;; ;; ;; ;; ;; ;; ;; 
;;;;---------------------
;; Setting up RefTeX
;;
;; First, we want to load to load RefTeX whenever we use org-mode. This is well documented, and mine only differs in the citation formats I pass to RefTex, and my additional key binding.
(defun org-mode-reftex-setup ()
  (load-library "reftex")
  (and (buffer-file-name) (file-exists-p (buffer-file-name))
       (progn
	 ;enable auto-revert-mode to update reftex when bibtex file changes on disk
	 (global-auto-revert-mode t)
	 (reftex-parse-all)
	 ;add a custom reftex cite format to insert links
	 (reftex-set-cite-format
	  '((?b . "[[bib:%l][%l-bib]]")
	    (?n . "[[notes:%l][%l-notes]]")
	    (?p . "[[papers:%l][%l-paper]]")
	    (?t . "%t")
	    (?h . "** %t\n:PROPERTIES:\n:Custom_ID: %l\n:END:\n[[papers:%l][%l-paper]]")))))
  (define-key org-mode-map (kbd "C-c )") 'reftex-citation)
  (define-key org-mode-map (kbd "C-c (") 'org-mode-reftex-search))

(add-hook 'org-mode-hook 'org-mode-reftex-setup)
;;
;;;;---------------------
;; Jump to Entry
;;
;; The other difference I added was the binding of  “C-c (” to org-mode-reftex-search, which I defined earlier in my init.el. This is the command that will jump to the entry in my org-mode file, and follows
;;;;---------------------
(defun org-mode-reftex-search ()
  ;;jump to the notes for the paper pointed to at from reftex search
  (interactive)
  (org-open-link-from-string (format "[[notes:%s]]" (reftex-citation t))))


(defun org-mode-reftex-search ()
  ;;jump to the notes for the paper pointed to at from reftex search
  (interactive)
  (org-open-link-from-string (format "[[notes:%s]]" (first (reftex-citation t)))))
;;;;--------------------------
;; Simple. But I was happy with the results. Update: changes in reftex from initial authoring of this post have reftex-citation return a list. An updated function to fix this has been added :P
;;;;-------------------------------------
;; Making Org-mode work with you
;;
;; Lastly, org-mode needs a few things to pull all this together. The first and most important is importing the bibtex file. RefTeX looks for a LaTeX \bibliography tag anywhere in the file, I place mine as an org-mode comment at the start of the file
# \bibliography{~/research/refs.bib}
;; The other thing needed is link abbreviations. While you could hardcode this into your citation formats, I prefer to put abbreviations in for the citation formats, and define defaults elsewhere in my init.el
;;;;-----------------------------
(setq org-link-abbrev-alist
      '(("bib" . "~/research/refs.bib::%s")
	("notes" . "~/research/org/notes.org::#%s")
	("papers" . "~/research/papers/%s.pdf")))
;;;;-----------------------------
;; These can be easily overridden in an org-mode file, which I actually do for the org-mode file I store the actual entries in. If I left it as is, following a “notes” link in this org-mode file would open the same file in a new window and jump to the entry in that one. Not quite what we want. This is where I override it in the local file by adding this to my heading.
#+LINK: notes #%s
;;;;----------------------------
;; Now, if I follow a “notes” link in the entries file, it jumps to that entry in the same frame, while following a “notes” link in another org-mode file (or using my new reftex search addition) will open this file in a new frame and jump to the entry.
;; Workflow
;; 
;; My setup for this involves two main files: refs.bib, the main bibtex file, and notes.org, the org-mode file I use to manage the papers and store notes for each.
;; 
;; In notes.org my overall workflow follows a typical org-mode hierarchical layout, the key parent being “Papers” with each child heading being either a category or an entry for a paper, each with the appropriate or useful org-mode tags. Each paper headline corresponds to that paper, and I write notes under these headlines about the paper.
;; 
;; The hierarchical layout has children inheriting parents tags which is quite nifty. This is my initial lookup method when I’m looking for a paper. For example, I want to find a paper that describes how to couple EDOT using an iron catalyst, I can type “C-c \” to do a tag search, type in one or all of the relevant keywords, and org-mode will show the entries matching those tag[s]. I can then expand those entries, see what notes I’ve written on the papers, and when I found the one I’m looking for, I can open the link to the pdf I’ve placed there using “C-c C-o”.
;; 
;; When I find a new paper I need to add, I initially gather all the data I need to use org-mode: the bibtex entry and the paper itself. I modify the bibtex key to fit with my scheme (FirstAuthorYear) but you can use whatever suites you best. I then save the paper using that bibtex key as the filename in another folder.
;; 
;; Note: I manage my bibtex entries by first saving each new bibtex entry as a separate file in a collective folder (due to the fact I usually export them from the journal’s website when I find the paper) and then I concatenate all the files in that folder to make a new bibtex file using
;;;;--------------------
$ cat bibtex/*.bib > refs.bib
;;;;----------------------
;; This feels a little messy, but the easiest solution I could think of; I’m sure I could setup a command to do this for me from emacs, but this is a low priority. The one problem with this is if you change the bibtex file while org-mode is running, RefTeX will not see the changes. To do so you need to enable “global-auto-revert-mode” in emacs. Supposedly, this is automatically enabled in emacs 23, but it seems to be disabled by default for me (23.2.1)
;; 
;; Adding a new headline in my notes.org file is simplified by using RefTex. I place my cursor on a new line and hit “C-c )” which is bound to “reftex-citation”. The first prompt is for a citation format (if more than one) and I have a few for different purposes. I hit ‘h’ for heading, which contains all the formatting for a barebones paper headline. This puts a new entry with the title of the paper as the headline, a propeties list with custom-id of the bibtex key (this allows linking to this entry by it’s bibtex key), and a body containing a link to the pdf. After selecting the format, RefTeX prompts for a regex to search the bibtex file with, presenting a list of matching entries. Selecting the desired entry inserts the citation, in this case, the new entry.
;; 
;; This is how we exploit RefTeX, we create custom citation formats that are really org-mode tags and formattings. A few other formats I have are all org-mode links: one that links to the entry in the bibtex file itself, one that links to the pdf, and another that links to the entry in the org-mode file. I use org-mode link abbreviations to get general behavior that can be changed on a per-file basis.
;; 
;; Another option I recently added to this is a way to search for other info I may not have placed in a tag, such as an author or journal name. Here I shamelessly take adavtage of having reftex loaded again. I bound this key to a custom command I made that will jump to the entry for the bibtex entry you select from the reftex-citation prompt.
;; 
;; And that’s that! So far, this is the most powerful approach I have found, and I know I’ve spent less time searching than any other method I’ve found. What’s also great about this is that org-mode’s exporting allows me to export this as HTML to serve up on our group’s website for the rest of my group to use. An additional benefit is that because I’m already gathering bibtex entries, when it comes time to write a paper, I already have all my citation data, and I can easily search a key to retrieve all my notes on that paper as well.
;; 
;; There are some weaknesses I’m still trying to work out, such as manually scraping bibtex entries and making sure everything has the proper filename. The problem really is that all the journals aren’t consistent with these things (some don’t even provide bibtex export! Luckily, there’s bibutils to handle the conversions) and entries need to be tweaked and/or pdf’s named according to the key. Ideally, I would like to find a database that I could script a tool against to scrape the data I need and already name and places the files for me, but that is for another day/entry
;; 
;; I’ve been trying to see about using attachments to handle the papers instead, but I haven’t been able to tweak it to my satisfaction just yet. Still trying though. This should allow me to attach multiple files for an entry (such as supporting info, etc)
;; ;;--------------------------------------
;; Vinh Nguyen permalink
;;
;; Hi, thanks for this; it sounds very interesting. First, I wasn’t aware of the features of RefTex. I’ve been using AucTeX for years but used it without RefTex. Now my workflow is even better. Thank you.
;;
;; Second, is it possible for you to put up a screencast on research paper management based on this post? I would love to manage research papers in emacs, especially via org-mode with the help of bibtex. However, the setup seems rather complicated and it is hard to visualize the workflow. I’m sure there are added benefits, but it’d be great to see it on video before others like myself invest the time to set it up. Hope you have time for it.
;;;;-----------------------------
;; tincman permalink
;;
;; Haha, I did have a hard time writing that workflow section. A screencast would certainly be clearer–I will have to start working on one. In the very least I may at least post some screenshots.
;;
;; Glad I could help out :]
;;;;------------------
;; Da Zhang permalink
;;
;; tincman:
;;
;; Thanks for this post.
;;
;; I have a short lisp function that do the auto formatting for me, and here is the code:
;;;;------
;; Filename: fbib.el
;; Author: Da Zhang
;; Usage:
;; Compile:
;; System:
;; Bugs:
;; Created: Thu Apr 29 23:38:36 2010
;; Last-Updated: Fri Oct 15 14:22:05 2010 (-14400 -0400)
;; Update #: 40
;; Description:
;;;;;;;;;;;;;;;;;;;;;;;;;;; -*- Mode: Emacs-Lisp -*- ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Code:

(defun fbib ()
“Format the bib entry copied from websites, and generate the file name for saving the pdf files systematically.”
(interactive)
(goto-char (point-max))
(re-search-backward “@” nil t)
(beginning-of-line)
(setq beg-pos (point))

;; remove the original bib entry name
(re-search-forward “\{” nil t)
(re-search-forward “,”)
(backward-char)
(let ((beg (point)))
(re-search-backward “\{” nil t)
(forward-char)
(delete-region beg (point)))

;; search for author name and copy it to bib entry name
(let ((tmp (point)))
(re-search-forward “author” nil t)
(re-search-forward “\{” nil t)
(let ((start (point)))
(re-search-forward “\}” nil t)
(let ((end (point)))
(if (re-search-in-region “,” start end)
(backward-word 1)
(if (re-search-in-region “and” start end)
(backward-word 2)
(re-search-forward “\}” nil t)
(backward-word 1)))))
;; (re-search-forward “and” nil t)
;; (backward-word 2)
(let ((beg (point)))
(forward-word)
(copy-region-as-kill beg (point)))
(goto-char tmp)
(yank)
(insert “-“))
;; search for year and copy it to bib entry name
(let ((tmp (point)))
(re-search-forward “year” nil t)
(re-search-forward “\{” nil t)
(let ((beg (point)))
(forward-word)
(copy-region-as-kill beg (point)))
(goto-char tmp)
(yank)
(insert “-“))

;; search for article title and copy it to bib entry name
(let ((tmp (point)))
(re-search-forward “title” nil t)
(re-search-forward “\{” nil t)
(let ((beg (point)))
(re-search-forward “\}” nil t)
(backward-char)
(copy-region-as-kill beg (point)))
(goto-char tmp)
(yank)
(let ((bib-name-end (point)))
(replace-in-region ” ” “-” tmp bib-name-end)
(replace-in-region “:” “-” tmp bib-name-end)
))

;; optional: search keywords, and kill it
(goto-char beg-pos)
(if (re-search-forward “keywords” nil t)
(progn
(beginning-of-line)
(let ((beg (point)))
(re-search-forward “\},”)
(forward-char)
(kill-region beg (point)))))

;; optional: search url, and move it to the back of the entry
(goto-char beg-pos)
(if (re-search-forward “url” nil t)
(progn
(beginning-of-line)
(kill-line)
(re-search-forward “^\}” nil t)
(forward-char)
(yank)
(re-search-backward “url” nil t)
(beginning-of-line)
(let ((beg (point)))
(end-of-line)
(comment-region beg (point)))))

;; form the pdf file name and add it to the end of the buffer
(goto-char (point-max))
(let ((tmp (point)))
(goto-char beg-pos)
(re-search-forward “author” nil t)
(re-search-forward “\{” nil t)
(let ((start (point)))
(re-search-forward “\}” nil t)
(let ((end (point)))
(if (re-search-in-region “,” start end)
(backward-word 1)
(if (re-search-in-region “and” start end)
(backward-word 2)
(re-search-forward “\}” nil t)
(backward-word 1)))))
;; (re-search-forward “and” nil t)
;; (backward-word 2)
(let ((beg (point)))
(forward-word)
(copy-region-as-kill beg (point)))
(goto-char tmp)
(yank)
(insert “_”))
(let ((tmp (point)))
(re-search-backward “year” nil t)
(re-search-forward “\{” nil t)
(let ((beg (point)))
(forward-word)
(copy-region-as-kill beg (point)))
(goto-char tmp)
(yank)
(insert “_”))
(let ((tmp (point)))
(re-search-backward “title” nil t)
(re-search-forward “\{” nil t)
(let ((beg (point)))
(re-search-forward “\}” nil t)
(backward-char)
(copy-region-as-kill beg (point)))
(goto-char tmp)
(yank)
(insert “_”))
(let ((tmp (point)))
(re-search-backward “journal” nil t)
(re-search-forward “\{” nil t)
(let ((beg (point)))
(re-search-forward “\}” nil t)
(backward-char)
(copy-region-as-kill beg (point)))
(goto-char tmp)
(yank)
(insert “.pdf”))
(beginning-of-line)
(let ((pdf-name-beg (point)))
(end-of-line)
(replace-in-region “:” “_” pdf-name-beg (point)))

;; optional: search abstract, and delete it
(goto-char beg-pos)
(if (re-search-forward “abstract” nil t)
(progn
(beginning-of-line)
(let ((beg (point)))
(re-search-forward “\}” nil t)
(end-of-line)
(kill-region beg (point)))
(kill-line)))
)

(defun re-search-in-region (pat start end)
“regexp search forward in region specified by start and end.”
(save-restriction
(narrow-to-region start end)
(goto-char (point-min))
(re-search-forward pat nil t)))

(defun replace-in-region (from-string to-string start end)
“Replace from-string with to-string in region specified by start and end.”
(save-restriction
(narrow-to-region start end)
(goto-char (point-min))
(while (search-forward from-string nil t) (replace-match to-string nil t))
)
)

(provide ‘fbib)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; fbib.el ends here
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;--------------------------------------------
;; tincman permalink
;;
;; Sorry for the late response, but this looks pretty awesome, thanks man :]
;;;;----
;; Karl permalink
;;
;; I found the solution to the problem mentioned by me:
;;
;; ######################################################
;; org-mode and paper references

(defadvice reftex-format-citation (before eval-citation-format)
(setq format (eval format)))

(defun org-mode-reftex-setup ()
(load-library “reftex”)
(and (buffer-file-name) (file-exists-p (buffer-file-name))
(progn
;enable auto-revert-mode to update reftex when bibtex file changes on disk
(global-auto-revert-mode t)
(reftex-parse-all)
;add a custom reftex cite format to insert links
(reftex-set-cite-format
‘((?b . “[[bib:%l][%l-bib]]”)
(?n . “[[notes:%l][%l-notes]]”)
(?p . “[[papers:%l][%l-pdf]]”)
(?t . “%t”)
(?h . (concat “* %l – %t\n:PROPERTIES:\n:Created: ”
“”
“\n:Custom_ID: %l\n:END:\n[[papers:%l][%l-pdf]] [[bib:%l][%l-bib]]”))
))))
(define-key org-mode-map (kbd “C-c )”) ‘reftex-citation)
(define-key org-mode-map (kbd “C-c (“) ‘org-mode-reftex-search))

;(add-hook ‘org-mode-hook ‘org-mode-reftex-setup)
(add-hook ‘org-mode-hook
(lambda ()
(if (member “CHECK_NEEDED” org-todo-keywords-1)
(org-mode-reftex-setup))))

(defun org-mode-reftex-search ()
;;jump to the notes for the paper pointed to at from reftex search
(interactive)
(org-open-link-from-string (format “[[notes:%s]]” (reftex-citation t))))

(setq org-link-abbrev-alist
‘((“bib” . “~/archive/papers_from_web/references.bib::%s”)
(“notes” . “~/share/all/org/references.org::#%s”)
(“papers” . “~/archive/papers_from_web/%s.pdf”)))

;; tries to format a new BibTeX entry according to own format
;; from: http://www.mfasold.net/blog/2009/02/using-emacs-org-mode-to-draft-papers/
;(vk-load-part “format-bib.el”)
;; does not work well enough – skipping for now
;;;;----------------------------------------------
;;;;----------------------------------------------
;; Nuno permalink
;;
;; Your setup is simply great. It was not easy to understand (I’m an Emacs noob, with no knowledge of Lisp, so I had to read your tutorial a few times and watch your video at low speed to see all the steps involved) but now everything’s working perfectly! Hard to imagine a better way of managing references, really.
;;
;; Just one question: when you’re writing an article/thesis/whatever in org-mode, do you add the following block to the head of the org document?
;;
#+LINK: bib file:~/research/refs.bib::%s
#+LINK: note file:~/research/org/notes.org::%s
;;
;; Thank you so much!
;;
;; PS – Couldn’t resist to publicize your blog post: http://tinyurl.com/3zfzynv
;;;;----------------------
;; tincman permalink
;;
;; Thanks man :]
;;
;; As for your question, yes those are the links you would use in a separate org-mode file, however I personally added those into my init.el, making them the default, and overriding them in my notes.org.
;;;;-------------------
;; jeff permalink
;;
;; Looks relatively good. I like that everything is in plain text as isn’t the case with Mendeley. I like the ease of retreiving citations in mendeley too and grabbing papers through our University’s source it. I’ll have to do some investigating to see if I can automate the citation grabbing through another source then I may adopt org-mode.
;;
;; Cheers,
;; Jeff
;;;;---------------
;; tincman permalink
;;
;; My fellow grad students have been getting excited over Mendeley, and your comment reminded me of our schools source/portal for fulltext links, I wonder if there is way to automate it there…
;;;;-----------------
;; Duong Bao Duy permalink
;;
;; Reblogged this on Duong Bao Duy and commented:
;; Research Paper Management with Emacs, org-mode and RefTeX
;;;;-----------------------
;; Nuno Salgueiro permalink
;;
;; Greetings!
;;
;; I’m experiencing a strange issue. I have the setup described in this article and it used to work flawlessly. Now, I believe something possibly changed in reftex. One of the citations I have in my notes.org file has ‘Custom_ID: Contreras2002’. When I do ‘C-c (‘ I can find it on the citations list. Then I press RET and get ‘No match – create this as a new heading? (y or n)’.
;;
;; This never happened before. The puzzling part is this: if I go to the entry in the notes.org file and manually change ‘Custom_ID: (Contreras2002)’ — yes, with parentheses–, it works, i.e., ‘C-c (‘ and RET on that citation will jump to the correct notes.org entry.
;;
;; Could it be somehow related to this problem?
;; http://tex.stackexchange.com/questions/47443/enable-parentheses-bib-entry-with-reftex
;;
;; My limited knowledge in Lisp does not allow me to move any further, so any help would be deeply appreciated.
;;;;----------------------
;; tincman permalink
;;
;; To be honest, I haven’t been using org-mode much anymore (or I would have caught this!)
;;
;; This is indeed a change that seems to have happened in RefTeX, but not the one you linked. It seems “reftex-citation” now defaults to returning a list, even if it returns one citation. This is why the parenthesis are around the text (lists in lisp are denoted by parenthesis, everything in lisp is a list! ;D)
;;
;; To fix this we just need to tell “org-mode-reftex-search” to take the first result “reftex-citation” returns: (reftex-citation t) will become (first (reftex-citation t)). The function as a whole now looks like:
;;;;----------------
(defun org-mode-reftex-search ()
;;jump to the notes for the paper pointed to at from reftex search
(interactive)
(org-open-link-from-string (format “[[notes:%s]]” (first (reftex-citation t “?l”)))))
;;;;------------------
;;
;; Thanks for finding this. To be honest I’ve been using Zotero lately to manage my references (makes it much much easier to scrape papers as you find them), but have been meaning to come back and revisit using emacs/org-mode and fix the problems that kept me using this regularly (I fell pretty far behind in managing my references…). Of course, I still use Org-mode/reftex when authoring ;D nothing beats it.
;;
;; Updated the post to reflect this :]
;;;;-------------------
;; Nuno Salgueiro permalink
;;
;; Thanks for the help, tincman; it’s now working perfectly again (I only had to replace ‘first’ by ‘car’, no big thing).
;;
;; I saw the parentheses and didn’t think the output could be a list, which shows how good (lame!) my command of Lisp is. :D
;;
;; Anyway, much appreciated for your help in solving this and looking forward for your comeback with further improvements!
;;;;------------------------
