![](https://github.com/senselogic/DEF/blob/master/LOGO/def.png)

# DEF

Data Exchange Format.

## Features

*   Simple, readable syntax based on indentation.
*   Easy to write, parse and generate.
*   Compact representation for complex data structures.
*   Supports all JSON data types and more:
    *   Constants
    *   Numbers
    *   Multiline strings
    *   Arrays
    *   Objects
    *   Maps
    *   Tabular arrays of objects and maps
*   Can execute custom commands to :
    *   Generate UUIDs : '#id'
    *   Generate base64 UUIDs : '%id'
    *   Load a DEF file : '@file.def'

```
{
    settings
        {
            theme
                dark
            fontSize
                16
            features
                [
                    search
                    filter
                    sort
                ]
            version
                2.0¨
            metrics
                {
                    cpuUsage
                        0.75
                    memoryUsage
                        0.6
                    networkTraffic
                        1234567890
                }
            logging
                true
        }
    plugins
        [
            {
                name
                    Analytics
                status
                    enabled
            }
            {
                name
                    SEO
                status
                    disabled
            }
        ]
    users
        [
            [
                name
                role
            ]
            [
                John Doe
                administrator
            ]
            [
                Jane Smith
                publisher
            ]
        ]{}
    texts
        {
            home
                "Home
                ¨fr:Accueil
                ¨de:Startseite
                ¨ja:ホーム"
            services
                `Services
                ¨fr:Services
                ¨de:Dienstleistungen
                ¨ja:サービス`
            contact
                ´Contact
                ¨fr:Contact
                ¨de:Kontakt
                ¨ja:連絡先´
        }
}
```

## Supported data types

* **Constants**: undefined, null, false, true, NaN, -Infinity, Infinity
* **Numbers**: decimal integers and reals, hexadecimal naturals
* **Strings**: quoted and unquoted multiline texts
* **Arrays**: ordered collections
* **Objects**: key-value collections using strings as keys
* **Maps**: key-value collections

```
{
    name
        DEF
    version
        1.0¨
    description
        Data exchange format.
    author
        {
            name
                Ecstatic Coder
            email
                ecstatic.coder@gmail.com
        }
    features
        [
            Simple, parseable syntax based on indentation.
            Compact representation for complex data structures.
            Supports all JSON data types and more.
            Flexible multiline string handling.
        ]
    examples
        {
            constants
                [
                    undefined
                    null
                    false
                    true
                    NaN
                    -Infinity
                    Infinity
                ]
            numbers
                [
                    0
                    -1
                    42
                    0xFF
                    3.14159
                    -1.23456e-7
                ]
            strings
                {
                    unquoted string
                        Single-line strings don't need quotes.
                    unquoted string starting and ending with spaces
                            Unquoted strings can start and end with spaces.    ¨
                    unquoted multiline string
                        A backslash escapes the next character.\\\
                        A trailing backslash makes the line continue \
                        over the next line. \
                            Starting spaces are kept. \
                        Ending spaces are not kept unless followed by a backspace \
                        or a diaeresis.    ¨
                    unquoted empty string

                    unquoted empty string with a trailing diaeresis
                        ¨
                    unquoted constant-like string with a trailing diaeresis
                        null¨
                    unquoted number-like string with a trailing diaeresis
                        1.0¨
                    quoted multiline string
                        'Lines are joined using line breaks.
                        A backslash escapes the next character.\'
                        A trailing backslash makes the line continue \
                        over the next line.
                            Starting spaces are kept.
                        Ending spaces are not kept unless followed by a backspace \
                        or a diaeresis.    ¨
                        'Non-ending' quotes don't have to be escaped.'
                    quoted empty string
                        ''
                    double-quoted multiline string
                        "Lines are joined using line breaks.
                        A backslash escapes the next character.\"
                        A trailing backslash makes the line continue \
                        over the next line.
                            Starting spaces are kept.
                        Ending spaces are not kept unless followed by a backspace \
                        or a diaeresis.    ¨
                        "Non-ending" double-quotes don't have to be escaped."
                    double-quoted empty string
                        ""
                    backticked multiline string
                        `Lines are joined using line breaks.
                        A backslash escapes the next character.\`
                        A trailing backslash makes the line continue \
                        over the next line.
                            Starting spaces are kept.
                        Ending spaces are not kept unless followed by a backspace \
                        or a diaeresis.    ¨
                        `Non-ending` backticks don't have to be escaped.`
                    backticked empty string
                        ``
                    ticked multiline string
                        ´Lines are joined using line breaks.
                        A backslash escapes the next character.\´
                        A trailing backslash makes the line continue \
                        over the next line.
                            Starting spaces are kept.
                        Ending spaces are not kept unless followed by a backspace
                        or a diaeresis.    ¨
                        ´Non-ending´ ticks don't have to be escaped.´
                    ticked empty string
                        ´´
                }
            collections
                {
                    array of values
                        [
                            null
                            0
                            one
                            2.0¨
                            '3'
                            "4"
                            `5`
                            ´6´
                        ]
                    array of empty strings
                        [

                            ¨
                            ''
                            ""
                            ``
                            ´´
                        ]
                    object of key/value pairs (where keys are coerced to strings)
                        {
                            key
                                value
                            other key
                                other value
                            123
                                null
                            undefined
                                not found
                            keys
                                [
                                    array value 1
                                    array value 2
                                ]
                            are converted
                                {
                                    object key 1
                                        object value 1
                                    object key 2
                                        object value 2
                                }
                            to strings
                                (
                                    map key 1
                                        map value 1
                                    map key 2
                                        map value 2
                                )
                        }
                    map of key/value pairs (where keys can be of any type)
                        (
                            key
                                value
                            other key
                                other value
                            123
                                null
                            undefined
                                not found
                            [
                                array value 1
                                array value 2
                            ]
                                (
                                    map key 1
                                        map value 1
                                    map key 2
                                        map value 2
                                )
                            {
                                object key 1
                                    object value 1
                                object key 2
                                    object value 2
                            }
                                [
                                    array value 1
                                    array value 2
                                ]
                            (
                                map key 1
                                    map value 1
                                map key 2
                                    map value 2
                            )
                                {
                                    object key 1
                                        object value 1
                                    object key 2
                                        object value 2
                                }
                        )
                    array of objects
                        [
                            {
                                name
                                    John Doe
                                role
                                    administrator
                            }
                            {
                                name
                                    Jane Smith
                                role
                                    publisher
                            }
                        ]
                    tabular array of objects
                        [
                            [
                                name
                                role
                            ]
                            [
                                John Doe
                                administrator
                            ]
                            [
                                Jane Smith
                                publisher
                            ]
                        ]{}
                    array of maps
                        [
                            (
                                name
                                    John Doe
                                role
                                    administrator
                            )
                            (
                                name
                                    Jane Smith
                                role
                                    publisher
                            )
                        ]
                    tabular array of maps
                        [
                            [
                                name
                                role
                            ]
                            [
                                John Doe
                                administrator
                            ]
                            [
                                Jane Smith
                                publisher
                            ]
                        ]()
                }
        }
}
```

## Dart API

```dart
// -- IMPORTS

