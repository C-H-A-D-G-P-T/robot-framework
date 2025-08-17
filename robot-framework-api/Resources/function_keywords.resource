*** Settings ***
Library    RequestsLibrary
Library    DateTime
Library    String
Library    Collections
Library    OperatingSystem
Library    FakerLibrary    AS    faker
Variables    ../Resources/url.yaml


*** Keywords ***
Generate Email And Password
    ${current_date}=    Get Current Date    result_format=%Y%m%d%H%M%S
    ${email}=    Set Variable    t${current_date}@gmail.com
    ${password}=    Generate Random String    10
    RETURN    ${email}    ${password}

Register New User
    GROUP    Prepare Headers and JSON Body for Register API
        ${first_name}=    First Name
        ${last_name}=    Last Name
        ${email}    ${password}=    Generate Email And Password
        ${body}=    Create Dictionary
        ...    firstName=${first_name}
        ...    lastName=${last_name}
        ...    email=${email}
        ...    password=${password}

        ${headers}=    Create Dictionary    Content-Type=application/json
    END
    GROUP    Call Register API
        Create Session    Register    ${BASE_URL}
        ${response}=    POST On Session    alias=Register    url=${ADD_USER_URI}    headers=${headers}    json=${body}
    END
    GROUP    Response Validation
        Should Be Equal    ${response.json()}[user][firstName]    ${first_name}
        Should Be Equal    ${response.json()}[user][lastName]    ${last_name}
        Should Be Equal    ${response.json()}[user][email]    ${email}
        RETURN    ${response.json()}[token]    ${first_name}    ${last_name}    ${email}    ${password}
    END

Log in with new registered user
    GROUP    Prepare Headers and JSON Body for Register API
        ${registered_bearer_token}    ${first_name}    ${last_name}    ${email}    ${password}=    Register New User
        ${body}=    Create Dictionary
        ...    email=${email}
        ...    password=${password}

        ${headers}=    Create Dictionary    Content-Type=application/json
    END
    GROUP    Call Login API
        Create Session    Login    ${BASE_URL}
        ${response}=    POST On Session    alias=Login    url=${LOGIN_URI}    headers=${headers}    json=${body}
        Log To Console    Logged in with\nemail: ${email}\npassword: ${password}
    END
    GROUP    Response Validation
        Should Be Equal    ${response.json()}[user][firstName]    ${first_name}
        Should Be Equal    ${response.json()}[user][lastName]    ${last_name}
        Should Be Equal    ${response.json()}[user][email]    ${email}
        RETURN    ${response.json()}[token]
    END
    
Add contacts
    [Arguments]    ${bearer_token}    ${contact_number}
    FOR    ${i}    IN RANGE    ${contact_number}
        GROUP    Prepare Add Contacts Body And Headers
            ${first_name}=    First Name
            ${last_name}=    Last Name
            ${birthdate}=    faker.Date Of Birth
            ${birthdate}=    Convert To String    ${birthdate}
            ${email}=    Email    domain=gmail.com
            ${phone_last_8_digits}=    Generate Random String    length=8    chars=[NUMBERS]
            ${phone}=    Set Variable    09${phone_last_8_digits}
            ${street1}=    Street Address
            ${street2}=    Street Address
            ${city}=    City
            ${state_province}=    State
            ${postal_code}=    Postalcode
            ${country}=    Current Country

            ${body}=    Create Dictionary
            ...    firstName=${first_name}
            ...    lastName=${last_name}
            ...    birthdate=${birthdate}
            ...    email=${email}
            ...    phone=${phone}
            ...    city=${city}
            ...    street1=${street1}
            ...    street2=${street2}
            ...    stateProvince=${state_province}
            ...    postalCode=${postal_code}
            ...    country=${country}

            ${headers}=    Create Dictionary    Content-Type=application/json    Authorization=Bearer ${bearer_token}
        END
        GROUP    Call Add Contact API
            Create Session    Add Contact    ${BASE_URL}
            ${response}=    POST On Session    alias=Add Contact    url=${ADD_CONTACT}    headers=${headers}    json=${body}
            ${response_json}=    Evaluate    json.dumps(${response.json()}, indent=4)    json
            ${body}=    Evaluate    json.dumps(${body}, indent=4)    json
            Log    ${response_json}
            Log    ${body}
            ${i}=    Evaluate    ${i} + 1
            Log To Console    ${i}.${email} has been added.
        END
        GROUP    Response Validation
            Should Be Equal    ${response.json()}[firstName]    ${first_name}
            Should Be Equal    ${response.json()}[lastName]    ${last_name}
            Should Be Equal    ${response.json()}[birthdate]    ${birthdate}
            Should Be Equal    ${response.json()}[email]    ${email}
            Should Be Equal    ${response.json()}[phone]    ${phone}
            Should Be Equal    ${response.json()}[street1]    ${street1}
            Should Be Equal    ${response.json()}[street2]    ${street2}
            Should Be Equal    ${response.json()}[city]    ${city}
            Should Be Equal    ${response.json()}[stateProvince]    ${stateProvince}
            Should Be Equal    ${response.json()}[postalCode]    ${postalCode}
            Should Be Equal    ${response.json()}[country]    ${country}
        END
    END

