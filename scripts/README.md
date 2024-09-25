# My Scripts

# Scripts

* chpy  
  This sript is a wrapper for the `pyenv` program, so you need to install it first

  first of all set your global python version by running `pyenv global 3.xxx`,
  and then by running `source chpy`, your python environment will change
  to what you have set before (activation), which means
  your `pip` and `python` commands now come from `pyenv` configuration;
  your shell prompt (PS1) will change indicating that.
  also your `pip` packages now get installed in `$PYENV_ROOT/versions/3.xxx`

  you can deactivate `pyenv` by running: `source chpy -d`

  ** WARNING ** This script works by changing your `$PATH` variable;
    it adds: `$PYENV_ROOT/shims` to the BEGINNING of the PATH variable,
    so this can lead to vulnerability with granted write access to `$PYENV_ROOT/shims`


* cowsay  
  `cowsay` is a minimal SHELL replacement script for the real `cowsay` program,
  you can either run: `cowsay "some string here"` or use stdin: `echo -e "xxx" | cowsay`


* mkbackup  
  make backup, my backup script

  It makes configurable tarball backup(s) of the entire filesystem
  You can exclude files and directories by editing the `EXCLUDES` variable 
  or using `--exclude` option (the same as the `tar --exclude PATTERN`),
  and also break your backup parts by declaring them in `PARTS` variable or using `--parts` option,
  for instance, if you pass `--parts "/home /var"` you will get 3 backup files: 
  `ROOT-xxx.tar,  HOME-xxx.tar,  VAR-xxx.tar` and
  by setting `TFLAGS=cpfz` or using `-z` option, the output will be in gzip compressed format

  To only see generated tar commands use `-n` (dry run)
  and to include other tar options use: `--` and then any tar option(s)


* dideofy  
  dideo.ir wrapper script, this script converts YouTube links including
  direct links (to videos and playlists), URLs from Google search to compatible dideo.ir links


  by adding `-d1` or `-d2` (d1 for the lower quality and d2 for 720p),
  gives a direct download link, which can be used like: `mpv $(dideofy [LINK] -d2)`
  
* jcal2panel  
  This script uses `jdate` program and outputs Jalali and Gregorian date
  in a compact format which I usually use in my desktop panels

  see <https://www.nongnu.org/jcal/> for more information about jcal, jdate and libjalali,
  or see my modified version (jtool) <https://gitlab.com/SI.AMO/jtool>


* chdns  
  Using chdns, you can define some DNS servers like `ns1, ns2, ...`,
  then by running `chdns -ns1`, chdns will update your `/etc/resolve.conf` file
  by the corresponding DNS server (`ns1` in this case)


* ln2ml  
  This script can be used to reformat files that consist of links (on each line)
  to a proper HTML format which you can copy the links to your clipboard
  by clicking on them


* vs2conf  
  This script gives you v2ray configuration file, based on URLs like vmess://xxx
  vmess, vless, ss, and trojan protocols are supported


* v2test  
  I use this script to make tested v2ray config files and also to test existing config files:
  ```{bash}
  cat /path/to/links.text | v2test 2>/dev/null        # to make verified config files
  v2test -c /path/to/*.json                           # to test config files
  cat /path/to/links.text | v2test -tn                # to skip testing and convert all links
  ```
  add `-s` and `2>/dev/null` to only get working links (simple link in each line)


* Bash_V2rayCollector  
  This script downloads v2ray config links from several telegram channels.
  you need to use another proxy if telegram is blocked in your region:
  `HTTP_PROXY="IP:port" Bash_V2rayCollector >> links`
  and then you may kill the current proxy and use the `v2test` script to generate JSON config files.

---

### Others
There are some other tiny simple scripts not documented here
(mostly because of their simplicity and limited usage)
like: `ghassets`, `calTopPanel`, `conck`, `setresol`, `oggify`

---

### Deploy
As a standard, if any of these scripts depends on another one,
it was done by referring to the other's name (without `.sh` at the end)

It is convenient to create symbolic links
from these scripts into some plase (like `~/.local/bin/`)
included in your PATH variable:
``` bash
for script in $(ls *sh -1); do
    ln -s "$PWD/$script" ~/.local/bin/${script:0:-3}
done
```
Alternatively modify the scripts as needed to use absolute path (not recommended)
