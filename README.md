![](https://github.com/senselogic/DEF/blob/master/LOGO/def.png)

# DEF

The Data Exchange Format allows complex configuration files to be defined in a simple readable way which is also easy to parse and generate.

It uses a consistent indentation scheme where each level is indented by a fixed amount of spaces (4 by default).

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
        }
    users
        [
            {
                name
                    John Doe
                role
                    admin
                preferences
                    {
                        notifications
                            true
                        language
                            en
                    }
            }
            {
                name
                    Jane Smith
                role
                    user
                preferences
                    {
                        notifications
                            false
                        language
                            fr
                    }
            }
        ]
}
```

## Supported data Types

* **Constants**: undefined, null, false, true, NaN, Infinity, -Infinity
* **Numbers**: decimal integers and reals, hexadecimal naturals
* **Strings**: quoted or unquoted multiline texts
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
                            "3"
                            `4`
                            ´5´
                        ]
                    array of empty strings
                        [

                            ¨
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
                }
        }
}
```

## JavaScript API

```javascript
// -- IMPORTS

import { buildDefText, getDumpText, parseDefText } from 'senselogic-def';

// -- STATEMENTS

let object =
    {
        name: "John Doe",
        age: 30,
        skills: [ "JavaScript", "TypeScript", "Node.js" ]
    };

let text = buildDefText( object );
console.log( text );
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

let value = parseDefText( text );
console.log( value );
/*
{
  name: 'John Doe',
  age: 30,
  skills: [ 'JavaScript', 'TypeScript', 'Node.js' ]
}
*/

let map = new Map();

map.set(
    [
        "first",
        "key"
    ],
    {
        first: "value",
        second: "value"
    }
    );

map.set(
    [
        "second",
        "key"
    ],
    {
        first: "value",
        second: "value",
        third: "value"
    }
    );

text = buildDefText( map );
console.log( text );
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
console.log( value );
/*
Map(2) {
  [ 'first', 'key' ] => { first: 'value', second: 'value' },
  [ 'second', 'key' ] => { first: 'value', second: 'value', third: 'value' }
}
*/

console.log( getDumpText( value ) );
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
