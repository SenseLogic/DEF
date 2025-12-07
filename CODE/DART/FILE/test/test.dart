import 'package:senselogic_def/senselogic_def.dart';
import 'package:senselogic_def_file/senselogic_def_file.dart';

// -- VARIABLES

List<String>?
    testDataArray;
int
    testDataIndex = 0;

// -- FUNCTIONS

void parseText(
    String defText,
    dynamic expectedValue
    )
{
    try
    {
        print( '================================' );
        print( 'defText:' );
        print( defText );

        print( 'expectedValue:' );
        print( getDumpText( expectedValue ) );

        var parsedValue =
            parseDefFileText(
                defText,
                filePath: '../../../DATA/FILE/test.def'
                );
        print( 'parsedValue:' );
        print( getDumpText( parsedValue ) );

        if ( !haveSameValue( parsedValue, expectedValue ) )
        {
            print( 'Invalid parsed value' );
            throw Exception( 'Invalid parsed value' );
        }

        var builtText = buildDefText( expectedValue );
        print( 'builtText:' );
        print( builtText );

        var reparsedValue = parseDefText( builtText );
        print( 'reparsedValue:' );
        print( getDumpText( reparsedValue ) );

        if ( !haveSameValue( reparsedValue, expectedValue ) )
        {
            print( 'Invalid parsed value' );
            throw Exception( 'Invalid parsed value' );
        }
    }
    catch ( error )
    {
        print( error );
        rethrow;
    }
}

// ~~

void runTest(
    dynamic expectedValue
    )
{
    var defText = testDataArray![ testDataIndex ];
    parseText( defText, expectedValue );

    ++testDataIndex;
}

// ~~

void main(
    )
{
    testDataArray = readTextFile( '../../../DATA/FILE/test.txt' ).split( '\n~~~\n' );

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

    print( 'All tests passed!' );
}
