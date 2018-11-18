ZFS_BINS=(zdb zdb_static zfs zhack zinject zpios zpool zstreamdump ztest ztest_static)

for bin in $ZFS_BINS;do
  alias $bin="sudo $bin"
done
