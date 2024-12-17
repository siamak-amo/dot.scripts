;; copy this file to ~/.emacs.d/proxy.el
(setq url-proxy-services
      '(("http" . "localhost:10809")
        ("https" . "localhost:10809")
        ("socks5" . "localhost:10808")))
