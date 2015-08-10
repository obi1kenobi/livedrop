crypto         = require('./crypto')
downloader     = require('./downloader')
$              = require('../../deps/jquery')

currentTimestamp = null

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
    console.error 'Error parsing private key JSON:', ex
    return

  crypto.importPrivateKey(key) \
    .catch (err) ->
      console.error 'Error importing private key:', err
    .then () ->
      console.log 'Key imported successfully!'
      handleClickPrevious()

handleClickPrevious = () ->
  downloader.getNewest(currentTimestamp) \
  .catch (err) ->
    console.error 'Error getting the previous data:', err
  .then(display)

handleClickNext = () ->
  downloader.getOldest(currentTimestamp) \
  .catch (err) ->
    console.error 'Error getting the next data:', err
  .then(display)

display = ({data, timestamp}) ->
  console.log 'Timestamp:', timestamp
  currentTimestamp = timestamp
  base64 = arrayToBase64(data)
  $('#imgbox').attr('src', "data:image/jpg;base64,#{base64}")

main = () ->
  $('#btn-privatekey').click(handlePrivateKeyImport)
  $('#btn-prev').click(handleClickPrevious)
  $('#btn-next').click(handleClickNext)


$(document).ready(main)
