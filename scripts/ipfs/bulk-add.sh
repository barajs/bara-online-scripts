#!/bin/bash

#
# IPFS Bulk Add via Docker Command
# Usage: curl https://scripts.barajs.dev/ipfs/bulk-add.sh | bash -s -- <information_directory> <container_root_related_to_directory>
# Example: curl https://scripts.barajs.dev/ipfs/bulk-add.sh | bash -s -- /home/user/information/some_dir /container/encrypted/some_dir
#

export info_dir_path=$1
export root_container_path=$2
declare add_num=12

declare arr_encrypt_path=()
declare arr_thumbnail_path=()

if [ -z "info_dir_path" ]; then
    echo "Please provide host \"information\" meta directory!" && exit 1;
fi;

if [ -z "$root_container_path" ]; then
    echo "Please provide root container path as 2nd parameter!" && exit 1;
fi;

parallel_add() {
    echo ""
    real_path=$1
    truncate_path=$(echo "$real_path" | sed 's/encrypted/information/g' | sed "s@$info_dir_path@@")
    container_path=$(readlink -m $(echo $root_container_path/$truncate_path | sed 's/\/\//\//g'))
    echo "Adding to ipfs at $container_path"
    docker exec vgm-ipfs.web.1 ipfs add -rQp $container_path
}
export -f parallel_add

add_encrypted() {
    _counter_add=0
    echo ""
    echo "================================================="
    echo "|| WALKING... in '$info_dir_path' ||"
    echo "================================================="
    echo ""

    for f in $(find $info_dir_path -name 'media.vgmhi' -type f);
    do
	echo "$"
        _counter_add=`expr $_counter_add + 1`
        temp_path=${f/%media.vgmhi/}
        new_path=${temp_path/information/encrypted}
        path=${new_path/#warehouse/data}
        echo "$_counter_add- $path"

        arr_encrypt_path+=($path)
    done
    echo ""

    add_arr_encrypt
}

add_arr_encrypt() {
    _arr_length=${#arr_encrypt_path[@]}
    _counter_added=0

    echo ""
    echo "-----------------------------------"
    echo "|| ADDING... $_arr_length items to IPFS! ||"
    echo "-----------------------------------"
    echo ""

    declare _pos=-1
    for i in $(seq 0 $add_num $_arr_length);
    do
        echo ""
        echo "Prepare add $add_num items!"
        
        _arg_path=""
        _counter=0
        _add_items=`expr $add_num - 1`
        for j in $(seq 0 $_add_items);
        do
            _counter=`expr $j + 1`
            _pos=`expr $_pos + 1`
            echo "$_counter- ${arr_encrypt_path[$_pos]}"

            _arg_path+=${arr_encrypt_path[$_pos]}
            _arg_path+=" "
        done

        echo ""
        echo "Parallel adding... $info_dir_path"
        parallel --tagstring '\033[30;3{=$_=++$::color%8=}m' parallel_add ::: $_arg_path
        echo ""

        _counter_added=`expr $_counter_added + $add_num`
        echo ""
        echo "Added $_counter_added/$_arr_length"
        echo "-------------------------------------------------"
        echo ""
    done
}

add_thumbnails() {
    echo ""
    echo "================================================="
    echo "|| WALKING... in '$info_dir_path' ||"
    echo "================================================="
    echo ""

    for f in $(find $info_dir_path -name 'media.vgmhi' -type f);
    do
        temp_path=${f/%media.vgmhi/}
        new_path=${temp_path/information/thumbnails}
        path=${new_path/#warehouse/data}
        echo "$path"

        arr_thumbnail_path+=($path)
    done
    echo ""

    add_arr_thumbnails
}

add_arr_thumbnails() {
    _arr_length=${#arr_thumbnail_path[@]}
    _counter_added=0

    echo ""
    echo "----------------------------------------"
    echo "|| ADDING... $_arr_length thumbnails to IPFS! ||"
    echo "----------------------------------------"
    echo ""

    declare _pos=-1
    for i in $(seq 0 $add_num $_arr_length);
    do
        echo ""
        echo "Prepare add $add_num items!"
        
        _arg_path=""
        _counter=0
        _add_items=`expr $add_num - 1`
        for j in $(seq 0 $_add_items);
        do
            _counter=`expr $j + 1`
            _pos=`expr $_pos + 1`
            echo "$_counter- ${arr_thumbnail_path[$_pos]}"

            _arg_path+=${arr_thumbnail_path[$_pos]}
            _arg_path+=" "
        done

        echo ""
        echo "Parallel adding... $info_dir_path "
        parallel --tagstring '\033[30;3{=$_=++$::color%8=}m' parallel_add ::: $_arg_path
        echo ""

        _counter_added=`expr $_counter_added + $add_num`
        echo ""
        echo "Added $_counter_added/$_arr_length"
        echo "-------------------------------------------------"
        echo ""
    done
}

add_api() {
    echo ""
    echo "========================================"
    echo "|| ADDING... api at '/vgm-data/api' ||"
    echo "========================================"
    echo ""

    docker exec vgm-ipfs.web.1 ipfs add -rQp '/vgm-data/api'
    echo ""
}

add_information() {
    echo ""
    echo "========================================================"
    echo "|| ADDING... information at '/vgm-data/information' ||"
    echo "========================================================"
    echo ""

    docker exec vgm-ipfs.web.1 ipfs add -rQp '/vgm-data/information'
    echo ""
}

main() {
    add_encrypted
    #add_thumbnails
    #add_api
    #add_information
}

main
