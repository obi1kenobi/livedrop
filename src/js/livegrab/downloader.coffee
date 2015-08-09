config        = require('../common/config')
crypto        = require('./crypto')
fbreq         = require('../../deps/firebase')
# Firebase adds itself to the global scope as Firebase

ref = new Firebase(config.firebase.url).child(config.firebase.paths.messages)

###
Converts a base64 encoded string to a byte array
###
base64ToUint8Array = (text) ->
  conv = window.atob(text)
  array = new Uint8Array(conv.length)
  for i in [0...conv.length]
    array[i] = conv.charCodeAt(i)
  return array

join = (blocks) ->
  counter = 0
  result = ''
  while blocks['' + counter]?
    result += blocks['' + counter]
    counter += 1
  return result

unpack = (data) ->
  {ciphertext, sessionKey, iv, additionalData, tagLength} = data
  result =
    ciphertext: join(base64ToUint8Array(ciphertext))
    sessionKey: base64ToUint8Array(sessionKey)
    iv: base64ToUint8Array(iv)
    timestamp: data.timestamp
  if additionalData?
    result.additionalData = base64ToUint8Array(additionalData)
    result.tagLength = tagLength
  return result

Downloader =
  ###
  # Returns the newest data item that has a timestamp
  # dated strictly before the optional timestamp parameter.
  # If the parameter is not provided, returns the newest item found.
  ###
  getNewest: (beforeTimestamp) ->
    return new Promise (resolve, reject) ->
      query = ref.orderByChild('date')
      if beforeTimestamp?
        query = query.endAt(beforeTimestamp - 1)

      query.limitToLast(1).once 'child_added', (snapshot) ->
        crypto.decrypt(unpack(snapshot)) \
          .catch(reject)
          .then(resolve)
      , reject

  ###
  # Returns the oldest data item that has a timestamp
  # dated strictly after the optional timestamp parameter.
  # If the parameter is not provided, returns the oldest item found.
  ###
  getOldest: (afterTimestamp) ->
    return new Promise (resolve, reject) ->
      query = ref.orderByChild('date')
      if afterTimestamp?
        query = query.startAt(afterTimestamp + 1)

      query.limitToFirst(1).once 'child_added', (snapshot) ->
        crypto.decrypt(unpack(snapshot)) \
          .catch(reject)
          .then(resolve)
      , reject


module.exports = Downloader
