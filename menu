#!/bin/bash

db_path="./databaseSystem"
mkdir -p "$db_path"
width=$(tput cols)
function printseparator {
    echo
    printf '%*s\n' "$width" '' | tr ' ' '='
    echo
}

function mainMenu
{
    clear
    printseparator
    printf "%*s%s\n" $(( $width/2 )) "Welcome to Database Manegment System"
    printseparator
    echo "1) Create Database"
    echo "2) List Databases"
    echo "3) Connect to Database"
    echo "4) Drop Database"
    echo "5) Exit"

    read -p "Choose an option: " choice

    case $choice in
        1)createdb ;;
        2)listdbs ;;
        3)connectdb ;;
        4)dropdb ;;
        5)exit ;;
        *)echo "Invalid Option"; mainMenu ;;
    esac
    
}
try=""
function createdb
{
    clear
    printseparator
    printf "%*s%s\n" $(( $width/2 )) "Create Your Database"
    printseparator
    echo $try
    read -p "Enter database name:" dbname
    if [[ -d "$db_path/$dbname" ]]
    then
        try="Database '$dbname' already exists! TRY AGAIN"
        createdb
    else
        mkdir "$db_path/$dbname"
        echo "Database '$dbname' created SUCCEFULLY !"
    fi
    echo
    read -p "Press Enter to return to menu....."
    mainMenu
}
function listdbs
{
    clear
    printseparator
    printf "%*s%s\n" $(( $width/2 )) "List The Databases"
    printseparator
    echo "Database:"
    ls "$db_path"
    echo
    read -p "Press Enter to return to menu....."
    mainMenu
}
function dropdb
{
    clear
    printseparator
    printf "%*s%s\n" $(( $width/2 )) "Drop The Database"
    printseparator
    echo $try
    read -p "Enter Database name to delete: " dbname
    if [[ -d "$db_path/$dbname" ]]
    then
        rm -r "$db_path/$dbname"
        echo "Database '$dbname' deleted SUCCEFULLY !"
    else
        try="Database not found.Try Again,Please?!"
        dropdb
    fi
    echo
    read -p "Press Enter to return to menu....."
    mainMenu
}
function connectdb
{
    clear
    printseparator
    printf "%*s%s\n" $(( $width/2 )) "Connect The Database"
    printseparator
    echo $try
    read -p "Enter Database name to connect: " dbname
    if [[ -d "$db_path/$dbname" ]]
    then
        cd "$db_path/$dbname"
        echo "Database '$dbname' connected SUCCEFULLY !"
        ./table_menu.sh "$db_path/$dbname"
    else
        try="Database not found.Try Again,Please?!"
        connectdb
    fi
    echo
    read -p "Press Enter to return to menu....."
    mainMenu
}

#START
mainMenu
