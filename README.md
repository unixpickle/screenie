screenie
========

Screenie can currently be used to change one's desktop wallpaper through terminal. Using the "wallpaper" subcommand, you can get, set, and inspect the current wallpaper's properties.

Usage
=====

    Usage: ./screenie [command] [options]
	Commands:

	wallpaper      Modify or read desktop wallpaper
	
wallpaper
---------

    Usage: wallpaper [--get | --set | --properties] [options] [file]
	Options for --set:
	 --scaling [none | down | stretch | updown]
	 --clipping [yes | no]
	 --bgcolor #AABBCC