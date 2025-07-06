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
