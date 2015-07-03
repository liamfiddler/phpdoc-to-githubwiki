#!/bin/bash

while true; do
	read -e -p "GitHub username: " github_username
	read -e -p "GitHub repository: " github_repo
	read -p "Update the wiki for $github_username/$github_repo? [y/n]: " yn
	case $yn in
		[Yy]* ) 
			current_time=$(date "+%Y.%m.%d-%H.%M.%S")
			temp_dir="temp_$current_time"
			mkdir $temp_dir
			cd $temp_dir
			git clone "https://github.com/$github_username/$github_repo.git"
			git clone "https://github.com/$github_username/$github_repo.wiki.git"
			git clone https://github.com/evert/phpdoc-md.git
			cd phpdoc-md
			composer update --no-dev
			cd ..
			phpdoc -d $github_repo -t docs/ --template="xml"
			rm -r "$github_repo.wiki/*"
			phpdoc-md/bin/phpdocmd docs/structure.xml "$github_repo.wiki"
			cd "$github_repo.wiki"
			git add .
			git commit -am "Updating documentation to match repo as at $current_time"
			git push
			cd ..
			chmod -R 777 $temp_dir
			rm -r $temp_dir
			exit;;
		[Nn]* ) exit;;
		* ) echo "Please answer yes or no.";;
	esac
done

