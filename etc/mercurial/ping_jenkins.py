import httplib

USERNAME = 'hghook'
PASSWORD = ''
BUILDSERVER='build.server'
JOBNAME = 'jobname'
BUILDBRANCH = 'default'

authstr = ('%s:%s' % (USERNAME, PASSWORD)).encode('base64')[:-1]

def hook(*args, **kwargs):
    h = httplib.HTTPSConnection(BUILDSERVER)
    headers = {
        'authorization': 'Basic %s' % authstr,
    }
    h.request("GET", "/job/%s/build" % JOBNAME, headers=headers)
    resp = h.getresponse()

def default_branch_hook(ui, repo, **kwargs):
    branch = repo[None].branch()
    if branch == BUILDBRANCH:
	hook()

if __name__ == "__main__":
    hook()

