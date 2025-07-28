#! /usr/bin/bash

#Create a Databases folder if it starts the first time
function check_program_folder {

if [[ -d "Databases" ]]
then
	cd Databases
else
	mkdir Databases
	cd Databases
fi	
}

check_program_folder

#Define base directory, and database directory to always return to:
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_DIR="$BASE_DIR/Databases"

#==================================================================================
#This is the welcome message at the start of the DB
PS3="Select an option: "
welcome_message="Greetings to the Bash DBMS.
Choose one of the following options: "
printf "%s\n" "$welcome_message"
#===================================================================================

#==================================================================================


#Create Table Function
function create_table {
#start by creating meta-data and data files for the table
read -p "Enter table name: " table_name
table_meta=$table_name.meta
table_data=$table_name.data
touch $table_meta $table_data
declare -i field_count=1
#declare -i num_fields
read -p "Enter number of fields: " num_fields
echo "Enter field info as follows: field_name:datatype:[primary_key]: "
while [[ $field_count -le $num_fields ]]
do
	read -p "Field $field_count : " column
	echo $column >> $table_meta
	(( field_count = $field_count + 1 ))
done

}
#==================================================================================

function insert_table {

read -p "Enter table name you want to insert to: " t_name
#Check if the metadata and data of file exists
if [[ -e "$t_name.meta" && -e "$t_name.data" ]]
then
	echo "Table exists"
else
	echo "No Table"
fi
number_of_fields=$(sed -n '$=' $t_name.meta)
declare -i fnum=1
while [[ $fnum -le $number_of_fields ]]
do
read fname ftype flag <<< "$(cat "$t_name.meta" 2> /dev/null | sed -E 's/^([^:]+):([^:]+)(:pk)?/\1 \2 \3/')"
read -p "Enter "
done




}

function db_menu {
select db_choice in "Create a Table" "List current Tables" "Drop a Table" "Insert into Table" "Select from Table" "Delete from Table" "Update Table" "Disconnect and back to Main Menu"; do
	case $db_choice in
		"Create a Table")
			echo "You will create a table"
			create_table
			;;
		"List current Tables")
			echo "You listed tables"
			ls
			;;
		"Drop a Table")
			echo "You dropped a table"
			;;
		"Insert into Table")
			echo "You inserted into a table"
			insert_table
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
			main_menu
			;;
		"List current Databases")
			list_db
			main_menu
			;;
		"Connect to a Database")
			connect_db
			db_menu
			cd $BASE_DIR
			main_menu	
			;;
		"Drop a Database")
			drop_db
			main_menu
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


main_menu



			
			
		


