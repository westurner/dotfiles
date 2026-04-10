javascript:(function(){
    var hostname = window.location.hostname;
    var pathname = window.location.pathname;
    var isGitHub = hostname.endsWith('.github.io');
    var isGitLab = hostname.endsWith('.gitlab.io');

    if (!isGitHub && !isGitLab) {
        alert('Not a github.io or gitlab.io domain');
        return;
    }

    var domain = isGitHub ? 'github.com' : 'gitlab.com';
    var parts = hostname.split('.');
    var org = parts[0];
    
    var pathParts = pathname.replace(/^\/|\/$/g, '').split('/');
    var repo = '';
    var repoPath = '';

    if (pathParts.length > 0 && pathParts[0] !== '') {
        repo = pathParts[0];
        repoPath = pathParts.slice(1).join('/');
    } else {
        repo = hostname;
    }

    var repoUrl = 'https://' + domain + '/' + org + '/' + repo;
    var pathUrl = repoUrl;
    if (repoPath) {
        // We use tree here; GitHub redirects to blob if it is a file.
        pathUrl += '/tree/main/' + repoPath;
    }

    var msg = 'Repo URL: ' + repoUrl + '\nPath URL: ' + pathUrl + '\n\nWhich one would you like to open?';
    var choice = prompt(msg, 'repo');
    
    if (choice === 'repo') {
        window.open(repoUrl, '_blank');
    } else if (choice === 'pathUrl' || choice === 'path') {
        window.open(pathUrl, '_blank');
    }
})();