# ivy-clojuredocs

Easily search the ClojureDocs from your favorite Editor =)


# Installation

We are on [MELPA](http://melpa.org) now.

```
M-x package-refresh-contents
M-x package-install RET ivy-clojuredocs
```

Using `use-package` with a binding suggestion:
```
(use-package ivy-clojuredocs
  :ensure t
  :bind (:map clojure-mode-map
              (("C-c d" . ivy-clojuredocs-at-point))))
```

Using `quelpa` to install directly from this github repository:

```elisp
(quelpa '(ivy-clojuredocs :repo "wandersoncferreira/ivy-clojuredocs" :fetcher github))
```


# Usage

There are two public functions available:

- `ivy-clojuredocs`: which search at the website interactively
- `ivy-clojuredocs-at-point`: which uses the name of the function 
at point to populate the interactive prompt.

Happy hacking!

# LICENSE

Copyright © 2019 Wanderson

Distributed under the Eclipse Public License, the same as Clojure.
