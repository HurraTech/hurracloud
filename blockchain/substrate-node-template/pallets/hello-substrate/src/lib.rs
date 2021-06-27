#![cfg_attr(not(feature = "std"), no_std)]

use frame_support::{
	decl_module,
	decl_event,
	decl_error,
	dispatch::DispatchResult,
};
use sp_io::offchain_index;

use frame_system::{
	ensure_none, ensure_signed,
	offchain::{
		AppCrypto, CreateSignedTransaction, SendSignedTransaction, SendUnsignedTransaction,
		SignedPayload, Signer, SigningTypes, SubmitTransaction,
	},
};

use sp_runtime::{
	print,
	offchain as rt_offchain,
	offchain::{
		storage::StorageValueRef,
		storage_lock::{BlockAndTime, StorageLock},
	},
	transaction_validity::{
		InvalidTransaction, TransactionSource, TransactionValidity, ValidTransaction,
	},
	RuntimeDebug,
};

use core::{convert::TryInto, fmt};

use sp_core::{crypto::KeyTypeId};
use codec::{Decode, Encode};
use serde::{Deserialize, Deserializer};
use sp_std::{collections::vec_deque::VecDeque, prelude::*, str};

pub use log;

pub const KEY_TYPE: KeyTypeId = KeyTypeId(*b"helo");
const ONCHAIN_TX_KEY: &[u8] = b"ocw-demo::storage::tx";
/// The type to sign and send transactions.
const UNSIGNED_TXS_PRIORITY: u64 = 100;

#[derive(Debug, Decode, Encode, Default)]
struct HelloRequest<T: frame_system::Config>(<T as frame_system::Config>::AccountId, Vec<u128>);

/// Based on the above `KeyTypeId` we need to generate a pallet-specific crypto type wrapper.
/// We can utilize the supported crypto kinds (`sr25519`, `ed25519` and `ecdsa`) and augment
/// them with the pallet-specific identifier.
pub mod crypto {
	use crate::KEY_TYPE;
	use sp_core::sr25519::Signature as Sr25519Signature;
	use sp_runtime::app_crypto::{app_crypto, sr25519};
	use sp_runtime::{traits::Verify, MultiSignature, MultiSigner};

	app_crypto!(sr25519, KEY_TYPE);

	pub struct TestAuthId;
	// implemented for ocw-runtime
	impl frame_system::offchain::AppCrypto<MultiSigner, MultiSignature> for TestAuthId {
		type RuntimeAppPublic = Public;
		type GenericSignature = sp_core::sr25519::Signature;
		type GenericPublic = sp_core::sr25519::Public;
	}

	// implemented for mock runtime in test
	impl frame_system::offchain::AppCrypto<<Sr25519Signature as Verify>::Signer, Sr25519Signature>
		for TestAuthId
	{
		type RuntimeAppPublic = Public;
		type GenericSignature = sp_core::sr25519::Signature;
		type GenericPublic = sp_core::sr25519::Public;
	}
}

pub trait Config: frame_system::Config + CreateSignedTransaction<Call<Self>> {
    type Event: From<Event> + Into<<Self as frame_system::Config>::Event>;
	type AuthorityId: AppCrypto<Self::Public, Self::Signature>;
}

// decl_storage! {
// 	trait Store for Mod	ule<T: Config> as HelloSubstrate {
// 		Nicks: map hasher(blake2_128_concat) T::AccountId => u32;
// 	}
// }

decl_event! {
	pub enum Event {
		EmitInput(u32),
	}
}

decl_error! {
	pub enum Error for Module<T: Config> {
		// Error returned when not sure which ocw function to executed
		UnknownOffchainMux,

		// Error returned when making signed transactions in off-chain worker
		NoLocalAcctForSigning,
		OffchainSignedTxError,

		// Error returned when making unsigned transactions in off-chain worker
		OffchainUnsignedTxError,

		// Error returned when making unsigned transactions with signed payloads in off-chain worker
		OffchainUnsignedTxSignedPayloadError,

		// Error returned when fetching github info
		HttpFetchingError,
	}
}

decl_module! {
	pub struct Module<T: Config> for enum Call where origin: T::Origin {
		fn deposit_event() = default;

		#[weight = 1000]
		pub fn say_hello(origin, message: Vec<u128>) -> DispatchResult {
			// Ensure that the caller is a regular keypair account
			let caller = ensure_signed(origin)?;

			// Print a message
			let key = Self::derived_key(frame_system::Pallet::<T>::block_number());

			let data = HelloRequest::<T>(caller, message);
			offchain_index::set(&key, &data.encode());

			Self::deposit_event(Event::EmitInput(200));
			// Indicate that this call succeeded
			Ok(())
		}

		#[weight = 1000]
		pub fn say_hi(origin) -> DispatchResult {
			// Ensure that the caller is a regular keypair account
			let caller = ensure_signed(origin)?;

			Self::deposit_event(Event::EmitInput(300));
			Ok(())
		}


		fn offchain_worker(block_number: T::BlockNumber) {
			log::debug!("Entering off-chain worker; block number {:?}", block_number);
			let key = Self::derived_key(block_number);
			let oci_mem = StorageValueRef::persistent(&key);
			if let Some(Some(data)) = oci_mem.get::<HelloRequest::<T>>() {
				log::debug!("off-chain indexing data: {:?}, {:?}",
					data.0, data.1);
				let result = Self::send_hi_repsonse(block_number);
				if let Err(e) = result {
					log::error!("offchain_worker error: {:?}", e);
				}
			} else {
				log::info!("no off-chain indexing data retrieved.");
			}

		}		
	}
}

impl<T: Config> Module<T> {
	fn derived_key(block_number: T::BlockNumber) -> Vec<u8> {
		block_number.using_encoded(|encoded_bn| {
			ONCHAIN_TX_KEY.clone().into_iter()
				.chain(b"/".into_iter())
				.chain(encoded_bn)
				.copied()
				.collect::<Vec<u8>>()
		})
	}

	fn send_hi_repsonse(block_number: T::BlockNumber) -> Result<(), Error<T>> {
		// We retrieve a signer and check if it is valid.
		//   Since this pallet only has one key in the keystore. We use `any_account()1 to
		//   retrieve it. If there are multiple keys and we want to pinpoint it, `with_filter()` can be chained,
		//   ref: https://substrate.dev/rustdocs/v3.0.0/frame_system/offchain/struct.Signer.html
		let signer = Signer::<T, T::AuthorityId>::any_account();

		// Translating the current block number to number and submit it on-chain
		let number: u64 = block_number.try_into().unwrap_or(0);

		// `result` is in the type of `Option<(Account<T>, Result<(), ()>)>`. It is:
		//   - `None`: no account is available for sending transaction
		//   - `Some((account, Ok(())))`: transaction is successfully sent
		//   - `Some((account, Err(())))`: error occured when sending the transaction
		let result = signer.send_signed_transaction(|_acct|
			// This is the on-chain function
			Call::say_hi());

		// Display error if the signed tx fails.
		if let Some((acc, res)) = result {
			if res.is_err() {
				log::error!("failure: offchain_signed_tx: tx sent: {:?}", acc.id);
				return Err(<Error<T>>::OffchainSignedTxError);
			}
			log::debug!("Successfully sent signed transatcion");
			// Transaction is sent successfully
			return Ok(());
		} else {
			// The case result == `None`: no account is available for sending
			log::error!("No local account available");
			return Err(<Error<T>>::NoLocalAcctForSigning);
		}
	}	
}
