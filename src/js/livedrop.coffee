arrayToBase64 = (arr) ->
  str = ""
  for i in [0...arr.length]
    str += String.fromCharCode(arr[i])
  return window.btoa(str)

encrypt = (buffer, cb) ->
  type = 'jwk'
  key =
    kty: 'RSA'
    e: 'AQAB'
    n: 'vGO3eU16ag9zRkJ4AK8ZUZrjbtp5xWK0LyFMNT8933evJoHeczexMUzSiXaLrEFSyQZortk' + \
       '81zJH3y41MBO_UFDO_X0crAquNrkjZDrf9Scc5-MdxlWU2Jl7Gc4Z18AC9aNibWVmXhgvHY' + \
       'kEoFdLCFG-2Sq-qIyW4KFkjan05IE'
    alg: 'RSA-OAEP-256'
    ext: true
  options =
    name: 'RSA-OAEP'
    hash:
      name: 'SHA-256'
  extractable = false
  actions = ['encrypt']
  window.crypto.subtle.importKey(type, key, options, extractable, actions) \
    .catch(cb) \
    .then (publicKey) ->
      console.log "Key import successful: #{publicKey}"
      options =
        name: 'RSA-OAEP'
      window.crypto.subtle.encrypt(options, publicKey, buffer) \
        .catch(cb) \
        .then (encrypted) ->
          cb(null, encrypted)

main = () ->
  console.log "Starting up..."
  $('#file-submit').click () ->
    file = $('#file-input').get()[0].files[0]
    if !file?
      console.error "No file selected"
      return

    reader = new FileReader()

    reader.onload = () ->
      console.log "Read file in: #{reader.result}"
      buffer = reader.result

      # temporarily override the buffer for test purposes
      # (RSA can only encrypt values < modulus in size)
      buffer = new Uint8Array(16)
      window.crypto.getRandomValues(buffer)

      encrypt buffer, (err, cipherbuffer) ->
        if err?
          if err.name?
            console.error err.name
          else
            console.error err
          throw err

        console.log "Encryption complete!"

        base64 = arrayToBase64(new Uint8Array(cipherbuffer))
        console.log base64

    reader.readAsArrayBuffer(file)

$(document).ready(main)
