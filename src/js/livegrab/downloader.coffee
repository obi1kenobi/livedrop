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
    ciphertext: base64ToUint8Array(join(ciphertext))
    sessionKey: base64ToUint8Array(sessionKey)
    iv: base64ToUint8Array(iv)
    timestamp: data.timestamp
  if additionalData?
    result.additionalData = base64ToUint8Array(additionalData)
    result.tagLength = tagLength
  return result

handleQueryResult = (snapshot, resolve, reject) ->
  value = snapshot.val()

  if !value?
    return reject('No more data')

  # remove the Firebase push ID
  pushids = Object.keys(value)
  if pushids.length > 1
    return reject('Unexpectedly found more than one push ID')
  value = value[pushids[0]]

  {timestamp} = value
  crypto.decrypt(unpack(value)) \
    .catch(reject)
    .then (data) ->
      resolve({data: new Uint8Array(data), timestamp})

Downloader =
  ###
  # Returns the newest data item that has a timestamp
  # dated strictly before the optional timestamp parameter.
  # If the parameter is not provided, returns the newest item found.
  ###
  getNewest: (beforeTimestamp) ->
    console.log 'Starting query...'
    return new Promise (resolve, reject) ->
      query = ref.orderByChild('timestamp')
      if beforeTimestamp?
        query = query.endAt(beforeTimestamp - 1)

      query.limitToLast(1).once 'value', (snapshot) ->
        handleQueryResult(snapshot, resolve, reject)
      , reject

  ###
  # Returns the oldest data item that has a timestamp
  # dated strictly after the optional timestamp parameter.
  # If the parameter is not provided, returns the oldest item found.
  ###
  getOldest: (afterTimestamp) ->
    console.log 'Starting query...'
    return new Promise (resolve, reject) ->
      query = ref.orderByChild('timestamp')
      if afterTimestamp?
        query = query.startAt(afterTimestamp + 1)

      query.limitToFirst(1).once 'value', (snapshot) ->
        handleQueryResult(snapshot, resolve, reject)
      , reject


module.exports = Downloader
