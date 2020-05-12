# Sykus 3

Sykus 3 is a complete network solution for schools. It provides filtered internet access, user management, file sharing and automatic software distribution. 

For more information and screenshots, see the website: https://dziemba.github.io/sykus3/ (german!)

## Status
This project is currently not maintained actively. I used to provide paid setup and support services, but this is no longer the case. Since I worked hard on this project for many months, I want to share it with the public. 

The frontend is localized in german only and the scripts are configured to set up a german client OS, but this can be adapted easily for other languages.

## Installation / Setup
Sykus 3 was designed for commercial support and central management, so there is a two-server architecture. The build-server manages one or more production servers, providing configuration and pre-assembled application packages. With some work this can be merged into a single-server setup. 

The development environment requires an Ubuntu Linux host. To get a complete VM setup and run some tests, just run
`./sykus ci` in the repo root. Look at the `sykus` and `sykus-dev` Thorfiles for a better unterstanding of the architecture. 

## Technology

* Ruby 2.0
  * Sinatra
  * DataMapper
  * RSpec
  * Resque
* MySQL
* Redis
* Libvirt / KVM
* Chef
* Twitter Bootstrap
* Font Awesome
* Dojo Framework

## Contribution
I would be really happy if this project lives on, so any contributions are welcome! If you decide that you want to actively work on Sykus, I can also make you a collaborator on github. Please be aware, that I am no longer supporting this project commercially and my spare time is limited.

## License 
MIT License, see LICENSE file.
