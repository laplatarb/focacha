# focacha

Focacha is an open source group chat. Basically, Focacha is an open source
Campfire clone.

## Features

* User identities through [omniauth](https://github.com/intridea/omniauth).
  Currently supporting
  * [omniauth-facebook](https://github.com/mkdynamic/omniauth-facebook)
  * [omniauth-google_oauth2](https://github.com/zquestz/omniauth-google-oauth2)
  * [omniauth-twitter](https://github.com/arunagw/omniauth-twitter)
* [HTML Pipeline](https://github.com/jch/html-pipeline)

## Quick start

1. Clone the repo
```
git clone git@github.com:paman/focacha.git
```
2. Run `bundle install` to install the dependencies
3. Configure focacha in `config/config.yml.erb` and `config/mongoid.yml`
4. Run `rackup -s thin` to start the focacha
5. Visit http://localhost:9292 to start using focacha!

## Contributing

1. Fork it.
2. Create a branch (`git checkout -b my_awesome_branch`)
3. Commit your changes (`git commit -am "Added some magic"`)
4. Push to the branch (`git push origin my_awesome_branch`)
5. Send pull request

## License

Copyright (c) 2012 Patricio Mac Adden <patriciomacadden@gmail.com>, Alvaro F. Lara <alvarola@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
