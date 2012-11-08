#!/usr/bin/python
from subprocess import Popen as popen
from subprocess import PIPE
import sys

def eachline(input, cmd):
	map(cmd, input)

def searchfor(name):
	eachline(popen("apt-cache search %s" % name,stdout=PIPE,shell=True).stdout.readlines(),apt_search)

def apt_search(line):
	print "======="
	print ''.join(popen("apt-cache show %s" % line.split(' ')[0],stdout=PIPE,shell=True).stdout.readlines())


if __name__=="__main__":
	searchfor(' '.join(sys.argv[1:]))

	
