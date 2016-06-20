*These scripts are provided AS IS without warranty of any kind!*

This is a simple bash helper script to quickly create [Docker Machine](https://docs.docker.com/machine/overview/) based EC2 instances.

You need an AWS IAM account with admin rights with permissions to create the needed resources (ec2, subnet, security group, etc.) and the IAM user keys (or [AWS cli](https://aws.amazon.com/cli/) configured) and docker-machine installed locally for this script to work.

Fill in the required variables and be sure to read the docker-machine documentation, specifically regarding the [AWS driver](https://docs.docker.com/machine/drivers/aws/).

The script provides the ability for a random default name but you can also specify your own name for the instance.

I'm working on OSX and while I'll try to keep it portable your milage may vary.

## What is it?
docker-machine does all the work. This scripts is a simple wrapper to help facilitate the repetitive creation of your machines into a VPC with your common defaults preselected.

You can leave the docker-machine defaults in place or easily override them in the scripts variables section.

The debugging option is easy to toggle but again docker-machine provides details on any error it encounters (though not always easy to understand).
