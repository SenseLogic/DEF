import 'dart:io';
import 'package:senselogic_def/senselogic_def.dart';

// -- VARIABLES

List<String>?
    testDataArray;
int
    testDataIndex = 0;

// -- FUNCTIONS

void runTest(
    dynamic expectedValue
    )
{
    var defText = testDataArray![ testDataIndex ];

    try
    {
        print( '================================' );
        print( 'defText:' );
        print( defText );

        print( 'expectedValue:' );
        print( getDumpText( expectedValue ) );

        var parsedValue =
            parseDefText(
                defText,
                filePath: '../../DATA/test.def',
                stringProcessingFunction: processDefQuotedString
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

    ++testDataIndex;
}

// ~~

void main(
    )
{
    testDataArray = readFileText( '../../DATA/test.txt' ).split( '\n~~~\n' );

    runTest(
        undefined
        );

    runTest(
        null
        );

    runTest(
        false
        );

    runTest(
        true
        );

    runTest(
        42
        );

    runTest(
        -123
        );

    runTest(
        3.14159
        );

    runTest(
        -1.23456e-7
        );

    runTest(
        0xFF
        );

    runTest(
        double.nan
        );

    runTest(
        double.negativeInfinity
        );

    runTest(
        double.infinity
        );

    runTest(
        {
            "actual-number": 42,
            "string-number": "42",
            "actual-float": 3.14159,
            "string-float": "3.14159",
            "actual-hex": 255,
            "string-hex": "0xFF"
        }
        );

    runTest(
        ""
        );

    runTest(
        ""
        );

    runTest(
        "["
        );

    runTest(
        "{"
        );

    runTest(
        "("
        );

    runTest(
        "¨"
        );

    runTest(
        "["
        );

    runTest(
        "{"
        );

    runTest(
        "("
        );

    runTest(
        "Simple string"
        );

    runTest(
        "String with \"quotes\" inside"
        );

    runTest(
        "String with `backticks` inside"
        );

    runTest(
        "String with ´ticks´ inside"
        );

    runTest(
        "String with backslash \\ inside"
        );

    runTest(
        "One trailing space "
        );

    runTest(
        "Multiple trailing spaces    "
        );

    runTest(
        "Multiple    trailing    spaces    "
        );

    runTest(
        "Multiple    trailing    \nspaces    ¨"
        );

    runTest(
        "    Multiple        trailing    \n    spaces    ¨"
        );

    runTest(
        [
            "    Multiple        trailing        spaces    ",
            "    Multiple        trailing    \n    spaces    ",
            "    Multiple        trailing    \n    spaces    ¨"
        ]
        );

    runTest(
        "Single line continued on next line"
        );

    runTest(
        "Line 1\nLine 2\nLine 3"
        );

    runTest(
        "Line 1\n\nLine 2\n\nLine 3"
        );

    runTest(
        "Line 1\n\n    Line 2\n\nLine 3"
        );

    runTest(
        [
            "Line 1        Line 2    Line 3",
            "Line 1    Line 2\n\nLine 3",
            "Line 1\n\n    Line 2\n\nLine 3"
        ]
        );

    runTest(
        "English text\n¨fr:Texte français\n¨de:Deutscher Text\n¨es:Texto español\n¨it:Testo italiano\n¨pt:Texto português\n¨ja:日本語テキスト\n¨ko:한국어 텍스트"
        );

    runTest(
        "Fruit list:\n* Banana\n* Kiwi\n* Orange\n¨fr:Liste de fruits :\n* Banane\n* Kiwi\n* Orange\n¨de:Obstliste:\n* Banane\n* Kiwi\n* Orange\n¨es:Lista de frutas:\n* Plátano\n* Kiwi\n* Naranja\n¨it:Elenco di frutta:\n* Banana\n* Kiwi\n* Arancia\n¨pt:Lista de frutas:\n* Banana\n* Kiwi\n* Laranja\n¨ja:果物リスト：\n* バナナ\n* キウイ\n* オレンジ\n¨ko:과일 목록:\n* 바나나\n* 키위\n* 오렌지"
        );

    runTest(
        "String with escaped \"quotes\" and \\ backslashes"
        );

    runTest(
        "String with escaped `backticks` and \\ backslashes"
        );

    runTest(
        "String with escaped ´ticks´ and \\ backslashes"
        );

    runTest(
        "This is a simple quoted string"
        );

    runTest(
        "This is a backtick quoted string"
        );

    runTest(
        "This is a tick quoted string"
        );

    runTest(
        "First line second line third line"
        );

    runTest(
        "First line    second line    \nthird line"
        );

    runTest(
        "Start   indented    ¨normal line slight indent    more indent"
        );

    runTest(
        [
            "Single space ",
            "Double spaces  ",
            "Triple spaces   "
        ]
        );

    runTest(
        [
            "",
            "",
            ""
        ]
        );

    runTest(
        "Line one\n    Indented line\n        More indented\n    Back to less indent\nNormal indent"
        );

    runTest(
        "Line one     Line two       Line three      \n   Line four           Line five"
        );

    runTest(
        {
            "emoji": "😀 😂 🤣 😊 🥰",
            "international": "こんにちは 你好 مرحبا Привет",
            "symbols": "★ ☀ ♫ ⚽ ♠ ⌛"
        }
        );

    runTest(
        {
            "no-quotes": "Text with \"double quotes\", `backticks`, and ´ticks´",
            "escaped-quotes": "\"Text with \"double quotes\", `backticks`, and ´ticks´\"",
            "all-quotes": "Text with \"double quotes\", `backticks`, and ´ticks´",
            "nested-quotes": "Text with \"double \"nested\" quotes\" and ´ticks´"
        }
        );

    runTest(
        "String with \t tab, \n newline, \\ backslash, and \" quote"
        );

    runTest(
        "First line\nSecond line\tTabbed\rCarriage return"
        );

    runTest(
        " 42"
        );

    runTest(
        "    42"
        );

    runTest(
        []
        );

    runTest(
        [
            1,
            2,
            3
        ]
        );

    runTest(
        [
            "a",
            "b",
            "c"
        ]
        );

    runTest(
        [
            undefined,
            null,
            false,
            true,
            double.nan,
            double.negativeInfinity,
            double.infinity
        ]
        );

    runTest(
        [
            0,
            -1,
            42,
            255,
            3.14159,
            -1.23456e-7
        ]
        );

    runTest(
        [
            "undefined",
            "null",
            "false",
            "true",
            "NaN",
            "-Infinity",
            "Infinity"
        ]
        );

    runTest(
        [
            "0",
            "-1",
            "42",
            "0xFF",
            "3.14159",
            "-1.23456e-7"
        ]
        );

    runTest(
        [
            undefined,
            null,
            true,
            42,
            "string"
        ]
        );

    runTest(
        [
            [
                1,
                2
            ],
            [
                3,
                4
            ]
        ]
        );

    runTest(
        [
            [
                [
                    [
                        "deep array"
                    ]
                ]
            ]
        ]
        );

    runTest(
        [
            1,
            "string",
            true,
            null,
            [
                "nested",
                "array"
            ],
            {
                "nested": "object"
            },
            {
                "nested": "map"
            }
        ]
        );

    runTest(
        {}
        );

    runTest(
        {
            "a": 1,
            "b": 2,
            "c": 3
        }
        );

    runTest(
        {
            "string key": "string value",
            "number key": 42,
            "boolean key": true,
            "null key": null
        }
        );

    runTest(
        {
            "level-one":
                {
                    "level-two": "value"
                }
        }
        );

    runTest(
        {
            "deep nesting":
                {
                    "level one":
                        {
                            "level two":
                                {
                                    "level three": "deep value"
                                }
                        }
                }
        }
        );

    runTest(
        {
            "array field":
                [
                    1,
                    2,
                    3
                ],
            "string field": "string value",
            "number field": 42,
            "boolean field": true,
            "null field": null,
            "object field":
                {
                    "nested": "object"
                },
            "map field":
                {
                    "key": "value"
                }
        }
        );

    runTest(
        {
            "mixed":
                [
                    {
                        "inner object": "value"
                    },
                    {
                        "inner map key": 42
                    }
                ]
        }
        );

    runTest(
        {
            "null-like": "null",
            "array-of-empties":
                [
                    "",
                    "",
                    "",
                    ""
                ],
            "true-like": "true",
            "diaeresis-escape": "Text with escaped diaeresis ¨"
        }
        );

    runTest(
        {
            "key with spaces": "value",
            "key-with-dashes": "value",
            "key_with_underscores": "value",
            "key.with.dots": "value",
            "123": "numeric key",
            "true": "boolean key",
            "null": "null key"
        }
        );

    runTest(
        {
            "english": "This is English text\n with multiple lines",
            "french": "Ceci est du texte français\n avec plusieurs lignes",
            "spanish": "Este es texto en español\n con múltiples líneas"
        }
        );

    runTest(
        {
            "meta":
                {
                    "type": "test",
                    "complexity": "high"
                },
            "data":
                [
                    {
                        "id": 1,
                        "labels":
                            [
                                "primary",
                                "secondary"
                            ],
                        "content": "Multi-line\ncontent with\nindentation preserved"
                    },
                    {
                        "id": 2,
                        "labels":
                            [
                                "tertiary"
                            ],
                        "content": "Line with continuation and preserved spaces    \nfinal line"
                    }
                ]
        }
        );

    runTest(
        <dynamic, dynamic>{}
        );

    runTest(
        <dynamic, dynamic>{
            "a": 1,
            "b": 2,
            "c": 3
        }
        );

    runTest(
        <dynamic, dynamic>{
            "string key": "string value",
            42: "number value",
            true: "boolean value",
            null: "null value"
        }
        );

    runTest(
        <dynamic, dynamic>{
            [
                1,
                2
            ]: "array key"
        }
        );

    runTest(
        <dynamic, dynamic>{
            {
                "nested": "key"
            }: "object key"
        }
        );

    runTest(
        <dynamic, dynamic>{
            {
                "inner": "map"
            }: "map key"
        }
        );

    runTest(
        <dynamic, dynamic>{
            "outer":
                {
                    "inner": "value"
                }
        }
        );

    runTest(
        <dynamic, dynamic>{
            {
                {
                    {
                        "map key": "map value"
                    }: "map value"
                }: "map value"
            }: "map value"
        }
        );

    runTest(
        <dynamic, dynamic>{
            "string key": "string value",
            42: 42,
            true: false,
            null: undefined,
            [
                1,
                2,
                3
            ]:
                [
                    4,
                    5,
                    6
                ],
            {
                "object": "key"
            }:
                {
                    "object": "value"
                },
            {
                "map": "key"
            }:
                {
                    "map": "value"
                }
        }
        );

    runTest(
        <dynamic, dynamic>{
            [
                {
                    "complex": "array object"
                },
                {
                    "inner": "array map"
                }
            ]:
                {
                    {
                        "complex": "value object"
                    }:
                        [
                            "nested value array"
                        ]
                }
        }
        );

    runTest(
        <dynamic, dynamic>{
            {
                "complex": "key1"
            }: "value1",
            [
                "complex",
                "key2"
            ]: "value2",
            {
                "sub": "map"
            }: "value3"
        }
        );

    runTest(
        [
            [
                [
                    [
                        {
                            "deep":
                                [
                                    {
                                        "key": "value"
                                    }
                                ]
                        }
                    ]
                ]
            ]
        ]
        );

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
        {
            "name": "DEF",
            "version": "1.0",
            "description": "Data exchange format.",
            "author":
                {
                    "name": "Ecstatic Coder",
                    "email": "ecstatic.coder@gmail.com"
                },
            "features":
                [
                    "Simple, parseable syntax based on indentation.",
                    "Compact representation for complex data structures.",
                    "Supports all JSON data types and more.",
                    "Flexible multiline string handling."
                ],
            "examples":
                {
                    "constants":
                        [
                            undefined,
                            null,
                            false,
                            true,
                            double.nan,
                            double.negativeInfinity,
                            double.infinity
                        ],
                    "numbers":
                        [
                            0,
                            -1,
                            42,
                            255,
                            3.14159,
                            -1.23456e-7
                        ],
                    "strings":
                        {
                            "unquoted string": "Single-line strings don't need quotes.",
                            "unquoted string starting and ending with spaces": "    Unquoted strings can start and end with spaces.    ",
                            "unquoted multiline string": "A backslash escapes the next character.\\A trailing backslash makes the line continue over the next line.     Starting spaces are kept. Ending spaces are not kept unless followed by a backspace or a diaeresis.    ",
                            "unquoted empty string": "",
                            "unquoted empty string with a trailing diaeresis": "",
                            "unquoted constant-like string with a trailing diaeresis": "null",
                            "unquoted number-like string with a trailing diaeresis": "1.0",
                            "quoted multiline string": "Lines are joined using line breaks.\nA backslash escapes the next character.'\nA trailing backslash makes the line continue over the next line.\n    Starting spaces are kept.\nEnding spaces are not kept unless followed by a backspace or a diaeresis.    \n'Non-ending' quotes don't have to be escaped.",
                            "quoted empty string": "",
                            "double-quoted multiline string": "Lines are joined using line breaks.\nA backslash escapes the next character.\"\nA trailing backslash makes the line continue over the next line.\n    Starting spaces are kept.\nEnding spaces are not kept unless followed by a backspace or a diaeresis.    \n\"Non-ending\" double-quotes don't have to be escaped.",
                            "double-quoted empty string": "",
                            "backticked multiline string": "Lines are joined using line breaks.\nA backslash escapes the next character.`\nA trailing backslash makes the line continue over the next line.\n    Starting spaces are kept.\nEnding spaces are not kept unless followed by a backspace or a diaeresis.    \n`Non-ending` backticks don't have to be escaped.",
                            "backticked empty string": "",
                            "ticked multiline string": "Lines are joined using line breaks.\nA backslash escapes the next character.´\nA trailing backslash makes the line continue over the next line.\n    Starting spaces are kept.\nEnding spaces are not kept unless followed by a backspace\nor a diaeresis.    \n´Non-ending´ ticks don't have to be escaped.",
                            "ticked empty string": ""
                        },
                    "collections":
                        {
                            "array of values":
                                [
                                    null,
                                    0,
                                    "one",
                                    "2.0",
                                    "3",
                                    "4",
                                    "5",
                                    "6"
                                ],
                            "array of empty strings":
                                [
                                    "",
                                    "",
                                    "",
                                    "",
                                    "",
                                    ""
                                ],
                            "object of key/value pairs (where keys are coerced to strings)":
                                {
                                    "key": "value",
                                    "other key": "other value",
                                    "123": null,
                                    "undefined": "not found",
                                    "keys":
                                        [
                                            "array value 1",
                                            "array value 2"
                                        ],
                                    "are converted":
                                        {
                                            "object key 1": "object value 1",
                                            "object key 2": "object value 2"
                                        },
                                    "to strings":
                                        {
                                            "map key 1": "map value 1",
                                            "map key 2": "map value 2"
                                        }
                                },
                            "map of key/value pairs (where keys can be of any type)":
                                {
                                    "key": "value",
                                    "other key": "other value",
                                    123: null,
                                    undefined: "not found",
                                    [
                                        "array value 1",
                                        "array value 2"
                                    ]:
                                        {
                                            "map key 1": "map value 1",
                                            "map key 2": "map value 2"
                                        },
                                    {
                                        "object key 1": "object value 1",
                                        "object key 2": "object value 2"
                                    }:
                                        [
                                            "array value 1",
                                            "array value 2"
                                        ],
                                    {
                                        "map key 1": "map value 1",
                                        "map key 2": "map value 2"
                                    }:
                                        {
                                            "object key 1": "object value 1",
                                            "object key 2": "object value 2"
                                        }
                                },
                            "array of objects":
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
                            "tabular array of objects":
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
                            "array of maps":
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
                            "tabular array of maps":
                                [
                                    {
                                        "name": "John Doe",
                                        "role": "administrator"
                                    },
                                    {
                                        "name": "Jane Smith",
                                        "role": "publisher"
                                    }
                                ]
                        }
                }
        }
        );

    runTest(
        "ef7c876f-00f3-acdd-d00f-a671f52d0b1f"
        );

    runTest(
        "73yHbwDzrN3QD6Zx9S0LHw"
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
