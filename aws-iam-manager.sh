#!/bin/bash
# Creator : Obieshenk
# Topic :AWS IAM User Management Script
# Description: This script creates IAM users, creates an admin group, attaches admin policy,
# and assigns users to the admin group using AWS CLI commands.
# Prerequisites:
# - AWS CLI installed and configured with appropriate permissions
# - IAM permissions to create users, groups, and attach policies

# Define IAM user names array - stores names of 5 IAM users
IAM_USER_NAMES=("chigozie" "obieshenk" "chidera" "chukwudi" "chukwuemeka")

# Define the AWS managed policy ARN for administrative access
ADMIN_POLICY_ARN="arn:aws:iam::aws:policy/AdministratorAccess"

# Function to print colored output for better readability
print_status() {
    local status=$1
    local message=$2
    case $status in
        "INFO")
            echo -e "\033[34m[INFO]\033[0m $message"
            ;;
        "SUCCESS")
            echo -e "\033[32m[SUCCESS]\033[0m $message"
            ;;
        "ERROR")
            echo -e "\033[31m[ERROR]\033[0m $message"
            ;;
        "WARNING")
            echo -e "\033[33m[WARNING]\033[0m $message"
            ;;
    esac
}

# Function to check if AWS CLI is installed and configured
check_aws_cli() {
    print_status "INFO" "Checking AWS CLI installation and configuration..."
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_status "ERROR" "AWS CLI is not installed. Please install AWS CLI first."
        exit 1
    fi
    
    # Check if AWS CLI is configured
    if ! aws sts get-caller-identity &> /dev/null; then
        print_status "ERROR" "AWS CLI is not configured or credentials are invalid."
        print_status "INFO" "Please run 'aws configure' to set up your credentials."
        exit 1
    fi
    
    print_status "SUCCESS" "AWS CLI is properly installed and configured."
}

# =============================================================================
# CORE FUNCTIONS
# =============================================================================

# Function to create IAM users
create_iam_users() {
    print_status "INFO" "Starting IAM user creation process..."
    
    # Iterate through the IAM users array
    for user in "${IAM_USER_NAMES[@]}"; do
        print_status "INFO" "Creating IAM user: $user"
        
        # Check if user already exists
        if aws iam get-user --user-name "$user" &> /dev/null; then
            print_status "WARNING" "User $user already exists. Skipping creation."
            continue
        fi
        
        # Create the IAM user using AWS CLI
        if aws iam create-user --user-name "$user" --path "/" > /dev/null 2>&1; then
            print_status "SUCCESS" "Successfully created IAM user: $user"
        else
            print_status "ERROR" "Failed to create IAM user: $user"
            return 1
        fi
    done
    
    print_status "SUCCESS" "IAM user creation process completed."
    return 0
}

# Function to create admin user group
create_admin_group() {
    print_status "INFO" "Creating admin group: $ADMIN_GROUP"
    
    # Check if group already exists
    if aws iam get-group --group-name "$ADMIN_GROUP" &> /dev/null; then
        print_status "WARNING" "Group $ADMIN_GROUP already exists. Skipping creation."
        return 0
    fi
    
    # Create the admin group using AWS CLI
    if aws iam create-group --group-name "$ADMIN_GROUP" --path "/" > /dev/null 2>&1; then
        print_status "SUCCESS" "Successfully created admin group: $ADMIN_GROUP"
        
        # Attach the AdministratorAccess policy to the admin group
        print_status "INFO" "Attaching AdministratorAccess policy to $ADMIN_GROUP group..."
        
        if aws iam attach-group-policy --group-name "$ADMIN_GROUP" --policy-arn "$ADMIN_POLICY_ARN" > /dev/null 2>&1; then
            print_status "SUCCESS" "Successfully attached AdministratorAccess policy to $ADMIN_GROUP group"
            return 0
        else
            print_status "ERROR" "Failed to attach AdministratorAccess policy to $ADMIN_GROUP group"
            return 1
        fi
    else
        print_status "ERROR" "Failed to create admin group: $ADMIN_GROUP"
        return 1
    fi
}

# Function to add users to admin group
add_users_to_admin_group() {
    print_status "INFO" "Adding users to admin group: $ADMIN_GROUP"
    
    # Iterate through the IAM users array and add each user to the admin group
    for user in "${IAM_USER_NAMES[@]}"; do
        print_status "INFO" "Adding user $user to $ADMIN_GROUP group..."
        
        # Check if user is already in the group
        if aws iam get-groups-for-user --user-name "$user" | grep -q "$ADMIN_GROUP" 2>/dev/null; then
            print_status "WARNING" "User $user is already in $ADMIN_GROUP group. Skipping."
            continue
        fi
        
        # Add user to the admin group using AWS CLI
        if aws iam add-user-to-group --group-name "$ADMIN_GROUP" --user-name "$user" > /dev/null 2>&1; then
            print_status "SUCCESS" "Successfully added $user to $ADMIN_GROUP group"
        else
            print_status "ERROR" "Failed to add $user to $ADMIN_GROUP group"
        fi
    done
    
    print_status "SUCCESS" "User assignment to admin group completed."
}

# Function to display summary of created resources
display_summary() {
    print_status "INFO" "=== SUMMARY OF CREATED RESOURCES ==="
    
    echo ""
    print_status "INFO" "Created IAM Users:"
    for user in "${IAM_USER_NAMES[@]}"; do
        if aws iam get-user --user-name "$user" &> /dev/null; then
            echo "  ✓ $user"
        else
            echo "  ✗ $user (creation failed)"
        fi
    done
    
    echo ""
    print_status "INFO" "Admin Group Status:"
    if aws iam get-group --group-name "$ADMIN_GROUP" &> /dev/null; then
        echo "  ✓ Group: $ADMIN_GROUP (created)"
        echo "  ✓ Policy: AdministratorAccess (attached)"
    else
        echo "  ✗ Group: $ADMIN_GROUP (creation failed)"
    fi
    
    echo ""
    print_status "INFO" "Group Membership:"
    for user in "${IAM_USER_NAMES[@]}"; do
        if aws iam get-groups-for-user --user-name "$user" 2>/dev/null | grep -q "$ADMIN_GROUP"; then
            echo "  ✓ $user → $ADMIN_GROUP"
        else
            echo "  ✗ $user → $ADMIN_GROUP (assignment failed)"
        fi
    done
    echo ""
}

# =============================================================================
# MAIN EXECUTION FUNCTION
# =============================================================================

main() {
    print_status "INFO" "=== AWS IAM User Management Script Started ==="
    print_status "INFO" "This script will create 5 IAM users and assign them to an admin group"
    echo ""
    
    # Step 1: Check AWS CLI prerequisites
    check_aws_cli
    echo ""
    
    # Step 2: Create IAM users
    if ! create_iam_users; then
        print_status "ERROR" "IAM user creation failed. Exiting."
        exit 1
    fi
    echo ""
    
    # Step 3: Create admin group and attach policy
    if ! create_admin_group; then
        print_status "ERROR" "Admin group creation failed. Exiting."
        exit 1
    fi
    echo ""
    
    # Step 4: Add users to admin group
    add_users_to_admin_group
    echo ""
    
    # Step 5: Display summary
    display_summary
    
    print_status "SUCCESS" "=== AWS IAM User Management Script Completed Successfully ==="
}

# =============================================================================
# SCRIPT EXECUTION
# =============================================================================

# Execute main function only if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi