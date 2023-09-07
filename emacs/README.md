# My Emacs Configuration
### This is my regular emacs configuration, there is a brief deployment instruction in the following

* copy the `emacs` file to `~/.emacs`  
  in this file, lines 32-190, many elpaca packages are declared that will get installed in your first run, so if you don't need some of them, eliminate the *whole* `(use-package xxx ... )` section.
* make `~/.emacs.d`, `~/.emacs.saves`, and `~/.emacs.d/themes`
* copy `init.el` file to `~/.emacs.d/init.el`
* [optional] installing themes  
  download your favorite emacs themes to `~/.emacs.d/[repo_name]` and then make links to their `xxx.el` files in the `~/.emacs.d/themes` directory
* run emacs and wait package manager installs all packages
  
