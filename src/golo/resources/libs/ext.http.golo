module Http


struct http = { server, port }
struct options = { protocol, host, port, path, encoding, userAgent, contentType }
struct callbacks = { success, error }

struct response = { code, message, text }

# helpers
function currentWorkingDirectory = -> java.io.File( "." ):getCanonicalPath()
function fileExists = |path| -> java.io.File(path):exists()
function fileName = |path| -> java.io.File(path):getName()

function filePath = |path| {
    let absolutePath = java.io.File(path):getAbsolutePath()
    let filePath = absolutePath:substring(
        0, absolutePath:lastIndexOf(java.io.File.separator())
    )
    return filePath
}




augment Http.types.http {

    function syncGet = |this, options, callbacks| {

        let url = options:protocol()+"://"+options:host()+":"+options:port()+options:path()
        #println("start downloading ... : " + url )

        try {
            let obj = java.net.URL(url) # URL obj
            let con = obj:openConnection() # HttpURLConnection con (Cast?)
            #optional default is GET
            con:setRequestMethod("GET")

            if options:contentType() is null {
                options:contentType("text/plain; charset=utf-8")
            }
            con:setRequestProperty("Content-Type", options:contentType())

            #add request header
            if options:userAgent() is null {
                options:userAgent("Mozilla/5.0")
            }
            con:setRequestProperty("User-Agent", options:userAgent())

            let responseCode = con:getResponseCode() # int responseCode
            let responseMessage = con:getResponseMessage() # String responseMessage

            let responseText = java.util.Scanner(con:getInputStream(), options:encoding()):useDelimiter("\\A"):next() # String responseText

            let success = callbacks:success()

            if success isnt null {
                success(response()
                    :code(responseCode)
                    :message(responseMessage)
                    :text(responseText)
                )
            }

        } catch(e) {
            let error = callbacks:error()
            if error isnt null { error(e) } else { raise("Huston, we've got a problem", e) }
        }

    }

    function aSyncGet = |this, options, callbacks| {
        let executor = java.util.concurrent.Executors.newCachedThreadPool()
        try {
            executor:submit((-> this:syncGet(options, callbacks)):to(java.util.concurrent.Callable.class))
        } finally {
            executor:shutdown()
        }
    }

    function sget = |this, options, callbacks| -> this:syncGet(options, callbacks)
    function aget = |this, options, callbacks| -> this:aSyncGet(options, callbacks)
}










