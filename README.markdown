StorMan - Storage Manager (SAN)
=================================

Storage Manager developed by the [IT Services Group](http://isg.phys.ethz.ch) of the Physics Department at ETH Zurich.

Motivation
----------

Our storage environment has grown constantly. In order to keep the overview the "Storage Manager" was born.

At first I used StorMan as pure monitoring, but there were more and more features added to also control the SAN.

Since January 2014 I use it productively for monitoring our SAN environment. However, it may still contain bugs and is primarily meant for advanced users. Please refer to the [documentation](docs/) for more details.

Main Features
---------------

  * Perl Dancer web frontend
    * Dashboard with most important information
    * show Quota status (ext/xfs)
  * managing multible server
  * BTRFS featurs:
    * show status of balancing, scrubbing and replacing of disks
    * show snapshot statistic
    * control balance (currently only 'pause' and 'resume')
    * control scrubbing (start, cancel, resume)
  * ISCSI features:
    * show sessions, supported protocols (tcp/iser)
    * Discover targets
    * Login on targets
  * Documentation rendering markdown files


Author
------

Patrick Schmid (schmid@phys.ethz.ch)


License
---------

> StorMan - Storage Manager
>
> Copyright 2019 Patrick Schmid
>
> This program is free software: you can redistribute it and/or modify
> it under the terms of the GNU General Public License as published by
> the Free Software Foundation, either version 3 of the License, or
> (at your option) any later version.
>
> This program is distributed in the hope that it will be useful,
> but WITHOUT ANY WARRANTY; without even the implied warranty of
> MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
> GNU General Public License for more details.
