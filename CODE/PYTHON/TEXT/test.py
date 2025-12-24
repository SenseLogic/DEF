# -- IMPORTS

from pathlib import Path;

from .constant import undefined;
from .index import build_def_text, get_dump_text, have_same_value, parse_def_text;
from .map import Map;
from .reading import parse_def_file_text, read_text_file, read_def_file_text;

# -- VARIABLES

test_data_array = None;
test_data_index = 0;

# -- FUNCTIONS

def fetch_text_file(
    file_path
    ):

    return Path( file_path ).read_text( encoding="utf8" );

# ~~

def parse_text(
    def_text,
    expected_value
    ):

    global test_data_index;

    try:

        print( "================================" );
        print( "defText:" );
        print( def_text );

        print( "expectedValue:" );
        print( get_dump_text( expected_value ) );

        parsed_value = parse_def_file_text(
            def_text,
            {
                "file_path": "../../../DATA/TEXT/test.def",
            }
            );
        print( "parsedValue:" );
        print( get_dump_text( parsed_value ) );

        if not have_same_value( parsed_value, expected_value ):

            print( "Invalid parsed value" );
            raise Exception( "Invalid parsed value" );

        built_text = build_def_text( expected_value );
        print( "builtText:" );
        print( built_text );

        reparsed_value = parse_def_text( built_text );
        print( "reparsedValue:" );
        print( get_dump_text( reparsed_value ) );

        if not have_same_value( reparsed_value, expected_value ):

            print( "Invalid parsed value" );
            raise Exception( "Invalid parsed value" );

    except Exception as error:

        print( error );
        raise;

# ~~

def run_test(
    expected_value
    ):

    global test_data_index;

    def_text = test_data_array[ test_data_index ];
    parse_text( def_text, expected_value );

    test_data_index += 1;

# ~~

def run_import_test(
    expected_value
    ):

    try:

        def_text = read_def_file_text(
            "../../../DATA/TEXT/imported.def",
            {
                "read_text_file_function": read_text_file
            }
            );
        parse_text( def_text, expected_value );

    except Exception as error:

        print( error );
        raise;

# -- STATEMENTS

test_data_array = Path( "../../../DATA/TEXT/test.txt" ).read_text( encoding="utf8" ).split( "\n~~~\n" );

run_test(
    undefined
    );

run_test(
    None
    );

run_test(
    False
    );

run_test(
    True
    );

run_test(
    42
    );

run_test(
    -123
    );

run_test(
    3.14159
    );

run_test(
    -1.23456e-7
    );

run_test(
    0xFF
    );

run_test(
    float( "nan" )
    );

run_test(
    float( "-inf" )
    );

run_test(
    float( "inf" )
    );

run_test(
    {
        "actual-number": 42,
        "string-number": "42",
        "actual-float": 3.14159,
        "string-float": "3.14159",
        "actual-hex": 255,
        "string-hex": "0xFF"
    }
    );

run_test(
    ""
    );

run_test(
    ""
    );

run_test(
    "["
    );

run_test(
    "{"
    );

run_test(
    "("
    );

run_test(
    "¨"
    );

run_test(
    "["
    );

run_test(
    "{"
    );

run_test(
    "("
    );

run_test(
    "Simple string"
    );

run_test(
    'String with "quotes" inside'
    );

run_test(
    "String with `backticks` inside"
    );

run_test(
    "String with ´ticks´ inside"
    );

run_test(
    "String with backslash \\ inside"
    );

run_test(
    "One trailing space "
    );

run_test(
    "Multiple trailing spaces    "
    );

run_test(
    "Multiple    trailing    spaces    "
    );

run_test(
    "Multiple    trailing    \nspaces    ¨"
    );

run_test(
    "    Multiple        trailing    \n    spaces    ¨"
    );

run_test(
    [
        "    Multiple        trailing        spaces    ",
        "    Multiple        trailing    \n    spaces    ",
        "    Multiple        trailing    \n    spaces    ¨"
    ]
    );

run_test(
    "Single line continued on next line"
    );

run_test(
    "Line 1\nLine 2\nLine 3"
    );

run_test(
    "Line 1\n\nLine 2\n\nLine 3"
    );

run_test(
    "Line 1\n\n    Line 2\n\nLine 3"
    );

run_test(
    [
        "Line 1        Line 2    Line 3",
        "Line 1    Line 2\n\nLine 3",
        "Line 1\n\n    Line 2\n\nLine 3",
    ]
    );

