config        = require('../common/config')

stringToBuffer = (text) ->
  buffer = new ArrayBuffer(text.length * 2)
  bufferView = new Uint16Array(buffer)
  for i in [0...text.length]
    bufferView[i] = text.charCodeAt(i)
  return buffer

bufferToString = (buffer) ->
  str = ""
  array = new Uint16Array(buffer)
  for i in [0...array.length]
    str += String.fromCharCode(array[i])
  return str

errorPrinter = (name, reject) ->
  return (err) ->
    console.error "Error in '#{name}':", err
    reject(err)

testPrivateKey: (privateKey) ->
  {type, key, options} = config.pubkey
  extractable = false
  uses = ['encrypt']

  # the message needs to be short because of asymmetric crypto limitations
  testMessage = 'test1234'

  return new Promise (resolve, reject) ->
    window.crypto.subtle.importKey(type, key, options, extractable, uses) \
      .catch(errorPrinter('pubkey import', reject))
      .then (publicKey) ->
        options =
          name: options.name
        window.crypto.subtle.encrypt(options, publicKey, stringToBuffer(testMessage)) \
          .catch(errorPrinter('test encrypt', reject))
          .then (ciphertext) ->
            window.crypto.subtle.decrypt(options, privateKey, ciphertext) \
              .catch(errorPrinter('test decrypt', reject))
              .then (buffer) ->
                decryptedMessage = bufferToString(buffer)
                if testMessage == decryptedMessage
                  resolve()
                else
                  reject('Test encrypt-decrypt message mismatch')

savedPrivateKey = null


Crypto =
  importPrivateKey: (privateKeyData) ->
    # the private and public keys both use the same
    # algorithm options and export format
    {type, options} = config.pubkey
    extractable = false
    uses = ['decrypt']

    return new Promise (resolve, reject) ->
      window.crypto.subtle.importKey(type, privateKeyData, options, extractable, uses) \
        .catch(errorPrinter('privkey import', reject))
        .then (privateKey) ->
          testPrivateKey(privateKey) \
            .catch(errorPrinter('privkey test', reject))
            .then () ->
              savedPrivateKey = privateKey
              resolve()

  decrypt: (data) ->
    return new Promise (resolve, reject) ->
      if !savedPrivateKey?
        return reject('No private key to decrypt with!')

      {ciphertext, sessionKey, iv, additionalData, tagLength} = data
      if !ciphertext? or !sessionKey? or !iv?
        return reject('Malformed message, cannot decrypt')

      asymmetricOptions =
        name: config.pubkey.options.name

      window.crypto.subtle.decrypt(options, savedPrivateKey, sessionKey) \
        .catch(errorPrinter('session key decrypt', reject))
        .then (rawKey) ->
          symmetricOptions =
            name: config.symmetric.options.name
          extractable = false
          uses = ['decrypt']

          window.crypto.subtle.importKey('raw', rawKey, symmetricOptions, \
                                         extractable, uses) \
            .catch(errorPrinter('session key import', reject))
            .then (sessionKey) ->
              # sessionKey now holds the decrypted key object,
              # rather than the encrypted key buffer
              decryptOptions =
                name: config.symmetric.options.name
                iv: iv
              if additionalData?
                decryptOptions.additionalData = additionalData
                decryptOptions.tagLength = tagLength

              window.crypto.subtle.decrypt(decryptOptions, sessionKey, ciphertext) \
                .catch(errorPrinter('ciphertext decrypt', reject))
                .then(resolve)


module.exports = Crypto
