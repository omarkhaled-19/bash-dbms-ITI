#!/bin/bash

width=$(tput cols)

function printseparator {
  echo
  printf '%*s\n' "$width" '' | tr ' ' '='
  echo
}

# Validate DB path
DB_PATH="$1"
DB_NAME=$(basename "$DB_PATH")  # or: DB_NAME="${DB_PATH##*/}"

# 'basename' gives you the last part of a file path — the actual file name.
# DB_PATH##*/ = "the longest match (last match of '/') of anything followed by a slash, from the start">>>if DB_PATH#*/ = the shortest match (first match of '/')

if [[ ! -d "$DB_PATH" ]]; then
  echo "Database path '$DB_PATH' not found!"
  exit 1
fi

# GLOBAL flag
try=""

function createTable
{
  clear
  printseparator
  printf "%*s%s\n" $((width / 2)) " Creation Tables to DB: $DB_NAME"
  printseparator

  while true
  do
    echo "$try"
    try=""
    read -p "Enter table name: " table_name
    table_file="$DB_PATH/$table_name"
    meta_file="$DB_PATH/.$table_name.meta"

    if [[ -f "$table_file" || -f "$meta_file" ]]
    then
      try="Table already exists! Please try again!"
    else
      break
    fi
  done

  read -p "Enter number of columns: " col_count

  metadata=""
  pk_set="false"
  declare -A col_names_seen

  reserved=("select" "from" "where" "insert" "delete" "update" "table")

  for ((i = 1; i <= col_count; i++))
  do
    while true
    do
      clear
      echo "$try"
      try=""
      read -p "Enter name of column $i: " col_name
      col_name=$(echo "$col_name" | tr '[:upper:]' '[:lower:]' | xargs)

      if [[ -z "$col_name" ]]
      then
        try="Column name cannot be empty.TRY AGAIN!"
        continue
      elif [[ "${col_names_seen[$col_name]}" == "1" ]]
      then
        try="Duplicate column name '$col_name'. Please choose another!"
        continue
      elif [[ " ${reserved[*]} " == *" $col_name "* ]]
      then
        echo "'$col_name' is a reserved SQL keyword. Please choose another."
        continue
      else
        col_names_seen[$col_name]=1
        break
      fi
    done

    while true
    do
      echo "$try"
      try=""
      read -p "Enter type of $col_name [int/string]: " col_type
      col_type=$(echo "$col_type" | tr '[:upper:]' '[:lower:]' | xargs)

      if [[ "$col_type" == "int" || "$col_type" == "string" ]]
      then
        break
      else
        try="INVALID type. Please enter 'int' or 'string'."
      fi
    done

    if [[ "$pk_set" == "false" ]]
    then
      while true
      do
        echo "$try"
        try=""
        read -p "Is $col_name a Primary Key? [yes/no]: " is_pk
        is_pk=$(echo "$is_pk" | tr '[:upper:]' '[:lower:]' | xargs)

        if [[ "$is_pk" =~ ^y(e|es|s)?$ ]]
        then
          pk_set="true"
          col_def="$col_name:$col_type:PK"
          break
        elif [[ "$is_pk" =~ ^n(o)?$ ]]
        then
          col_def="$col_name:$col_type"
          break
        else
          try="Please answer 'yes' or 'no'. Try again!"
        fi
      done
    else
      col_def="$col_name:$col_type"
    fi

    if [[ $i -eq $col_count ]]
    then
      metadata+="$col_def"
    else
      metadata+="$col_def|"
    fi
  done

  echo "$metadata" > "$meta_file"

  touch "$table_file"

  echo "Table '$table_name' created successfully."
  echo "Metadata: $metadata"
}

function insertIntoTable
{
  clear
  printseparator
  printf "%*s%s\n" $((width / 2)) " Insert Into Tables of DB: $DB_NAME"
  printseparator

  read -p "Enter table name to insert into: " table_name
  table_file="$DB_PATH/$table_name"
  meta_file="$DB_PATH/$table_name.meta"

  if [[ ! -f "$table_file" || ! -f "$meta_file" ]]
  then
    echo "Table '$table_name' does not exist."
    return
  fi

  IFS='|' read -ra columns < "$meta_file"
  row=""
  pk_col_index=-1
  pk_value=""

  for idx in "${!columns[@]}"
  do
    IFS=':' read -r col_name col_type col_key <<< "${columns[$idx]}"

    while true
    do
      read -p "Enter value for '$col_name' [$col_type]: " value

      if [[ "$col_type" == "int" && ! "$value" =~ ^-?[0-9]+$ ]]
      then
        echo "'$col_name' must be an integer."
        continue
      elif [[ "$col_type" == "string" && "$value" =~ [|:] ]]
      then
        echo "Strings cannot contain '|' or ':'."
        continue
      fi

      if [[ "$col_key" == "PK" ]]
      then
        pk_value="$value"
        pk_col_index=$idx

        pk_exists=false

        while IFS='|' read -ra fields
        do
          if [[ "${fields[$pk_col_index]}" == "$pk_value" ]]
          then
            pk_exists=true
            break
          fi
        done < "$table_file"

        if $pk_exists
        then
          echo "Primary Key value '$pk_value' already exists in column $(($pk_col_index+1))."
          continue
        fi
      fi

      break
    done

    if [[ $idx -eq 0 ]]
    then
      row="$value"
    else
      row+="|$value"
    fi
  done

  echo "$row" >> "$table_file"
  echo "Row inserted successfully: $row"
}

