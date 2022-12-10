#import <UIKit/UIKit.h>
#import "MySSL.h"

//! Project version number for Plugin.
FOUNDATION_EXPORT double PluginVersionNumber;

//! Project version string for Plugin.
FOUNDATION_EXPORT const unsigned char PluginVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Plugin/PublicHeader.h>
/*
const int RSA_PUBLIC_EXPONENT = 65537;

void startup_openssl()
{
    CRYPTO_malloc_init();
    ERR_load_crypto_strings();
    OpenSSL_add_all_algorithms();
    
    // Pre-initialize the PRNG.
    RAND_poll();
}

void shutdown_openssl()
{
    OBJ_cleanup();
    EVP_cleanup();
    ENGINE_cleanup();
    CRYPTO_cleanup_all_ex_data();
    ERR_remove_thread_state(NULL);
    RAND_cleanup();
    ERR_free_strings();
}

int get_ecc_curve_identifier(const std::string& curve)
{
    return OBJ_txt2nid(curve.c_str());
}

EC_KEY* generate_ecc_key(int curve_NID, BN_CTX* bn_ctx)
{
    auto key = EC_KEY_new_by_curve_name(curve_NID);
    EC_KEY_set_asn1_flag(key, OPENSSL_EC_NAMED_CURVE);
    
    if (key != nullptr)
    {
        EC_KEY_precompute_mult(key, bn_ctx);
        
        if (!EC_KEY_generate_key(key))
        {
            EC_KEY_free(key);
            return nullptr;
        }
    }
    
    return key;
}

void free_ecc_key(EC_KEY* key)
{
    EC_KEY_free(key);
}

BIGNUM* encode_rsa_public_exponent(int exponent)
{
    BIGNUM* e = BN_new();
    
    if (e != nullptr)
    {
        BN_set_word(e, exponent);
    }
    
    return e;
}

RSA* generate_rsa_key(int modulus_size, BIGNUM* exponent)
{
    RSA* key = RSA_new();
    
    if (key != nullptr)
    {
        if (!RSA_generate_key_ex(key, modulus_size, exponent, 0))
        {
            RSA_free(key);
            return nullptr;
        }
    }
    
    return key;
}

void free_rsa_key(RSA* key)
{
    RSA_free(key);
}

enum class Algorithm { ECC, RSA, Unknown };

Algorithm get_algorithm_by_name(const std::string& algorithm)
{
    if (algorithm.compare("ECC") == 0)
    {
        return Algorithm::ECC;
    }
    else if (algorithm.compare("RSA") == 0)
    {
        return Algorithm::RSA;
    }
    else
    {
        return Algorithm::Unknown;
    }
}

void write_ecc_key(EC_KEY* key, const std::string& file_name)
{
    FILE* private_file = std::fopen(file_name.c_str(), "wb");
    if (private_file == nullptr)
    {
        std::cerr
        << "Opening ECC private key file "
        << file_name
        << " failed!"
        << std::endl;
        return;
    }
    
    if (!i2d_ECPrivateKey_fp(private_file, key))
    {
        std::cerr
        << "Writing ECC private key to file "
        << file_name
        << " failed!"
        << std::endl;
        return;
    }
}

void perform_ecc_speed_test(const std::string& curve, int rounds)
{
    std::vector<EC_KEY*> keys;
    std::vector<long> round_times;
    
    // Create a BIGNUM context.
    BN_CTX* bn_ctx = BN_CTX_new();
    BN_CTX_start(bn_ctx);
    
    // Get the curve identifier.
    int curve_id = get_ecc_curve_identifier(curve);
    
    for (int i = 0; i < rounds; i++)
    {
        auto start_time = high_resolution_clock::now();
        EC_KEY* key = generate_ecc_key(curve_id, bn_ctx);
        auto stop_time = high_resolution_clock::now();
        
        if (key == nullptr)
        {
            std::cerr << "ECC Key generation in round " << i + 1 << " failed!" << std::endl;
        }
        else
        {
            keys.push_back(key);
            
            auto diff = duration_cast<microseconds>(stop_time - start_time);
            round_times.push_back(diff.count());
        }
    }

#ifdef SAVE_GENERATED_KEYS
    // Save the keys to file
    int counter = 1;
    for (auto &key : keys)
    {
        EC_KEY_set_conv_form(key, POINT_CONVERSION_COMPRESSED);
        std::string file_name = "ecc-" + curve + "-" + std::to_string(counter) + ".key";
        write_ecc_key(key, file_name);
        
        counter++;
    }
#endif
    
    // Output the times
    for (auto &time : round_times)
    {
        std::cout << time << std::endl;
    }
    
    // Free the keys again
    for (auto &key : keys)
    {
        free_ecc_key(key);
    }
    
    // Free the BIGNUM context.
    BN_CTX_end(bn_ctx);
    BN_CTX_free(bn_ctx);
}

void write_rsa_key(RSA* key, const std::string& file_name)
{
    std::string private_key_file_name = file_name + ".priv";
    FILE* private_file = std::fopen(private_key_file_name.c_str(), "wb");
    if (private_file == nullptr)
    {
        std::cerr
            << "Opening RSA private key file "
            << private_key_file_name
            << " failed!"
            << std::endl;
        return;
    }
    
    if (!i2d_RSAPrivateKey_fp(private_file, key))
    {
        std::cerr
            << "Writing RSA private key to file "
            << private_key_file_name
            << " failed!"
            << std::endl;
        return;
    }
}

void perform_rsa_speed_test(int modulus_length, int public_exponent, int rounds)
{
    std::vector<RSA*> keys;
    std::vector<long> round_times;
    
    auto bn_exp = encode_rsa_public_exponent(public_exponent);
    
    for (int i = 0; i < rounds; i++)
    {
        auto start_time = high_resolution_clock::now();
        RSA* key = generate_rsa_key(modulus_length, bn_exp);
        auto stop_time = high_resolution_clock::now();
        
        if (key == nullptr)
        {
            std::cerr << "RSA Key generation in round " << i + 1 << " failed!" << std::endl;
        }
        else
        {
            keys.push_back(key);
            
            auto diff = duration_cast<microseconds>(stop_time - start_time);
            round_times.push_back(diff.count());
        }
    }

#ifdef SAVE_GENERATED_KEYS
    // Save the keys to file
    int counter = 1;
    for (auto &key : keys)
    {
        std::string file_name = "rsa-" + std::to_string(modulus_length) + "-" + std::to_string(counter) + ".key";
        write_rsa_key(key, file_name);

        counter++;
    }
#endif
    
    // Output the times
    for (auto &time : round_times)
    {
        std::cout << time << std::endl;
    }
    
    // Free the keys again
    for (auto &key : keys)
    {
        free_rsa_key(key);
    }
    
    BN_free(bn_exp);
}

int main(int argc, const char * argv[])
{
    if (argc != 4)
    {
        std::cerr << "Usage: keygenspeed <rounds> <algorithm> {curve|modlen}" << std::endl;
        return 1;
    }
    
    // Get the number of rounds to run.
    int rounds = atoi(argv[1]);
    if (rounds == 0)
    {
        std::cerr << "Invalid number of rounds: " << argv[1] << std::endl;
        return 1;
    }
    
    startup_openssl();
    
    // Get the algorithm.
    Algorithm algorithm = get_algorithm_by_name(argv[2]);
    switch (algorithm)
    {
        case Algorithm::ECC:
        {
            // Get the curve identifier.
            int curve_id = get_ecc_curve_identifier(argv[3]);
            if (curve_id == 0)
            {
                std::cerr << "Unknown curve: " << argv[3] << std::endl;
                return 1;
            }
            
            // Do the ECC speed test.
            perform_ecc_speed_test(argv[3], rounds);
            break;
        }
        case Algorithm::RSA:
        {
            // Get the modulus length.
            int modulus_length = atoi(argv[3]);
            if (modulus_length == 0)
            {
                std::cerr << "Invalid modlen: " << argv[3] << std::endl;
                return 1;
            }
            // Do the RSA speed test.
            perform_rsa_speed_test(modulus_length, RSA_PUBLIC_EXPONENT, rounds);
            break;
        }
        case Algorithm::Unknown:
        {
            std::cerr << "Unknown algorithm: " << argv[2] << std::endl;
            return 1;
        }
    }
    
    shutdown_openssl();
    return 0;
}
*/
