#!/usr/bin/env bash

echo "File Janitor, 2024"
echo "Powered by Bash"
echo

countFiles() {
    tmp_files=$(find "$1" -maxdepth 1 -type f -name "*.tmp" | wc -l | tr -d ' ')
    py_files=$(find "$1" -maxdepth 1 -type f -name "*.py" | wc -l | tr -d ' ')
    log_files=$(find "$1" -maxdepth 1 -type f -name "*.log" | wc -l | tr -d ' ')
    declare tmp_size
    declare py_size
    declare log size

    if [ "$tmp_files" = "0" ]; then
        tmp_size=0
    elif [ "$tmp_files" = "1" ]; then
        tmp_size=$(find "$1" -maxdepth 1 -type f -name "*.tmp" -exec wc {} \+ | tr -s " " | cut -d " " -f 4)
    else
        tmp_size=$(find "$1" -maxdepth 1 -type f -name "*.tmp" -exec wc {} \+ | grep total | tr -s " " | cut -d " " -f 4)
    fi

    if [ "$py_files" = "0" ]; then
        py_size=0
    elif [ "$py_files" = "1" ]; then
        py_size=$(find "$1" -maxdepth 1 -type f -name "*.py" -exec wc {} \+ | tr -s " " | cut -d " " -f 4)
    else
        py_size=$(find "$1" -maxdepth 1 -type f -name "*.py" -exec wc {} \+ | grep total | tr -s " " | cut -d " " -f 4)
    fi

    if [ "$log_files" = "0" ]; then
        log_size=0
    elif [ "$log_files" = "1" ]; then
        log_size=$(find "$1" -maxdepth 1 -type f -name "*.log" -exec wc {} \+ | tr -s " " | cut -d " " -f 4)
    else
        log_size=$(find "$1" -maxdepth 1 -type f -name "*.log" -exec wc {} \+ | grep total | tr -s " " | cut -d " " -f 4)
    fi

    echo "$tmp_files tmp file(s), with total size of $tmp_size bytes"
    echo "$py_files py file(s), with total size of $py_size bytes"
    echo "$log_files log file(s), with total size of $log_size bytes"
}

clean_files() {
    if [ "$1" = "." ]; then
        echo "Cleaning the current directory..."
        delete_log_files $1
        delete_tmp_files $1
        move_py_files $1
        echo
        echo "Clean up of the current directory is complete!"
    else
        echo "Cleaning $1..."
        delete_log_files $1
        delete_tmp_files $1
        move_py_files $1
        echo
        echo "Clean up of $1 is complete!"
    fi
}

delete_log_files() {
    count=$(find "$1" -maxdepth 1 -type f -name "*.log" -mtime +3 | wc -l | tr -d " ")
    find "$1" -maxdepth 1 -type f -name "*log" -mtime +3 -exec rm {} \;
    echo "Deleting old log files...  done! $count files have been deleted"
}

delete_tmp_files() {
    count=$(find "$1" -maxdepth 1 -type f -name "*.tmp"| wc -l | tr -d " ")
    find "$1" -maxdepth 1 -type f -name "*tmp" -exec rm {} \;
    echo "Deleting temporary files...  done! $count files have been deleted"
}

move_py_files() {
    count=$(find "$1" -maxdepth 1 -type f -name "*.py"| wc -l | tr -d " ")
    if [ "$count" != "0" ]; then
        mkdir -p "$1/python_scripts"
        find "$1" -maxdepth 1 -type f -name "*.py" -exec mv {} "$1/python_scripts" \;
    fi
    echo "Moving python files... done! $count files have been moved"
}

if [ "$1" = "help" ]; then
    cat ./file-janitor-help.txt;
elif [ "$1" = "list" -a "$2" = "" ]; then
    echo "Listing files in the current directory"
    ls -la | tr -s ' ' | cut -d ' ' -f 9 | grep -vw '\.'
elif [ "$1" = "list" -a "$2" != "" ]; then
    if [ ! -e "$2" ]; then
        echo "$2 is not found"
    elif [ ! -d "$2" ]; then
        echo "$2 is not a directory"
    else
        echo "Listing files in $2"
        ls -la $2 | tr -s ' ' | cut -d ' ' -f 9 | grep -vw '\.'
    fi
elif [ "$1" = "report" -a "$2" = "" ]; then
    echo "The current directory contains:"
    countFiles "."
elif [ "$1" = "report" -a "$2" != "" ]; then
    if [ ! -e "$2" ]; then
        echo "$2 is not found"
    elif [ ! -d "$2" ]; then
        echo "$2 is not a directory"
    else
        echo "$2 contains:"
        countFiles "$2"
    fi
elif [ "$1" = "clean" -a "$2" = "" ]; then
    clean_files "."
elif [ "$1" = "clean" -a "$2" != "" ]; then
    if [ ! -e "$2" ]; then
        echo "$2 is not found"
    elif [ ! -d "$2" ]; then
        echo "$2 is not a directory"
    else
        clean_files $2
    fi
else
    echo "Type $0 help to see available options"
fi
