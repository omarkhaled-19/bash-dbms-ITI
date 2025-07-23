#! /usr/bin/bash

#This is the welcome message at the start of the DB
main_folder=$(basename $PWD)
PS3="Select an option: "
welcome_message="Greetings to the Bash DBMS.
Choose one of the following options: "
printf "%s\n" "$welcome_message"

function return_to_main_dir {
current_directory=$(basename $PWD)

if [[ "$current_directory" != "$main_folder"  ]]
then
	echo "I am now in $PWD"
	cd ..
fi
}


function db_menu {
select db_choice in "Create a Table" "List current Tables" "Drop a Table" "Insert into Table" "Select from Table" "Delete from Table" "Update Table" "Disconnect and back to Main Menu"; do
	case $db_choice in
		"Create a Table")
			echo "You created a table"
			;;
		"List current Tables")
			echo "You listed tables"
			;;
		"Drop a Table")
			echo "You dropped a table"
			;;
		"Insert into Table")
			echo "You inserted into a table"
			;;
		"Select from Table")
			echo "You selected from a table"
			;;
		"Delete from Table")
			echo "You deleted from a table"
			;;
		"Update Table")
			echo "You updated a table"
			;;
		"Disconnect and back to Main Menu")
			echo "back to main menu"
			break
			;;
		*)
			echo "Invalid again"
			;;
	esac
done
}

function check_program_folder {

if [[ -d "Databases" ]]
then
	cd Databases
else
	mkdir Databases
	cd Databases
fi	
}
function create_db {
	read -p "Enter Database Name: " db_name
	mkdir $db_name 
}
function list_db {
	list=$(ls -d */ 2> /dev/null)
	if [[ $list ]]
	then
		echo $list
	else
		echo "No Databases"
	fi
}

function connect_db {
	read -p "Enter db name: " db
	if [[ -d $db ]]
	then
		cd $db
	else
		echo "No Database with that name"
	fi
	
}

function drop_db {
	read -p "Enter db you would like to delete: " db_delete
	if [[ -d $db_delete ]]
	then 
		rm -r $db_delete
	else
		echo "No Database with that name"
	fi
}



function main_menu {


select choice in "Create a Database" "List current Databases" "Connect to a Database" "Drop a Database" "Exit"; do
	case $choice in
		"Create a Database")
			create_db
			;;
		"List current Databases")
			list_db
			;;
		"Connect to a Database")
			connect_db
			db_menu
			;;
		"Drop a Database")
			drop_db
			;;
		"Exit")
			exit
			;;
		*)
			echo "Invalid Option"
			;;
	esac
done

echo "The End"

}

check_program_folder
main_menu



			
			
		


