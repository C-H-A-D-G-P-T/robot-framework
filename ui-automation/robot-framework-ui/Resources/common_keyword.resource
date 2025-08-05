*** Settings ***
Library    SeleniumLibrary


*** Keywords ***
Wait Until Element Is Visible And Click Element
    [Arguments]    ${locator}
    Wait Until Element Is Visible    ${locator}    30s
    Click Element    ${locator}

Wait Until Text Area Is Visible And Input Text
    [Arguments]    ${locator}    ${text}
    Wait Until Element Is Visible    ${locator}    30s
    Input Text    ${locator}    ${text}
    
Navigate to thinking-tester-contact-list
    Open Browser    url=https://thinking-tester-contact-list.herokuapp.com/    browser=edge
    Wait Until Element Is Visible    xpath=//div[@class="welcome-message"]