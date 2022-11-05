- https://www.chezmoi.io/user-guide/manage-different-types-of-file/#populate-sshauthorized_keys-with-your-public-ssh-keys-from-github
- Setup ssh and ssh.d configurations
- Setup encryption for restricted files
- Configure setup to either be `arm` or standard and conditionally load what I install in Brewfile
- Setup a `minimal or full` install using ENV vars in chezmoi configuration and scripts
[x] - Build tiny script to shrink and dedupe PATH
[ ] - Adjust fish shell setting script to be idempotent and not re-run if fish is default shell
[ ] - Use https://www.chezmoi.io/user-guide/encryption/age/ and store the keys in 1Password, then on
setup these can be placed as 0600 in ~/.ssh with encryption for multiple identities, including one
that is never copied to disk and only stored in 1password as my safety backup.
