extern crate ring;

use ring::hmac;
use ring::aead::*;
use ring::rand::SystemRandom;
use ring::rand::SecureRandom;
use std::num::NonZeroU32;

pub fn init_keys() {
    println!("Hey:)");

    // The password will be used to generate a key
    let password = b"nice password";

    // Usually the salt has some random data and something that relates to the user
    // like an username
    let salt = [0, 1, 2, 3, 4, 5, 6, 7];

    // Keys are sent as &[T] and must have 32 bytes
    let mut key = [0; 32];
    ring::pbkdf2::derive(ring::pbkdf2::PBKDF2_HMAC_SHA256, NonZeroU32::new(100_000).unwrap(), &salt, &password[..], &mut key);

    // Your private data
    let content = b"content to encrypt".to_vec();
    println!("Content to encrypt's size {}", content.len());

    // Ring uses the same input variable as output
    let mut in_out = content.clone();

    // The input/output variable need some space for a suffix
    // println!("Tag len {}", CHACHA20_POLY1305.tag_len());
    // for _ in 0..CHACHA20_POLY1305.tag_len() {
    //     in_out.push(0);
    // }

    // Opening key used to decrypt data
    let u_okey = UnboundKey::new(&CHACHA20_POLY1305, &key).unwrap();
    let opening_key = LessSafeKey::new(u_okey);

    // Sealing key used to encrypt data
    let u_skey = UnboundKey::new(&CHACHA20_POLY1305, &key).unwrap();
    let sealing_key = LessSafeKey::new(u_skey);

    // Random data must be used only once per encryption
    let mut noncev: [u8; 12] = [0;12];
    let mut noncev2: [u8; 12] = [0;12];

    // Fill nonce with random data
    let rand = SystemRandom::new();
    rand.fill(&mut noncev).unwrap();
    rand.fill(&mut noncev2).unwrap();

    // Nonce obj
    let nonce = Nonce::assume_unique_for_key(noncev);
    let nonce2 = Nonce::assume_unique_for_key(noncev);

    // Encrypt data into in_out variable
    let output_size = sealing_key.seal_in_place_append_tag(nonce, Aad::empty(), &mut in_out).unwrap();

    // println!("Encrypted data's size {}", output_size);

    let decrypted_data = opening_key.open_in_place(nonce2, Aad::empty(), &mut in_out).unwrap();

    println!("{:?}", String::from_utf8(decrypted_data.to_vec()).unwrap());
    assert_eq!(content, decrypted_data);
}

