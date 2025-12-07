// -- IMPORTS

import { buildDefText, getDumpText, haveSameValue, parseDefText } from 'senselogic-def';
import { parseDefFileText, readTextFile } from './index.js';

// -- VARIABLES

var
    testDataArray,
    testDataIndex = 0;

// -- FUNCTIONS

function parseText(
    defText,
    expectedValue
    )
{
    try
    {
        console.log( '================================' );
        console.log( 'defText:' );
        console.log( defText );

        console.log( 'expectedValue:' );
        console.log( getDumpText( expectedValue ) );

        let parsedValue =
            parseDefFileText(
                defText,
                {
                    filePath: '../../../../DATA/FILE/test.def'
                }
                );
        console.log( 'parsedValue:' );
        console.log( getDumpText( parsedValue ) );

        if ( !haveSameValue( parsedValue, expectedValue ) )
        {
            console.error( 'Invalid parsed value' );
            throw new Error( 'Invalid parsed value' );
        }

        let builtText = buildDefText( expectedValue );
        console.log( 'builtText:' );
        console.log( builtText );

        let reparsedValue = parseDefText( builtText );
        console.log( 'reparsedValue:' );
        console.log( getDumpText( reparsedValue ) );

        if ( !haveSameValue( reparsedValue, expectedValue ) )
        {
            console.error( 'Invalid parsed value' );
            throw new Error( 'Invalid parsed value' );
        }
    }
    catch ( error )
    {
        console.error( error );
        throw error;
    }
}

// ~~

function runTest(
    expectedValue
    )
{
    let defText = testDataArray[ testDataIndex ];
    parseText( defText, expectedValue );

    ++testDataIndex;
}

// -- STATEMENTS

testDataArray = readTextFile( '../../../../DATA/FILE/test.txt' ).split( '\n~~~\n' );

runTest(
    {
        "settings":
            {
                "theme": "dark",
                "fontSize": 16,
                "features":
                    [
                        "search",
                        "filter",
                        "sort"
                    ],
                "version": "2.0",
                "metrics":
                    {
                        "cpuUsage": 0.75,
                        "memoryUsage": 0.6,
                        "networkTraffic": 1234567890
                    },
                "logging": true
            },
        "plugins":
            [
                {
                    "name": "Analytics",
                    "status": "enabled"
                },
                {
                    "name": "SEO",
                    "status": "disabled"
                }
            ],
        "users":
            [
                {
                    "name": "John Doe",
                    "role": "administrator"
                },
                {
                    "name": "Jane Smith",
                    "role": "publisher"
                }
            ],
        "texts":
            {
                "home": "Home\n¨fr:Accueil\n¨de:Startseite\n¨ja:ホーム",
                "services": "Services\n¨fr:Services\n¨de:Dienstleistungen\n¨ja:サービス",
                "contact": "Contact\n¨fr:Contact\n¨de:Kontakt\n¨ja:連絡先"
            },
        "articles":
            [
                "Article 1",
                "Article 002",
                "Article 3",
                "Article 10",
                "Article 200"
            ]
    }
    );

runTest(
    "Included value"
    );

runTest(
    [
        "Included value",
        "Included value 2"
    ]
    );

runTest(
    [
        "Included value",
        "Included value 2"
    ]
    );

runTest(
    [
        "Included value",
        "Included value 2"
    ]
    );

runTest(
    [
        "Included value",
        "Included value 2",
        "Included value",
        "Included value 2",
        "Included value",
        "Included value 2"
    ]
    );

console.log( 'All tests passed!' );