run_test(
    "English text\n¨fr:Texte français\n¨de:Deutscher Text\n¨es:Texto español\n¨it:Testo italiano\n¨pt:Texto português\n¨ja:日本語テキスト\n¨ko:한국어 텍스트"
    );

run_test(
    "Fruit list:\n* Banana\n* Kiwi\n* Orange\n¨fr:Liste de fruits :\n* Banane\n* Kiwi\n* Orange\n¨de:Obstliste:\n* Banane\n* Kiwi\n* Orange\n¨es:Lista de frutas:\n* Plátano\n* Kiwi\n* Naranja\n¨it:Elenco di frutta:\n* Banana\n* Kiwi\n* Arancia\n¨pt:Lista de frutas:\n* Banana\n* Kiwi\n* Laranja\n¨ja:果物リスト：\n* バナナ\n* キウイ\n* オレンジ\n¨ko:과일 목록:\n* 바나나\n* 키위\n* 오렌지"
    );

run_test(
    'String with escaped "quotes" and \\ backslashes'
    );

run_test(
    "String with escaped `backticks` and \\ backslashes"
    );

run_test(
    "String with escaped ´ticks´ and \\ backslashes"
    );

run_test(
    "This is a simple quoted string"
    );

run_test(
    "This is a backtick quoted string"
    );

run_test(
    "This is a tick quoted string"
    );

run_test(
    "First line second line third line"
    );

run_test(
    "First line    second line    \nthird line"
    );

run_test(
    "Start   indented    ¨normal line slight indent    more indent"
    );

run_test(
    [
        "Single space ",
        "Double spaces  ",
        "Triple spaces   ",
    ]
    );

run_test(
    [
        "",
        "",
        ""
    ]
    );

run_test(
    "Line one\n    Indented line\n        More indented\n    Back to less indent\nNormal indent"
    );

run_test(
    "Line one     Line two       Line three      \n   Line four           Line five"
    );

run_test(
    {
        "emoji": "😀 😂 🤣 😊 🥰",
        "international": "こんにちは 你好 مرحبا Привет",
        "symbols": "★ ☀ ♫ ⚽ ♠ ⌛",
    }
    );

run_test(
    {
        "no-quotes": 'Text with "double quotes", `backticks`, and ´ticks´',
        "escaped-quotes": '"Text with "double quotes", `backticks`, and ´ticks´"',
        "all-quotes": 'Text with "double quotes", `backticks`, and ´ticks´',
        "nested-quotes": 'Text with "double "nested" quotes" and ´ticks´',
    }
    );

run_test(
    'String with \t tab, \n newline, \\ backslash, and " quote'
    );

run_test(
    "First line\nSecond line\tTabbed\rCarriage return"
    );

run_test(
    " 42"
    );

run_test(
    "    42"
    );

run_test(
    []
    );

run_test(
    [
        1,
        2,
        3
    ]
    );

run_test(
    [
        "a",
        "b",
        "c"
    ]
    );

run_test(
    [
        undefined,
        None,
        False,
        True,
        float( "nan" ),
        float( "-inf" ),
        float( "inf" )
    ]
    );

run_test(
    [
        0,
        -1,
        42,
        255,
        3.14159,
        -1.23456e-7
    ]
    );

