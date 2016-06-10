#!/bin/bash
# 2016-06-06 Chris Hales chris@drupalvoodoo.com

## Creation of AWS EC2 instance using docker-machine

# You must have docker-machine (https://docs.docker.com/machine)
# and AWS cli (http://docs.aws.amazon.com/cli) installed and configured.


## Setup default variables
debug= # Set to non-empty to enable debugging.

# AWS credentials
# (can be omitted if you are using your own AWS cli with creds)
aws_access_key=
aws_secret_key=

# AWS location vars
aws_region='us-east-1' # Region to deploy into
aws_vpc_id='' # VPC to deploy into
aws_zone='a' # Zone a,b,c,d
aws_subnet='' # Subnet to use
aws_security_group='' # The name (not ID) of your security group, only 1 can be specified

# AWS instance vars
#aws_ami_id='ami-7205ee1f' # Omit to use the default daily Ubuntu 15.10 AMI.
aws_instance_type='t2.micro' # Instance size
aws_volume_size='8' # Root drive size in GB, default is 16
aws_ssh_user='' # Login user for the AMI, e.g. ubuntu or ec2-user. ubuntu is default

# Path to a preferred ssh private key that will be copied into
# the machine config. If not provided a key will be created.
# Warning: The key must already be "unlocked" or passwordless to work!
#aws_ssh_key='~/.ssh/id_rsa'

# AWS IAM role for the instance if applicable
aws_iam_role='myRole'

# Tags # To Do - work in a tags array, Issues with spaces
tag_owner=''
tag_purpose=''

# Prefix for the randomly generated instance name
name_prefix='my'

# Random name source
name_source='http://frightanic.com/goodies_content/docker-names.php'

#########################################################################################

# Colors
color_0=$'\e[0m'    # No Color
color_1=$'\e[1;31m' # Red
color_2=$'\e[1;32m' # Green
color_3=$'\e[1;33m' # Yellow
color_4=$'\e[1;36m' # light cyan
# e.g. echo -e "${color_1}my text here${color_0}"

# Validate the instance name
function func_instance_name_request () {

  # Create the name
  default_name=$(_func_random_name)

  # Validate the name/ID if given.
  echo -e "${color_3}(Hit ENTER to use the default name '${default_name}')${color_0}"
  while read -r instance_name; do
    # if empty use the default name, default_name
    if [[ $instance_name == '' ]]; then
      echo -e "Running build script:"
      func_create_dm_ec2 "$default_name"
      break
    else
      # Validate the name/ID if given.
      if [[ ! $aws_name =~ ^[a-z0-9-]{3,60}$ ]]; then
        echo -e "${color_1}\nThe name must be a lowercase alphanumeric (and dashes) string!${color_0}"
        echo -e "${color_4}$1${color_0}"
        echo -e "${color_3}(Hit ENTER to use the default name '${default_name}')${color_0}"
      else
        echo -e "Running build script:"
        func_create_dm_ec2 "$aws_name"
        break
      fi
    fi
  done
}

##############################################################
# Function to create and instance

function func_create_dm_ec2 () {
  if [[ -z $1 ]]; then
    echo -e "You must supply a name!\n"
  else
    echo 'Starting build:' $(date +"%c")
    # Build the command options and run the creation
    OPTIONS=''
    if [[ ! -z $aws_access_key ]]; then
      OPTIONS="$OPTIONS --amazonec2-access-key ${aws_access_key}"
      OPTIONS="$OPTIONS --amazonec2-secret-key ${aws_secret_key}"
    fi

    OPTIONS="$OPTIONS --amazonec2-region ${aws_region}"
    OPTIONS="$OPTIONS --amazonec2-vpc-id ${aws_vpc_id}"
    OPTIONS="$OPTIONS --amazonec2-zone ${aws_zone}"
    OPTIONS="$OPTIONS --amazonec2-subnet-id ${aws_subnet}"
    OPTIONS="$OPTIONS --amazonec2-security-group ${aws_security_group}"
    OPTIONS="$OPTIONS --amazonec2-instance-type ${aws_instance_type}"
    OPTIONS="$OPTIONS --amazonec2-tags Owner,${tag_owner},Purpose,${tag_purpose}"

    if [[ ! -z $aws_ami_id ]]; then
      OPTIONS="$OPTIONS --amazonec2-ami ${aws_ami_id}"
    fi

    if [[ ! -z $aws_volume_size ]]; then
      OPTIONS="$OPTIONS --amazonec2-root-size ${aws_volume_size}"
    fi

    if [[ ! -z $aws_ssh_user ]]; then
      OPTIONS="$OPTIONS --amazonec2-ssh-user ${aws_ssh_user}"
    fi

    if [[ ! -z $aws_ssh_key ]]; then
      OPTIONS="$OPTIONS --amazonec2-ssh-keypath ${aws_ssh_key}"
    fi

    if [[ ! -z $aws_iam_role ]]; then
      OPTIONS="$OPTIONS --amazonec2-iam-instance-profile ${aws_iam_role}"
    fi

    # Debugging enabled?
    if [[ ! -z $debug ]]; then
      OPTIONS="$OPTIONS --debug"
      echo -e "${color_3}### DEBUG Enabled ###\nOptions: $OPTIONS \n### DEBUG ###\n${color_0}"
    fi

    # Run the creation
    docker-machine create -d amazonec2 --engine-insecure-registry localhost:5000 $OPTIONS $1 ;

    echo 'Build complete:' $(date +"%c")
  fi
}

# Helper to create a random instance name
function _func_random_name () {
  # Fetch and cleanup the name
  random_name=$(curl -s $name_source)
  local my_random_name=${name_prefix}-${random_name//_/-}-$((RANDOM%99))

  if [[ ! $my_random_name =~ ^[a-z0-9-]{10,50}$ ]]; then # Validate the name
    my_random_name='bad_auto_name_please_check'
  fi

  echo $my_random_name
}

# Run it!
func_instance_name_request
