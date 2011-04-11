= meme_generator

* http://github.com/drbrain/meme
* http://docs.seattlerb.org/meme_generator

== DESCRIPTION:

Generate meme images using http://memegenerator.net!  Save yourself some time!

== FEATURES/PROBLEMS:

* Features many popular meme pictures
* No tests

== SYNOPSIS:

Generate a Y U NO meme:

  $ meme Y_U_NO 'write tests?'

Generate a Y U NO meme url only, no clipboard or pulling of the image data:

  $ meme --text Y_U_NO 'write tests?'

See a list of available generators

  $ meme --list

You can also drive it like an API.

== REQUIREMENTS:

* nokogiri
* internet connection

== INSTALL:

  gem install meme_generator

== DEVELOPERS:

After checking out the source, run:

  $ rake newb

This task will install any missing dependencies, run the tests/specs,
and generate the RDoc.

== LICENSE:

(The MIT License)

Copyright (c) 2011 Eric Hodel

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
