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
  
  you can exclude files and directories by editing the `EXCLUDES` variable 
  or using `--exclude` option (the same as the `tar --exclude PATTERN`),
  and also break your backup parts by declaring them in `PARTS` variable or using `--parts` option,
  for instance, if you pass `--parts "/home /var"` you will get 3 backup files `ROOT-xxx.tar,  HOME-xxx.tar,  VAR-xxx.tar`.
  
  also by setting `TFLAGS=cpfz` or using `-z` option, the output will be in gzip compressed format.

* dideofy  
  dideo.ir is YouTube cache website (that makes it possible to watch 'some' YouTube videos from Iran without using VPN), I use this script to convert YouTube links (either direct links or links from Google search) to compatible dideo.ir links.
  
  also by adding `-d1` or `-d2` (d1 for lower quality, d2 for 720p quality), you will get a direct download link, which I usually use like `mpv $(dideofy [LINK] -d2)`.
  
* jcal2panel  
  I always use the `jcal` program (it's a Jalali calendar), this script uses the `jdate` (similar to the `date` command) and outputs Jalali and Gregorian date in a compact format which I usually use in my desktop panels.

* ldict  
  simply is a wrapper around the `dict` command to use `less -S` instead of messing with your terminal.

* chdns  
  in this simple script, you can define some DNS servers by names like `ns1, ns2, ...` then by running `chdns -ns1`, chdns will write corresponding `nameserver ns1` to your `/etc/resolve.conf` file.

* oggify  
  oggify is a simple script to change file extensions, I named oggify when it was so simple to only change file extensions to `.ogg`
  
  I use it like `for f in $(ls *.mp3); do  ffmpeg -i $f $(echo $f | oggify);  done` to convert all mp3 files to ogg format.

* ln2ml  
  this script can be used to reformat files that include links separated by newlines, to a proper HTML format.

* vs2conf  
  this script gives you v2ray configuration file, based on URLs like vmess://xxx.
  vmess, vless, ss, and trojan protocols are supported.

* v2test  
  I use this script to make tested v2ray config files and also to test existing config files:
  ```{bash}
  cat /path/to/links.text | v2test 2>/dev/null        # to make verified config files
  v2test -c /path/to/*.json                           # to test config files
  cat /path/to/links.text | v2test -tn                # to skip testing and convert all links
  ```
  add `-s` and `2>/dev/null` to only get working links (simple link in each line)

* Bash_V2rayCollector  
  this script downloads v2ray config links from several telegram channels.
  you need to use another proxy if telegram is blocked in your region:
  `HTTP_PROXY="IP:port" Bash_V2rayCollector >> links`
  and then you may kill the current proxy and use the `v2test` script to generate JSON config files.

there are other tiny simple scripts not documented here (mostly because of their simplicity and limited usage)
like `ghassets`, `calTopPanel`, `conck`, `setresol`


### Deploy
as a standard, if any of these scripts depend on another one, it was done by referring to
the script name (without .sh), so creating links from some of `.sh` files to a location 
in your PATH, such as `~/.local/bin/`, is necessary, Alternatively modify the scripts as needed.

example:
``` bash
for script in $(ls *sh -1); do
    ln -s "$PWD/$script" ~/.local/bin/${script:0:-3}
done
```
