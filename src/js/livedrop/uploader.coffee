config        = require('./config')
fbreq         = require('../../deps/firebase')
# Firebase adds itself to the global scope as Firebase

ref = new Firebase(config.firebase.url).child('messages')

arrayToBase64 = (arr) ->
  str = ""
  for i in [0...arr.length]
    str += String.fromCharCode(arr[i])
  return window.btoa(str)

split = (text) ->
  MAX_LENGTH_PER_PART = 1000000
  index = 0
  counter = 0
  result = {}
  while index < text.length
    result[counter] = text.substr(index, MAX_LENGTH_PER_PART)
    index += MAX_LENGTH_PER_PART
    counter += 1
  return result


Uploader =
  upload: (data) ->
    {ciphertext, sessionKey, iv, additionalData, tagLength} = data
    result =
      ciphertext: split(arrayToBase64(new Uint8Array(ciphertext)))
      sessionKey: arrayToBase64(new Uint8Array(sessionKey))
      iv: arrayToBase64(new Uint8Array(iv))
      timestamp: Firebase.ServerValue.TIMESTAMP
    if additionalData?
      result.additionalData = arrayToBase64(new Uint8Array(additionalData))
      result.tagLength = tagLength

    return new Promise (resolve, reject) ->
      ref.push result, (err) ->
        if err?
          reject(err)
        else
          resolve()


module.exports = Uploader
