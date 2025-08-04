# AWS-IAM-MANAGEMENT.
This Project demonstrates how to automate AWS IAM management using shell script.

## Prerequisites.
1. Install AWS CLI. Run the following depending on you OS platform.

```bash
# On macOS
brew install awscli

# On Ubuntu/Debian
sudo apt-get install awscli

# On Windows
# Download from: https://aws.amazon.com/cli/
```
2. Configure AWS CLI

```bash
aws configure
```
### You will have to provide:
* AWS Acess Key ID.
* AWS Secret Access Key.
* Default region(e.g, us-east-1).
* Default output format (jason recommended).

![](./img/Pasted%20image%20(2).png)

### I had already configured AWS CLI earlier. If you are doing so for the first time you have to supply all the rquired information mention above.

3. verify AWS CLI configuration. Run `aws sts get-caller-identity`

![](./img/Pasted%20image.png)

### If you are using an IAM account(Account you configured on AWS-CLI). Be sure the account have these permissions.

```jason
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateUser",
                "iam:GetUser",
                "iam:CreateGroup",
                "iam:GetGroup",
                "iam:AttachGroupPolicy",
                "iam:AddUserToGroup",
                "iam:GetGroupsForUser"
            ],
            "Resource": "*"
        }
    ]
}
```

## Script Execution.

* After creating the script. Run `chmod +x aws-iam-manager.sh`

![](./img/Pasted%20image%20(3).png)

* Run `./aws-iam-manager.sh` to execute the script.

![](./img/Pasted%20image%20(4).png)

* Scripting creating users.

![](./img/Pasted%20image%20(5).png)

![](./img/Pasted%20image%20(5).png)

![](./img/Pasted%20image%20(6).png)

![](./img/Pasted%20image%20(7).png)

![](./img/Pasted%20image%20(8).png)

* Script creating admin group.

![](./img/Pasted%20image%20(9).png)

* Script adding user to admin group.

![](./img/Pasted%20image%20(10).png)

### Head over to your AWS account to if the users were created.

![](./img/Pasted%20image%20(11).png)

### Click user group to see if 'admin' user-group was created.

![](./img/Pasted%20image%20(12).png)

### Finally, click the admin group to see if users have been added to the group.

![](./img/Pasted%20image%20(13).png)

## Verification, Command-line/Terminal.

* List all IAM users run `aws iam list-users`

![](./img/Pasted%20image%20(16).png)

* Check admin gruop detail run `aws iam get-group --group-name admin`

![](./img/Pasted%20image%20(17).png)

* Verify group policies, run `aws iam list-attached-group-policies --group-name admin`

![](./img/Pasted%20image%20(18).png)

* Check which users are in the admin group. run `aws iam get-group --group-name admin --query 'Users[].UserName'`

![](./img/Pasted%20image%20(19).png)

## Link to script below.

[Script file here](./aws-iam-manager.sh)

```bash
#!/bin/bash

# ============================
# IAM Admin Setup Script
# ============================
# Created by: Obieshenk
# Date: 31-07-2025
# This script:
# 1. Creates 5 IAM users
# 2. Creates an 'admin' IAM group
# 3. Attaches administrative policy to the group
# 4. Adds all users to the admin group

# -------------
# Define IAM users in an array
# -------------
IAM_USER_NAMES=("Chimezie" "Tombra" "Ayoniyi" "Obieshenk" "Abdul")

# -------------
# Function to create IAM users
# -------------
create_iam_users() {
echo "Starting IAM user creation process..."
  for user in "${IAM_USER_NAMES[@]}"
  do
    echo "Creating IAM user: $user"
    aws iam create-user --user-name "$user"
  done
}

# -------------
# Function to create the 'admin' IAM group
# -------------
create_admin_group() {
  echo "Creating IAM group: admin"
  aws iam create-group --group-name admin
}

# -------------
# Function to attach administrative policy to 'admin' group
# -------------
attach_admin_policy() {
  echo "Attaching 'AdministratorAccess' policy to 'admin' group"
  aws iam attach-group-policy --group-name admin --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
}

# -------------
# Function to add users to the 'admin' group
# -------------
add_users_to_admin_group() {
  for user in "${IAM_USER_NAMES[@]}"
  do
    echo "Adding $user to admin group"
    aws iam add-user-to-group --user-name "$user" --group-name admin
  done
}

# -------------
# Main Execution Function
# -------------
main() {
  create_iam_users
  create_admin_group
  attach_admin_policy
  add_users_to_admin_group
  echo "AWS IAM Management Completed."
}

# Run the main function
main

```