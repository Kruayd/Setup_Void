# Automatic setup for Void Linux

## Before running

The project is divided into 2 main shell scripts: `setup.sh` and `personal_setup.sh`.
I highly recommend to check them out before running them since **everything that you need to know** is in the comments!

## setup.sh

In order to make the setup as fast as possible, you should run this script while you are still in chroot but after the installation is completed. If you followed the [Void Linux Docs](https://docs.voidlinux.org/), the right time is exactly between the

```
(chroot) # xbps-reconfigure -fa
```
and

```
(chroot) # exit
# shutdown -r now
```
blocks in the [Finalization section](https://docs.voidlinux.org/installation/guides/chroot.html#finalization)

### Run script

give execution right with `chmod +x` and then simply run `setup.sh`

## personal\_setup.sh

Though it is less commented than the previous one, what this script does should still be fairly easy to understand.
Run it when you are logged in as your user and not as root!

### Run script

give execution right with `chmod +x` and then simply run `personal_setup.sh`

## Authors

- **Luca Cinnirella** - *creator* - [Kruayd (yep, it's me)](https://github.com/Kruayd)

## License

This project is licensed under the **GNU GPLv3** - see the [LICENSE.md](LICENSE.md) file for details
