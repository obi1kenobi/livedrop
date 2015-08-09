pubkeyJSON = '{"alg":"RSA-OAEP-256","e":"AQAB","ext":true,"key_ops":["encrypt"],' + \
             '"kty":"RSA","n":"zICcKMzLmuZjjGXg8A4Mdz_-flfpkDFQIz87M3zTAw63EQ0Mr' + \
             'Y3m49uayW1Dxwg_kCuNk9nItqkCixVHJfY4DQ3sBHhxPElk8v0IMZ9jx5Qt0P9FCyF' + \
             'SOIsY-pj84r7RchzmIFUVFkQgcqMe5UUA76dvlEpeQ2ecM3IaQch3iBPNvFsvcyWJp' + \
             'ESUs4iE4x-hYF914durxQ85mGqgwoRXE3HOB8a8SaqeyOzRcxd3y2BUM7sp8Qgb2bR' + \
             'axAKt_wmyvoF5n4Fm0ykVs4xw1xjCSlFytwOPRu980nlwrVM9RR4p41Tp3bFmoAjgh' + \
             'BSeP26yRmL_gBDFXu03GIIECbZpWR1keJSS1gRRxn_dz8GvSYPcbhBMQ5Ay6HUGtYD' + \
             'uE6kE2UhlLDgvVRUOKaohbYuQ1y-6OisxjOv40TZwoLXBJzrL9Vt6kIp1i9pt3FTb5' + \
             'QahJnH5Swd_c66KzBLWq4SCwAKLFd-v9OtqJBJLZGtKyvonWwb0Fji1cwMt092wSq7' + \
             'vskMUy2K_xxlkDHmCSG-FXI4bvFHDQReJ7wsnH4XzBMVs8aF6jmxwCz70UgqYDUfhZ' + \
             'DdUDHO97uGQp-HBVjMrvYaM-oCPs7eAF-4YpvonoHkwFCHsDIqr1dKpZo5PFHC5wIT' + \
             'xJAGRORiw5Dhgss9C2vtWe6lKIvfMngCSIlIF-a0"}'

Config =
  pubkey:
    type: 'jwk'
    key: JSON.parse(pubkeyJSON)
    options:
      name: 'RSA-OAEP'
      hash:
        name: 'SHA-256'
  symmetric:
    options:
      name: 'AES-GCM'
      length: 256
    authTagLength: 128


module.exports = Config
