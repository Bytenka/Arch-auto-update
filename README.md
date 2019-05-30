# Arch-auto-update

Set of scripts to update an Arch Linux based system using the `yay` package manager. Setup a cron job and let the system update automatically. On each update, you will receive an email telling you how the update performed, and if manual intervention if required.

### Requirements
- [`yay`](https://github.com/Jguer/yay)
- some way of executing a bash script

If you want to enable the mailing system
- `python` >= 3
- `s-nail` (should be installed by default with `base`)
- `msmtp` (or any other system that make the `mail` command to work)
Make sure you have a working `msmtp` configuration

Some improvements are needed to make mails look nice when viewed on some clients like Gmail, but for now it works fine for me.
