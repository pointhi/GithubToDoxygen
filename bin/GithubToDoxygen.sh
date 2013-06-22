#!/bin/bash

#################################################
# Github -> Doxygen Documentation		#
#						#
# by Thomas Pointhuber				#
# GNU General Public License (GPL) 3.0		#
#################################################

#Header

echo "################################"
echo "# Automatic Doxyfile generator #"
echo "################################"
echo -e "by Thomas Pointhuber\n"

# Reading config-file

echo -e "Reading config.cfg....\n"
source config.cfg
echo "Url of Repository: $cfg_github_url"
echo -e "Url to FTP-Server: $cfg_ftp_server\n"

echo "Download Sourcecode from $cfg_github_url"
if [ -d "src/" ];then
	echo "Update repository"
	cd src
	git remote update
	cd ..
else
	echo "Clone repository"
	git clone $cfg_github_url src
fi


# Loading last GITHUB-Hash

cfg_last_commit_hash=`cat last-commit.hash`
echo "Hash from last commit: $cfg_last_commit_hash"

cd src
# Reading hash from current commit
cfg_current_commit_hash=`git rev-parse HEAD`	
echo -e "Hash from current commit: $cfg_current_commit_hash\n"
cd ..


if [ $cfg_last_commit_hash == $cfg_current_commit_hash ]
	then
	echo "Close program, it's not been updated"
	exit
	fi

# Generate special Doxyfile

if [! -e "Doxyfile" ];then
	echo "ERROR: No Doxyfile available!"
	exit
fi

cp Doxyfile Doxyfile-tmp

echo "" >> Doxyfile-tmp
echo "# Automatic generated Data from Github-Repository" >> Doxyfile-tmp
echo "# Url: $cfg_github_url" >> Doxyfile-tmp
echo "# Program made by Thomas Pointhuber" >> Doxyfile-tmp
echo "" >> Doxyfile-tmp
echo "PROJECT_NUMBER         = $cfg_current_commit_hash" >> Doxyfile-tmp
echo "INPUT                  = src" >> Doxyfile-tmp
echo "OUTPUT_DIRECTORY       = output" >> Doxyfile-tmp
echo "HTML_OUTPUT            = html" >> Doxyfile-tmp
echo "USE_MDFILE_AS_MAINPAGE = README.md" >> Doxyfile-tmp

# Delete old Documentation

if [ -d "output/" ]
	then
	echo "Delete old Documentation"
	rm -rv output > /dev/null
	fi

# Call doxygen

doxygen Doxyfile-tmp

# Write new hash into file

echo -e "\nSave new Hash"
echo $cfg_current_commit_hash > last-commit.hash
