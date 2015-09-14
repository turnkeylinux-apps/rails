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
- Uses `Ruby Enterprise`_ for improved performance and memory
  utilization.
- Ruby on Rails configuration:
   
   - Deployment via Phusion Passenger for Apache (mod\_rails)
   - Preconfigured example Rails application located at
     */var/www/rails*
   - MySQL databases setup for production, development and testing.

- RubyGems package manager installed from upstream tarball
   
   - APT and RubyGems are both package management systems and may
     potentially conflict.
   - We recommend using RubyGems for managing Rails components (called
     gems), and APT for everything else.
   - Essential build packages (build-essentials) are included to aid in
     building gems.

Upgrading RubyGems itself and Rails components (gems)::

    gem update --system
    gem update

See the `Ruby on Rails docs`_ for further details.

Credentials *(passwords set at first boot)*
-------------------------------------------

-  Webmin, SSH, and MySQL: username **root**


.. _Ruby on Rails: http://rubyonrails.org/
.. _TurnKey Core: https://www.turnkeylinux.org/core
.. _Ruby Enterprise: http://www.rubyenterpriseedition.com/
.. _Ruby on Rails docs: https://www.turnkeylinux.org/docs/rails
