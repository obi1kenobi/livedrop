crypto         = require('./crypto')
downloader     = require('./downloader')
$              = require('../../deps/jquery')

currentTimestamp = null

updateStatus = (text) ->
  $('#status').text("Status: #{text}")

###
Converts the given byte array to a base64 encoded string.
###
arrayToBase64 = (arr) ->
  str = ""
  for i in [0...arr.length]
    str += String.fromCharCode(arr[i])
  return window.btoa(str)

handlePrivateKeyImport = () ->
  keyjson = $('#text-privkey').val()
  key = null
  try
    key = JSON.parse(keyjson)
  catch ex
    updateStatus("Error! Couldn't parse private key JSON: #{ex}")
    console.error 'Error parsing private key JSON:', ex
    return

  crypto.importPrivateKey(key) \
    .catch (err) ->
      console.error 'Error importing private key:', err
    .then () ->
      console.log 'Key imported successfully!'
      updateStatus("Key import successful, downloading newest image...")
      $('#livegrab-keyed').removeClass('hidden')
      $('#livegrab-keyenter').addClass('hidden')
      handleClickPrevious()

handleClickPrevious = () ->
  downloader.getNewest(currentTimestamp) \
    .catch (err) ->
      updateStatus("No older images found.")
      console.error 'Error getting the previous data:', err
    .then(display)

handleClickNext = () ->
  downloader.getOldest(currentTimestamp) \
    .catch (err) ->
      updateStatus("No newer images found.")
      console.error 'Error getting the next data:', err
    .then(display)

display = ({data, timestamp}) ->
  updateStatus("Showing image with timestamp: #{timestamp}")
  console.log 'Timestamp:', timestamp
  currentTimestamp = timestamp
  base64 = arrayToBase64(data)
  $('#imgbox').attr('src', "data:image/jpg;base64,#{base64}")

main = () ->
  $('#btn-privatekey').click(handlePrivateKeyImport)
  $('#btn-prev').click () ->
    updateStatus("Downloading image...")
    handleClickPrevious()
  $('#btn-next').click () ->
    updateStatus("Downloading image...")
    handleClickNext()
  $('#imgbox').click () ->
    $('#imgbox').toggleClass('imgbox-bounded')


$(document).ready(main)