import 'package:senselogic_def/senselogic_def.dart';

// -- FUNCTIONS

void main(
    )
{
    var object =
        {
            'name': 'John Doe',
            'age': 30,
            'skills': [ 'JavaScript', 'TypeScript', 'Node.js' ]
        };

    var text = buildDefText( object );
    print( text );
    /*
    {
        name
            John Doe
        age
            30
        skills
            [
                JavaScript
                TypeScript
                Node.js
            ]
    }
    */

    var value = parseDefText( text );
    print( getDumpText( value ) );
    /*
    {
      "name": "John Doe",
      "age": 30,
      "skills": [
        "JavaScript",
        "TypeScript",
        "Node.js"
      ]
    }
    */

    var map =
        <dynamic, dynamic>{
            [
                'first',
                'key'
            ]: {
                'first': 'value',
                'second': 'value'
            },
            [
                'second',
                'key'
            ]: {
                'first': 'value',
                'second': 'value',
                'third': 'value'
            }
        };

    text = buildDefText( map );
    print( text );
    /*
    (
        [
            first
            key
        ]
            {
                first
                    value
                second
                    value
            }
        [
            second
            key
        ]
            {
                first
                    value
                second
                    value
                third
                    value
            }
    )
    */

    value = parseDefText( text );
    print( getDumpText( value ) );
    /*
    Map(2) {
      [
        "first",
        "key"
      ] => {
        "first": "value",
        "second": "value"
      },
      [
        "second",
        "key"
      ] => {
        "first": "value",
        "second": "value",
        "third": "value"
      }
    }
    */
}
```

## Limitations

*   Tab characters are automatically replaced by a fixed number of spaces, regardless of their position in the line.

## Version

0.1

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU Lesser General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
