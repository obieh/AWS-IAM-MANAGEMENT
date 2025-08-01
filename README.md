# AWS-IAM-MANAGEMENT
This Project demonstrates how to automate AWS IAM management using shell script.

## Prerequisites
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
* AWS Acess Key ID
* AWS Secret Access Key
* Default region(e.g, us-east-1)
* Default output format (jason recommended)

![](./img/Pasted%20image%20(2).png)

### I had already configured AWS CLI earlier. If you are doing so for the first time you have to supply all the rquired information mention above.

3. verify AWS CLI configuration. Run `aws sts get-caller-identity`

![](./img/Pasted%20image.png)

### If you are using an IAM account(Account you configured on AWS-CLI). Be sure the account have these permissions

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

## Script Execution

* After creating the script. Run `chmod +x aws-iam-manager.sh`

![](./img/Pasted%20image%20(3).png)