# nagios #

This is the nagios module for the office.

The server submodule provides a built, nagios server. It needs further configuration to work as our current one in production, but should serve for testing.

The nrpe submodule will configure nrpe with our current server settings (this is not dynamic) and will install checks for a variety of things.

The client class will set up a host on the nagios server. This is necessary for new servers, but old servers will probably already have this on the nagios server in question
