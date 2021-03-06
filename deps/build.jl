using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libzstd"], :libzstd),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/bicycle1885/ZstdBuilder/releases/download/v1.0.0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, :glibc) => ("$bin_prefix/ZstdBuilder.v1.3.5.aarch64-linux-gnu.tar.gz", "97e67a71dc1b7a65229e5bec76fd088c77333943cf9724d4f3855229563de7f9"),
    Linux(:aarch64, :musl) => ("$bin_prefix/ZstdBuilder.v1.3.5.aarch64-linux-musl.tar.gz", "ad601bba5ec35ae04ebb540ef397a8ab29fe09f7a3b6310bcf0ad90b5c05c3bf"),
    Linux(:armv7l, :glibc, :eabihf) => ("$bin_prefix/ZstdBuilder.v1.3.5.arm-linux-gnueabihf.tar.gz", "9add827c7b4ad838081da79bde9813b11e5276780b590960cb457781feace7e2"),
    Linux(:armv7l, :musl, :eabihf) => ("$bin_prefix/ZstdBuilder.v1.3.5.arm-linux-musleabihf.tar.gz", "2005bfa5cace0136d54aa613bb6391c4f0f634b1b443a4744bd6f9e31968b9fc"),
    Linux(:i686, :glibc) => ("$bin_prefix/ZstdBuilder.v1.3.5.i686-linux-gnu.tar.gz", "96b6184006afa2368f3670953b222a26fb4a65ac8934eb5c12890c7394cd1203"),
    Linux(:i686, :musl) => ("$bin_prefix/ZstdBuilder.v1.3.5.i686-linux-musl.tar.gz", "39e681a87cc6483bca042ac1ce3b04de894368a19dfd16a95ce26e6d5f3c37e3"),
    Linux(:powerpc64le, :glibc) => ("$bin_prefix/ZstdBuilder.v1.3.5.powerpc64le-linux-gnu.tar.gz", "3b39026efa4cff3cb1c6ac286f7ae4d359d134f741cc9dfd5543df904ae1875d"),
    MacOS(:x86_64) => ("$bin_prefix/ZstdBuilder.v1.3.5.x86_64-apple-darwin14.tar.gz", "43c7ded749de65bc422a99b890e493cddfa46d4b2415b9da09a504624dc7b904"),
    Linux(:x86_64, :glibc) => ("$bin_prefix/ZstdBuilder.v1.3.5.x86_64-linux-gnu.tar.gz", "197bce9aae1403445ef6af443adf71461f7f5e6c451efc192be0b4280675c47e"),
    Linux(:x86_64, :musl) => ("$bin_prefix/ZstdBuilder.v1.3.5.x86_64-linux-musl.tar.gz", "771cdb081f306f5e2e54b07478d68785f59c6970b77eabd454058a94ba2f67de"),
    FreeBSD(:x86_64) => ("$bin_prefix/ZstdBuilder.v1.3.5.x86_64-unknown-freebsd11.1.tar.gz", "1316f654b6f74551968988db423568268a76a76d9b1f98d2aa12f561fa2bc0d1"),
    Windows(:x86_64) => ("$bin_prefix/ZstdBuilder.v1.3.5.x86_64-w64-mingw32.tar.gz", "0967ebac58666f24dc3e0edcb07c29b27960a0d4af67591c10f374f65231e003"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
