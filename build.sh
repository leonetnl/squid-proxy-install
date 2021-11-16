for file in *; 
do
    if [ "${file: -3}" == ".sh" ] && [ "${file}" != "build.sh" ]
    then
        echo "Compiling ${file}"
        shc -f $file
    fi
done