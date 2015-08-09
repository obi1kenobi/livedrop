var outputKeys = function(key) {
    window.crypto.subtle.exportKey("jwk", key.publicKey)
    .then(function(keydata) {
        console.log("Public key:");
        console.log(JSON.stringify(keydata));

        window.crypto.subtle.exportKey("jwk", key.privateKey)
        .then(function(keydata) {
            console.log("Private key:");
            console.log(JSON.stringify(keydata));
        })
        .catch(function(err) {
            console.error(err);
        })
    })
    .catch(function(err) {
        console.error(err);
    })
}

window.crypto.subtle.generateKey(
    {
        name: "RSA-OAEP",
        modulusLength: 4096, //can be 1024, 2048, or 4096
        publicExponent: new Uint8Array([0x01, 0x00, 0x01]),
        hash: {name: "SHA-256"}, //can be "SHA-1", "SHA-256", "SHA-384", or "SHA-512"
    },
    true, //whether the key is extractable (i.e. can be used in exportKey)
    ["encrypt", "decrypt"] //must contain both "encrypt" and "decrypt"
)
.then(function(key) {
    outputKeys(key);
})
.catch(function(err) {
    console.error(err);
});
