Usage
-----

**RUN IN EMPTY DIRECTORY**

    greeklish.sh <text for translation> Gl2Gr|Gr2Gl

Bugs / Security
---------------
Not secure at all, will create files specified by form field ID's in the gadget form.

Example
-------

    janus@Zeus:~/greeklish$ ./greeklish.sh kalinixta Gl2Gr
    καληνύχτα
    ["καληνύχτα","kalinixta"]
    [ [ 0, 1 ], [ 1, 0 ] ]
    janus@Zeus:~/greeklish$ ./greeklish.sh καληνύχτα Gr2Gl
    kalhnyxta
    No JSON object could be decoded
    undefined

    janus@Zeus:~/greeklish$
