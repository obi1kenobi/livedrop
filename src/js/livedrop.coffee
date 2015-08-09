crypto     = require('./crypto')

arrayToBase64 = (arr) ->
  str = ""
  for i in [0...arr.length]
    str += String.fromCharCode(arr[i])
  return window.btoa(str)

main = () ->
  console.log "Starting up..."
  $('#file-submit').click () ->
    file = $('#file-input').get()[0].files[0]
    if !file?
      console.error "No file selected"
      return

    reader = new FileReader()

    reader.onload = () ->
      console.log "Read file in..."
      buffer = reader.result

      crypto.encrypt(buffer) \
        .catch(console.error)
        .then (obj) ->
          console.log "Encryption complete!"

          {ciphertext, sessionKey, iv, additionalData, tagLength} = obj
          result =
            ciphertext: arrayToBase64(new Uint8Array(ciphertext))
            sessionKey: arrayToBase64(new Uint8Array(sessionKey))
            iv: arrayToBase64(new Uint8Array(iv))
          if additionalData?
            result.additionalData = arrayToBase64(new Uint8Array(additionalData))
            result.tagLength = tagLength

          console.log 'Result:', result

    reader.readAsArrayBuffer(file)

$(document).ready(main)
