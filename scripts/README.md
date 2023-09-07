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
  make backup, is my backup script, you can dry run it (just echo what it's going to do) by `mkbackup -n`.
  
  you can exclude files and directories by editing `EXCLUDES` variable, and also break your backup parts by declaring them in `PARTS` variable, for instance, if you set `PARTS="/home /var"` you will get 3 backup files `ROOT-xxx.tar,  HOME-xxx.tar,  VAR-xxx.tar`.
  
  also by setting `TFLAGS=cpfz`, the output will be in gzip compressed format.

* dideofy  
  dideo.ir is YouTube cache website (that makes it possible to watch 'some' YouTube videos from Iran without using VPN), I use this script to convert YouTube links (either direct links or links from Google search) to compatible dideo.ir links.
  
  also by adding `-d1` or `-d2` (d1 for lower quality, d2 for 720p quality), you will get a direct download link, which I usually use like `mpv $(dideofy [LINK] -d2)`.
  
* jcal2panel  
  I always use the `jcal` program (it's a Jalali calendar), this script uses the `jdate` (similar to the `date` command) and outputs Jalali and Gregorian date in a compact format which I usually use in my desktop panels.

* ldict  
  simply is a wrapper around the `dict` command to use `less -S` instead of messing with your terminal.

* chdns  
  in this simple script, you can define some DNS servers by names like `ns1, ns2, ...` then by running `chdns -ns1`, chdns will write corresponding `nameserver ns1` to your `/etc/resolve.conf` file.
