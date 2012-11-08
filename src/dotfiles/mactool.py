#!/usr/bin/env python
from urllib import urlopen
from os import getenv
from random import randrange,seed
import sys

_OUI_URL = "http://standards.ieee.org/regauth/oui/oui.txt"
_MACFILE = "%s/.macvendors" % getenv("HOME")


_V_VMWARE = '00:0c:29'

def rand_hex(num):
    return [hex(randrange(0,255)).split("x")[1].zfill(2) for n in range(0,num)]

def rand_vmware():
    l = _V_VMWARE.split(":")
    l.extend(rand_hex(3))
    return ':'.join(l)

rand_global = lambda: ':'.join(rand_hex(6))

def format_line(line):
    s = line.split()
    return s[0], ' '.join(x.lower().capitalize() for x in s[2:]))

def download_oui():
    #f = file(filename,"r")
    f = urlopen(_OUI_URL)
    o = file(_MACFILE,"w+")
    lines = (format_line(l) for l in f if "(hex)" in l)
    o.writelines( ','.join(x)+"\n" for x in lines)
    o.close()
    print "OUI File downloaded to %s" % _MACFILE

def mac_to_vendor(mac):
    f = file(_MACFILE,"r")
    mac = mac.replace(":","-")[:8].upper()

    return '\n'.join(
        ''.join(x.split(",")[1:]).strip() for x in f if x.startswith(mac))

def find_vendor(vendor):
    f = file(_MACFILE,"r")
    vendor = vendor.lower()
    return '\n'.join(
        x.replace('-',':').strip() for x in f if vendor in f.lower())

def mac_from_prefix(prefix):
    p = prefix.replace("-",":")[:8]
    l = p.split(":")
    if len(l) is not 3:
        raise Exception("Bad prefix")
    l.extend(rand_hex(3))
    return (':'.join(l)).upper()

def mac_from_vendor(vendor):
    l = [x.split(",")[0] for x in find_vendor(vendor).split("\n")]
    return mac_from_prefix(l[randrange(0,len(l))])

if __name__=="__main__":
    _VERSION = 0.1
    seed()

    from optparse import OptionParser
    arg = OptionParser(version="%prog 0.1")
    arg.add_option("-d","--download",
            dest="download",
            action="store_true",
            help="Download latest MAC list")
    arg.add_option("-m","--mac",
            dest="mac",
            help="MAC Address to Convert to Vendor String")
    arg.add_option("-v","--vendor",
            dest="vendor",
            help="Vendor to search for prefixes")
    arg.add_option("-r","--random",
            dest="rand",
    action="store_true",
            help="Generate random MAC")
    arg.add_option("-a",
            dest="stdall",
            action="store_true",
            help="Convert All From stdin")

    (options, args) = arg.parse_args()
    if(options.download):
        download_oui()

    if(options.vendor and options.rand):
        print mac_from_vendor(options.vendor)
    elif(options.vendor):
        print find_vendor(options.vendor)

    if(options.mac and options.rand):
        print mac_from_prefix(options.mac)
    elif(options.mac):
        print mac_to_vendor(options.mac)

    if(options.stdall):
        ilines = sys.stdin.readlines()
        for x in ilines:
            print "%s -> %s" % (x.strip(), mac_to_vendor(x))
