# My Scripts
### here you can read about my scripts and how to use them.

* chpy  
  this sript works with `pyenv` program, at fist you might set your global python version by running `pyenv global 3.xxx`, and then by running `source chpy` your python environment will change to what have you set before (activation), which means your `pip` and `python` commands now get run by python `3.xxx` (your shell prompt will change indicating that).
  and also your `pip ` packages will get installed in the `$PYENV_ROOT/versions/3.xxx` directory.
  you can deactivate `pyenv` by running `source chpy -d`.

  ** WARNING ** This program works by changing your `$PATH`variable by adding `$PYENV_ROOT/shims` to its beginning, so this could lead to vulnerability if someone has write access to `$PYENV_ROOT/shims`.

* cowsay  
  `cowsay` is a minimal `sh` replacement script for real `cowsay` program, 
  you can either run `cowsay "some string here"` or pipe to it `xxx | cowsay`.

* mkbackup  
* dideofy  
* jcal2panel  
  I always use the `jcal` program (it's a Jalali calendar), this script uses the `jdate` (similar to the `date` command) and outputs Jalali and Gregorian date in a compact format which I usually use in my desktop panels.

* mkhosts  
* conck  
* ldict  
  simply is a wrapper around the `dict` command to use `less -S` instead of messing with your terminal.

* chdns  
  in this simple script, you can define some DNS servers by names like `ns1, ns2, ...` then by running `chdns -ns1`, chdns will write corresponding `nameserver ns1` to your `/etc/resolve.conf` file.
