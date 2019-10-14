# phpfpm-7.0.8
Dockerfile for php-fpm version 7.0.8


## Xdebug Settings:
The xdebug is configured via the following enviromental variables:

Variable | Default Value | Purpoce
--- | --- | ---
`XDEBUG_HOST` | N/A | The url where the Xdebug will connect into. (Keep in mind that the Xdebug is the **client** and not the server.)
`XDEBUG_PORT` | 9000 | The port where the xdebug will connect back.
`XDEBUG_IDE_KEY` | N/A | The IDE Key.
`XDEBUG_DBGP` | Whether thje GBGP protocol will be used or not.