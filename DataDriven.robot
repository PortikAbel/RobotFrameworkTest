*** Settings ***
Documentation   Data Driven Robot Framework Demo with Google Maps
Library         SeleniumLibrary
Library         String
Library         HelpLib.py   
Suite Setup     Nyissa meg a Chrome böngészőt
Suite Teardown  Zárja be a böngészőt

Test Template   Útvonal keresés nem kell találatot adjon

*** Test Cases ***      Honnan      Hova

Útvonal Antarktiszra    Kolozsvár   Antarktisz
Útvonal Antarktiszról   Antarktisz  Szováta
Útvonal ugyanoda        Kolozsvár   Kolozsvár

*** Variables ***
${útvonal gomb}     //*[@id="hArJGc"]
${kiindulási pont mező}     //input[@placeholder="Válassza ki a kiindulási pontot, vagy kattintson a térképre…" or @aria-label="Kiindulópont Az Ön tartózkodási helye"]
${úticél mező}     //input[@placeholder="Válasszon úti célt, vagy kattintson a térképre…"]

*** Keywords ***

Nyissa meg a Chrome böngészőt
    #Open Webdriver hosted on Azure Devops
    ${chromedriver_path}    get chromedriver path
    ${chrome_options} =    Evaluate    selenium.webdriver.ChromeOptions()
    Call Method    ${chrome_options}    add_argument    --start-maximized
    Call Method    ${chrome_options}    add_argument    --lang\=hu
    Call Method    ${chrome_options}    add_argument    --disable-geolocation
    Create Webdriver    Chrome    executable_path=${chromedriver_path}      chrome_options=${chrome_options}
    

Zárja be a böngészőt
    Close Browser

Meg van nyitva a Google Térkép
    Go To    https://www.google.com/maps/

Az útvonal keresésénél vagyok
    Wait Until Element Is Visible   ${útvonal gomb}
    Click Button    ${útvonal gomb}

Útvonalat keresek ${indulás} és ${cél} között
    Wait Until Element Is Visible   ${kiindulási pont mező}
    Input Text      ${kiindulási pont mező}     ${indulás}
    Input Text      ${úticél mező}              ${cél}
    Press Keys      None                        RETURN

Ezt kell lássam:
    [Arguments]     ${üzenet}
    Wait Until Page Contains    ${üzenet}

Útvonal keresés nem kell találatot adjon
    [Arguments]     ${honnan}   ${hova}
    Meg van nyitva a Google Térkép
    Az útvonal keresésénél vagyok
    Útvonalat keresek ${honnan} és ${hova} között
    Ezt kell lássam:   Sajnáljuk, nem
