#!/bin/bash

if ! type "php" > /dev/null; then
    echo "PHP not found!" 1>&2
    echo "Please follow the install instructions at http://php.net/ then try again" 1>&2
    exit
fi

if ! type "git" > /dev/null; then
    echo "Git not found!" 1>&2
    echo "Please follow the install instructions at https://git-scm.com/ then try again" 1>&2
    exit
fi

while true; do
	read -e -p "GitHub username: " github_username
	read -e -p "GitHub repository: " github_repo
	read -p "Update the wiki for $github_username/$github_repo? [y/n]: " yn
	case $yn in
		[Yy]* ) 

			# create & switch to the temporary directory
			current_time=$(date "+%Y.%m.%d-%H.%M.%S")
			temp_dir=`mktemp -d "${TMPDIR:-/tmp}"/phpdocmd.XXXX`
			cd $temp_dir

			# clone & update the repos we need
			git clone "https://github.com/$github_username/$github_repo.git"
			git clone "https://github.com/$github_username/$github_repo.wiki.git"
			git clone https://github.com/evert/phpdoc-md.git
			cd phpdoc-md
			composer update --no-dev
			cd ..

			# run PHPDocumentor and generate .MD files
			if ! type "phpdoc" > /dev/null; then
				echo "Global PHPDocumentor not found, downloading local PHAR..."
				curl -sS https://www.phpdoc.org/phpDocumentor.phar > phpdoc.phar
				php ./phpdoc.phar -d $github_repo -t docs/ --template="xml"
			else
				phpdoc -d $github_repo -t docs/ --template="xml"
			fi

			# generate into a "phpdoc" directory so we don't accidently 
			# overwrite other documentation
			chmod -R 777 "$github_repo.wiki"
			mkdir -p "$github_repo.wiki/phpdoc"
			rm -r "$github_repo.wiki/phpdoc/*"
			phpdoc-md/bin/phpdocmd docs/structure.xml "$github_repo.wiki/phpdoc"

			# switch to the Wiki repo documentation dir
			cd "$github_repo.wiki/phpdoc"

			# remove the .MD extension from URLs so GitHub links them correctly
			sed -i '' 's/.md)/)/g' *.md

			# remove the HTML P tags from the comments
			sed -i '' 's/&lt;p&gt;//g' *.md
			sed -i '' 's/&lt;\/p&gt;//g' *.md

			# update the Wiki repo
			git add .
			git commit -am "Updating documentation to match repo as at $current_time"
			git push

			# clean up
			cd ..
			chmod -R 777 $temp_dir
			rm -r $temp_dir

			exit;;
		[Nn]* ) exit;;
		* ) echo "Please answer yes or no.";;
	esac
done
