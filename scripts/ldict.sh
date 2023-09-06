#!/bin/bash
#

_PAGER="less -S"
_DICT=dict

[ -z $1 ] && exit 1

$_DICT $1 | $_PAGER
