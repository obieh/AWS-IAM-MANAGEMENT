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
