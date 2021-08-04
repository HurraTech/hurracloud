extern crate ring;

use ring::hmac;
use ring::aead::*;
use ring::rand::SystemRandom;
use ring::rand::SecureRandom;
use std::num::NonZeroU32;
use std::str;
use once_cell::sync::OnceCell;

static OPENING_KEY: OnceCell<LessSafeKey> = OnceCell::new();
static SEALING_KEY: OnceCell<LessSafeKey> = OnceCell::new();

pub fn encrypt(msg: &str, nonce: [u8; 12]) -> Vec<u8> {
    let nonce = Nonce::assume_unique_for_key(nonce);
    let mut m = msg.clone().as_bytes().to_vec();
    let ref encrypt_key = match SEALING_KEY.get() {
        Some(k) => k,
        None => panic!()
    };
    encrypt_key.seal_in_place_append_tag(nonce, Aad::empty(),&mut m).unwrap();
    m
}

pub fn decrypt(msg: Vec<u8>, nonce: [u8; 12]) -> String {
    // Check nonce has not been used previously
    let nonce = Nonce::assume_unique_for_key(nonce);
    let ref decrypt_key = match OPENING_KEY.get() {
        Some(k) => k,
        None => panic!()
    };
    let mut m = msg.clone();
    let data = decrypt_key.open_in_place(nonce, Aad::empty(), &mut m).unwrap();
    let s = match str::from_utf8(data) {
        Ok(v) => v,
        Err(e) => panic!("Invalid UTF-8 sequence: {}", e),
    };
    String::from(s)
}

pub fn init_keys() {
    // The password will be used to generate a key
    let password = b"nice password";

    // Usually the salt has some random data and something that relates to the user
    // like an username
    let salt = [0, 1, 2, 3, 4, 5, 6, 7];

    // Keys are sent as &[T] and must have 32 bytes
    let mut key = [0; 32];
    ring::pbkdf2::derive(ring::pbkdf2::PBKDF2_HMAC_SHA256, NonZeroU32::new(100_000).unwrap(), &salt, &password[..], &mut key);

    // Opening key used to decrypt data
    let u_okey = UnboundKey::new(&CHACHA20_POLY1305, &key).unwrap();
    let opening_key = LessSafeKey::new(u_okey);
    OPENING_KEY.set(opening_key).unwrap();

    // Sealing key used to encrypt data
    let u_skey = UnboundKey::new(&CHACHA20_POLY1305, &key).unwrap();
    let sealing_key = LessSafeKey::new(u_skey);
    SEALING_KEY.set(sealing_key).unwrap();

    // Test encrpytion util functions
    let e = encrypt("Aiman", [0;12]);
    println!("Encrypted data is {:?}", e);

    let d = decrypt(e, [0;12]);
    println!("DECRYPTED VALUE IS {:?}", d);
}

