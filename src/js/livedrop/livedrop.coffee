crypto     = require('./crypto')
uploader   = require('./uploader')
$          = require('../../deps/jquery')

updateStatus = (text) ->
  $('#status').text("Status: #{text}")

main = () ->
  console.log "Starting up..."
  $('#file-send').click () ->
    file = $('#file-input').get()[0].files[0]
    if !file?
      updateStatus("Error! No file selected.")
      console.error "No file selected"
      return

    reader = new FileReader()

    updateStatus("Reading file...")
    reader.onload = () ->
      updateStatus("File read successful, encrypting...")
      console.log "Read file in..."
      buffer = reader.result

      crypto.encrypt(buffer) \
        .catch (err) ->
          updateStatus("Error! Encryption failed: #{err}")
          console.error "Error during encryption:", err
        .then (obj) ->
          updateStatus("Encryption complete, uploading...")
          console.log "Encryption complete!"

          uploader.upload(obj) \
            .catch (err) ->
              updateStatus("Error! Upload failed: #{err}")
              console.error "Error during upload:", err
            .then () ->
              updateStatus("Uploaded successfully! All done!")
              console.log "Uploaded successfully!"


    reader.readAsArrayBuffer(file)

$(document).ready(main)
