*** Settings ***
Library    SeleniumLibrary
Library    String
Library    DateTime
Library    FakerLibrary
Library    Collections
Library    OperatingSystem
Resource    common_keyword.resource


*** Keywords ***
Generate email and password
    ${current_date}=    Get Current Date    result_format=%Y%m%d%H%M%S
    ${email}=    Set Variable    t${current_date}@gmail.com
    ${password}=    Generate Random String    10
    RETURN    ${email}    ${password}

Register new registered user
    GROUP    Click Signup button
        Wait Until Element Is Visible And Click Element    id=signup
        Wait Until Element Is Visible    xpath=//h1[text()="Add User"]
        Wait Until Element Is Visible    xpath=//p[text()="Sign up to begin adding your contacts!"]
    END
    GROUP    Register with generated email and password
        ${email}    ${password}=    Generate email and password
        ${first_name}=    First Name
        ${last_name}=    Last Name
        Wait Until Text Area Is Visible And Input Text    id=firstName    ${first_name}
        Wait Until Text Area Is Visible And Input Text    id=lastName    ${last_name}
        Wait Until Text Area Is Visible And Input Text    id=email    ${email}
        Wait Until Text Area Is Visible And Input Text    id=password    ${password}
        Click Element    xpath=//button[text()="Submit" and @form="add-user"]
        Log To Console    \nfirstName-lastName: ${first_name} ${last_name}\nEmail: ${email}\nPassword: ${password}
        Log    firstName-lastName: ${first_name} ${last_name}\nEmail: ${email}\nPassword: ${password}
    END
    GROUP    Log out and return registerd email and password
        Wait Until Element Is Visible And Click Element    xpath=//button[@class="logout" and text()="Logout"]
        RETURN    ${email}    ${password}
    END
    
Register and log in with new registered user
    ${email}    ${password}=    Register new registered user
    Wait Until Text Area Is Visible And Input Text    id=email    ${email}
    Wait Until Text Area Is Visible And Input Text    id=password    ${password}
    Click Button    id=submit

Add contacts
    [Arguments]    ${contact_number}
    FOR    ${i}    IN RANGE    ${contact_number}
        GROUP    Prepare registration data
            ${first_name}=    First Name
            ${last_name}=    Last Name
            ${date_of_birth}=    Date Of Birth
            ${email}=    Email    domain=gmail.com
            ${phone_number_last_8_digits}=    Generate Random String    length=8    chars=[NUMBERS]
            ${phone_number}=    Set Variable    09${phone_number_last_8_digits}
            ${address_1}=    Street Address
            ${address_2}=    Street Address
            ${city}=    City
            ${state_or_province}=    State
            ${postal_code}=    Postalcode
            ${country}=    Current Country
        END
        GROUP    Input data
            Wait Until Element Is Visible And Click Element    id=add-contact
            Input Text    id=firstName        ${first_name}
            Input Text    id=lastName         ${last_name}
            Input Text    id=birthdate        ${date_of_birth}
            Input Text    id=email            ${email}
            Input Text    id=phone            ${phone_number}
            Input Text    id=street1          ${address_1}
            Input Text    id=street2          ${address_2}
            Input Text    id=city             ${city}
            Input Text    id=stateProvince    ${state_or_province}   
            Input Text    id=postalCode       ${postal_code}
            Input Text    id=country          ${country}
            Click Button    id=submit
            Wait Until Element Is Visible    xpath=//h1[text()="Contact List"]
            Wait Until Element Is Visible    id=myTable
        END
    END

Export contacts as JSON
    ${index}=    Set Variable    ${0}
    ${contact_list}=    Create List
    WHILE    ${True}
        ${index}=    Evaluate    ${index}+1
        ${contact_remain}=    Run Keyword And Return Status    Get WebElement    xpath=(//tr[@class="contactTableBodyRow"])[${index}]
        Exit For Loop If    ${contact_remain} == ${False}
        ${name}=    Get Text    xpath=(//tr[@class="contactTableBodyRow"])[${index}]/td[2]
        ${birthdate}=    Get Text    xpath=(//tr[@class="contactTableBodyRow"])[${index}]/td[3]
        ${email}=    Get Text    xpath=(//tr[@class="contactTableBodyRow"])[${index}]/td[4]
        ${phone}=    Get Text    xpath=(//tr[@class="contactTableBodyRow"])[${index}]/td[5]
        ${address}=    Get Text    xpath=(//tr[@class="contactTableBodyRow"])[${index}]/td[6]
        ${city_state_postalCode}=    Get Text    xpath=(//tr[@class="contactTableBodyRow"])[${index}]/td[7]
        ${Country}=    Get Text    xpath=(//tr[@class="contactTableBodyRow"])[${index}]/td[8]

        ${data_dict}=    Create Dictionary    
        ...    name=${name}
        ...    birthdate=${birthdate}
        ...    email=${email}
        ...    phoneNumber=${phone}
        ...    address=${address}
        ...    cityStatePostalCode=${city_state_postalCode}
        ...    country=${Country}
        ${contact_json}=    Create Dictionary    contact${index}=${data_dict}
        Append To List    ${contact_list}    ${contact_json}
    END
    Log    ${contact_list}
    ${dump_json}=    Evaluate    json.dumps(${contact_list}, indent=4, ensure_ascii=False)    json
    Create File    ui-automation/robot-framework-ui/Result/contacts.json    ${dump_json}

Delete all contacts
    WHILE    ${True}
        Wait Until Element Is Visible    //table[@class="contactTable"]
        ${contain_contact}=    Run Keyword And Return Status    Get WebElement    id=myTable
        Exit For Loop If    ${contain_contact} == ${False}
        Wait Until Element Is Visible And Click Element    xpath=(//tr[@class="contactTableBodyRow"])[1]
        Wait Until Element Is Visible And Click Element    id=delete
        Handle Alert    action=ACCEPT    timeout=10s
    END

Log out
    Wait Until Element Is Visible And Click Element    id=logout
    Log To Console    Log out successfully