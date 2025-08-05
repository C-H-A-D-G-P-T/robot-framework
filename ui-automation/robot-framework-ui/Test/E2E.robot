*** Settings ***
Resource    ../Resources/function_keywords.resource


*** Test Cases ***
Verify that a user can successfully register, log in, add 10 contacts, export contacts as JSON, delete all contacts, and log out
    Navigate to thinking-tester-contact-list
    Register and log in with new registered user
    Add contacts    contact_number=10
    Export contacts as JSON
    Delete all contacts
    Log out