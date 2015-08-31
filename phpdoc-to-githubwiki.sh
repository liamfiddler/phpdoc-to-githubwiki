#!/bin/bash

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
			# (generate into a "phpdoc" directory so we don't accidently 
			# overwrite other documentation)
			phpdoc -d $github_repo -t docs/ --template="xml"
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
