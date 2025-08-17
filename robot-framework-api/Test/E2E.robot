*** Settings ***
Resource    ../Resources/function_keywords.resource
Suite Setup    Evaluate    urllib3.disable_warnings()    urllib3


*** Test Cases ***
Verify that a user can successfully register, log in, add 10 contacts, export contacts as JSON, delete all contacts, and log out
    ${registered_bearer_token}    
    ...    ${first_name}    
    ...    ${last_name}    
    ...    ${email}    
    ...    ${password}=    Register New User
    ${bearer_token}=    Log in with new registered user
    Add contacts    bearer_token=${bearer_token}    contact_number=1
    Export contacts as JSON    bearer_token=${bearer_token}
    # Delete all contacts (Service Unavailable)
    Log out    bearer_token=${bearer_token}
    Delete user    bearer_token=${registered_bearer_token}