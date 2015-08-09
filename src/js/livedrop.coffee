crypto     = require('./crypto')
uploader   = require('./uploader')


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

          uploader.upload(obj) \
            .catch(console.error)
            .then () ->
              console.log "Uploaded successfully!"


    reader.readAsArrayBuffer(file)

$(document).ready(main)