function selectWholeTable {
echo "+----+-------+-----+ " | column -t
sed -E 's/ *\| */ /g; s/:([^| ]*)//g' $meta_file | column -t 
echo "+----+-------+-----+ " | column -t
sed 's/|/ /g' $table_file | column -t
}

function selectFields {
	
	declare -A fields
	declare -i i=1
	while read -r key; do
    	fields["$key"]=$i
    	((++i))
	done < <(sed -E 's/\|/\n/g' $meta_file | awk -F: '{print $1}' )
	
	for key in "${!fields[@]}"; do
    		echo "${fields[$key]} ) $key  "	
	done

selected_fields=()
while read -p "Enter fields you want displayed. Press Enter when finished: " -ra input;
do
	[[ -z $input ]] && break;
	if [[ $input -lt $i && $input -ge 1 ]]
	then
		selected_fields+=($input)
	else
		echo "Invalid Entry. Please enter a valid number from 1 to $i"
	fi

done

echo "+----+-------+-----+ " | column -t
awk -F' ' -v fi_head="${selected_fields[*]}" 'BEGIN{split(fi_head,arr,/\s/);}
NR==1 {
for (head in arr)
{printf "%s \t", $arr[head]}
#print "\n"
}' < <(sed -E 's/\|/\n/g' $meta_file | awk -F: '{print $1}' | column)
echo " "
echo "+----+-------+-----+ " | column -t
#read -p "Enter column number: " col_num
awk -F'|' -v fi="${selected_fields[*]}"  'BEGIN{split(fi,arr,/\s/);}
{

for (data in arr)
{
printf "%s \t", $arr[data]
}
print "\n"
}' "$table_file"


}

function selectRows {
	echo "Enter the range of rows you want to select: "
	read -p "Enter starting row: " row_start
	read -p "Enter ending row: " row_end
	
	echo "+----+-------+-----+ " | column -t
	sed -E 's/ *\| */ /g; s/:([^| ]*)//g' $meta_file | column -t 
	echo "+----+-------+-----+ " | column -t
	
	head -$row_end $table_file | tail -$(($row_end-$row_start+1)) | sed 's/|/ /g' | column -t --output-separator '|'

}

function selectFromTable {
  clear
  printseparator
  printf "%*s%s\n" $((width / 2)) " Insert Into Tables of DB: $DB_NAME"
  printseparator
  
  read -p "Enter table name to select from: " table_name
  table_file="$DB_PATH/$table_name"
  meta_file="$DB_PATH/$table_name.meta"
  
  if [[ ! -f "$table_file" || ! -f "$meta_file" ]]
  then
    echo "Table '$table_name' does not exist."
    return
  fi
  clear
  printseparator
  printf "%*s%s\n" $((width / 2)) " The Main Menu of DB: $DB_NAME"
  printseparator
  
  echo "1. Select Whole table"
  echo "2. Select field/s from table"
  echo "3. Select row/s from table"
  echo "4. Select with condition"
  echo "==============================="
  read -p "Enter your select choice [1-4]: " select_choice
  
  case $select_choice in
  1) selectWholeTable;;
  2) selectFields;;
  3) selectRows;;
  *) echo "Invalid Option";;
  esac
}


while true
do
  clear
  printseparator
  printf "%*s%s\n" $((width / 2)) " The Main Menu of DB: $DB_NAME"
  printseparator
  echo "1. Create Table"
  echo "2. List Tables"
  echo "3. Drop Table"
  echo "4. Insert into Table"
  echo "5. Select From Table"
  echo "6. Delete From Table"
  echo "7. Update Table"
  echo "8. Back to Main Menu"
  echo "==============================="

  read -p "Enter your choice [1-8]: " choice

  case $choice in
    1) createTable ;;
    2) echo "Tables in $DB_NAME:" && ls -1 "$DB_PATH" ;;
    3) dropTable;;
    4) insertIntoTable ;;
    5) selectFromTable;;
    *) echo "❌ Invalid choice. Try again." ;;
  esac

  read -p "Press Enter to continue..." dummy
  
done 