run_test(
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

run_test(
    [
        "0",
        "-1",
        "42",
        "0xFF",
        "3.14159",
        "-1.23456e-7"
    ]
    );

run_test(
    [
        undefined,
        None,
        True,
        42,
        "string"
    ]
    );

run_test(
    [
        [
            1,
            2
        ],
        [
            3,
            4
        ],
    ]
    );

run_test(
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

run_test(
    [
        1,
        "string",
        True,
        None,
        [
            "nested",
            "array",
        ],
        {
            "nested": "object",
        },
        Map(
            [
                ( "nested", "map" )
            ]
        ),
    ]
    );

run_test(
    {}
    );

run_test(
    {
        "a": 1,
        "b": 2,
        "c": 3,
    }
    );

run_test(
    {
        "string key": "string value",
        "number key": 42,
        "boolean key": True,
        "null key": None,
    }
    );

run_test(
    {
        "level-one": {
            "level-two": "value"
            }
    }
    );

run_test(
    {
        "deep nesting": {
            "level one": {
                "level two": {
                    "level three": "deep value",
                }
            }
        }
    }
    );

run_test(
    {
        "array field": [
            1,
            2,
            3,
            ],
        "string field": "string value",
        "number field": 42,
        "boolean field": True,
        "null field": None,
        "object field": {
            "nested": "object",
            },
        "map field": Map(
            [
                ("key", "value"),
            ]
            )
    }
    );

run_test(
    {
        "mixed": [
            {
                "inner object": "value",
            },
            Map(
                [
                    ("inner map key", 42),
                ]
                )
            ]
    }
    );

run_test(
    {
        "null-like": "null",
        "array-of-empties": [
            "",
            "",
            "",
            "",
            ],
        "true-like": "true",
        "diaeresis-escape": "Text with escaped diaeresis ¨"
    }
    );

run_test(
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

run_test(
    {
        "english": "This is English text\n with multiple lines",
        "french": "Ceci est du texte français\n avec plusieurs lignes",
        "spanish": "Este es texto en español\n con múltiples líneas"
    }
    );

run_test(
    {
        "meta": {
            "type": "test",
            "complexity": "high",
            },
        "data": [
            {
                "id": 1,
                "labels": [
                    "primary",
                    "secondary",
                    ],
                "content": "Multi-line\ncontent with\nindentation preserved"
            },
            {
                "id": 2,
                "labels": [
                    "tertiary",
                    ],
                "content": "Line with continuation and preserved spaces    \nfinal line"
            }
            ]
    }
    );

run_test(
    Map()
    );

run_test(
    Map(
        [
            ( "a", 1 ),
            ( "b", 2 ),
            ( "c", 3 )
        ]
        )
    );

run_test(
    Map(
        [
            ( "string key", "string value" ),
            ( 42, "number value" ),
            ( True, "boolean value" ),
            ( None, "null value" ),
        ]
    )
    );

run_test(
    Map(
        [
            (
                [
                    1,
                    2,
                ],
                "array key"
            )
        ]
    )
    );

run_test(
    Map(
        [
            (
                {
                    "nested": "key",
                },
                "object key"
            )
        ]
    )
    );

run_test(
    Map(
        [
            (
                Map(
                    [
                        ("inner", "map"),
                    ]
                    ),
                "map key"
            )
        ]
    )
    );

run_test(
    Map(
        [
            (
                "outer",
                Map(
                    [
                        ("inner", "value"),
                    ]
                    )
            )
        ]
    )
    );

run_test(
    Map(
        [
            (
                Map(
                    [
                        (
                            Map(
                                [
                                    (
                                        Map(
                                            [
                                                ("map key", "map value"),
                                            ]
                                            ),
                                        "map value",
                                    )
                                ]
                                ),
                            "map value",
                        )
                    ]
                    ),
                "map value",
            )
        ]
    )
    );

run_test(
    Map(
        [
            ( "string key", "string value" ),
            ( 42, 42 ),
            ( True, False ),
            ( None, undefined ),
            (
                [
                    1,
                    2,
                    3,
                ],
                [
                    4,
                    5,
                    6,
                ]
            ),
            (
                {
                    "object": "key",
                },
                {
                    "object": "value",
                }
            ),
            (
                Map(
                    [
                        ("map", "key"),
                    ]
                    ),
                Map(
                    [
                        ("map", "value"),
                    ]
                    )
            )
        ]
    )
    );

run_test(
    Map(
        [
            (
                [
                    {
                        "complex": "array object",
                    },
                    Map(
                        [
                            ("inner", "array map"),
                        ]
                        )
                ],
                Map(
                    [
                        (
                            {
                                "complex": "value object",
                            },
                            [
                                "nested value array",
                            ]
                        )
                    ]
                    )
            )
        ]
    )
    );

run_test(
    Map(
        [
            (
                {
                    "complex": "key1",
                },
                "value1",
            ),
            (
                [
                    "complex",
                    "key2",
                ],
                "value2",
            ),
            (
                Map(
                    [
                        ("sub", "map"),
                    ]
                    ),
                "value3"
            )
        ]
    )
    );

run_test(
    [
        [
            [
                [
                    {
                        "deep": [
                            Map(
                                [
                                    ( "key", "value" ),
                                ]
                                )
                            ]
                    }
                ]
            ]
        ]
    ]
    );

run_test(
    {
        "settings": {
            "theme": "dark",
            "fontSize": 16,
            "features": [
                "search",
                "filter",
                "sort",
                ],
            "version": "2.0",
            "metrics": {
                "cpuUsage": 0.75,
                "memoryUsage": 0.6,
                "networkTraffic": 1234567890,
                },
            "logging": True,
            },
        "plugins": [
            {
                "name": "Analytics",
                "status": "enabled",
            },
            {
                "name": "SEO",
                "status": "disabled",
            }
            ],
        "users": [
            {
                "name": "John Doe",
                "role": "administrator",
            },
            {
                "name": "Jane Smith",
                "role": "publisher",
            }
            ],
        "texts": {
            "home": "Home\n¨fr:Accueil\n¨de:Startseite\n¨ja:ホーム",
            "services": "Services\n¨fr:Services\n¨de:Dienstleistungen\n¨ja:サービス",
            "contact": "Contact\n¨fr:Contact\n¨de:Kontakt\n¨ja:連絡先",
            }
    }
    );

run_test(
    {
        "name": "DEF",
        "version": "1.0",
        "description": "Data exchange format.",
        "author": {
            "name": "Ecstatic Coder",
            "email": "ecstatic.coder@gmail.com",
            },
        "features": [
            "Simple, parseable syntax based on indentation.",
            "Compact representation for complex data structures.",
            "Supports all JSON data types and more.",
            "Flexible multiline string handling.",
            ],
        "examples": {
            "constants": [
                undefined,
                None,
                False,
                True,
                float("nan"),
                float("-inf"),
                float("inf"),
            ],
            "numbers": [
                0,
                -1,
                42,
                255,
                3.14159,
                -1.23456e-7,
                ],
            "strings": {
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
                "ticked empty string": "",
                },
            "collections": {
                "array of values": [
                    None,
                    0,
                    "one",
                    "2.0",
                    "3",
                    "4",
                    "5",
                    "6",
                    ],
                "array of empty strings": [
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    ],
                "object of key/value pairs (where keys are coerced to strings)": {
                    "key": "value",
                    "other key": "other value",
                    "123": None,
                    "undefined": "not found",
                    "keys": [
                        "array value 1",
                        "array value 2",
                        ],
                    "are converted": {
                        "object key 1": "object value 1",
                        "object key 2": "object value 2",
                        },
                    "to strings": Map(
                        [
                            ("map key 1", "map value 1"),
                            ("map key 2", "map value 2"),
                        ]
                        )
                    },
                "map of key/value pairs (where keys can be of any type)": Map(
                    [
                        ( "key", "value" ),
                        ( "other key", "other value" ),
                        ( 123, None ),
                        ( undefined, "not found" ),
                        (
                            [
                                "array value 1",
                                "array value 2",
                            ],
                            Map(
                                [
                                    ("map key 1", "map value 1"),
                                    ("map key 2", "map value 2"),
                                ]
                                )
                        ),
                        (
                            {
                                "object key 1": "object value 1",
                                "object key 2": "object value 2",
                            },
                            [
                                "array value 1",
                                "array value 2",
                            ]
                        ),
                        (
                            Map(
                                [
                                    ("map key 1", "map value 1"),
                                    ("map key 2", "map value 2"),
                                ]
                                ),
                            {
                                "object key 1": "object value 1",
                                "object key 2": "object value 2",
                            }
                        ),
                    ]
                    ),
                "array of objects": [
                    {
                        "name": "John Doe",
                        "role": "administrator",
                    },
                    {
                        "name": "Jane Smith",
                        "role": "publisher",
                    }
                    ],
                "tabular array of objects": [
                    {
                        "name": "John Doe",
                        "role": "administrator",
                    },
                    {
                        "name": "Jane Smith",
                        "role": "publisher",
                    }
                    ],
                "array of maps": [
                    Map(
                        [
                            ("name", "John Doe"),
                            ("role", "administrator"),
                        ]
                    ),
                    Map(
                        [
                            ("name", "Jane Smith"),
                            ("role", "publisher"),
                        ]
                        )
                    ],
                "tabular array of maps": [
                    Map(
                        [
                            ("name", "John Doe"),
                            ("role", "administrator"),
                        ]
                        ),
                    Map(
                        [
                            ("name", "Jane Smith"),
                            ("role", "publisher"),
                        ]
                        )
                    ]
                }
            }
    }
    );

run_test(
    "ef7c876f-00f3-acdd-d00f-a671f52d0b1f"
    );

run_test(
    "73yHbwDzrN3QD6Zx9S0LHw"
    );

run_import_test(
    [
        "imported",
        [
            "imported_1",
            [
                "imported/imported_1",
                "imported/imported/imported_1",
                "imported/imported/imported_2",
            ],
            [
                "imported/imported_2",
                "imported/imported/imported_1",
                "imported/imported/imported_2",
            ]
        ],
        [
            "imported_2",
            [
                "imported/imported_1",
                "imported/imported/imported_1",
                "imported/imported/imported_2",
            ],
            [
                "imported/imported_2",
                "imported/imported/imported_1",
                "imported/imported/imported_2",
            ]
        ]
    ]
    );

print( "All tests passed!" );
