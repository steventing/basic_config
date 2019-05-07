# Add auto-completion and a stored history file of commands to your Python
# interactive interpreter. Requires Python 2.0+, readline. Autocomplete is
# bound to the Esc key by default (you can change it - see readline docs).
#
# Store the file in ~/.pyrc.py, and set an environment variable to point
# to it:  "export PYTHONSTARTUP=/home/yourname/.pyrc.py" in bash.
#
# Note that PYTHONSTARTUP does *not* expand "~", so you have to put in the
# full path to your home directory.

from datetime import datetime
from pprint import pprint
import base64
import json
import math
import os
import re
import sys

is_py2 = (sys.version_info.major == 2)

if is_py2:
    import urllib, urllib2
else:
    import urllib.request, urllib.parse


def init():
    '''Mods, functions here will not remain in the interpreter session.'''
    import atexit
    import readline
    import rlcompleter

    # Change autocomplete to tab
    if readline.__doc__ and 'libedit' in readline.__doc__:
        # for mac
        readline.parse_and_bind("bind ^I rl_complete")
    else:
        readline.parse_and_bind("tab: complete")

    # If history file exist, source it.
    history_path = os.path.expanduser("~/.pyhistory")
    if os.path.exists(history_path):
        readline.read_history_file(history_path)

    # Save history on exit
    def save_history(history_path=history_path):
        readline.write_history_file(history_path)
    atexit.register(save_history)

    # Stop saving history feature. Use it if you want to test something sensitive.
    # Make it global so it will remain in the interpreter session.
    # TODO: not working in Python2.
    global stop_saving_history
    def stop_saving_history():
        atexit.unregister(save_history)

init()
del init


def try_import(mod_name, func=None, alias=None):
    ''' Helper function for you to write .pylocal.py

    Examples:

        # import requests
        try_import('requests')

        # import itertools as it
        try_import('itertools', alias='it')

        # from unittest.mock import Mock
        try_import('unittest.mock', 'Mock')

        # from datetime import timedelta as td
        try_import('datetime', 'timedelta', 'td')

        # detect if import succesfully.
        if try_import('boto3')[0]: print('boto3 is imported')

    Return Value:
        True, None          If success.
        False, exception    If failed, and exception for debug purpose.

    Bugs:
        This is not working because the full_name contains '.':
            try_import('os.path')
        You should give it an alias:
            try_import('os.path', alias='path')
    '''
    import importlib

    try:
        target = importlib.import_module(mod_name)
    except ImportError as e:
        return False, e

    if func:
        try:
            target = getattr(target, func)
        except AttributeError as e:
            return False, e
        full_name = mod_name + '.' + func
    else:
        full_name = mod_name

    if not alias:
        alias = func if func else mod_name

    globals()[alias] = target
    print('{magenta}[{full_name}]{clr} is imported as {cyan}[{alias}]{clr}'
          .format(magenta='\033[1;35m', cyan='\033[1;36m', clr='\033[m',
                  full_name=full_name, alias=alias))
    return True, None


def openurl(url, params={}, method="GET"):
    """open the url
    args:
        @url(string): the url to be opened.
        @params(dict): the url's params
        @method(string): GET/POST
    
    return value:
        urllib2.urlopen() instance. you can get the content by .read().
        # urllib.request.urlopen()
    
    example:
        openurl('http://www.google.com/', {'q':'google'}, 'GET').read()
    """
    if is_py2:
        urlopen = urllib2.urlopen
        urlencode = urllib.urlencode
    else:
        urlopen = urllib.request.urlopen
        urlencode = urllib.parse.urlencode

    if method.upper() == "POST":
        return urlopen(url, data=urlencode(params))
    else:
        return urlopen(url + "?" + urlencode(params))


def S(cmd, input=None, **kwargs):
    """Shortcut for subprocess.Popen. Intent to simulate backquote is shell.
    cmd: list or str
    input: str or bytes
    **kwargs: same as subprocess.Popen
    return value: str of stdout and stderr
    """
    import subprocess
    # default arguments
    popen_args = dict(
        stdin = subprocess.PIPE,
        stdout = subprocess.PIPE,
        stderr = subprocess.PIPE,
    )
    popen_args.update(kwargs)   # override by kwargs

    # force shell=True if cmd is str
    if isinstance(cmd, str):
        popen_args.update({'shell': True})

    # ensure input is bytes
    if input and not isinstance(input, bytes):
        input = input.encode()
    else:
        popen_args.update({'stdin': None})

    out = subprocess.Popen(cmd, **popen_args).communicate(input=input)
    ret = (out[0] if out[0] else b'') + (out[1] if out[1] else b'')
    return ret.decode()


# If ~/.pylocal.py exist, source it.
# This should be the last step because .pylocal.py may want to use functions
# above.
# This part cannot be put in init(), or Python2 will give you SyntaxError at
# exec() even if Python2 never executes it...
pylocal_path = os.path.expanduser("~/.pylocal.py")
if os.path.exists(pylocal_path):
    print("\033[1;32mexec '.pylocal.py'  ...\033[m")
    if is_py2:
        execfile(pylocal_path)
    else:
        exec(compile(open(pylocal_path).read(), pylocal_path, 'exec'))
del pylocal_path
