#!/bin/bash
#
# Check empty file and download those file from S3 bucket

#Globals start from here
BUCKETNAME=""
BUCKETPATH=""

readonly dashLine="======================================================"


#######################################
# Download file from S3 bucket
# Globals:
#   bucketName
#   bucketPath
# Arguments:
#   fileName
# Outputs:
#   Download file from S3 and replace with original name
#######################################
function retrive_file (){
    local fileName=$1
    fullBucketPath="s3://${BUCKETNAME}/${BUCKETPATH}"
    aws s3 cp ${fullBucketPath}/${fileName} ${fileName}
}

#######################################
# Check file status
# Globals:
#   None
# Arguments:
#   None
#######################################
function check_file_status ()  {
    listFiles=($(ls))
    numberOfFile=${#listFiles[@]}
    for ((i = 0 ; i < ${numberOfFile} ; i++)); do
        # echo ${listFiles[$i]}
        if [ ! -s ${listFiles[$i]} ]
        then
            retrive_file ${listFiles[$i]}
        fi
    done
}

#######################################
# Check the existance of S3 bucket
# Globals:
#   bucketName
# Arguments:
#   None
# Outputs:
#   Existance of S3 bucket
#######################################
function check_bucket_existance () {
    listOfBucket=$(aws s3 ls | awk '{print $3}')
    numberOfBucket=${#listOfBucket[@]}
    i=0
    while [ $i -lt $numberOfBucket ]; do
        if [ $BUCKETNAME = ${listOfBucket[$i]} ] 
        then
            echo "bucket is exist"
            echo "${dashLine}"
        else
            echo "bucket is not exist"
            echo "${dashLine}"
            exit 1
        fi
        ((i++))
    done
}

#######################################
# Get the bucket name from user
# Globals:
#   bucketName
#   bucketPath
# Arguments:
#   None
#######################################
function get_bucket_name () {
    while [ -z "${BUCKETNAME}" ]
    do
        echo "Enter the name of S3 bucket"
        read BUCKETNAME
    done
    check_bucket_existance
    while [ -z "${BUCKETPATH}" ]
    do
        echo "Enter the path of S3 bucket without / in last"
        read BUCKETPATH
    done
}

#######################################
# Execution start from here
#######################################
function main (){
    echo "This script will check files only in current directory"
    echo ${dashLine}
    get_bucket_name
    check_file_status
}

main
