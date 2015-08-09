crypto     = require('./crypto')
uploader   = require('./uploader')
$          = require('../../deps/jquery')

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
        .catch (err) ->
          console.error "Error during encryption:", err
        .then (obj) ->
          console.log "Encryption complete!"

          uploader.upload(obj) \
            .catch (err) ->
              console.error "Error during upload:", err
            .then () ->
              console.log "Uploaded successfully!"


    reader.readAsArrayBuffer(file)

$(document).ready(main)
