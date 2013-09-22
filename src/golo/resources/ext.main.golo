module golio

import Http
import bozzo

struct item = { source, target }
struct repository = { name, description, files, url }


function download =  |source, target, callbk| {
    
    # make a helper with that
    let dir = java.io.File(filePath(target))
    if dir:exists() isnt true {
        dir:mkdir()
    }

    http():aget(
        options()
            :protocol("https")
            :host("raw.github.com")
            :port(443)
            :path(source)
            :encoding("UTF-8")
      , callbacks()
            :success(|response| {
                textToFile(response:text(), target)
                callbk(source,target)
            })
            :error(|exception|-> println("error:%s":format(exception:getMessage())))
    )
}

function read_golio_cdn = |success, fail| {

    http():aget(
        options()
            :protocol("https")
            :host("raw.github.com")
            :port(443)
            :path("/k33g/golio.cdn/master/golio.cdn.json")
            :encoding("UTF-8")
      , callbacks()
            :success(|response| {
                #println("code:%s":format(response:code()))
                #println("message:%s":format(response:message()))
                let cdn = jsonParse(response:text())
                let repositories = map[]
                cdn:each(|repo|{
                    let current_repo = repository():url(repo:get("repository"))
                        :name(repo:get("name"))
                        :description(repo:get("description")):files(list[])
                    repo:get("files"):each(|file|{
                        current_repo:files():append(
                            item(file:get("source"),file:get("target"))
                        ) 
                    })
                    repositories:add(repo:get("name"):toLowerCase(), current_repo)
                })
                success(repositories)
            })
            :error(|exception|-> fail("error:%s":format(exception:getMessage())))
    )
}

function choice = |your_choice, repos| {
    
    case {
        when your_choice: equals("list") {
            println("--- Repositories ---")
            repos:each(|key, repo| {
                print("[id : "+key+"] ")
                print(repo:name())
                print(" : " + repo:description())
                println(" ("+repo:url()+")")
            })
            
        }
        otherwise {
            let repo = repos:get(your_choice)
            if repo isnt null {
                println("--- Downloading ---")
                repo:files():each(|file|{
                    download(file:source(), file:target(), |source, target|{
                        println(source + " -> " + target)
                    })
                })

            } else {
                println("WTF?") 
            }
        }
    }
}

function go = |keyword| {

    if keyword: equals("?") { println("""
=== Golio (c) @K33G_org ===

Golio is a golo script(s) downloader. It queries a "Content delivery network" : Golio.cdn.
Golio.cdn is a directory of github repositories with golo scripts. 
The url of the directory is https://github.com/k33g/golio.cdn/blob/master/golio.cdn.json

Do not hesitate to add your scripts (a simple pull request)

--- How To ---

golio list      : get the list of repositories 
golio id_repo   : download the repository with id=id_repo to the current directory

    """)
    } else {
        read_golio_cdn(|repos|{
            choice(keyword, repos)
        },|err|{
            println(err)
        })        
    }
}


#function main = |args| {

#    read_golio_cdn(|repos|{
#        choice(args:get(0),repos)
#    },|err|{
#        println(err)
#    })
#}


