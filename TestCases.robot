*** Settings ***
Documentation   Robot Framework Demo with Google Maps
Library         SeleniumLibrary
Library         String
Library         HelpLib.py
Library         Collections    
Suite Setup     Nyissa meg a Chrome böngészőt
Suite Teardown  Zárja be a böngészőt

*** Test Cases ***

TC3 - Autós útvonal keresés Szováta és Kolozsvár között
    Meg van nyitva a Google Térkép
    Az útvonal keresésénél vagyok
    Útvonalat keresek Szováta és Kolozsvár között
    Autós útvonalat keresek
    Útvonalak hosszai 140 és 190 km köztiek

TC4 - Gyalogos útvonal keresés Kolozsvár és Marosvásárhely között
    Meg van nyitva a Google Térkép
    Az útvonal keresésénél vagyok
    Útvonalat keresek Kolozsvár és Marosvásárhely között
    Gyalogos útvonalat keresek
    Útvonalak időtartamai 19 óra 5 perc és 20 óra 5 perc köztiek

TC5 - Élelmiszerboltok keresése értékelés alapján
    Meg van nyitva a Google Térkép
    Élelmiszerboltot keresek
    Szűrés 4.0 értékeléssel

*** Variables ***
${útvonal gomb}     //*[@id="hArJGc"]
${kiindulási pont mező}     //input[@placeholder="Válassza ki a kiindulási pontot, vagy kattintson a térképre…" or @aria-label="Kiindulópont Az Ön tartózkodási helye"]
${úticél mező}     //input[@placeholder="Válasszon úti célt, vagy kattintson a térképre…"]

${autó opció gomb}  //img[@data-tooltip="Autó"]
${gyalogos opció gomb}  //img[@data-tooltip="Gyalog"]
@{talált útvonalak}     //*[@id="section-directions-trip-0"]    //*[@id="section-directions-trip-1"]    //*[@id="section-directions-trip-2"]

${útvonal gyalogos ideje}    /div[1]/div[3]/div[1]/div[1]
${útvonal autós ideje}    /div[1]/div[1]/div[1]/div[1]/span
${útvonal gyalogos hossza}    /div[1]/div[3]/div[1]/div[2]
${útvonal autós hossza}    /div[1]/div[1]/div[1]/div[2]/div

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

Autós útvonalat keresek
    Wait Until Element Is Visible   ${autó opció gomb}
    Click Element   ${autó opció gomb}

Gyalogos útvonalat keresek
    Wait Until Element Is Visible   ${gyalogos opció gomb}
    Click Element   ${gyalogos opció gomb}

Útvonal hossza
    [Arguments]  ${útvonal}     ${autós}
    IF  ${autós}
        ${elem útvonal}=    Set Variable    ${útvonal}${útvonal autós hossza}
    ELSE
        ${elem útvonal}=    Set Variable    ${útvonal}${útvonal gyalogos hossza}
    END
    Wait Until Element Is Visible   ${elem útvonal}
    ${elem}        Get Webelement   ${elem útvonal}
    ${tartalom}    Get Text    ${elem}
    ${távolság}		Get Regexp Matches      ${tartalom}  	(\\d+) km   1
    ${távolság}     Convert To Integer      ${távolság}[0]
    [Return]     ${távolság}

Útvonal időtartama
    [Arguments]  ${útvonal}     ${autós}
    IF  ${autós}
        ${elem útvonal}=    Set Variable    ${útvonal}${útvonal autós ideje}
    ELSE
        ${elem útvonal}=    Set Variable    ${útvonal}${útvonal gyalogos ideje}
    END
    Wait Until Element Is Visible   ${elem útvonal}
    ${elem}        Get Webelement   ${elem útvonal}
    ${tartalom}    Get Text    ${elem}
    ${idő}		Get Regexp Matches      ${tartalom}  	(?:(\\d+) óra)? (\\d+) perc     1   2
    ${óra}     Convert To Integer      ${idő}[0][0]
    ${perc}     Convert To Integer      ${idő}[0][1]
    [Return]     ${óra}     ${perc}

Útvonalak hosszai ${min} és ${max} km köztiek 
    FOR   ${div}   IN    @{talált útvonalak}
        Wait Until Element Is Visible   ${div}
        ${távolság}     Útvonal hossza  ${div}  ${True}

        Should Be True  ${távolság} >= ${min}
        Should Be True  ${távolság} <= ${max}

    END

Útvonalak időtartamai ${min óra} óra ${min perc} perc és ${max óra} óra ${max perc} perc köztiek
    FOR   ${div}   IN    @{talált útvonalak}
        Wait Until Element Is Visible   ${div}
        ${óra}     ${perc}  Útvonal időtartama  ${div}  ${False}

        Should Be True  ${óra} > ${min óra} or (${óra} == ${min óra} and ${perc} > ${min perc})
        Should Be True  ${óra} < ${max óra} or (${óra} == ${max óra} and ${perc} < ${max perc})
    END

Web elem ${cimke} cimkével
    Wait Until Element Is Visible   //*[@aria-label=${cimke}]   10s
    ${web elem}     Get Webelement      //*[@aria-label=${cimke}]
    [Return]    ${web elem}

Élelmiszerboltot keresek
    ${élelmiszerboltok gomb}     Web elem "Élelmiszerboltok" cimkével
    Click Element       ${élelmiszerboltok gomb}

Szűrés ${pontszám} értékeléssel
    ${értékelés gomb}      Web elem "Szűrés Értékelés szerint" cimkével
    Click Element       ${értékelés gomb}
    ${értékelés lista elem}     Web elem " ${pontszám} csillag " cimkével
    Press Keys       ${értékelés lista elem}    RETURN
    Sleep      5s