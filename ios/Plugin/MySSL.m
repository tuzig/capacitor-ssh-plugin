//
//  ssl.m
//  Plugin
//
//  Created by Benny Daon on 08/12/2022.
//  Copyright © 2022 Max Lynch. All rights reserved.
//

#include <string.h>
#include <openssl/evp.h>
#include <openssl/pem.h>
// Include the necessary headers from the libssh2 library
// #include <libssh2.h>
#include "MySSL.h"

@implementation MySSL

+  (int)keyGenPublicKey:(char *)publicKey privateKey:(char *)privateKey
             passphrase:(char *)passphrase {
    
    EVP_PKEY *pkey = NULL;
    size_t publicKeyLen = 1024;
     EVP_PKEY_CTX *pctx = EVP_PKEY_CTX_new_id(EVP_PKEY_ED25519, NULL);
     EVP_PKEY_keygen_init(pctx);
     EVP_PKEY_keygen(pctx, &pkey);
     EVP_PKEY_CTX_free(pctx);
    BIO *mem = BIO_new(BIO_s_mem());
    PEM_write_bio_PrivateKey(mem, pkey, NULL, NULL, 0, NULL, NULL);
    int len = BIO_pending(mem);
    BIO_read(mem, privateKey, len);
    privateKey[len] = '\0';
    BIO_free(mem);

    // Generate the public key
    unsigned char *publicKeyData;
    size_t publicKeyDataLen;
    /*
    int ret = gen_publickey_from_ed25519_openssh_priv_data(
    privateKeyData, privateKeyDataLen, &publicKeyData, &publicKeyDataLen);
    if (ret != 0) {
    // Handle error
    }

    // Encode the public key data as a PEM string
    BIO *mem = BIO_new(BIO_s_mem());
    PEM_write_bio_PUBKEY(mem, publicKeyData, publicKeyDataLen);
    int len = BIO_pending(mem);
    char publicKeyPem = (char)malloc(len + 1);
    BIO_read(mem, publicKeyPem, len);
    publicKeyPem[len] = '\0';

    // Do something with the private and public keys

    // Clean up
    EVP_PKEY_CTX_free(ctx);
    EVP_PKEY_free(privateKey);
    free(publicKeyData);
    free(publicKeyPem);
    
    
    
    
    
    
    EVP_PKEY *pkey = NULL;
    size_t publicKeyLen = 1024;
     EVP_PKEY_CTX *pctx = EVP_PKEY_CTX_new_id(EVP_PKEY_ED25519, NULL);
     EVP_PKEY_keygen_init(pctx);
     EVP_PKEY_keygen(pctx, &pkey);
     EVP_PKEY_CTX_free(pctx);
    BIO *mem = BIO_new(BIO_s_mem());
    PEM_write_bio_PrivateKey(mem, pkey, NULL, NULL, 0, NULL, NULL);
    int len = BIO_pending(mem);
    BIO_read(mem, privateKey, len);
    privateKey[len] = '\0';
    BIO_free(mem);
    
    char *publicKeyRaw = malloc(publicKeyLen);

    EVP_PKEY_get_raw_public_key(pkey, publicKeyRaw, &publicKeyLen);
    char publicKeyString = malloc(publicKeyLen * 2 + 1);
    int result = EVP_EncodeBlock(publicKey, publicKeyRaw, publicKeyLen);
    if (result == -1) {
    // error encoding the public key
    // ...
    }
    
    /*
    // Generate the key pair
    EVP_PKEY_gen_cb(key);

    EVP_PKEY *key = EVP_PKEY_new_raw_private_key(EVP_PKEY_ED25519, NULL, NULL, 0);
    // Allocate memory for the public and private keys
    // *public_key = malloc(EVP_PKEY_size(key));
    // *private_key = malloc(EVP_PKEY_size(key));

    // Encode the public key in PEM format
    int len = i2d_PublicKey(key, publicKey);

    // Encode the private key in PEM format, encrypted with the given passphrase
    len = i2d_PKCS8PrivateKey_nid(key, privateKey, EVP_PKEY_ED25519, passphrase, strlen(passphrase), NULL, NULL);

    // Free the key pair
    EVP_PKEY_free(key);
    /*
    // Generate the key pair
    RSA *keypair = RSA_new();
    RSA_generate_key_ex(keypair, 2048, RSA_F4, NULL);


    // Get the BIO objects for the public and private keys
    BIO *public_bio = BIO_new(BIO_s_mem());
    BIO *private_bio = BIO_new(BIO_s_mem());

    // Write the public key to the BIO object
    PEM_write_bio_RSAPublicKey(public_bio, keypair);

    // Write the private key to the BIO object with the given passphrase
    PEM_write_bio_RSAPrivateKey(private_bio, keypair, EVP_des_ede3_cbc(),
    //TODO: support passphrase
    //                          passphrase, strlen(passphrase), NULL, NULL);
                                passphrase, 0, NULL, NULL);
    // Get the length of the public key
    int public_key_len = BIO_pending(public_bio);
    // char *public_key = malloc(public_key_len + 1);
    // Allocate memory for the public key
    BIO_read(public_bio, &publicKey, public_key_len);
    (publicKey)[public_key_len] = '\0';
    int private_key_len = BIO_pending(public_bio);
    // char *private_key = malloc(private_key_len + 1);
    BIO_read(private_bio, &privateKey, private_key_len);
    // Null-terminate the private key string
    (privateKey)[private_key_len] = '\0';

    // Clean up the BIO and RSA objects
    BIO_free_all(public_bio);
    BIO_free_all(private_bio);
    RSA_free(keypair);

    // Return success
    */
    return 0;
}

@end
/*
// Define a function that generates an Ed25519 SSH key
void generate_ssh_key(const char *passphrase, unsigned char **public_key, unsigned char **private_key) {
  // Create a new Ed25519 key pair
  EVP_PKEY *key = EVP_PKEY_new_raw_private_key(EVP_PKEY_ED25519, NULL, NULL, 0);

  // Generate the key pair
  EVP_PKEY_gen_cb(key);

  // Allocate memory for the public and private keys
  *public_key = malloc(EVP_PKEY_size(key));
  *private_key = malloc(EVP_PKEY_size(key));

  // Encode the public key in PEM format
  int len = i2d_PublicKey(key, public_key);

  // Encode the private key in PEM format, encrypted with the given passphrase
  len = i2d_PKCS8PrivateKey_nid(key, private_key, EVP_PKEY_ED25519, passphrase, strlen(passphrase), NULL, NULL);

  // Free the key pair
  EVP_PKEY_free(key);
}

#include "openssl/crypto.h"
#include "openssl/rsa.h"
#include "openssl/engine.h"
#include "openssl/evp.h"
#include "openssl/objects.h"
#include "openssl/rand.h"



/*
 // Define the passphrase for the private key
 const char *passphrase = "my secret passphrase";

 // Define pointers for the public and private keys
 unsigned char *public_key, *private_key;

 // Generate the SSH key pair
 generate_ssh_key(passphrase, &public_key, &private_key);

 // Use the libssh2 library to authenticate using the generated key pair
 int rc = libssh2_userauth_publickey_frommemory(session, username, strlen(username), public_key, private_key);

 // Check the return code to see if authentication was successful
 if (rc != 0) {
   // Handle the error...
 }

 // Free the public and private keys
 free(public_key);
 free(private_key);

 #include <openssl/pem.h>

 // Generate a 2048 bit long ssh-rsa key with the given passphrase
 

 
 */
