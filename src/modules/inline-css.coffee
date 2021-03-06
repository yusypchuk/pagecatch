convertURL = require '../modules/get-relative-link.coffee'
convertToBase64 = require '../modules/xhr-to-base64.coffee'


module.exports = (src, dom, source, callback) ->
  if(src.indexOf("url(") < 0)
    callback null, dom, src
  else
    #console.log "inline-css:", src, dom
    urlMas = []
    elemMas = []
    convMas = []
    i = 0
    while i < src.length
      k = src.indexOf "url(", i
      if k!= -1
        elemMas.push src.substring(i, k+4)
        j = src.indexOf ")", k+1
        urlMas.push convertURL(src.substring(k+4, j), source)
        i = j
      else
        elemMas.push src.substring(i, src.length)
        break
    counter = urlMas.length
    for i in [0...urlMas.length]
      convertToBase64 urlMas[i], dom, (error, obj, result, url) ->
        counter--
        if error?
          console.error "Error base64:", error.stack
        else
          convMas.push([url, result])

        if counter == 0
          src = ""
          i = 0
          for elem in elemMas
            src += elem
            if urlMas[i]?
              j = -1
              for conv, index in convMas
                if conv[0] == urlMas[i]
                  j = index
                  break
              if j >= 0
                src += convMas[j][1]
              i++
          callback null, dom, src