Export contacts as JSON
    [Arguments]    ${bearer_token}
    GROUP    Prepare Get Contacts Body And Headers
        ${headers}=    Create Dictionary    Content-Type=application/json    Authorization=Bearer ${bearer_token}
    END
    GROUP    Call Get Contacts API
        Create Session    Get Contacts    ${BASE_URL}
        ${response}=    GET On Session    alias=Get Contacts    url=${GET_CONTACTS}    headers=${headers}
        ${response_json}=    Evaluate    json.dumps(${response.json()}, indent=4)    json
        Log    ${response_json}
    END
    GROUP    Create List Of Contacts And Create JSON File
        ${index}=    Set Variable    ${0}
        ${contact_list}=    Create List
        FOR    ${contact}    IN    @{response.json()}
            ${index}=    Evaluate    ${index}+1
            ${data_dict}=    Create Dictionary
            ...    name=${contact}[firstName] ${contact}[lastName]
            ...    birthdate=${contact}[birthdate]
            ...    email=${contact}[email]
            ...    phoneNumber=${contact}[phone]
            ...    address=${contact}[street1], ${contact}[street2], ${contact}[city], ${contact}[stateProvince]
            ...    cityStatePostalCode=${contact}[postalCode]
            ...    country=${contact}[country]
            ${contact_json}=    Create Dictionary    contact${index}=${data_dict}
            Append To List    ${contact_list}    ${contact_json}
        END
        Log    ${contact_list}
        ${dump_json}=    Evaluate    json.dumps(${contact_list}, indent=4, ensure_ascii=False)    json
        Create File    robot-framework-api/Result/contacts.json    ${dump_json}
    END

Log out
    [Arguments]    ${bearer_token}
    GROUP    Prepare Logout Headers
        ${headers}=    Create Dictionary    Content-Type=application/json    Authorization=Bearer ${bearer_token}
    END
    GROUP    Call Logout API
        Create Session    Logout    ${BASE_URL}
        ${response}=    POST On Session    alias=Logout    url=${LOGOUT_URI}    headers=${headers}
        Should Be Equal    ${response.status_code}    ${200}
    END

Delete user
    [Arguments]    ${bearer_token}
    GROUP    Prepare User Deletion Headers
        ${headers}=    Create Dictionary    Content-Type=application/json    Authorization=Bearer ${bearer_token}
    END
    GROUP    Call Get Contacts API
        Create Session    Get Contacts    ${BASE_URL}
        ${response}=    GET On Session    alias=Get Contacts    url=${DELETE_USER_URI}    headers=${headers}
        Should Be Equal    ${response.status_code}    ${200}
    END