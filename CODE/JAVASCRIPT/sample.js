// -- IMPORTS

import { buildDefText, getDumpText, parseDefText } from './index.js';

// -- STATEMENTS

let object =
    {
        name: 'John Doe',
        age: 30,
        skills: [ 'JavaScript', 'TypeScript', 'Node.js' ]
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
console.log( getDumpText( value ) );
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

let map = new Map();

map.set(
    [
        'first',
        'key'
    ],
    {
        first: 'value',
        second: 'value'
    }
    );

map.set(
    [
        'second',
        'key'
    ],
    {
        first: 'value',
        second: 'value',
        third: 'value'
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
