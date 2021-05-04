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
# Check the existance of S3 bucket path
# Globals:
#   bucketName
#   bucketPath
# Arguments:
#   None
# Outputs:
#   Existance of S3 bucket path
#######################################
function check_bucket_path_existance () {
    local IFS='/ '
    listOfBucketPath=$(aws s3 ls s3://${BUCKETNAME}/${BUCKETPATH} | awk '{print $2}' |tr '\n' ' ')
    read -a listOfBucketPath <<< ${listOfBucketPath}
    numberOfBucketpath=${#listOfBucketPath[@]}
    if [ $numberOfBucketpath != 0 ]
    then
        i=0
        while [ $i -lt $numberOfBucketpath ]; do
        if [ $BUCKETPATH = ${listOfBucketPath[$i]} ] 
        then
            echo "bucketpath is exist"
            break
        else
            echo "bucketpath is not exist in bucket"
            exit 1
        fi
        ((i++))
    done
    else
        echo "bucketpath is not exist in bucket"
        exit 1
    fi
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
}

#######################################
# Get the bucket path from user
# Globals:
#   bucketPath
# Arguments:
#   None
#######################################
function get_bucket_path () {
    while [ -z "${BUCKETPATH}" ]
    do
        echo "Enter the path of S3 bucket without / in last"
        read BUCKETPATH
    done
    check_bucket_path_existance
}

#######################################
# Execution start from here
#######################################
function main (){
    echo "This script will check files only in current directory"
    echo ${dashLine}
    get_bucket_name
    get_bucket_path
    check_file_status
}

main
