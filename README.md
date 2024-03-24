# WP 34S build environment with Docker

This image allows you to easily build WP 34S realcalc firmware images. It provides all tools necessary to compile the firmware as recommended in the official documentation.


## Example usage

```
host> docker run -it --rm --name wp34s-builder -v /path/to/source:/wp-src:ro wp34s-builder
container> cp -a /wp-src wp
container> cd wp/trunk
container> make REALBUILD=1
```

You can then copy the firmware image to the host by running:

```
host> docker cp wp34s-builder:/wp/trunk/realbuild/calc.bin .
```


## TODO

- Automate build by combining copy, make and returning calc.bin
- Fix revision parsing (it might be enough to install svn and use the official SVN repository)


## Credits

Installing Wine inside a Docker image is loosely based on [GitHub:scottyhardy/docker-wine](https://github.com/scottyhardy/docker-wine). Information about the Yagarto compiler was taken from the official "Compiling WP 34S / 31S on Linux" documentation.
