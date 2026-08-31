Ruby on Rails - Web Application Framework
=========================================

`Ruby on Rails`_ is an open-source web framework that's optimized for
programmer happiness and sustainable productivity. Written in Ruby,
Rails lets you write beautiful code by favoring convention over
configuration. The result is a web framework that allows you to
transition from idea to implementation in a very short period of time.

This appliance includes all the standard features in `TurnKey Core`_,
and on top of that:

- SSL support out of the box.
- Webmin modules for configuring Apache2, and MySQL.
- Ruby on Rails configuration:

   - Ruby 3.3 and Rails 7.2 from Debian 13 packages.
   - Deployment through Phusion Passenger for Apache.
   - Preconfigured example Rails application located at
     */var/www/railsapp*
   - MariaDB databases and an application user configured for production,
     development and testing.
   - Node.js 20 and essential build packages for application development.

- Rails, Ruby, Passenger and the sample application's gems are maintained by
  Debian APT packages. The sample application's Bundler lock is generated from
  those locally installed packages.

Updating the packaged Rails stack::

    apt update
    apt full-upgrade

Application-specific gems added by a developer continue to use Bundler from
the application directory.

See the `Ruby on Rails docs`_ for further details.

Credentials *(passwords set at first boot)*
-------------------------------------------

- Webmin and SSH: username **root**

The generated MariaDB application credential is stored in
*/var/www/railsapp/config/database.yml* and is regenerated during first boot.


.. _Ruby on Rails: https://rubyonrails.org/
.. _TurnKey Core: https://www.turnkeylinux.org/core
.. _Ruby on Rails docs: https://www.turnkeylinux.org/docs/rails
