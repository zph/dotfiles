LOCAL_RUBY_VERSION="2.5.3"

install_chruby(){
  wget -O chruby-0.3.8.tar.gz https://github.com/postmodern/chruby/archive/v0.3.8.tar.gz
  tar -xzvf chruby-0.3.8.tar.gz
  cd chruby-0.3.8/
  sudo make install

  wget -O ruby-install-0.5.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.5.0.tar.gz
  tar -xzvf ruby-install-0.5.0.tar.gz
  cd ruby-install-0.5.0/
  sudo make install
  ruby-install ruby # latest stable MRI

cat <<EOF > /etc/profile.d/chruby.sh
if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then
  source /usr/local/share/chruby/chruby.sh
  chruby "$LOCAL_RUBY_VERSION"
fi
EOF

  source /usr/local/share/chruby/chruby.sh
  chruby 2.1
}

lazyload_init_chruby(){
  source /usr/local/share/chruby/chruby.sh
  source /usr/local/share/chruby/auto.sh
  zph/prepend_to_path "$PATHS_TO_PREFIX_BEFORE_CHRUBY"
}
