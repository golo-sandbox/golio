#Golio Content delivery network

##What is it ?

Golio is a golo script(s) downloader. It queries a "Content delivery network" : **Golio.cdn**.
**Golio.cdn** is a directory of github repositories with golo scripts. 
The url of the directory is [https://github.com/k33g/golio.cdn/blob/master/golio.cdn.json](https://github.com/k33g/golio.cdn/blob/master/golio.cdn.json)

Don't hesitate to add your scripts (a simple pull request) :)


##Installation

- Create a directory, ie `golotools`
- Copy to `golotools` : `golio.0.0-BETA.jar` and `golio` (add execution rights to `golio` : `chmod a+x`)
- Then, in `~/.bash_profile`  add the path : `PATH=$PATH:/golotools`

##How To

- Go to a directory
- Type `golio list` : you obtain the list of repositories 
- Type `golio <id_repo>`: golio download the repository with id=id_repo to the current directory (ie : `golio golohttpserver`)

##A little something extra

You can execute some golo script before and after the `golio` command :

- create in the current directory a `golio.conf`
- in `golio.conf` create a `conf.golo` file

###conf.golo

```coffeescript
module conf

function initialize = |arg| {
	println("Initializing ... : " + arg)
}

function terminate = |arg| {
	println("That's all folks : " + arg)
}
```

**Remark:** value of `arg` is the value of the argument passed to `golio` command.

##Build Golio

You need maven : `mvn compile assembly:single`

##License

<a href="http://www.wtfpl.net/"><img
       src="http://www.wtfpl.net/wp-content/uploads/2012/12/wtfpl-badge-4.png"
       width="80" height="15" alt="WTFPL" /></a>

##TODO:

- put content of cdn in cache
- add some colors
- review directory creation (bug ?)
- see if replacing bozzo by jackson worth


