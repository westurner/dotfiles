# adapted from: https://gist.github.com/goldsmith/7163055

# A guide to prevent pain and suffering while upgrading to OS X Mavericks
# This will vary greatly depending on system set up, so read the instructions carefully

# Back up Virtulenvs
####################

# Very important! 
# For each virtualenv you have, run "pip freeze > requirements.txt" while in the activated virtualenv 
# in order to prevent loss of dependencies during the upgrade.

# Install Mavericks
###################

# Go to the App Store and install Mavericks
# Takes about 15 - 20 mins including set up

# Test Configuration
####################

# See if anything broke during the upgrade - I obviously had errors here.

#cd project/using/virtualenv
#workon <myproject>
#python <myproject.py>

# If everything works, you're good! Otherwise, continue...

# Reinstall Virtualenv
######################

cd /System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/setuptools/command
python easy_install.py virtualenv

#Reinstall Xcode Command Line Tools
##################################

# Yes, for some reason Mavericks uninstalls command line tools...
# Make sure you get the latest version (5.0.1)

xcode-select --install

# Repair Homebrew
#################

# If you don't already have Homebrew, I highly recommend that you install it now (http://brew.sh/)
# It will make fixing Python much easier if you need to relink it

sh ./setup_brew.sh

brew update
brew upgrade
brew doctor

# Reinstall Python (if necessary)
#################################

# Try python from the command line. If it works, congratulations! 
# Depending on your system set up, you may need to reinstall using Homebrew.

brew install python # if you have an error, it's already installed and there's no issue
brew unlink python
brew link --overwrite python

# Then, if you want to include Python 3 as well (recommended):
brew install python3 # same deal here
brew unlink python3
brew link --overwrite python3

# Reinstall virtualenv{,wrapper}
################################

sudo pip install virtualenv
sudo pip install virtualenvwrapper

# Reinstall requirements
########################

# You might need to reinstall pip requirements (usually not, but if you have any issues, do this):

#cd path/to/project
#mkvirtualenv <project>
#pip install -r requirements.txt # you backed them up didn't you?

# Finish
########

# I hope this guide was helpful! 
# Please fork if you have any suggestions, or shoot me an email at jhghank@gmail.com.
