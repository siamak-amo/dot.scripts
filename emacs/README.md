# My Emacs Configuration
### This is my regular emacs configuration, there is a brief deployment instruction in the following

* copy the `emacs` file to `~/.emacs`  
  in this file, lines 32-190, many elpaca packages are declared that will get installed in your first run, so if you don't need some of them, eliminate the *whole* `(use-package xxx ... )` section.
* make `~/.emacs.d`, `~/.emacs.saves`, and `~/.emacs.d/themes`
* copy `init.el` file to `~/.emacs.d/init.el`
* [optional] installing themes  
  download your favorite emacs themes to `~/.emacs.d/[repo_name]` and then make links to their `xxx.el` files in the `~/.emacs.d/themes` directory
* run emacs and wait until the package manager installs all packages
  

### Shortcuts
This configuration uses evil-mode (vi shortcuts for emacs), so most vi shortcuts are available.

1. navigation  
   - `CTRL-PageUp` and `CTRL_PageDown` to switch to the next and previous buffers
   - `CTRL-Home` and `CTRL-End` to switch between tabs
   - `SPC-bb` for listing up buffers to choose
   - `SPC-bk` and `CTRL-k` to kill the current buffer
   - `SPC-bn` and `SPC-bp` for switch to the next and previous buffers
   - `SPC-br` and `SPC-g` for reloading the current buffer (Dired buffer)
   - `SPC-dw` to make Dired buffer writable and `SPC-df` to finish
   - `ALT-]` and `ALT-[` to increase and decrease the opacity
2. compilation  
   - `<F6>` for running the emacs `compile` command
   - in python-mode `C-c C-c` for sending python file to the interpreter which runs by default shortcut `C-c C-p`
   - in go-mode `C-c 6` and `<f5>` for running gofmt (formats your code)
   - in latex-mode `C-c C-c` to compile latex file to pdf
4. others  
   - `<f9>` for checking the spell (under the cursor one)
   - `<f8>` for enabling flyspell-mode (spell checking)

### Themes I use
1. <https://github.com/doomemacs/themes.git>
2. <https://github.com/emacs-jp/replace-colorthemes.git>
3. <https://github.com/owainlewis/emacs-color-themes.git>
4. <https://github.com/rexim/gruber-darker-theme.git>
