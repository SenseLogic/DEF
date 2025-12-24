# -- IMPORTS

from .index import build_def_text, get_dump_text, parse_def_text, Map;

# -- STATEMENTS

obj = {
    "name": "John Doe",
    "age": 30,
    "skills": [ "JavaScript", "TypeScript", "Node.js" ],
};

text = build_def_text( obj );
print( text );
"""
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
"""

value = parse_def_text( text );
print( get_dump_text( value ) );
"""
{
  "name": "John Doe",
  "age": 30,
  "skills": [
    "JavaScript",
    "TypeScript",
    "Node.js"
  ]
}
"""

map_value = Map();

map_value.set(
    [
        "first",
        "key",
    ],
    {
        "first": "value",
        "second": "value",
    }
    );

map_value.set(
    [
        "second",
        "key",
    ],
    {
        "first": "value",
        "second": "value",
        "third": "value",
    }
    );

text = build_def_text( map_value );
print( text );
"""
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
"""

value = parse_def_text( text );
print( get_dump_text( value ) );
"""
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
"""
