#!/bin/bash
# print bashmarks in nerdtree format
export | grep 'DIR_' | pyline "line[15:].replace('\"','').split('=',1)"
