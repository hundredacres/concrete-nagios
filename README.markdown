# nagios #

A puppet nagios module, focusing primarily on configuration of checks and clients.

The server submodule provides a built, nagios server. It will work fully from scratch. The most important module is nagios::server::config which will ensure it compiles the client checks, as well as give you several options for how to configure the various notification plugins and check plugins. The details of these are in the manifest documentation.

The client class will set up a host on the nagios server. The basic class is nagios::client - there are then a series of nagios::nrpe::* which will install and configure individual checks for you. The names of the modules should be fairly self explanatory, but there should be some help in the manifest documentation.

Important Note:

This module will require you to have puppetdb set up as the checks and clients are collected by external resource collectors.

Version 2 is a large refactor of the server manifests in order to make it totally self sufficent.