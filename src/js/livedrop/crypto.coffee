config        = require('../common/config')

errorPrinter = (name, reject) ->
  return (err) ->
    console.error "Error in '#{name}':", err
    reject(err)

getSecureRandomBytes = (count) ->
  array = new Uint8Array(count)
  window.crypto.getRandomValues(array)
  return array

getSessionKey = () ->
  options = config.symmetric.options
  extractable = true
  uses = ['encrypt']

  return window.crypto.subtle.generateKey(options, extractable, uses)

encryptSessionKey = (sessionKey) ->
  {type, key, options} = config.pubkey
  extractable = false
  uses = ['encrypt']

  return new Promise (resolve, reject) ->
    window.crypto.subtle.importKey(type, key, options, extractable, uses) \
      .catch(errorPrinter('pubkey import', reject))
      .then (publicKey) ->
        window.crypto.subtle.exportKey('raw', sessionKey) \
          .catch(errorPrinter('session key export', reject))
          .then (sessionKeyBuffer) ->
            options =
              name: options.name
            window.crypto.subtle.encrypt(options, publicKey, sessionKeyBuffer) \
              .then(resolve, reject)

encryptData = (sessionKey, dataBuffer) ->
  tagLength = config.symmetric.authTagLength
  options =
    name: config.symmetric.options.name
    iv: getSecureRandomBytes(16)

  result =
    iv: options.iv

  if tagLength?
    options.additionalData = getSecureRandomBytes(tagLength / 8)
    options.tagLength = tagLength
    result.additionalData = options.additionalData
    result.tagLength = tagLength

  return new Promise (resolve, reject) ->
    window.crypto.subtle.encrypt(options, sessionKey, dataBuffer) \
      .catch(errorPrinter('encrypt data 1', reject))
      .then (ciphertext) ->
        result.ciphertext = ciphertext
        resolve(result)


Crypto =
  ###
  # Returns a Promise, whose fulfillment yields an object composed of
  # {ciphertext, sessionKey, iv, authTag, tagLength}
  #   ciphertext:  ArrayBuffer, encrypted data passed in with the buffer
  #   sessionKey:  ArrayBuffer, session key, encrypted with the pubkey
  #   iv:          ArrayBuffer, random initialization vector
  #   authTag:     ArrayBuffer, random authentication data, only inluded if
  #                             supported by the symmetric encryption algorithm
  #   tagLength:   Number,      only inluded if supported by the symmetric
  #                             encryption algorithm
  ###
  encrypt: (dataBuffer) ->
    return new Promise (resolve, reject) ->
      getSessionKey() \
        .catch(errorPrinter('generate session key', reject))
        .then (sessionKey) ->
          encryptData(sessionKey, dataBuffer) \
            .catch(errorPrinter('encrypt data 2', reject))
            .then (result) ->
              encryptSessionKey(sessionKey) \
                .catch(errorPrinter('encrypt session key', reject))
                .then (encryptedSessionKey) ->
                  result.sessionKey = encryptedSessionKey
                  resolve(result)


module.exports = Crypto
